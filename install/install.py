#!/usr/bin/env python
# This script provides a standard installation of sbp-linux-config through
# the following steps:
#   1. It copies everything from ./src to ./bin.
#   2. It makes several symlinks in standard places (such as ~) that point
#      to the appropriate files in ./bin.
#   3. If arguments are provided, each is interpreted as a directory which
#      may contain zero or more subdirectories corresponding to the
#      subdirectories of ./src. Each file in each of these directires is
#      read in and appended to the corresponding file in ./bin. If no such
#      file exists yet in ./bin, it is created with the appended contents.
#      This provides a simple mechanism for adding per-machine customizations.

import os
import os.path as p
import shutil
import sys
import subprocess

HOME = os.getenv('HOME')
assert len(HOME) > 0
SBP_LINUX_CONFIG = p.join(HOME, 'sbp-linux-config')

INSTALL = p.join(SBP_LINUX_CONFIG, 'install')
SRC = p.join(SBP_LINUX_CONFIG, 'src')
BIN = p.join(SBP_LINUX_CONFIG, 'bin')

DOTFILES_BIN = p.join(BIN, 'dotfiles')
SCRIPTS_BIN = p.join(BIN, 'scripts')
PYTHON_BIN = p.join(BIN, 'python')
I3STATUS_CONF = p.join(BIN, 'dotfiles/i3status.conf')
I3_CONFIG = p.join(BIN, 'dotfiles/i3/config')

GO_PATH = p.join(SBP_LINUX_CONFIG, 'go')

# Add this directory to the path so that we can import the other installation
# modules.
sys.path.append(INSTALL)
# So far, there are no other install modules. That may change in the future.


# Some utility methods for other install scripts to use for manipulating the
# output of this script:

def readFile(name):
  with open(name) as f:
    return f.read()


def writeFile(name, text):
  with open(name, 'w') as f:
    f.write(text)


def insertBefore(text, afterLine, newLine):
  """ Inserts newLine into text, right before afterLine. """
  lines = text.splitlines()
  lineNum = lines.index(afterLine)
  lines.insert(lineNum, newLine)
  return '\n'.join(lines)


def appendLines(a, b):
  lines = a.splitlines() + b.splitlines()
  return '\n'.join(lines)


# Helper function.
def forceLink(target, linkName):
  """ Forces a symlink, even if the linkName already exists. """
  if p.islink(linkName) or p.isfile(linkName):
    # Don't handle the case where linkName is a directory--it's too easy to
    # blow away existing config folders that way.
    print 'Deleting existing file %s ...' % linkName
    os.remove(linkName)

  print 'Linking %s as %s ...' % (target, linkName)
  os.symlink(target, linkName)


# Recursive helper for linking over individual files in the tree rooted at
# dotfiles.
def linkDotfiles(targetDir, linkDir, addDot):
  if not p.exists(linkDir):
    print 'Creating %s ...' % linkDir
    os.mkdir(linkDir)

  for childName in os.listdir(targetDir):
    targetChild = p.join(targetDir, childName)
 
    linkChildName = '.' + childName if addDot else childName
    linkChild = p.join(linkDir, linkChildName)

    if p.isfile(targetChild):
      forceLink(targetChild, linkChild)
    elif p.isdir(targetChild):
      # Recurse, and don't add any more dots.
      linkDotfiles(targetChild, linkChild, False)


def goInstall(package, binary):
  """ Fetches and builds the Go main file named by 'package'. The resulting
  executable is written to 'binary'.
  """
  print 'Fetching code for Go package %s ...' % package
  goEnv = os.environ.copy()
  goEnv['GOPATH'] = GO_PATH

  # Pass -d to avoid installing packages. We will do that manually.
  child = subprocess.Popen(['go', 'get', '-d', package], env=goEnv)
  if child.wait() != 0:
    raise Exception('"go get" failed with exit code %d' % child.returncode)
  
  print 'Compiling code for Go package %s to %s ...' % (package, binary)
  child = subprocess.Popen(['go', 'build', '-o', binary, package], env=goEnv)
  if child.wait() != 0:
    raise Exception('"go build" failed with exit code %d' % child.returncode)


def initGoWorkspace():
  """ Cleans the Go workspace used to build Go binaries during installation. """
  if p.isdir(GO_PATH):
    shutil.rmtree(GO_PATH)
  os.mkdir(GO_PATH)


def standard(appendDirs):
  """ Invokes the standard install procedure. """
  
  # Clean out any existing bin stuff.
  if p.isdir(BIN):
    shutil.rmtree(BIN)

  # Perform the copy.
  shutil.copytree(SRC, BIN)

  # Process arguments to see if they contain append-files.
  for appendDir in appendDirs:
    if not p.isdir(appendDir):
      print 'ERROR: %s is not a directory.' % appendDir
    else:
      # Look at every file in the appendDir.
      for root, dirs, files in os.walk(appendDir):
        # Make root relative to the appendDir, since we'll want to use it both in
        # the appendDir and in BIN.
        root = p.relpath(root, appendDir)
        for fil in files:
          # Compute the full path from the appendDir to the file.
          fil = p.join(root, fil)

          appendSource = p.join(appendDir, fil)
          appendDest = p.join(BIN, fil)

          if p.exists(appendDest):
            print 'Appending %s to %s ...' % (appendSource, appendDest)
            with open(appendDest) as f:
              text = f.read()
            while not text.endswith('\n\n'):
              text += '\n'
            with open(appendSource) as f:
              text += f.read()
            with open(appendDest, 'w') as f:
              f.write(text)
          else:
            print 'Copying %s to %s ...' % (appendSource, appendDest)
            # Make sure the target directory exists.
            destDir, _ = p.split(appendDest)
            if not p.exists(destDir):
              os.makedirs(destDir)
            shutil.copy(appendSource, appendDest)

  # Link over dotfiles.
  linkDotfiles(DOTFILES_BIN, HOME, True)

  # Download source and build Go binaries. The resulting binaries will be in
  # sbp-linux-config/go/bin.
  initGoWorkspace()
  goInstall('code.google.com/p/sbp-go-utils/prompt/main',
            p.join(SCRIPTS_BIN, 'sbp-prompt'))

  # Link in all the other scripts that should be on the path.
  forceLink(SCRIPTS_BIN, p.join(HOME, 'bin'))
  forceLink(PYTHON_BIN, p.join(HOME, 'python'))

  # Prevent GNOME's nautilus from leaving behind those weird "Desktop" windows.
  # This may print some errors if there is no X session; suppress those errors.
  with open('/dev/null', 'w') as sink:
    subprocess.call(['gsettings', 'set', 'org.gnome.desktop.background',
        'show-desktop-icons', 'false'], stderr=sink)

  # Set up my go development workspace. Note that this is not the
  # sbp-linux-config go workspace. This workspace is used just for development;
  # the sbp-linux-config go workspace is used just to check out modules and
  # build them as a part of this installation process.
  goDevWorkspace = p.join(HOME, 'go')
  if not p.isdir(goDevWorkspace):
    os.mkdir(goDevWorkspace)


def standardLaptop():
  """ Meant to be invoked after standard() for laptops. Adds some useful
  configuration settings for laptops.
  """
  i3status_conf = readFile(I3STATUS_CONF)
  print 'Inserting Wi-Fi entry into i3status.conf ...'
  i3status_conf = insertBefore(i3status_conf,
      'order += "ethernet em1"', 'order += "wireless wlan0"')
  writeFile(I3STATUS_CONF, i3status_conf)

  i3_config = readFile(I3_CONFIG)
  print 'Inserting nm-applet autostart entry into i3/config ...'
  print 'Inserting Alt+B shortcut into i3/config ...'
  i3_config = appendLines(i3_config,
                          # Keep a wi-fi widget in the system tray.
                          '\nexec --no-startup-id nm-applet'
                          # Alt+B sets backlight to max.
                          '\nbindsym $mod+b exec xbacklight -set 100')
  writeFile(I3_CONFIG, i3_config)


if __name__ == '__main__':
  standard(sys.argv[1:])

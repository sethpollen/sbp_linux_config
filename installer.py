# Utilities for installing sbp_linux_config on a machine.

import os
import os.path as p
import shutil
import sys
import subprocess

# Build the set of paths used by sbp_linux_config during installation.

HOME = os.getenv('HOME')
assert len(HOME) > 0
SBP = p.join(HOME, 'sbp')

# Most of the results of the installation process are placed here and then
# symlinked to as appropriate. The three main things I put in ~/sbp/bin:
#   dotfiles - targets of .symlinks in ~
#   scripts - executables to be placed on $PATH
#   python - libraries to be placed on $PYTHONPATH
BIN = p.join(SBP, 'bin')
DOTFILES_BIN = p.join(BIN, 'dotfiles')
SCRIPTS_BIN = p.join(BIN, 'scripts')
PYTHON_BIN = p.join(BIN, 'python')

# We currently build Go code using the "go" tool.
# TODO: Let Bazel do this instead. Also migrate the Go tools to C++.
GO_PATH = p.join(SBP, 'go')

SBP_LINUX_CONFIG = p.join(SBP, 'sbp_linux_config')
TEXT = p.join(SBP_LINUX_CONFIG, 'text')

# Some config files of special significance.
I3STATUS_CONF = p.join(BIN, 'dotfiles/i3status.conf')
I3_CONFIG = p.join(BIN, 'dotfiles/i3/config')
SETUP_ZSH = p.join(BIN, 'dotfiles/oh-my-zsh/custom/setup.zsh')

# Utility methods for manipulating config files.

def ReadFile(name):
  with open(name) as f:
    return f.read()

def WriteFile(name, text):
  with open(name, 'w') as f:
    f.write(text)

def InsertBefore(text, afterLine, newLine):
  """ Inserts newLine into text, right before afterLine. """
  lines = text.splitlines()
  lineNum = lines.index(afterLine)
  assert lineNum >= 0
  lines.insert(lineNum, newLine)
  return '\n'.join(lines)

def ConcatLines(a, b):
  """Concatenates the lines of text from 'a' and 'b'."""
  # Separate a and b by a blank line.
  lines = a.splitlines() + [''] + b.splitlines()
  return '\n'.join(lines)

# Utility functions for symlinking.

def ForceLink(target, linkName):
  """ Forces a symlink, even if the linkName already exists. """
  if p.islink(linkName) or p.isfile(linkName):
    # Don't handle the case where linkName is a directory--it's too easy to
    # blow away existing config folders that way.
    print 'Deleting existing file %s' % linkName
    os.remove(linkName)

  print 'Linking %s as %s' % (target, linkName)
  os.symlink(target, linkName)

# Recursive helper for linking over individual files in the tree rooted at
# dotfiles.
def LinkDotfiles(targetDir, linkDir, addDot):
  if not p.exists(linkDir):
    print 'Creating %s' % linkDir
    os.mkdir(linkDir)

  for childName in os.listdir(targetDir):
    targetChild = p.join(targetDir, childName)

    linkChildName = '.' + childName if addDot else childName
    linkChild = p.join(linkDir, linkChildName)

    if p.isfile(targetChild):
      ForceLink(targetChild, linkChild)
    elif p.isdir(targetChild):
      # Recurse, and don't add any more dots.
      LinkDotfiles(targetChild, linkChild, False)

def GoInstall(package, binary):
  """ Fetches and builds the Go main file named by 'package'. The resulting
  executable is written to 'binary'.
  """
  print 'Fetching code for Go package %s' % package
  goEnv = os.environ.copy()
  goEnv['GOPATH'] = GO_PATH

  # Pass -d to avoid installing packages. We will do that manually.
  child = subprocess.Popen(['go', 'get', '-d', package], env=goEnv)
  if child.wait() != 0:
    raise Exception('"go get" failed with exit code %d' % child.returncode)

  print 'Compiling code for Go package %s to %s' % (package, binary)
  child = subprocess.Popen(['go', 'build', '-o', binary, package], env=goEnv)
  if child.wait() != 0:
    raise Exception('"go build" failed with exit code %d' % child.returncode)

def InitGoWorkspace():
  """ Cleans the Go workspace used to build Go binaries during installation.
  """
  if p.isdir(GO_PATH):
    shutil.rmtree(GO_PATH)
  os.mkdir(GO_PATH)

def StandardInstallation(appendDirs):
  """ Invokes the standard install procedure.
  1. Copies everything from ~/sbp/sbp_linux_config/text to ~/sbp/bin.
  2. Makes several symlinks in standard places (such as ~) that point
     to the appropriate files in ~/sbp/bin.
  3. If arguments are provided, each is interpreted as a directory which
     may contain zero or more subdirectories corresponding to the
     subdirectories of ~/sbp/sbp_linux_config/text. Each file in each of these
     directories is read in and appended to the corresponding file in
     ~/sbp/bin. If no such file exists yet in ~/sbp/bin, it is created with
     the appended contents. This provides a simple mechanism for adding
     per-machine customizations.
  """

  # Clean out any existing bin stuff.
  if p.isdir(BIN):
    shutil.rmtree(BIN)

  # Perform the copy.
  shutil.copytree(TEXT, BIN)

  # Process arguments to see if they contain append-files.
  for appendDir in appendDirs:
    if not p.exists(appendDir):
      print 'Skipping non-existent appendDir: %s' % appendDir
      continue
    assert p.isdir(appendDir), appendDir

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
          print 'Appending %s to %s' % (appendSource, appendDest)
          with open(appendDest) as f:
            text = f.read()
          while not text.endswith('\n\n'):
            text += '\n'
          with open(appendSource) as f:
            text += f.read()
          with open(appendDest, 'w') as f:
            f.write(text)
        else:
          print 'Copying %s to %s' % (appendSource, appendDest)
          # Make sure the target directory exists.
          destDir, _ = p.split(appendDest)
          if not p.exists(destDir):
            os.makedirs(destDir)
          shutil.copy(appendSource, appendDest)

  # Link over dotfiles.
  LinkDotfiles(DOTFILES_BIN, HOME, True)

  # Download source and build Go binaries. The resulting binaries will be in
  # ~/sbp/go/bin.
  InitGoWorkspace()
  GoInstall('github.com/sethpollen/sbp-go-utils/prompt/main',
            p.join(SCRIPTS_BIN, 'sbp-prompt'))
  GoInstall('github.com/sethpollen/sbp-go-utils/sleep/main',
            p.join(SCRIPTS_BIN, 'vsleep'))

  # Link in all the other scripts that should be on the path.
  ForceLink(SCRIPTS_BIN, p.join(HOME, 'bin'))
  ForceLink(PYTHON_BIN, p.join(HOME, 'python'))

  # Configure cron.
  print "Installing .crontab"
  subprocess.call(['crontab', p.join(HOME, '.crontab')])

def LaptopInstallation():
  """ Meant to be invoked after StandardInstallation() for laptops. Adds some
  useful configuration settings for laptops.
  """
  i3status_conf = ReadFile(I3STATUS_CONF)
  print 'Inserting Wi-Fi entry into i3status.conf'
  i3status_conf = InsertBefore(i3status_conf,
      'order += "ethernet em1"', 'order += "wireless wlan0"')
  WriteFile(I3STATUS_CONF, i3status_conf)

  i3_config = ReadFile(I3_CONFIG)
  print 'Inserting nm-applet autostart entry into i3/config'
  print 'Inserting Alt+B shortcut into i3/config'
  i3_config = ConcatLines(
    i3_config,
    """
    # Keep a wi-fi widget in the system tray. Use exec_always to ensure that
    # the widget comes back after restarting i3.
    $exec-always-no-startup-id launch-nm-applet

    # Backlight controls.
    bindsym $mod+b $exec xbacklight -set 100
    bindsym XF86MonBrightnessUp $exec xbacklight -inc 10
    bindsym XF86MonBrightnessDown $exec xbacklight -dec 10
    """)
  WriteFile(I3_CONFIG, i3_config)

  setup_zsh = ReadFile(SETUP_ZSH)
  print 'Adding $IS_LAPTOP variable to setup.zsh'
  setup_zsh = ConcatLines(
    setup_zsh,
    """
    # Signal that this is a laptop to any scripts which may care.
    export IS_LAPTOP=1
    """)
  WriteFile(SETUP_ZSH, setup_zsh)

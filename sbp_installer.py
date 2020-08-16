# Utilities for installing sbp_linux_config on a machine.

import os
import os.path as p
import shutil
import stat
import string
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
BIN = p.join(SBP, 'bin')
DOTFILES_BIN = p.join(BIN, 'dotfiles')
SCRIPTS_BIN = p.join(BIN, 'scripts')

SBP_LINUX_CONFIG = p.join(SBP, 'sbp_linux_config')
COMMON_TEXT = p.join(SBP_LINUX_CONFIG, 'common-text')

# Some config files of special significance.
I3_CONF = p.join(BIN, 'dotfiles/i3/config')
TERMINATOR_CONF = p.join(BIN, 'dotfiles/config/terminator/config')
APPLY_MATE_SETTINGS = p.join(BIN, 'scripts/apply-sbp-mate-settings')

# Standard Go binaries to install.
INSTALL_BINARIES = {
  'sbpgo_main': './sbpgo/sbpgo_main',
  'sbp-prompt': './sbpgo/prompt_main',
}

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

def ForceLink(target, linkName):
  """ Forces a symlink, even if the linkName already exists. """
  if p.islink(linkName) or p.isfile(linkName):
    # Don't handle the case where linkName is a directory--it's too easy to
    # blow away existing config folders that way.
    os.remove(linkName)

  print('Linking %s' % linkName)
  os.symlink(target, linkName)

def InstallBinary(src, dest):
  """Ensures the binary gets chmod+x, as apparently Bazel doesn't always do that
  automatically.
  """
  print('Copying %s' % dest)
  shutil.copyfile(src, dest)
  os.chmod(dest,  os.stat(dest).st_mode | stat.S_IXUSR)

# Recursive helper for linking over individual files in the tree rooted at
# dotfiles.
def LinkDotfiles(targetDir, linkDir, addDot):
  if not p.exists(linkDir):
    print('Creating %s' % linkDir)
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

def StandardInstallation(appendDirs, install_binaries):
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
  4. Installs binaries from 'install_binaries'. Keys are destination names;
     values are paths to copy from.
  """

  # Clean out any existing bin stuff.
  if p.isdir(BIN):
    shutil.rmtree(BIN)

  # Perform the copy.
  shutil.copytree(COMMON_TEXT, BIN)

  # Process arguments to see if they contain append-files.
  for appendDir in appendDirs:
    if not p.exists(appendDir):
      print('Skipping non-existent appendDir: %s' % appendDir)
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
          print('Appending %s' % appendSource)
          with open(appendDest) as f:
            text = f.read()
          while not text.endswith('\n\n'):
            text += '\n'
          with open(appendSource) as f:
            text += f.read()
          with open(appendDest, 'w') as f:
            f.write(text)
        else:
          print('Copying %s' % appendSource)
          # Make sure the target directory exists.
          destDir, _ = p.split(appendDest)
          if not p.exists(destDir):
            os.makedirs(destDir)
          shutil.copy(appendSource, appendDest)

  # Link over dotfiles.
  LinkDotfiles(DOTFILES_BIN, HOME, True)

  # Link in all the other scripts that should be on the path.
  ForceLink(SCRIPTS_BIN, p.join(HOME, 'bin'))

  # Configure cron.
  print("Installing .crontab")
  subprocess.call(['crontab', p.join(HOME, '.crontab')])

  # Install binaries.
  for dest in install_binaries:
    InstallBinary(install_binaries[dest], p.join(SCRIPTS_BIN, dest))

def LaptopInstallation():
  """ Meant to be invoked after StandardInstallation() for laptops. Adds some
  useful configuration settings for laptops.
  """
  SetMonospaceFontSize(15)

def SetMonospaceFontSize(size):
  terminator_config = ReadFile(TERMINATOR_CONF)
  print('Setting terminator font size')
  terminator_config = terminator_config.replace(
      'Ubuntu Mono 15', 'Ubuntu Mono %d' % size)
  WriteFile(TERMINATOR_CONF, terminator_config)

  apply_mate_settings = ReadFile(APPLY_MATE_SETTINGS)
  print('Setting system monospace font size')
  apply_mate_settings = apply_mate_settings.replace(
      'Ubuntu Mono 15', 'Ubuntu Mono %d' % size)
  WriteFile(APPLY_MATE_SETTINGS, apply_mate_settings)

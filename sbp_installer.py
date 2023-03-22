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
BIN = p.join(SBP, 'bin')

# Directory for targets of dotfile symlinks under $HOME.
DOTFILES_BIN = p.join(BIN, 'dotfiles')

# Executables to be placed on $PATH.
SCRIPTS_BIN = p.join(BIN, 'scripts')

SBP_LINUX_CONFIG = p.join(SBP, 'sbp_linux_config')
COMMON_TEXT = p.join(SBP_LINUX_CONFIG, 'common-text')

def ForceLink(target, linkName):
  """ Forces a symlink, even if the linkName already exists. """
  if p.islink(linkName) or p.isfile(linkName):
    # Don't handle the case where linkName is a directory--it's too easy to
    # blow away existing config folders that way.
    os.remove(linkName)

  print('Linking %s' % linkName)
  os.symlink(target, linkName)

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

def StandardInstallation():
  """ Invokes the standard install procedure.

  1. Copies everything from ~/sbp/sbp_linux_config/common-text to ~/sbp/bin.
  2. Makes several symlinks in standard places (such as ~) that point
     to the appropriate files in ~/sbp/bin.
  3. If command-line arguments are provided, each is interpreted as a directory
     which may contain zero or more subdirectories corresponding to the
     subdirectories of ~/sbp/sbp_linux_config/common-text. Each file in each
     of these directories is read in and appended to the corresponding file
     in ~/sbp/bin. If no such file exists yet in ~/sbp/bin, it is created with
     the appended contents. This provides a simple mechanism for adding
     per-machine customizations.
  """

  # Clean out any existing bin stuff.
  if p.isdir(BIN):
    shutil.rmtree(BIN)

  # Perform the copy.
  shutil.copytree(COMMON_TEXT, BIN)

  # Process arguments to see if they contain append-files.
  appendDirs = sys.argv[1:]
  for appendDir in appendDirs:
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

if __name__ == "__main__":
    StandardInstallation()

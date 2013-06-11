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

HOME = p.expanduser('~')
SBP_LINUX_CONFIG = p.join(HOME, 'sbp-linux-config')
SRC = p.join(SBP_LINUX_CONFIG, 'src')
BIN = p.join(SBP_LINUX_CONFIG, 'bin')
DOTFILES_BIN = p.join(BIN, 'dotfiles')
SCRIPTS_BIN = p.join(BIN, 'scripts')


def insertBefore(text, afterLine, newLine):
  """ Inserts newLine into text, right before afterLine. """
  lines = text.splitlines()
  lineNum = lines.index(afterLine)
  lines.insert(lineNum, newLine)
  return '\n'.join(lines)


def standard(appendDirs):
  # Clean out any existing bin stuff.
  if p.isdir(BIN):
    shutil.rmtree(BIN)

  # Perform the copy.
  shutil.copytree(SRC, BIN)

  # Link in all the dotfiles.
  for dotfile in os.listdir(DOTFILES_BIN):
    target = p.join(DOTFILES_BIN, dotfile)
    linkName = p.join(HOME, '.' + dotfile)
    os.symlink(target, linkName)

  # Link in all the other scripts that should be on the path.
  os.symlink(SCRIPTS_BIN, p.join(HOME, 'bin'))

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
            print 'Copying %s to %s ...'
            shutil.copy(appendSource, appendDest)

  # Prevent GNOME's nautilus from leaving behind those weird "Desktop" windows:
  subprocess.call(['gsettings', 'set', 'org.gnome.desktop.background',
      'show-desktop-icons', 'false'])


if __name__ == '__main__':
  standard(sys.argv[1:])

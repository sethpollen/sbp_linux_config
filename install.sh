#!/bin/sh
# This script provides a standard installation of sbp-linux-config through
# the following steps:
#   1. It copies everything from ./src to ./bin
#   2. It makes several symlinks in standard places (such as ~) that point
#      to the appropriate files in ./bin
# Users who wish to add additional (per-machine) customizations to
# the sbp-linux-config installation may do so by manipulating the files
# in ./bin after this script has run.

SBP_LINUX_CONFIG=~/sbp-linux-config
SRC=$SBP_LINUX_CONFIG/src
BIN=$SBP_LINUX_CONFIG/bin

# Clean out any existing bin stuff.
if [ -e "$BIN" ]; then
  rm -rf $BIN
fi

# Perform the copy.
cp -r $SRC $BIN

# Create all the symlinks, using this nice function:
make_link() {
  TARGET=`realpath $1`
  NAME=$2
  echo Linking $TARGET as $NAME ...
  ln --symbolic --force --no-target-directory $TARGET $NAME
}

# Link in all the dotfiles.
DOTFILES_TARGET_DIR=$BIN/dotfiles/
for TARGET in $DOTFILES_TARGET_DIR* ; do
  NAME=$(echo $TARGET | sed "s|$DOTFILES_TARGET_DIR|$HOME/.|")
  make_link $TARGET $NAME
done

# Link in all the other scripts that should be on the path.
make_link $BIN/scripts ~/bin

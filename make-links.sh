#!/bin/sh
# This script sets up some standard symlinks for sbp-linux-config.

make_link() {
  TARGET=`realpath $1`
  NAME=$2
  echo Linking $TARGET as $NAME ...
  ln --symbolic --force --no-target-directory $TARGET $NAME
}

# Some links are dependent on the host name.
HOST=$(hostname)

# Link in all the dotfiles.
TARGET_DIR=~/sbp-linux-config/dotfiles/
for TARGET in $TARGET_DIR* ; do
  NAME=$(echo $TARGET | sed "s|$TARGET_DIR|$HOME/.|")
  make_link $TARGET $NAME
done

# Link in special script folders.
make_link ~/sbp-linux-config/hosts/$HOST/display ~/display
make_link ~/sbp-linux-config/bin ~/bin

#!/bin/sh
# This script sets up some standard symlinks for sbp-linux-config.

make_link() {
  TARGET=`realpath $1`
  NAME=$2
  echo Linking $TARGET as $NAME ...
  ln --symbolic --force --no-target-directory $TARGET $NAME
}

# Some links are dependent on the host name.
HOST=`hostname`

# Link in all the dotfiles.
make_link dotfiles/_.Xresources ~/.Xresources
make_link dotfiles/_.vimrc ~/.vimrc
make_link dotfiles/_.i3 ~/.i3

# Link in special script folders.
make_link hosts/$HOST/display ~/display

#!/bin/sh
# This script sets up some standard symlinks for sbp-linux-config. These links should be
# applicable to all X-based Linux desktops.

make_link() {
  echo Linking `realpath $1` as $2 ...
  ln -sf `realpath $1` $2
}

make_link ./_.Xresources ~/.Xresources
make_link ./_.vimrc ~/.vimrc


#!/bin/sh
# Runs the X keymap settings in ~/.xkeymap.

MAP=~/.xkeymap
if [ -f "$MAP" ]; then
  xmodmap $MAP
fi

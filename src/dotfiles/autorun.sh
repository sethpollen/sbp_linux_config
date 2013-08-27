#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session.

# Clear out the downloads folder.
DOWNLOADS=~/Downloads
if [ -d "$DOWNLOADS" ]; then
  rm -rf $DOWNLOADS
  mkdir $DOWNLOADS
fi

# Set up X key mappings.
KEYMAP=~/.xkeymap
if [ -f "$KEYMAP" ]; then
  xmodmap $KEYMAP
fi
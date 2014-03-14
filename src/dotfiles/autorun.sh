#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# Clear out the downloads folder.
DOWNLOADS="${HOME}/Downloads"
if [ -d "$DOWNLOADS" ]; then
  rm -rf "$DOWNLOADS"
  mkdir "$DOWNLOADS"
fi

# Set up X key mappings.
KEYMAP="${HOME}/.xkeymap"
if [ -f "$KEYMAP" ]; then
  xmodmap "$KEYMAP"
fi

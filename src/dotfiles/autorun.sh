#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# This command is required to get middle-click functionality to work with the
# Logitech Marble Mouse. See
#   https://wiki.archlinux.org/index.php/Logitech_Marble_Mouse
gsettings set \
  org.gnome.settings-daemon.peripherals.mouse middle-button-enabled true

# Clear out the downloads folder.
DOWNLOADS="${HOME}/Downloads"
if [ -d "$DOWNLOADS" ]; then
  rm -rf "$DOWNLOADS"
  mkdir "$DOWNLOADS"
fi

# Tweak X key bindings.
setxkbmap -layout us -option caps:escape

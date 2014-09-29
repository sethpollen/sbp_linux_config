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

# Configure Logitech Marble Mouse.
xinput set-int-prop "Logitech USB Trackball" "Evdev Wheel Emulation Button" 8 8
xinput set-int-prop "Logitech USB Trackball" "Evdev Wheel Emulation" 8 1
xinput set-int-prop "Logitech USB Trackball" "Evdev Middle Button Emulation" 8 1
xinput set-prop "Logitech USB Trackball" "Evdev Wheel Emulation Axes" 6 7 4 5

# Set up X key mappings.
KEYMAP="${HOME}/.xkeymap"
if [ -f "$KEYMAP" ]; then
  xmodmap "$KEYMAP"
else
  echo "Failed to modify X keymap."
fi

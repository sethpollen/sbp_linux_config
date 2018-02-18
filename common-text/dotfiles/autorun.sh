#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# TODO: clean these gsettings calls up

# This command is required to get middle-click functionality to work with the
# Logitech Marble Mouse. See
#   https://wiki.archlinux.org/index.php/Logitech_Marble_Mouse
gsettings set \
  org.cinnamon.settings-daemon.peripherals.mouse \
  middle-button-enabled true

gsettings set \
  org.cinnamon.settings-daemon.peripherals.touchpad \
  horizontal-two-finger-scrolling true

gettings set \
  org.cinnamon.settings-daemon.peripherals.touchpad \
  custom-threshold true
gettings set \
  org.cinnamon.settings-daemon.peripherals.touchpad \
  motion-threshold 5
gettings set \
  org.cinnamon.settings-daemon.peripherals.touchpad \
  custom-acceleration true
gettings set \
  org.cinnamon.settings-daemon.peripherals.touchpad \
  motion-acceleration 7.3

# TODO: record here any settings which need adjusting after a fresh Rodete
# installation

# Make the CapsLock key send the same keystroke as Escape.
# TODO: try to do this instead with gsettings
xmodmap -e "remove Lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = Escape"

# Allow screen locking.
daemon mate-screensaver

# Volume control widget.
daemon mate-volume-control-applet

# Handle laptop brightness keys.
# TODO: try to make this work faster
# TODO: dim display when idle
daemon mate-power-manager

# Clear out the downloads folder.
DOWNLOADS="${HOME}/Downloads"
if [ -d "$DOWNLOADS" ]; then
  rm -rf "$DOWNLOADS"
  mkdir "$DOWNLOADS"
fi

# Prove that none of the above commands blocked.
echo "Autoruns complete"

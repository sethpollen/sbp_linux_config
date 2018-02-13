#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# This command is required to get middle-click functionality to work with the
# Logitech Marble Mouse. See
#   https://wiki.archlinux.org/index.php/Logitech_Marble_Mouse
gsettings set \
  org.cinnamon.settings-daemon.peripherals.mouse \
  middle-button-enabled true
gsettings set \
  org.cinnamon.settings-daemon.peripherals.touchpad \
  scroll-method two-finger-scrolling
gsettings set \
  org.cinnamon.settings-daemon.peripherals.touchpad \
  horizontal-two-finger-scrolling true

# TODO: record here any settings which need adjusting after a fresh Rodete
# installation

# Make the CapsLock key send the same keystroke as Escape.
xmodmap -e "remove Lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = Escape"

# Now that we are done invoking gsettings, we can spawn a
# cinnamon-settings-daemon to apply those changes. This also handles the laptop
# brightness and volume keys.
daemon cinnamon-settings-daemon
daemon cinnamon-screensaver

# Spawn a desktop widget for volume control. This runs as a daemon by default.
kmix

# Clear out the downloads folder.
DOWNLOADS="${HOME}/Downloads"
if [ -d "$DOWNLOADS" ]; then
  rm -rf "$DOWNLOADS"
  mkdir "$DOWNLOADS"
fi

# Prove that none of the above commands blocked.
echo "Autoruns complete"

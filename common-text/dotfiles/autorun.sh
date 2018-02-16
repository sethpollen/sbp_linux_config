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
  horizontal-two-finger-scrolling true

# TODO: record here any settings which need adjusting after a fresh Rodete
# installation

# Make the CapsLock key send the same keystroke as Escape.
# TODO: try to do this instead with gsettings and dex
xmodmap -e "remove Lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = Escape"

# Spawn all the daemons which make up a Cinnamon desktop.
fk sbp-exec dex --verbose --autostart --environment X-Cinnamon

# Needed to get sbplock to work. For some reason, dex doesn't start this.
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

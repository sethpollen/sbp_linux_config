#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# Populate dmenu_run cache.
fk dmenu_path

gsettings set org.mate.interface monospace-font-name "Ubuntu Mono 14"

# TODO: also add settings here for touchpads
gsettings set org.mate.peripherals-mouse motion-threshold 5
gsettings set org.mate.peripherals-mouse motion-acceleration 10

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
daemon mate-power-manager

# Handle laptop volume keys and other settings.
daemon mate-settings-daemon

# Clear out the downloads folder.
DOWNLOADS="${HOME}/Downloads"
if [ -d "$DOWNLOADS" ]; then
  rm -rf "$DOWNLOADS"
  mkdir "$DOWNLOADS"
fi

# Prove that none of the above commands blocked.
echo "Autoruns complete"

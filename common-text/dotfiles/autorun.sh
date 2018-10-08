#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# Populate dmenu_run cache.
fk dmenu_path

apply-sbp-mate-settings

# Make the CapsLock key send the same keystroke as Escape.
xmodmap -e "remove Lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = Escape"

# Allow screen locking.
daemon mate-screensaver

# Volume control widget.
daemon mate-volume-control-applet

# Handle laptop brightness keys.
daemon mate-power-manager

# Handle laptop volume keys and other settings.
daemon mate-settings-daemon

# Systray icon for network.
daemon nm-applet

# Clear out the downloads folder.
DOWNLOADS="${HOME}/Downloads"
if [ -d "$DOWNLOADS" ]; then
  rm -rf "$DOWNLOADS"
  mkdir "$DOWNLOADS"
fi

# Prove that none of the above commands blocked.
echo "Autoruns complete"

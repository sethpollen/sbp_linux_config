#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# Populate dmenu_run cache.
fk dmenu_path

apply-sbp-mate-settings

# Make the CapsLock key send the same keystroke as Escape.
xmodmap -e "remove Lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = Escape"

# Enable the numeric keypad on my Redragon mouse.
numlockx on

# Allow screen locking.
daemon mate-screensaver

# Volume control widget.
daemon mate-volume-control-applet

# Wi-fi widget.
daemon nm-applet

# Handle laptop brightness keys.
daemon mate-power-manager

# Handle laptop volume keys and other settings.
daemon mate-settings-daemon

# Clear out the downloads folder.
downloads="${HOME}/Downloads"
if [ -d "$downloads" ]; then
  rm -rf "$downloads"
  mkdir "$downloads"
fi

# Clear out any leftover state from detached processes. They probably died
# on logout anyway.
back="${HOME}/.back"
if [ -d "$back" ]; then
  rm -rf "$back"
  mkdir "$back"
fi

# Prove that none of the above commands blocked.
echo "Autoruns complete"
touch "${HOME}/.autorun.finished"

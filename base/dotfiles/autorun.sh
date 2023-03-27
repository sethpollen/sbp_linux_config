#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# Populate dmenu_run cache.
fk dmenu_path

apply-sbp-mate-settings

# Enable the numeric keypad on my Redragon mouse.
numlockx on

# Volume control widget.
daemon mate-volume-control-status-icon

# Set my input and output volume settings.
amixer set Master,0 80%,80%
amixer set Capture,0 40%,40%

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

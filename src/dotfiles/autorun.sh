#!/bin/sh
# Standard stuff that should run when the user logs into a desktop session (i.e.
# an i3 session).

# Clear out the downloads folder.
DOWNLOADS="${HOME}/Downloads"
if [ -d "$DOWNLOADS" ]; then
  rm -rf "$DOWNLOADS"
  mkdir "$DOWNLOADS"
fi

# This command is required to get middle-click functionality to work with the
# Logitech Marble Mouse. See
#   https://wiki.archlinux.org/index.php/Logitech_Marble_Mouse
gsettings set \
  org.gnome.settings-daemon.peripherals.mouse middle-button-enabled true

# Tweak X key bindings.
gsettings set \
  org.gnome.desktop.input-sources xkb-options "['caps:escape']"

# Now that we are done invoking gsettings, we can spawn a gnome-settings-daemon
# to apply those changes. This also handles the laptop brightness and volume
# keys.
daemon unity-settings-daemon


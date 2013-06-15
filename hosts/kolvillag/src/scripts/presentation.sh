#!/bin/sh
# Configures the display to use a projector for presentations.

set-up-x-modes.sh

xrandr --output LVDS-1 --mode "1280x1024" --primary
xrandr --output VGA-1 --mode "1280x1024" --same-as LVDS-1

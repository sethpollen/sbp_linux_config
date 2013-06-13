#!/bin/sh
# Configures the display to use my external monitor setup at home.

xrandr --output LVDS-1 --mode "1440x900" --primary
xrandr --output VGA-1 --mode "1280x1024" --right-of LVDS-1

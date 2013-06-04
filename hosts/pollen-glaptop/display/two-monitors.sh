#!/bin/sh
# Configures the display to use my external monitor setup at home.

xrandr --output LVDS1 --mode "1600x900" --primary
xrandr --output VGA1 --mode "1280x1024" --right-of LVDS1

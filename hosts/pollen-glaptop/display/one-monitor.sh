#!/bin/sh
# Configures the display to use just the integrated flatpanel.

xrandr --output LVDS1 --mode "1600x900" --primary
xrandr --output VGA1 --off

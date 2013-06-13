#!/bin/sh
# Configures the display to use just the integrated flatpanel.

xrandr --output LVDS-1 --mode "1440x900" --primary
xrandr --output VGA-1 --off

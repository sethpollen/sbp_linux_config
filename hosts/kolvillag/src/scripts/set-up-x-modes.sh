#!/bin/sh
# Verifies that my favorite X display modes have been added to xrandr.

# Thew --newmode command will fail with non-zero exit status if the specified
# name is already in use.
xrandr --newmode "1440x900" \
    106.47 1440 1520 1672 1904 900 901 904 932 -HSync +Vsync \
    2> /dev/null

# This command is idempotent.
xrandr --addmode LVDS-1 "1440x900"



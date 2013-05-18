#!/bin/sh
# Tries to auto-detect the current display hardware and choose the
# appropriate config script.

# Tries to use xrandr's command-line output to see if the display output $1
# is currently connected.
is_connected() {
  if xrandr --query | grep --silent "$1 connected" ; then
    return 0
  else
    return 1
  fi
}

# Based on the host, we choose the name of the external monitor which
# determines the configuration to use.
HOST=`hostname`
case "$HOST" in
  kolvillag)
    SECOND_DISPLAY="VGA-1" ;;
esac

# Now test if the external monitor is connected, and run the appropriate
# script.
DISPLAY_BIN=$SBP_LINUX_CONFIG/hosts/$HOST/display
if is_connected $SECOND_DISPLAY ; then
  $DISPLAY_BIN/two-monitors.sh
else
  $DISPLAY_BIN/one-monitor.sh
fi

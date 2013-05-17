#!/bin/sh
# Tries to auto-detect the current display hardware and choose the appropriate
# config script.

# Tries to use xrandr's command-line output to see if the display output $1
# is currently connected.
is_connected() {
  if xrandr --query | grep "$1 connected"; then
    #TODO
  fi
}

HOST=`hostname`
case "$HOST" in
  kolvillag)
    # TODO
    ;;
esac

# This file will be appended to the standard autorun.sh.

# Pick the right display setup, based on currently connected external monitors.
if is-display-connected VGA-1 ; then
  two-monitors.sh
else
  one-monitor.sh
fi

#!/bin/sh
# Sources everything from the autorun.d directory.

for SCRIPT in $SBP_LINUX_CONFIG/autorun.d/*.sh ; do
  $SCRIPT
done

#!/bin/sh
# Executes everything from the autorun.d directory.

for SCRIPT in ~/sbp-linux-config/autorun.d/*.sh ; do
  $SCRIPT
done

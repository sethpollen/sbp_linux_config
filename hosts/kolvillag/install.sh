#!/bin/sh
# Wrapper for install.sh which provides kolvillag-specific configurations.

SBP_LINUX_CONFIG=~/sbp-linux-config
SPECIFIC=$SBP_LINUX_CONFIG/hosts/kolvillag
$SBP_LINUX_CONFIG/install.sh $SPECIFIC
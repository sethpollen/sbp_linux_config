#!/bin/sh
# Wrapper for install.sh which provides kolvillag-specific configurations.

SBP_LINUX_CONFIG=~/sbp-linux-config
SPECIFIC=$SBP_LINUX_CONFIG/hosts/kolvillag

# First, call the standard install.sh.
$SBP_LINUX_CONFIG/install.sh

# Copy over machine-specific scripts.
cp -v $SPECIFIC/scripts/* $SBP_LINUX_CONFIG/bin/scripts
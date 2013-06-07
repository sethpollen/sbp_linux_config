#!/bin/sh
# Wrapper for install.sh which provides kolvillag-specific configurations.

SBP_LINUX_CONFIG=~/sbp-linux-config
TWEAKS=$SBP_LINUX_CONFIG/hosts/kolvillag/tweaks
$SBP_LINUX_CONFIG/install.sh $TWEAKS
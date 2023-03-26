#!/bin/sh

cd $HOME/sbp/sbp_linux_config
$HOME/sbp/tools/bazelisk run -c opt //go:install_main || exit 1

# TODO: Automatically invoke desktop setup for desktops.

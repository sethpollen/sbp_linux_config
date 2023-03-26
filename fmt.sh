#!/bin/sh
#
# Auto-format all BUILD and Go files in this workspace.

gofmt -w $HOME/sbp/sbp_linux_config

$HOME/sbp/tools/buildifier \
  $(find $HOME/sbp/sbp_linux_config -name "BUILD*" -type f)

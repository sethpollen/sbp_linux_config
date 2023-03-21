#!/bin/sh

$HOME/sbp/buildifier-linux-amd64 \
  $(find $HOME/sbp/sbp_linux_config -name "BUILD*" -type f)

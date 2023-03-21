#!/bin/sh

$HOME/sbp/tools/buildifier \
  $(find $HOME/sbp/sbp_linux_config -name "BUILD*" -type f)

#!/usr/bin/env fish
#
# Invokes the proper Python installer script for the current machine.

set install $HOME/sbp/tools/bazelisk run //:sbp_installer --
set corp $HOME/sbp/corp_linux_config

# Prepare to invoke bazel.
cd $HOME/sbp/sbp_linux_config

# Pass the appropriate set of input directories for each host.
switch (hostname --short)
  case holroyd
    $install $corp/common $corp/workstation $corp/hosts/holroyd

  case montero
    $install $corp/common $corp/workstation

  case pollen
    $install $corp/common $corp/hosts/pollen

  case penguin
    $install
end

# Install spbgo_main, which is the same for all hosts.
$HOME/sbp/tools/bazelisk run //sbpgo:deploy || exit 1

echo Installation complete.

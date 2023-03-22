#!/usr/bin/env fish
#
# Invokes the proper Python installer script for the current machine.

# Build everything we'll need below.
cd $HOME/sbp/sbp_linux_config
$HOME/sbp/tools/bazelisk build -c opt //:install //sbpgo:sbpgo_main || exit 1
cd ./bazel-bin

set corp $HOME/sbp/corp_linux_config

# Pass the appropriate set of input directories for each host.
switch (hostname --short)
  case holroyd
    ./install $corp/common $corp/workstation $corp/hosts/holroyd || exit 1

  case montero
    ./install $corp/common $corp/workstation || exit 1

  case pollen
    ./install $corp/common $corp/hosts/pollen || exit 1

  case penguin
    ./install || exit 1
end

# Install spbgo_main, which is the same for all hosts.
echo Copying sbpgo_main
cp ./sbpgo/sbpgo_main_/sbpgo_main $HOME/sbp/bin/scripts/ || exit 1

echo Installation complete.

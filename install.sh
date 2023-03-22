#!/usr/bin/env fish
#
# Invokes the proper Python installer script for the current machine.

set bazel $HOME/sbp/tools/bazelisk

# Build everything we'll need below.
cd $HOME/sbp/sbp_linux_config
$bazel build -c opt //:sbp_installer //sbpgo:sbpgo_main

set installer bazel-bin/sbp_installer
set corp $HOME/sbp/corp_linux_config

# Pass the appropriate set of input directories for each host.
switch (hostname --short)
  case holroyd
    $installer $corp/common $corp/workstation $corp/hosts/holroyd || exit 1

  case montero
    $installer $corp/common $corp/workstation || exit 1

  case pollen
    $installer $corp/common $corp/hosts/pollen || exit 1

  case penguin
    $installer || exit 1
end

# Install spbgo_main, which is the same for all hosts.
echo Copying sbpgo_main
cp bazel-bin/sbpgo/sbpgo_main_/sbpgo_main $HOME/sbp/bin/scripts/

echo Installation complete.

#!/usr/bin/env fish
#
# Invokes the proper Python installer script for the current machine.

# Figure out what host we are installing on.
set host (hostname --short)

# Assume the host is a personal machine.
set repo sbp

# ... unless it matches one of my known corp hostnames.
switch $host
  case holroyd
    set repo corp
  case montero
    set repo corp
  case pollen
    set repo corp
end

echo Installing from {$repo}_linux_config/hosts/{$host}.

# Run the appropriate installer script for the host.
cd $HOME/sbp/{$repo}_linux_config
$HOME/sbp/tools/bazelisk run //hosts/{$host}:installer || exit 1

# Install spbgo_main, which is the same for all hosts.
cd $HOME/sbp/sbp_linux_config
$HOME/sbp/tools/bazelisk run //sbpgo:deploy || exit 1

echo Installation complete.

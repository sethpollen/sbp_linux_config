#!/usr/bin/env bash
#
# Invokes the proper Python installer script for the current machine.

hostname="$(hostname --short)"
# Replace hyphens with underscores, as we can't use hyphens in Bazel directory
# names if we wish to use Python.
hostname="${hostname//-/_}"

cd $HOME/sbp/sbp_linux_config
echo "Building installer..."
~/sbp/tools/bazelisk build -c opt "//hosts/${hostname}:installer" || exit 1

cd bazel-bin
echo "Running installer..."
"hosts/${hostname}/installer"

echo "Installation complete."

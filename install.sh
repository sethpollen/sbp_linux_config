#!/bin/sh
#
# Installs my linux config on a freshly imaged machine. To download and run,
# try this:
#
#   curl https://raw.githubusercontent.com/sethpollen/sbp_linux_config/master/install.sh | /bin/sh

# Install git so we can clone the repo.
sudo apt-get update || exit 1
yes | sudo apt-get install git || exit 1

# Prepare directories.
mkdir $HOME/sbp
mkdir $HOME/sbp/tools
mkdir $HOME/log

# Clone the main repo. There is no "|| exit 1" after this line,
# since the repo might already be present.
git clone \
  https://github.com/sethpollen/sbp_linux_config.git \
  $HOME/sbp/sbp_linux_config

# Jump into the cloned repo.
cd $HOME/sbp/sbp_linux_config

# Verify that the repo is working.
git pull || exit 1

# Download pre-built tools needed for later steps.
wget -O $HOME/sbp/tools/bazelisk \
  https://github.com/bazelbuild/bazelisk/releases/download/v1.16.0/bazelisk-linux-amd64 \
  || exit 1
chmod +x $HOME/sbp/tools/bazelisk

wget -O $HOME/sbp/tools/buildifier \
  https://github.com/bazelbuild/buildtools/releases/download/6.0.1/buildifier-linux-amd64 \
  || exit 1
chmod +x $HOME/sbp/tools/buildifier

# Build and run the rest of the installer.
$HOME/sbp/tools/bazelisk run -c opt //go:install_main || exit 1

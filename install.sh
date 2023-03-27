#!/bin/sh
#
# Installs my linux config on a freshly imaged machine. To download and run,
# try this:
#
#   curl https://raw.githubusercontent.com/sethpollen/sbp_linux_config/master/install.sh | /bin/sh

# Install git so we can clone the repo. Apparently we also need to install
# golang at this time, or else the bazelisk invocation below fails.
sudo apt-get update || exit 1
yes | sudo apt-get install git golang || exit 1

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

# Build the rest of the installer.
$HOME/sbp/tools/bazelisk build -c opt \
  //go:packages_main \
  //go:install_main \
  //go:sbp_main \
  || exit 1

# The binaries we just built expect to be executed from bazel-bin.
cd bazel-bin

# Install remaining packages.
yes | sudo apt-get install $(go/packages_main_/packages_main) || exit 1

# Add some separation after the wall of text produced by wget and apt-get.
echo

# Copy over my special mouse settings.
sudo cp \
  $HOME/sbp/sbp_linux_config/80-trackman.conf \
  $HOME/sbp/sbp_linux_config/81-elecom.conf \
  /usr/share/X11/xorg.conf.d \
  || exit 1
echo 'Installed Trackman and Elecom configurations. You may have to log out before'
echo 'they will take effect.'
echo

# Invoke the rest of the installation process.
go/install_main_/install_main || exit 1

echo
echo 'You may need to run `chsh` to get fish set up.'

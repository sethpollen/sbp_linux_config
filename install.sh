#!/bin/sh
#
# Installs my linux config on a freshly imaged machine. To download and run,
# try this:
#
#   curl https://raw.githubusercontent.com/sethpollen/sbp_linux_config/master/install.sh | /bin/sh

# Install git so we can clone the repo. Apparently we also need to install
# gcc in order for bazel to work below.
sudo apt-get update || exit 1
yes | sudo apt-get install git gcc || exit 1

# Prepare directories.
mkdir $HOME/sbp
mkdir $HOME/sbp/tools
mkdir $HOME/log

# Download pre-built tools needed for later steps.
wget -O $HOME/sbp/tools/bazelisk \
  https://github.com/bazelbuild/bazelisk/releases/download/v1.16.0/bazelisk-linux-amd64 \
  || exit 1
chmod +x $HOME/sbp/tools/bazelisk

wget -O $HOME/sbp/tools/buildifier \
  https://github.com/bazelbuild/buildtools/releases/download/6.0.1/buildifier-linux-amd64 \
  || exit 1
chmod +x $HOME/sbp/tools/buildifier

# Download sbp_linux_config.
git clone \
  https://github.com/sethpollen/sbp_linux_config.git \
  $HOME/sbp/sbp_linux_config

# Jump into the cloned repo.
cd $HOME/sbp/sbp_linux_config

# Build the rest of the installer tools.
$HOME/sbp/tools/bazelisk build -c opt \
  //go:packages_main \
  //go:install_main \
  //go:is_corp_main \
  //go:sbp_main \
  || exit 1
echo

# The binaries we just built expect to be executed from bazel-bin.
cd bazel-bin

if go/is_corp_main_/is_corp_main; then
  # This is a corp host. Download the corp_linux_config files.
  echo 'Downloading corp_linux_config'
  gcert || exit 1
  git clone sso://user/pollen/corp_linux_config $HOME/sbp/corp_linux_config
  echo
fi

# Install remaining packages.
yes | sudo apt-get install $(go/packages_main_/packages_main) || exit 1
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

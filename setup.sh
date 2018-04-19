#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $(readlink -f "$0"))
SCRIPT_NAME=$(basename "$0")

# Must be run as root
if [[ `whoami` != "root" ]]
then
  echo "This install must be run as root or with sudo."
  echo
  echo "Try 'sudo bash ${SCRIPT_NAME}'"
  exit
fi

export DEBIAN_FRONTEND=noninteractive

INSTALL_PKGS="ntp git perl debhelper gpac"

BUILD_TIME=`stat -c %Y /boot/kernel.img`
case $BUILD_TIME in
  1523086824)
    echo "Detect Crankshaft image 2018-04-07, disabling auto-shutdown and skip NTP..."
    shutdown -c
    INSTALL_PKGS=${INSTALL_PKGS/ntp /}
    ;;
esac

echo "Installing packages..."
apt-get update -y
apt-get install -y $INSTALL_PKGS

if [[ $INSTALL_PKGS == *"ntp "* ]]; then
  echo "Setup NTP time sync..."
  systemctl enable ntp
  timedatectl set-ntp 1
fi

echo "Getting and Building USBmount..."
cd $HOME
git clone https://github.com/rbrito/usbmount.git
cd usbmount
rm -f ../usbmount_*.deb
dpkg-buildpackage -us -uc -b
apt install  ../usbmount_*.deb

echo "Cloning Open Auto Pi Utilities repository..."
cd $HOME
git clone https://github.com/snailium/OpenAutoPiUtils.git

echo "Setup not finished yet..."

echo "Now use 'sudo reboot' to reboot system."


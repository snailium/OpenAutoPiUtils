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

BUILD_TIME=`stat -c %Y /boot/kernel.img`
case $BUILD_TIME in
  1523086824)
    echo "Detect Crankshaft image 2018-04-07, disabling auto-shutdown"
    shutdown -c
    ;;
esac

echo "Installing packages"
apt-get update -y
apt-get install -y ntp git perl

echo "Setup NTP time sync"
systemctl enable ntp
timedatectl set-ntp 1

echo "Cloning Open Auto Pi Utilities repository..."
cd $HOME
ssh-keyscan >> ~/.ssh/known_hosts
git clone git@github.com:snailium/OpenAutoPiUtils.git


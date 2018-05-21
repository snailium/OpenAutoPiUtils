#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $(readlink -f "$0"))
SCRIPT_NAME=$(basename "$0")

UTIL_PROJ=OpenAutoPiUtils
UTIL_REPO=https://github.com/snailium/${UTIL_PROJ}.git
UTIL_ROOT=/home/pi/${UTIL_PROJ}

# Must be run as root
if [[ `whoami` != "root" ]]
then
  echo "This install must be run as root or with sudo."
  echo
  echo "Try 'sudo bash ${SCRIPT_NAME}'"
  exit
fi

export DEBIAN_FRONTEND=noninteractive

INSTALL_PKGS="ntp git i2c-tools perl bc debhelper gpac"

BUILD_TIME=`stat -c %Y /usr/local/bin/autoapp`
# Crankshaft build time database
#
# Version    Date           Time
# -------    ----------     ----------
# v0.1.0     2018-02-24     1519516837
# v0.1.1     2018-02-28     1519861911
# v0.1.5     2018-03-02     1520047217
# v0.1.6     2018-03-05     1520238100
# v0.1.7     2018-03-10     1520658814
# v0.2.0     2018-03-13     1520928566
# v0.2.1-0   2018-04-01     1522564529
# v0.2.1-1   2018 04-01     1522599276
# v0.2.2     2018-04-07     1522552897
# v0.2.3     2018-04-18     1522552897
# v0.2.4     2018-05-18     1526619131
case $BUILD_TIME in
  1523086824)
    echo "Detect Crankshaft image v0.2.2 (2018-04-07), disabling auto-shutdown and skip NTP..."
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

echo "Fetching, building and installing USBmount..."
cd $HOME
git clone https://github.com/rbrito/usbmount.git
cd usbmount
rm -f ../usbmount_*.deb
dpkg-buildpackage -us -uc -b
apt install -y ../usbmount_*.deb

echo "Cloning Open Auto Pi Utilities repository..."
cd $HOME
sudo -H -u pi git clone ${UTIL_REPO} ${UTIL_ROOT}

echo "Enabling Open Auto Pi Utilities..."
# For Crankshaft v0.2.3 and later, install scripts into /boot/crankshaft/startup.sh
CRANKSHAFT_STARTUP=/boot/crankshaft/startup.sh
if [ -e ${CRANKSHAFT_STARTUP} ]; then
  /opt/crankshaft/filesystem.sh unlock_boot
  echo "${UTIL_ROOT}/brightness.sh &" | tee -a ${CRANKSHAFT_STARTUP}
else
  #TODO install to /etc/rc.local
fi

echo "Enabling Raspberry Pi I2C interface..."
raspi-config nonint do_i2c 0

echo "Enabling Raspberry Pi camera interface..."
raspi-config nonint do_camera 0

echo "Resizing partitions on SD card..."
raspi-config --expand-rootfs

echo "Setup not finished yet..."

echo "Now use 'sudo reboot' to reboot system."

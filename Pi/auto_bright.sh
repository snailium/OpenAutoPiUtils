#!/bin/bash

I2CBUS=1
I2CDEV="/dev/i2c-${I2CBUS}"
I2CGET="i2cget -y $I2CBUS"
I2CSET="i2cset -y $I2CBUS"
I2CDET="i2cdetect -y $I2CBUS"
I2CADDR=0x23

I2CADDR_L=23
I2CADDR_H=5c

SUDO=

# Check I2C enable
if [ ! -e $I2CDEV ]; then
  echo "I2C is not enabled!"
  echo "Please run 'raspi-config' and enable I2C."
  exit 1
fi

# Check privilege
if [[ `whoami` != "root" ]]; then
  SUDO=sudo
fi

# Check device
I2C_PRESENCE_L=$($SUDO $I2CDET 0x${I2CADDR_L} 0x${I2CADDR_L} | grep -c ${I2CADDR_L})
I2C_PRESENCE_H=$($SUDO $I2CDET 0x${I2CADDR_H} 0x${I2CADDR_H} | grep -c ${I2CADDR_H})

if [[ $I2C_PRESENCE_L -gt 0 ]]; then
  I2CADDR=0x${I2CADDR_L}
#  echo "BH1750FVI is found at low address ${I2CADDR}"
elif [[ $I2C_PRESENCE_H -gt 0 ]]; then
  I2CADDR=0x${I2CADDR_H}
#  echo "BH1750FVI is found at high address ${I2CADDR}"
else
  echo "BH1750FVI is not found."
  exit 1
fi

# Power on BH1750FVI
$SUDO $I2CSET $I2CADDR 0x01

# Reset BH1750FVI
$SUDO $I2CSET $I2CADDR 0x07

while [ : ]; do
  # Start a H Resolution Mesurement
  $SUDO $I2CSET $I2CADDR 0x10

  # Wait for reading finish
  sleep 0.2s

  # Read back value
  LUX_RAW=$($SUDO $I2CGET $I2CADDR 0x00 w)

  if [[ $? -eq 0 ]]; then
    # Get decimal value
    LUX_HEX=${LUX_RAW:4:2}${LUX_RAW:2:2}
    LUX=$((16#${LUX_HEX}))

    # Calculate brightness - starting from 15 to 255, in step of 10 (25 steps)
    LIGHT=$(echo "sqrt ( $LUX )" | bc)
    BRIGHT=$((LIGHT/4*10+15))
    if [[ $BRIGHT -ge 255 ]]; then
      BRIGHT=255
    fi
#    echo "BH1750FVI reading is $LIGHT, set display brightness to $BRIGHT"
    echo $BRIGHT > /sys/class/backlight/rpi_backlight/brightness
  fi

  sleep 5s

done

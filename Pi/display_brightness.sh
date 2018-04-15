#!/bin/bash

SERDEV=/dev/ttyACM0


while [ : ]
do
  # Wait for device
  while [ ! -e $SERDEV ]
  do
    sleep 1
  done

  read LIGHT < $SERDEV

  if [ ! -z $LIGHT ]; then
    BRIGHT=$((LIGHT*240/800+15));
    if [[ $BRIGHT -le 15 ]]; then
      BRIGHT=15
    elif [[ $BRIGHT -ge 255 ]]; then
      BRIGHT=255
    fi
#    echo "Arduino reading is $LIGHT, set display brightness to $BRIGHT"
    echo $BRIGHT > /sys/class/backlight/rpi_backlight/brightness
  fi
done

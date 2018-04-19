#!/bin/bash

CAM_STATUS=`vcgencmd get_camera`

if [[ $CAM_STATUS == *"supported=0"* ]]
then
  echo "Main camera is not supported."
  exit
fi

if [[ $CAM_STATUS == *"detected=0"* ]]
then
  echo "Main camera is not attached."
  exit
fi

USB_STATUS=
# Wait for USB storage
while [ -z $USB_STATUS ]
do
  sleep 5
  USB_STATUS=`mount | grep usb0`
done

cd /media/usb0

while [ : ]
do
  TIMESTAMP=`date %Y%H%s`
  raspivid -t 300000 -w 1920 -h 1080 -fps 15 -b 2000000 -n -o main_${TIMESTAMP}.h264
  MP4Box -add main_${TIMESTAMP}.h264 main_${TIMESTAMP}.mp4 && rm main_${TIMESTAMP}.h264 &
done

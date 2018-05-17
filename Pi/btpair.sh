#!/bin/bash

DEBUG_FILE=/home/pi/btpair.log

SUDO=

# Check privilege
if [[ `whoami` != "root" ]]; then
  SUDO=sudo
fi

if [ -e ${DEBUG_FILE}.last ]; then
  mv ${DEBUG_FILE}.last ${DEBUG_FILE}.before
fi

if [ -e ${DEBUG_FILE} ]; then
  mv ${DEBUG_FILE} ${DEBUG_FILE}.last
fi

echo "Launched with SUDO=${SUDO}, BT_PHONE=${BT_PHONE}" > ${DEBUG_FILE}

systemctl status bluetooth | tee -a ${DEBUG_FILE}

echo "Waiting 30s, now BT_PHONE=${BT_PHONE}" | tee -a ${DEBUG_FILE}

while ! systemctl status bluetooth | grep 'Status: "Running"' >/dev/null; do
    echo "Waiting for bluetoothd" | tee -a ${DEBUG_FILE}
    sleep 1
done

if ! systemctl status ofono | grep 'Active: active (running)' >/dev/null; then
    echo "Starting ofono" | tee -a ${DEBUG_FILE}
    sudo service ofono start
fi

while ! systemctl status ofono | grep 'Active: active (running)' >/dev/null; do
    echo "Waiting for ofono" | tee -a ${DEBUG_FILE}
    sleep 1
done

echo "Waited 30s, now BT_PHONE=${BT_PHONE}" | tee -a ${DEBUG_FILE}

systemctl status bluetooth | tee -a ${DEBUG_FILE}

echo "Chech ofono status" | tee -a ${DEBUG_FILE}

systemctl status ofono | tee -a ${DEBUG_FILE}

$SUDO bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
connect ${BT_PHONE}
EOF


#!/bin/bash
set -e

bn=$(basename $1)

# Ensure the folder exists
ssh pi@$2 "mkdir -p /home/pi/projects/$bn/"

# Sync executable
rsync -az $1/build/SETR_TP1 pi@$2:/home/pi/projects/$bn/SETR_TP1

# Execute GDB
ssh pi@$2 "rm -f /home/pi/capture-stdout; rm -f /home/pi/capture-stderr; nohup gdbserver :4567 /home/pi/projects/$bn/SETR_TP1 > /home/pi/capture-stdout 2> /home/pi/capture-stderr < /dev/null &"
sleep 1 

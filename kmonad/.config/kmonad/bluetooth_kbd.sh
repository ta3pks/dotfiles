#!/bin/sh
__EVENTS=$(ls /dev/input/event*)

for __EVENT in $__EVENTS
do
    __DEVICE=$(udevadm info $__EVENT | grep "bluetooth" |grep "input" |grep  "DEVPATH" | grep -o "event[0-9]\+" )
    if [ -n "$__DEVICE" ]
    then
        echo "Found device: /dev/input/$__DEVICE"
        echo "linking /dev/input/$__DEVICE to /dev/input/by-id/current"
        ln -svf /dev/input/$__DEVICE /dev/input/by-id/current
        exit 0
    else
        echo "$__DEVICE"
    fi
done
#not found at this point
if [ -f /dev/input/by-id/usb-SteelSeries_SteelSeries_Apex_3_TKL-event-kbd ]
then
    ln -svf /dev/input/by-id/usb-SteelSeries_SteelSeries_Apex_3_TKL-event-kbd /dev/input/by-id/current
    exit 0
fi

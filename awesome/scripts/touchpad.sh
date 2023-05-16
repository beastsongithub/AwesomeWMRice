#!/bin/bash

state=$(xinput --list-props  "ETPS/2 Elantech Touchpad" | grep "Device Enabled" | cut -d\  -f3 | cut -f2)

if (($state=="1")); then
        xinput --disable "ETPS/2 Elantech Touchpad"
        notify-send -te 1800 "Touchpad OFF"
    elif (($state=="0")); then
        xinput --enable "ETPS/2 Elantech Touchpad"
        notify-send -te 1800 "Touchpad ON"
fi

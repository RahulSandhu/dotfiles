#!/bin/bash

BT_IDX=$(rfkill | grep -i bluetooth | awk '{print $1}' | head -n 1)

if rfkill list "$BT_IDX" | grep -q "Soft blocked: yes"; then
    rfkill unblock "$BT_IDX"
    notify-send \
        --app-name="Sway" \
        --icon=bluetooth-active-symbolic \
        --urgency=low \
        --expire-time=3000 \
        --replace-id=9994 \
        "Bluetooth" "On"
else
    rfkill block "$BT_IDX"
    notify-send \
        --app-name="Sway" \
        --icon=bluetooth-disabled-symbolic \
        --urgency=low \
        --expire-time=3000 \
        --replace-id=9994 \
        "Bluetooth" "Off"
fi
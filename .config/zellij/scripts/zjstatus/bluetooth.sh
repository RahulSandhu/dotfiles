#!/usr/bin/env bash

icon=""

if ! command -v bluetoothctl &>/dev/null; then
    echo "$icon Off"
    exit 0
fi

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo "$icon Off"
    exit 0
fi

connected_device=$(bluetoothctl devices Connected 2>/dev/null | head -n 1 | awk '{$1=""; $2=""; print $0}' | sed 's/^ *//')

if [ -n "$connected_device" ]; then
    echo "$icon $connected_device"
else
    echo "$icon On"
fi

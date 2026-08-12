#!/bin/bash

# Get the index of the first wifi connection
WIFI_IDX=$(rfkill | grep -i wlan | awk '{print $1}' | head -n 1)

# Toggle wifi soft block status (unblock if currently blocked, block otherwise)
rfkill list "$WIFI_IDX" | grep -q "Soft blocked: yes" && rfkill unblock "$WIFI_IDX" || rfkill block "$WIFI_IDX"

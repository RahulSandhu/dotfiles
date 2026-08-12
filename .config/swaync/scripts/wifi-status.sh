#!/bin/bash

# Check wifi soft block status
WIFI_IDX=$(rfkill | grep -i wlan | awk '{print $1}' | head -n 1)

# Report true if not soft blocked, false otherwise
rfkill list "$WIFI_IDX" | grep -q "Soft blocked: no" && echo true || echo false

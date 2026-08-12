#!/bin/bash

# Get the index of the first bluetooth device
BT_IDX=$(rfkill | grep -i bluetooth | awk '{print $1}' | head -n 1)

# Check if bluetooth is currently soft blocked. If yes, unblock it; otherwise, block it.
rfkill list "$BT_IDX" | grep -q "Soft blocked: yes" && rfkill unblock "$BT_IDX" || rfkill block "$BT_IDX"

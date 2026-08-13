#!/bin/bash

BT_IDX=$(rfkill | grep -i bluetooth | awk '{print $1}' | head -n 1)

rfkill list "$BT_IDX" | grep -q "Soft blocked: yes" && rfkill unblock "$BT_IDX" || rfkill block "$BT_IDX"

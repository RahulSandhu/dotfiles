#!/bin/bash

WIFI_IDX=$(rfkill | grep -i wlan | awk '{print $1}' | head -n 1)

rfkill list "$WIFI_IDX" | grep -q "Soft blocked: no" && echo true || echo false

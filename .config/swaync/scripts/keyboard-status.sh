#!/bin/bash

CURRENT_LAYOUT=$(swaymsg -t get_inputs | jq -r '.. | objects | select(.type? == "keyboard") | .xkb_active_layout_name' | head -n1)

if [[ "$CURRENT_LAYOUT" == "Spanish" ]]; then
    echo true
else
    echo false
fi

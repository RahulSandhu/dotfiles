#!/bin/bash

# All keyboards of a given type share one XKB layout in sway, so switch the
# whole "keyboard" type in a single command. Enumerating devices and switching
# each one toggles the shared layout N times, which cancels out whenever N is
# even (e.g. a Bluetooth headset's AVRCP media keys register as an extra
# keyboard). Switching by type is immune to how many devices are present.
swaymsg input type:keyboard xkb_switch_layout next >/dev/null

CURRENT_LAYOUT=$(swaymsg -t get_inputs |
    jq -r '[.[] | select(.type == "keyboard" and .name != "wlr_virtual_keyboard_v1")][0].xkb_active_layout_name // "unknown"')

notify-send \
    --app-name="Sway" \
    --icon=input-keyboard-symbolic \
    --urgency=low \
    --replace-id=9992 \
    "Keyboard Layout" "Switched to $CURRENT_LAYOUT"

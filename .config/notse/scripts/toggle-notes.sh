#!/bin/bash

NOTSE_BIN="$HOME/.local/share/go/bin/notse"

if pgrep -f "kitty.*notse" > /dev/null; then
    pkill -f "kitty.*notse"
else
    kitty --class notse -e "$NOTSE_BIN" &
fi

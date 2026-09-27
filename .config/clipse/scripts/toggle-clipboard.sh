#!/bin/bash

if pgrep -f "kitty.*clipse" > /dev/null; then
    pkill -f "kitty.*clipse"
else
    kitty --class clipse -e clipse &
fi

#!/bin/bash

if pgrep -f "kitty.*--class terrahour" > /dev/null; then
    pkill -f "kitty.*--class terrahour"
else
    kitty --class terrahour -e terrahour &
fi

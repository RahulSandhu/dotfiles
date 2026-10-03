#!/bin/bash

if pgrep -f "kitty.*--class terrahour" > /dev/null; then
    pkill -f "kitty.*--class terrahour"
else
    pkill -x galendae
    kitty --class terrahour -e terrahour &
fi

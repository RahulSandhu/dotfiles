#!/bin/bash

if pgrep -x galendae > /dev/null; then
    pkill -x galendae
else
    pkill -f "kitty.*--class terrahour"
    galendae &
fi

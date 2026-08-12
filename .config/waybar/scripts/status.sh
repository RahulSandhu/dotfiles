#!/bin/bash

# Get number of unread notifications
count=$(swaync-client -c)

# ANSI blue color code (you can change it)
NOTIFICATION='󰅽'  
ICON='󰅺'

# If notifications exist, output blue icon
if [ "$count" -gt 0 ]; then
    echo $NOTIFICATION
else
    echo $ICON
fi

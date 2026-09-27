#!/bin/bash

count=$(swaync-client -c)

NOTIFICATION='󰅽'
ICON='󰅺'

if [ "$count" -gt 0 ]; then
    echo $NOTIFICATION
else
    echo $ICON
fi

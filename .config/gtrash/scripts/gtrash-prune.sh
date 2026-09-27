#!/bin/bash

/usr/bin/gtrash prune --day 30 --force

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    /usr/bin/notify-send \
        --app-name="Sway" \
        --icon=user-trash-full \
        --urgency=normal \
        --expire-time=5000 \
        "Trash Pruned" "Files older than 30 days removed successfully"
else
    /usr/bin/notify-send \
        --app-name="Sway" \
        --icon=dialog-error \
        --urgency=critical \
        --expire-time=0 \
        "Trash Prune Failed" "Check logs: journalctl --user -u gtrash-prune.service"
fi

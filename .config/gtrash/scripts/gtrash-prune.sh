#!/bin/bash

# Make read-only trashed dirs (e.g. Go module cache) deletable
chmod -R u+w "$HOME/.local/share/Trash/files" 2>/dev/null

/usr/bin/gtrash prune --day 0 --force

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    /usr/bin/notify-send \
        --app-name="Sway" \
        --icon=user-trash-full \
        --urgency=normal \
        --expire-time=5000 \
        "Trash Pruned" "All trashed files removed successfully"
else
    /usr/bin/notify-send \
        --app-name="Sway" \
        --icon=dialog-error \
        --urgency=critical \
        --expire-time=0 \
        "Trash Prune Failed" "Check logs: journalctl --user -u gtrash-prune.service"
fi

#!/bin/bash

notify-send \
    --app-name="rclone" \
    --icon=network-server \
    --urgency=low \
    --expire-time=3000 \
    "Sync Started" "Syncing to the homelab..."

rclone \
  --config ${HOME}/.config/rclone/rclone.conf \
  --log-level NOTICE \
  --log-file=${HOME}/.config/rclone/rclone.log \
  --progress \
  --retries 3 \
  --low-level-retries 10 \
  --buffer-size 32M \
  --transfers 8 \
  --checkers 16 \
  sync \
  --skip-links \
  --delete-during \
  ${HOME}/ \
  "homelab:/srv/backup" \
  --filter-from=${HOME}/.config/rclone/scripts/filters.txt \
  --delete-excluded \
  > /dev/null 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    notify-send \
        --app-name="rclone" \
        --icon=network-server \
        --urgency=normal \
        --expire-time=5000 \
        "Sync Complete" "Homelab sync finished successfully"
else
    notify-send \
        --app-name="rclone" \
        --icon=dialog-error \
        --urgency=critical \
        --expire-time=0 \
        "Sync Failed" "Homelab sync exited with code $EXIT_CODE"
fi

#!/bin/bash

notify-send \
    --app-name="rclone" \
    --icon=network-server \
    --urgency=low \
    --expire-time=3000 \
    "Sync Started" "Syncing to Google Drive..."

rclone \
  --config ${HOME}/.config/rclone/rclone.conf \
  --log-level NOTICE \
  --log-file=${HOME}/.config/rclone/rclone.log \
  --progress \
  --retries 3 \
  --max-backlog 999999 \
  --buffer-size 256M \
  --tpslimit 8 \
  --transfers 4 \
  --checkers 4 \
  --drive-pacer-min-sleep 100ms \
  sync \
  --skip-links \
  --delete-during \
  ${HOME}/ \
  "google drive:framework12" \
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
        "Sync Complete" "Google Drive sync finished successfully"
else
    notify-send \
        --app-name="rclone" \
        --icon=dialog-error \
        --urgency=critical \
        --expire-time=0 \
        "Sync Failed" "Google Drive sync exited with code $EXIT_CODE"
fi

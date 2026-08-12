#!/bin/bash

MONTH_NAME=$(date +%B)
DAY_OF_MONTH=$(date +%d)
WEEK_NUM=$(( (10#$DAY_OF_MONTH + 6) / 7 ))
CURRENT_MONTH_PATTERN=$(date +%Y-%m)

/usr/bin/notify-send \
    --app-name="Timeshift" \
    --icon=drive-harddisk \
    --urgency=low \
    --expire-time=3000 \
    "Timeshift" "Creating ${MONTH_NAME} Week ${WEEK_NUM} snapshot..."

# Check if any existing snapshot is from current month
HAS_CURRENT_MONTH=$(/usr/bin/sudo /usr/bin/timeshift --list | /usr/bin/grep -c "${CURRENT_MONTH_PATTERN}")

if [ "$HAS_CURRENT_MONTH" -eq 0 ]; then
    /usr/bin/notify-send \
        --app-name="Timeshift" \
        --icon=drive-harddisk \
        --urgency=normal \
        --expire-time=5000 \
        "Timeshift" "New month detected — deleting old snapshots..."
    /usr/bin/sudo /usr/bin/timeshift --delete-all
fi

/usr/bin/sudo /usr/bin/timeshift --create --comments "${MONTH_NAME} Week ${WEEK_NUM}"

EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    /usr/bin/notify-send \
        --app-name="Timeshift" \
        --icon=dialog-error \
        --urgency=critical \
        --expire-time=0 \
        "Timeshift" "Snapshot creation failed (exit code ${EXIT_CODE})"
fi

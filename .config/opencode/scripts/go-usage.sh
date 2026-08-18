#!/bin/bash

set -euo pipefail

DB="$HOME/.local/share/opencode/opencode.db"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/go-usage"
TODAY=$(date +%F)
DAY_START_MS=$(date -d 'today 00:00:00' +%s%3N)

WARN_CENTS=150
LIMIT_CENTS=200

usage=$(sqlite3 -readonly "$DB" \
    "SELECT COALESCE(SUM(json_extract(data,'\$.cost')),0)
     FROM message
     WHERE json_extract(data,'\$.time.created') >= $DAY_START_MS
       AND json_extract(data,'\$.providerID') = 'opencode-go';")

usage_cents=$(awk -v u="$usage" 'BEGIN { printf "%d", u * 100 + 0.5 }')
usage_disp=$(printf '%.2f' "$usage")

mkdir -p "$STATE_DIR"

for f in "$STATE_DIR"/warn.* "$STATE_DIR"/limit.*; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    [ "${base##*.}" != "$TODAY" ] && rm -f "$f"
done

notify() {
    /usr/bin/notify-send \
        --app-name="OpenCode Go" \
        --icon="${1}" \
        --urgency="${2}" \
        --expire-time=8000 \
        --replace-id=9901 \
        "${3}" "${4}"
}

if [ "$usage_cents" -ge "$WARN_CENTS" ] && [ ! -e "$STATE_DIR/warn.$TODAY" ]; then
    notify "dialog-warning" "normal" "OpenCode Go" \
        "Used \$$usage_disp today (75% of \$2.00 daily budget)"
    touch "$STATE_DIR/warn.$TODAY"
fi

if [ "$usage_cents" -ge "$LIMIT_CENTS" ] && [ ! -e "$STATE_DIR/limit.$TODAY" ]; then
    notify "dialog-error" "critical" "OpenCode Go" \
        "Used \$$usage_disp today — daily budget of \$2.00 exhausted"
    touch "$STATE_DIR/limit.$TODAY"
fi

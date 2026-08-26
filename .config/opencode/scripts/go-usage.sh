#!/bin/bash

set -euo pipefail

DB="$HOME/.local/share/opencode/opencode.db"
TODAY=$(date +%F)
DAY_START_MS=$(date -d 'today 00:00:00' +%s%3N)

PRO_MONTHLY=15
FLASH_MONTHLY=30
DAYS=30
WARN_PCT=75

PRO_DAILY_CENTS=$(awk -v m="$PRO_MONTHLY" -v d="$DAYS" 'BEGIN { printf "%d", m / d * 100 + 0.5 }')
FLASH_DAILY_CENTS=$(awk -v m="$FLASH_MONTHLY" -v d="$DAYS" 'BEGIN { printf "%d", m / d * 100 + 0.5 }')
PRO_WARN_CENTS=$(awk -v c="$PRO_DAILY_CENTS" -v p="$WARN_PCT" 'BEGIN { printf "%d", c * p / 100 + 0.5 }')
FLASH_WARN_CENTS=$(awk -v c="$FLASH_DAILY_CENTS" -v p="$WARN_PCT" 'BEGIN { printf "%d", c * p / 100 + 0.5 }')

read -r pro_used flash_used < <(sqlite3 -readonly "$DB" "
    SELECT COALESCE(SUM(CASE WHEN json_extract(data,'\$.modelID')='deepseek-v4-pro'
                             THEN json_extract(data,'\$.cost') END),0),
           COALESCE(SUM(CASE WHEN json_extract(data,'\$.modelID')='deepseek-v4-flash'
                             THEN json_extract(data,'\$.cost') END),0)
    FROM message
    WHERE json_extract(data,'\$.time.created') >= $DAY_START_MS
      AND json_extract(data,'\$.providerID') = 'opencode-go';")

pro_cents=$(awk -v u="$pro_used" 'BEGIN { printf "%d", u * 100 + 0.5 }')
flash_cents=$(awk -v u="$flash_used" 'BEGIN { printf "%d", u * 100 + 0.5 }')

level_of() {
    if [ "$1" -ge "$3" ]; then
        echo critical
    elif [ "$1" -ge "$2" ]; then
        echo warn
    else
        echo ok
    fi
}

pro_level=$(level_of "$pro_cents" "$PRO_WARN_CENTS" "$PRO_DAILY_CENTS")
flash_level=$(level_of "$flash_cents" "$FLASH_WARN_CENTS" "$FLASH_DAILY_CENTS")

notify() {
    /usr/bin/notify-send \
        --app-name="OpenCode Go" \
        --icon="${1}" \
        --urgency="${2}" \
        --expire-time=8000 \
        --replace-id=9901 \
        "${3}" "${4}"
}

fmt_cents() {
    awk -v c="$1" 'BEGIN { printf "$%.2f", c / 100 }'
}

fmt_pct() {
    awk -v c="$1" -v d="$2" 'BEGIN { printf "%d%%", c / d * 100 + 0.5 }'
}

pro_suffix=""
[ "$pro_level" != ok ] && pro_suffix=" — $pro_level"
flash_suffix=""
[ "$flash_level" != ok ] && flash_suffix=" — $flash_level"

pro_line=$(printf '%-6s %s/%s  (%s)%s' \
    "pro" "$(fmt_cents "$pro_cents")" "$(fmt_cents "$PRO_DAILY_CENTS")" \
    "$(fmt_pct "$pro_cents" "$PRO_DAILY_CENTS")" "$pro_suffix")
flash_line=$(printf '%-6s %s/%s  (%s)%s' \
    "flash" "$(fmt_cents "$flash_cents")" "$(fmt_cents "$FLASH_DAILY_CENTS")" \
    "$(fmt_pct "$flash_cents" "$FLASH_DAILY_CENTS")" "$flash_suffix")

body=$(printf '%s\n%s' "$pro_line" "$flash_line")

if [ "$pro_level" = critical ] || [ "$flash_level" = critical ]; then
    notify "dialog-error" "critical" "OpenCode Go" "$body"
elif [ "$pro_level" = warn ] || [ "$flash_level" = warn ]; then
    notify "dialog-warning" "normal" "OpenCode Go" "$body"
else
    notify "dialog-information" "low" "OpenCode Go" "$body"
fi
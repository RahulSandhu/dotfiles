#!/bin/bash

set -euo pipefail

WARN_BALANCE=1.00

key=${DEEPSEEK_KEY:-}
if [ -z "$key" ]; then
    key=$(grep -E '^export DEEPSEEK_KEY=' "$HOME/.zshenv" | tail -1 | cut -d= -f2- | tr -d '"'"'"'')
fi

balance_json=$(curl -fsS https://api.deepseek.com/user/balance \
    -H "Authorization: Bearer $key") || {
    notify-send --app-name="DeepSeek" --icon=dialog-error --urgency=normal \
        --expire-time=8000 --replace-id=9902 "DeepSeek" "Could not fetch balance"
    exit 1
}

is_available=$(jq -r '.is_available' <<<"$balance_json")
currency=$(jq -r '.balance_infos[0].currency' <<<"$balance_json")
total=$(jq -r '.balance_infos[0].total_balance' <<<"$balance_json")

body="$total $currency"

if [ "$is_available" = false ] || awk -v t="$total" -v w="$WARN_BALANCE" 'BEGIN { exit !(t < w) }'; then
    notify-send --app-name="DeepSeek" --icon=dialog-warning --urgency=critical \
        --expire-time=8000 --replace-id=9902 "DeepSeek Balance low" "$body"
else
    notify-send --app-name="DeepSeek" --icon=dialog-information --urgency=normal \
        --expire-time=8000 --replace-id=9902 "DeepSeek Balance" "$body"
fi

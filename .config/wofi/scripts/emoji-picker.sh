#!/bin/bash

# Emoji picker using wofi.
# Fetches the full Unicode emoji list on first run and caches it. Selected
# glyph is copied to the clipboard via wl-copy.

PID_FILE="/tmp/wofi-emoji.pid"

if [ -f "$PID_FILE" ]; then
    exit 0
fi

echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT INT TERM

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wofi-emoji"
CACHE_FILE="$CACHE_DIR/picker.txt"
MAX_AGE_DAYS=30

needs_update() {
    if [ ! -f "$CACHE_FILE" ]; then
        return 0
    fi
    if [ -n "$(find "$CACHE_FILE" -mtime +$MAX_AGE_DAYS 2>/dev/null)" ]; then
        return 0
    fi
    return 1
}

fetch_data() {
    local tmp_file
    tmp_file=$(mktemp)

    # Full Unicode emoji list
    curl -fsSL "https://unicode.org/Public/emoji/latest/emoji-test.txt" 2>/dev/null | \
    python3 -c '
import sys, re
for line in sys.stdin:
    line = line.rstrip("\n")
    if not line or line.startswith("#"):
        continue
    parts = line.split(";")
    if len(parts) < 2:
        continue
    status = parts[1].strip().split()[0]
    if status != "fully-qualified":
        continue
    codepoints = parts[0].strip().split()
    try:
        emoji = "".join(chr(int(cp, 16)) for cp in codepoints)
    except ValueError:
        continue
    m = re.search(r"#\s+\S+\s+E[\d.]+\s+(.*)", line)
    if not m:
        continue
    desc = m.group(1).strip()
    print(f"{emoji} {desc}")
' >> "$tmp_file"

    if [ ! -s "$tmp_file" ]; then
        rm -f "$tmp_file"
        return 1
    fi

    mkdir -p "$CACHE_DIR"
    mv "$tmp_file" "$CACHE_FILE"
    return 0
}

if needs_update; then
    if ! fetch_data; then
        notify-send --app-name="Emoji Picker" --icon=dialog-error --urgency=critical "Failed" "Could not fetch emoji data. Check your internet connection."
        exit 1
    fi
fi

# Show in wofi and copy selection
selected=$(grep -v '^#' "$CACHE_FILE" 2>/dev/null | wofi --dmenu --prompt="Pick emoji:" --width 700 --height 500)

if [ -n "$selected" ]; then
    glyph=$(echo "$selected" | awk '{print $1}')
    echo -n "$glyph" | wl-copy
fi

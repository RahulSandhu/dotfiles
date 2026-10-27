#!/bin/bash

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/com.pais.handy"
LOG_FILE="$DATA_DIR/logs/handy.log"

state() {
    tail -n 2000 "$LOG_FILE" | grep -o 'icon=resources/[a-z]*\.png' | tail -1
}

history_id() {
    sqlite3 -cmd '.timeout 500' "$DATA_DIR/history.db" \
        'SELECT COALESCE(MAX(id), 0) FROM transcription_history;' 2>/dev/null
}

if ! pgrep -x handy > /dev/null; then
    handy --start-hidden &
    notify-send --app-name="Sway" --icon=media-playback-stop --urgency=normal \
        "Transcription Stopped" "Handy was not running - started it, press again to dictate"
    exit 0
fi

if [ "$(state)" = "icon=resources/recording.png" ]; then
    before=$(history_id)
    handy --toggle-transcription

    # Wait until Handy is idle again, then report where the text landed.
    for _ in {1..60}; do
        sleep 0.2
        [ "$(state)" = "icon=resources/handy.png" ] && break
    done

    id=$(history_id)
    if [ -n "$id" ] && [ "$id" -gt "${before:-0}" ]; then
        notify-send --app-name="Sway" --icon=media-playback-stop --urgency=normal \
            "Transcription Stopped" "Saved to clipboard + History #$id"
    else
        notify-send --app-name="Sway" --icon=media-playback-stop --urgency=normal \
            "Transcription Stopped" "No transcript produced - check the microphone, see $LOG_FILE"
    fi
    exit 0
fi

handy --toggle-transcription
sleep 0.4

if [ "$(state)" = "icon=resources/recording.png" ]; then
    notify-send --app-name="Sway" --icon=media-record --urgency=low \
        "Transcription Started" "Speak now, press the shortcut again to stop"
else
    notify-send --app-name="Sway" --icon=media-playback-stop --urgency=normal \
        "Transcription Stopped" "Handy did not start recording - see $LOG_FILE"
fi

#!/bin/bash

DIR="$HOME/pictures/screenshots"
mkdir -p "$DIR"

cleanup() {
    if [ -n "$WATCHER_PID" ]; then
        kill -- -"$WATCHER_PID" 2>/dev/null
    fi
}

trap cleanup EXIT INT TERM

if [[ "$1" != "full" && "$1" != "area" ]]; then
    echo "Usage: $0 {full|area}"
    exit 1
fi

BASENAME="$(date +%Y%m%d_%H%M%S)"
FILENAME="$DIR/$BASENAME.png"

CAPTURE_SUCCESS=false
case "$1" in
    full)
        grim "$FILENAME" && CAPTURE_SUCCESS=true
        ;;
    area)
        grim -g "$(slurp)" "$FILENAME" && CAPTURE_SUCCESS=true
        ;;
esac

if [ "$CAPTURE_SUCCESS" = true ]; then
    wl-copy < "$FILENAME"
    notify-send \
        --app-name="Sway" \
        --icon=camera-photo \
        --urgency=normal \
        --expire-time=5000 \
        "Screenshot Saved" "$FILENAME"
    set -m
    (
        inotifywait -m -e create --format '%f' "$HOME" | while read -r file; do
            if [[ "$file" == swappy-*.png ]]; then
                SRC="$HOME/$file"

                index=1
                while true; do
                    MODIFIED_FILE="${DIR}/${BASENAME}_modified_$(printf '%02d' $index).png"
                    [[ ! -f "$MODIFIED_FILE" ]] && break
                    ((index++))
                done

                mv "$SRC" "$MODIFIED_FILE"
                notify-send \
                    --app-name="Sway" \
                    --icon=document-save \
                    --urgency=normal \
                    --expire-time=5000 \
                    "Swappy Export" "Modified saved: $MODIFIED_FILE"
            fi
        done
    ) &
    WATCHER_PID=$!
    set +m 
    swappy --file "$FILENAME"
else
    notify-send \
        --app-name="Sway" \
        --icon=dialog-error \
        --urgency=critical \
        --expire-time=0 \
        "Screenshot Failed" "Could not capture the screen"
    exit 1
fi

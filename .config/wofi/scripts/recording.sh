#!/bin/bash

# Define the path for the recording and PID
PID_FILE="/tmp/wl_screenrec.pid"
SCREENKEY_PID_FILE="/tmp/wl_screenrec_screenkey.pid"

# Set the output directory for the recordings
OUTPUT_DIR="$HOME/videos/recordings"

# Audio source (system audio monitor)
AUDIO_SOURCE="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"

# Check if a recording is already in progress
if [ -f "$PID_FILE" ]; then
    # Stop recording
    read -r PID SAVED_PATH < "$PID_FILE"
    kill "$PID" 2>/dev/null
    rm "$PID_FILE"

    # Stop screenkey if running
    if [ -f "$SCREENKEY_PID_FILE" ]; then
        read -r SK_PID < "$SCREENKEY_PID_FILE"
        kill "$SK_PID" 2>/dev/null
        rm "$SCREENKEY_PID_FILE"
    fi

    notify-send \
        --app-name="Sway" \
        --icon=media-playback-stop \
        --urgency=normal \
        --expire-time=5000 \
        "Recording Stopped" "Saved to: $SAVED_PATH"
    exit 0
fi

# Check for a valid argument first
if [[ "$1" != "full" && "$1" != "area" ]]; then
    echo "Usage: $0 {full|area}"
    echo "(Use any argument to stop an existing recording)"
    exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate a timestamped filename for the recording
FILENAME="$(date +'%Y%m%d_%H%M%S').mp4"

# Set the full path for the output video file
FULL_PATH="$OUTPUT_DIR/$FILENAME"

# Start showmethekey to show keypresses
# Keep the overlay compact so Sway can pin it to the bottom-right corner.
gsettings set one.alynx.showmethekey width 320.0
gsettings set one.alynx.showmethekey height 100.0
gsettings set one.alynx.showmethekey timeout 200
gsettings set one.alynx.showmethekey mode 'composed'
gsettings set one.alynx.showmethekey alignment 'center'
gsettings set one.alynx.showmethekey clickable-modifier 'ctrl'
gsettings set one.alynx.showmethekey draw-border false
gsettings set one.alynx.showmethekey hide-visible false
gsettings set one.alynx.showmethekey margin-ratio 1.0
gsettings set one.alynx.showmethekey show-keyboard true
gsettings set one.alynx.showmethekey show-mouse true
gsettings set one.alynx.showmethekey show-shift true
# Ensure the overlay is not paused and disable the pause shortcut so
# modifier keys used during the demo don't accidentally stop it.
gsettings set one.alynx.showmethekey paused false
gsettings set one.alynx.showmethekey paused-modifier 'none'
showmethekey-gtk --keys-win --no-app-win --no-clickable &
echo "$!" > "$SCREENKEY_PID_FILE"

# Start recording based on argument
case "$1" in
    full)
        wl-screenrec --audio --audio-device "$AUDIO_SOURCE" -f "$FULL_PATH" &
        ;;
    area)
        wl-screenrec --audio --audio-device "$AUDIO_SOURCE" -g "$(slurp)" -f "$FULL_PATH" &
        ;;
esac

# Save PID and path to PID file
REC_PID=$!
echo "$REC_PID $FULL_PATH" > "$PID_FILE"
notify-send \
    --app-name="Sway" \
    --icon=media-record \
    --urgency=low \
    --expire-time=3000 \
    "Recording Started" "Capturing screen and audio"

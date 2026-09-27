#!/bin/bash

# Define paths 
SCRIPTS_DIR="$HOME/.config/wofi/scripts"
REC_PID_FILE="/tmp/wl_screenrec.pid"
CAST_PID_FILE="/tmp/wl_screencast.pid"

# Function to handle screenshot selection
show_screenshot_menu() {
    screenshot_type=$(printf "󰍹  Full Screen\n󰒅  Selected Area" | wofi --dmenu --prompt="Select screenshot type:")
    case "$screenshot_type" in
        "󰍹  Full Screen")
            "$SCRIPTS_DIR/screenshot.sh" full
            ;;
        "󰒅  Selected Area")
            "$SCRIPTS_DIR/screenshot.sh" area
            ;;
    esac
}

# Function to handle recording selection
show_recording_menu() {
    recording_type=$(printf "󰍹  Full Screen\n󰒅  Selected Area" | wofi --dmenu --prompt="Select recording type:")
    case "$recording_type" in
        "󰍹  Full Screen")
            "$SCRIPTS_DIR/recording.sh" full
            ;;
        "󰒅  Selected Area")
            "$SCRIPTS_DIR/recording.sh" area
            ;;
    esac
}

# Function to handle screencast selection
show_screencast_menu() {
    screencast_type=$(printf "󰍹  Full Screen\n󰒅  Selected Area" | wofi --dmenu --prompt="Select screencast type:")
    case "$screencast_type" in
        "󰍹  Full Screen")
            "$SCRIPTS_DIR/screencast.sh" full
            ;;
        "󰒅  Selected Area")
            "$SCRIPTS_DIR/screencast.sh" area
            ;;
    esac
}

# Check what mode we're in based on argument
if [[ "$1" == "display" ]]; then
    # Display/Screencast mode (mod+p / F9)
    if [ -f "$CAST_PID_FILE" ]; then
        main_choice=$(printf "󰍹  Display Settings\n󰓕  Stop Screen Cast" | wofi --dmenu --prompt="Select display action:")
        case "$main_choice" in
            "󰍹  Display Settings")
                nwg-displays
                ;;
            "󰓕  Stop Screen Cast")
                "$SCRIPTS_DIR/screencast.sh"
                ;;
        esac
    else
        main_choice=$(printf "󰍹  Display Settings\n󰑋  Start Screen Cast" | wofi --dmenu --prompt="Select display action:")
        case "$main_choice" in
            "󰍹  Display Settings")
                nwg-displays
                ;;
            "󰑋  Start Screen Cast")
                show_screencast_menu
                ;;
        esac
    fi
else
    # Default capture mode (F11 / original behavior)
    if [ -f "$REC_PID_FILE" ]; then
        main_choice=$(printf "󰹑  Screenshot\n󰓕  Stop Recording" | wofi --dmenu --prompt="Select capture action:")
        case "$main_choice" in
            "󰹑  Screenshot")
                show_screenshot_menu
                ;;
            "󰓕  Stop Recording")
                "$SCRIPTS_DIR/recording.sh"
                ;;
        esac
    else
        main_choice=$(printf "󰹑  Screenshot\n󰑋  Start Recording" | wofi --dmenu --prompt="Select capture action:")
        case "$main_choice" in
            "󰹑  Screenshot")
                show_screenshot_menu
                ;;
            "󰑋  Start Recording")
                show_recording_menu
                ;;
        esac
    fi
fi

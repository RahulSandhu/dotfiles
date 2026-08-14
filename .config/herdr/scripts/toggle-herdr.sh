#!/bin/bash

SESSION="zen"

# Check if the focused window is a terminal running herdr
focused_pid=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .pid // empty')

if [ -n "$focused_pid" ]; then
	# Recursively search the focused window's process tree for herdr
	has_herdr_descendant() {
		local pid=$1
		local children
		children=$(pgrep -P "$pid" 2>/dev/null)
		for child in $children; do
			if ps -p "$child" -o comm= 2>/dev/null | grep -qx "herdr"; then
				return 0
			fi
			if has_herdr_descendant "$child"; then
				return 0
			fi
		done
		return 1
	}

	if has_herdr_descendant "$focused_pid"; then
		# Currently attached to herdr — close the terminal window (detach)
		swaymsg kill
		exit 0
	fi
fi

# No herdr session focused — launch/create the zen session
kitty herdr --session "$SESSION"

#!/bin/bash

# Idle handling: after 10 minutes show the eye screen saver on a spare
# workspace, and tear it down as soon as there is any input.
#
# kitty's default confirm_os_window_close=-1 asks for confirmation before a
# window running a program (the screen saver counts) is closed via the window
# manager, so the screen saver instance disables that and closes instantly.

exec swayidle -w \
    timeout 600 'swaymsg workspace number 99; swaymsg "exec kitty -o confirm_os_window_close=0 --class eye-screensaver python3 ~/.config/sway/scripts/eyes.py"' \
    resume 'swaymsg "[app_id=eye-screensaver] kill"; swaymsg workspace back_and_forth; swaymsg seat seat0 cursor move 960 600'

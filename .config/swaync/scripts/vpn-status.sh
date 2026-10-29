#!/bin/bash

# Delegate to the toggle's own detection (vpn.sh --status) instead of keeping a
# second copy of the logic here: the two used to disagree because a plain
# `ip link show type tun` match also counts tailscale0, leaving the button
# permanently "on" while Tailscale was stopped.
exec "$HOME/.config/swaync/scripts/vpn.sh" --status

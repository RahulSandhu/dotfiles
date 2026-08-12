#!/bin/bash

# Check bluetooth soft block status
BT_IDX=$(rfkill | grep -i bluetooth | awk '{print $1}' | head -n 1)

# Report true if not soft blocked, false otherwise
rfkill list "$BT_IDX" | grep -q "Soft blocked: no" && echo true || echo false

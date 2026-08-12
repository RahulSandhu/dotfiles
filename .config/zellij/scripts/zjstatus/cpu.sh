#!/usr/bin/env bash

read -r _ prev_user prev_nice prev_system prev_idle prev_iowait prev_irq prev_softirq prev_steal prev_guest prev_guest_nice < /proc/stat
prev_idle_total=$((prev_idle + prev_iowait))
prev_non_idle=$((prev_user + prev_nice + prev_system + prev_irq + prev_softirq + prev_steal + prev_guest + prev_guest_nice))
prev_total=$((prev_idle_total + prev_non_idle))

sleep 0.5

read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
idle_total=$((idle + iowait))
non_idle=$((user + nice + system + irq + softirq + steal + guest + guest_nice))
total=$((idle_total + non_idle))

diff_idle=$((idle_total - prev_idle_total))
diff_total=$((total - prev_total))

if [ "$diff_total" -eq 0 ]; then
    usage=0
else
    usage=$(((diff_total - diff_idle) * 100 / diff_total))
fi

echo " ${usage}%"

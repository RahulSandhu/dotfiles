#!/usr/bin/env bash

percent=$(free | awk '/^Mem:/ { printf "%.0f", ($3 / $2) * 100 }')
echo " ${percent}%"

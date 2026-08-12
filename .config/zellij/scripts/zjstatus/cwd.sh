#!/usr/bin/env bash

max_length=30
prefix_chars=2
min_depth=3
icon=""

truncate_path() {
    local path="$1"
    local parts=()
    local truncated
    local slash_count

    if [[ ${#path} -le $max_length ]]; then
        echo "$path"
        return
    fi

    IFS='/' read -ra parts <<<"$path"
    truncated=""

    for ((i = 0; i < ${#parts[@]} - 1; i++)); do
        truncated+="${parts[i]:0:$prefix_chars}/"
    done
    truncated+="${parts[-1]}"

    if [[ ${#truncated} -le $max_length ]]; then
        echo "$truncated"
        return
    fi

    slash_count=$(tr -cd '/' <<<"$truncated" | wc -c)
    if [[ $slash_count -gt $min_depth ]]; then
        IFS='/' read -ra parts <<<"$truncated"
        echo "${parts[0]}/${parts[1]}/.../${parts[-2]}/${parts[-1]}"
    else
        echo "$truncated"
    fi
}

main() {
    local path cwd truncated_cwd

    path=$(cat /tmp/zen-shell-cwd 2>/dev/null || echo "$HOME")
    cwd="${path/"$HOME"/'~'}"
    truncated_cwd=$(truncate_path "$cwd")

    echo "$icon $truncated_cwd"
}

main

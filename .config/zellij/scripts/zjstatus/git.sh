#!/usr/bin/env bash

# Always show git status for the Shell pane's CWD (same as cwd.sh)
cd "$(cat /tmp/zen-shell-cwd 2>/dev/null || echo "$HOME")" || exit 0

repo_icon=""
diff_icon=""
added_icon=""
modified_icon=""
updated_icon=""
deleted_icon=""

is_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

get_branch() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    printf '%.20s' "$branch"
}

has_changes() {
    [ "$(git status -s)" != "" ]
}

get_changes() {
    declare -i added=0
    declare -i modified=0
    declare -i updated=0
    declare -i deleted=0

    while IFS= read -r line; do
        local status_chars="${line:0:2}"
        case "$status_chars" in
            *A*) added+=1 ;;
            *M*) modified+=1 ;;
            *U*) updated+=1 ;;
            *D*) deleted+=1 ;;
        esac
    done < <(git status -s)

    local output=""
    [ $added -gt 0 ]    && output+="${added} ${added_icon}"
    [ $modified -gt 0 ] && output+=" ${modified} ${modified_icon}"
    [ $updated -gt 0 ]  && output+=" ${updated} ${updated_icon}"
    [ $deleted -gt 0 ]  && output+=" ${deleted} ${deleted_icon}"

    echo "${output# }"
}

main() {
    if ! is_git_repo; then
        return 0
    fi

    local branch
    branch=$(get_branch)

    if has_changes; then
        local changes
        changes=$(get_changes)
        if [ -n "$changes" ]; then
            echo "$diff_icon $changes $branch"
        else
            echo "$diff_icon $branch"
        fi
    else
        echo "$repo_icon $branch"
    fi
}

main

#!/bin/bash

# Emoji and Nerd Font icon picker using wofi.
# Fetches the full Unicode emoji list on first run, then merges it with a
# curated list of commonly used Nerd Font icons. Selected glyph is copied to
# the clipboard via wl-copy.

PID_FILE="/tmp/wofi-emoji.pid"

if [ -f "$PID_FILE" ]; then
    exit 0
fi

echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT INT TERM

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wofi-emoji"
CACHE_FILE="$CACHE_DIR/picker.txt"
MAX_AGE_DAYS=30

needs_update() {
    if [ ! -f "$CACHE_FILE" ]; then
        return 0
    fi
    if [ -n "$(find "$CACHE_FILE" -mtime +$MAX_AGE_DAYS 2>/dev/null)" ]; then
        return 0
    fi
    return 1
}

fetch_data() {
    local tmp_file
    tmp_file=$(mktemp)

    # Full Unicode emoji list
    curl -fsSL "https://unicode.org/Public/emoji/latest/emoji-test.txt" 2>/dev/null | \
    python3 -c '
import sys, re
for line in sys.stdin:
    line = line.rstrip("\n")
    if not line or line.startswith("#"):
        continue
    parts = line.split(";")
    if len(parts) < 2:
        continue
    status = parts[1].strip().split()[0]
    if status != "fully-qualified":
        continue
    codepoints = parts[0].strip().split()
    try:
        emoji = "".join(chr(int(cp, 16)) for cp in codepoints)
    except ValueError:
        continue
    m = re.search(r"#\s+\S+\s+E[\d.]+\s+(.*)", line)
    if not m:
        continue
    desc = m.group(1).strip()
    print(f"{emoji} {desc}")
' >> "$tmp_file"

    # Curated list of commonly used Nerd Font icons
    cat >> "$tmp_file" << 'EOF'
󰇄 folder open
󰉋 folder
󰉎 folder multiple
󰉒 folder remove
󰉕 folder upload
󰉘 folder star
󰉠 folder picture
󰉣 folder code
󰉥 folder wrench
󰊀 file
󰊁 file plus
󰊄 file export
󰊅 file import
󰊇 file replace
󰊈 file restore
󰊊 file star
󰊚 file code
󰊛 file table
󰊝 file chart
󰊢 git
󰊣 git branch
󰊤 git commit
󰊥 git compare
󰊦 git merge
󰊧 git pull request
󰊨 github
󰊫 github full
󰊬 gitlab
󰋓 terminal
󰋔 terminal plus
󰋗 terminal variant
󰋙 console
󰋝 laptop
󰋣 monitor
󰋤 monitor multiple
󰋰 cast
󰋶 speaker
󰋸 speaker multiple
󰋺 speaker wireless
󰋻 headphones
󰌂 music
󰌇 music note
󰌒 play
󰌓 play box
󰌗 play circle outline
󰌞 pause
󰌠 pause circle
󰌤 stop
󰌨 record circle
󰌯 skip next
󰌲 skip previous
󰌵 fast forward
󰌻 rewind
󰍁 volume high
󰍂 volume low
󰍅 volume mute
󰍆 volume off
󰍉 volume variant off
󰍊 web
󰍓 webcam
󰍡 wifi
󰍢 wifi off
󰍩 wifi strength 3
󰍬 wifi strength 4
󰍹 window maximize
󰍺 window minimize
󰍻 window open
󰍿 window shutter alert
󰎁 window shutter open
󰎇 wrench
󰎳 account
󰏂 account box
󰏏 account circle
󰏿 account plus
󰐀 account plus outline
󰐏 account multiple
󰐓 account network
󰐣 home
󰐤 home account
󰐩 home assistant
󰑓 home outline
󰑢 home variant
󰑣 bell
󰑤 bell alert
󰑲 bell off
󰑹 bell ring
󰑽 book
󰒎 book open
󰒐 book cog
󰓀 bookmark
󰓅 bookmark multiple
󰓏 calendar
󰓕 calendar blank
󰓗 calendar check
󰓻 calendar today
󰓾 camera
󰔅 camera enhance
󰔚 camera switch
󰔟 card
󰕎 chat
󰕔 chat plus
󰕖 chat processing
󰕞 check
󰕡 check bold
󰕢 check circle
󰕣 check circle outline
󰕵 checkbox marked
󰕼 checkbox multiple marked
󰖈 chevron left
󰖔 chevron right
󰖙 chevron up
󰖊 chevron down
󰖼 close
󰖽 close circle
󰗆 cloud
󰗉 cloud check
󰗑 cloud upload
󰗓 cloud download
󰗡 code braces
󰗣 code brackets
󰗰 code tags
󰗻 coffee
󰗽 cog
󰘃 cog outline
󰙀 compass
󰙄 content copy
󰙅 content cut
󰙇 content paste
󰙈 content save
󰙉 content save alert
󰚒 cricket
󰚓 crop
󰛛 database
󰜑 delete
󰜒 delete alert
󰜚 delete forever
󰜞 delete outline
󰜠 delete sweep
󰛔 cursor default
󰛕 cursor pointer
󰞙 download
󰞛 download box
󰞟 download lock
󰟐 egg
󰟠 email
󰟦 email check
󰠂 email search
󰠄 email send
󰠉 emby
󰠍 engine
󰠏 epsilon
󰛏 code parenthesis
󰛐 code parenthesis box
󰑄 home group
󰑅 home group minus
󰑆 home group plus
󰑇 home group remove
󰑈 home heart
󰑒 home percent
󰑗 home remove
󰑘 home roof
󰑡 home variant outline
󰑩 home automation
󰑫 home battery
󰑬 home battery outline
󰑯 home check
󰑱 home city
󰑵 home edit
󰒀 home export outline
󰒈 home import outline
󰒉 home minus
󰒊 home plus
󰐣 lightning bolt
󰐸 home flood
󰑀 home floor 1
󰑁 home floor 2
󰑂 home floor 3
󰑋 home floor g
󰑍 home floor l
󰔇 content save cog
󰔈 content save edit
󰔊 content save minus
󰔌 content save move
󰔎 content save off
󰔐 content save plus
󰔒 content save settings
󰔔 content save sync
󰔑 content save check
󰔓 content save move outline
󰔕 content save off outline
󰔗 content save plus outline
󰔙 content save settings outline
󰔛 content save sync outline
󰔝 content save check outline
󰔡 content save edit outline
󰔣 content save cog outline
󰔥 content save minus outline
󰐿 account voice
󰑀 account voice off
󰐠 account star
󰐡 account star outline
󰐢 account switch
󰐣 account sync
󰐤 account tie
󰐥 account school
󰐦 account question
󰐧 account check
󰐨 account clock
󰐩 account cog
󰐪 account convert
󰐫 account details
󰐬 account edit
󰐭 account eye
󰐮 account filter
󰐯 account group
󰐰 account heart
󰐱 account injury
󰐲 account key
󰐳 account lock
󰐴 account minus
󰐵 account music
󰐶 account network
󰐷 account off
󰐸 account outline
󰐹 account plus
󰐺 account remove
󰐻 account school
󰐼 account search
󰐽 account settings
󰐾 account supervisor
󰐿 account switch
󰑀 account tie
󰑁 account tie hat
󰑂 account tie outline
󰑃 account tie voice
󰑄 account tie voice off
󰑅 account tie woman
󰑆 account voice
󰑇 account voice off
󰑈 account wrench
󰅼 linux
󰣃 archlinux
󰣳 almalinux
󰣷 artixlinux
󰣻 arcolinux
󰣼 biglinux
󰣽 debian
󰣾 fedora
󰣿 gentoo
󰤀 kali
󰤁 linuxmint
󰤂 manjaro
󰤃 nixos
󰤄 opensuse
󰤅 pop_os
󰤆 raspberry_pi
󰤅 rockylinux
󰤈 slackware
󰤉 ubuntu
󰤊 void
󰌠 apple
󰮧 docker
󰛳 dot_net
󰻿 nginx
󰜯 nodejs
󰚼 npm
󰛟 python
󰛠 ruby
󰜎 rust
󰛝 typescript
󰛞 vim
󰛟 vscode
󰛠 vuejs
󰛡 webpack
󰛢 yarn
󰛣 angular
󰛤 react
󰛥 svelte
󰛦 tailwind
󰛧 bootstrap
󰛨 css3
󰛩 html5
󰛪 java
󰛫 javascript
󰛬 json
󰛭 kotlin
󰛮 markdown
󰛯 php
󰛰 swift
󰛱 tor
󰛲 webstorm
󰛳 windows
󰛴 wordpress
󰛵 android
󰛶 c
󰛷 cpp
󰛸 haskell
󰛹 lua
󰛺 perl
󰛻 scala
󰛼 shell
󰛽 sql
󰛾 go
󰛿 kotlin
󰜀 flutter
󰜁 dart
󰜂 elixir
󰜃 erlang
󰜄 graphql
󰜅 julia
󰜆 latex
󰜇 lua
󰜈 ocaml
󰜉 pony
󰜊 rlang
󰜋 reasonml
󰜌 vim
󰜍 neovim
󰜎 emacs
󰜏 sublime
󰜐 atom
󰜑 jetbrains
󰜒 pycharm
󰜓 intellij
󰜔 phpstorm
󰜕 rubymine
󰜖 clion
󰜗 goland
󰜘 rider
󰜙 datagrip
󰜚 appcode
󰜛 fleet
󰜜 helix
󰜝 lunarvim
󰜞 spacemacs
󰜟 doom
EOF

    if [ ! -s "$tmp_file" ]; then
        rm -f "$tmp_file"
        return 1
    fi

    mkdir -p "$CACHE_DIR"
    mv "$tmp_file" "$CACHE_FILE"
    return 0
}

if needs_update; then
    if ! fetch_data; then
        notify-send --app-name="Emoji Picker" --icon=dialog-error --urgency=critical "Failed" "Could not fetch emoji data. Check your internet connection."
        exit 1
    fi
fi

# Show in wofi and copy selection
selected=$(grep -v '^#' "$CACHE_FILE" 2>/dev/null | wofi --dmenu --prompt="Pick emoji/icon:" --width 700 --height 500)

if [ -n "$selected" ]; then
    glyph=$(echo "$selected" | awk '{print $1}')
    echo -n "$glyph" | wl-copy
fi

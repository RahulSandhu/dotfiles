#!/bin/bash

grim -g "$(slurp -p)" -t ppm - \
    | convert - -format '%[pixel:p{0,0}]' txt:- \
    | tail -n 1 \
    | cut -d ' ' -f 4 \
    | tee >(wl-copy) \
    | xargs -I {} notify-send --app-name="Sway" --icon=applications-graphics --urgency=low --expire-time=3000 "Color Picked" "<b>{}</b> copied to clipboard"

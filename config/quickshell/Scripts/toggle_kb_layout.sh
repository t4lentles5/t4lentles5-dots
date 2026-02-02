#!/bin/bash

CURRENT_LAYOUT=$(hyprctl getoption input:kb_layout -j | jq -r '.str')
CURRENT_LAYOUT=$(echo "$CURRENT_LAYOUT" | xargs)

if [[ "$CURRENT_LAYOUT" == "us" ]]; then
    NEW_LAYOUT="es"
else
    NEW_LAYOUT="us"
fi

hyprctl keyword input:kb_layout "$NEW_LAYOUT"

notify-send "Keyboard Layout" "Switched to $NEW_LAYOUT" -i input-keyboard -t 1500

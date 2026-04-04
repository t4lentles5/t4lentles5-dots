#!/bin/bash

CURRENT_LAYOUT=$(hyprctl getoption input:kb_layout -j | jq -r '.str')
CURRENT_LAYOUT=$(echo "$CURRENT_LAYOUT" | xargs)
ICON_PATH="/usr/share/icons/Tela-circle-dracula-dark/22/devices/input-keyboard.svg"

if [[ "$CURRENT_LAYOUT" == "latam" ]]; then
  NEW_LAYOUT="us"
else
  NEW_LAYOUT="latam"
fi

hyprctl keyword input:kb_layout "$NEW_LAYOUT"

notify-send -i "$ICON_PATH" "Keyboard Layout" "Switched to $NEW_LAYOUT"

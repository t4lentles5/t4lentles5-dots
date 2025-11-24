#!/bin/bash

ROFI_THEME="$HOME/.config/rofi/themes/keyboard-layout.rasi"
PROMPT="Keyboard Layout"
LAYOUT_CODES=("us" "es" "de" "fr" "br" "ru")
LAYOUT_NAMES=("English (US)" "Spanish (Latam)" "German" "French" "Portuguese (BR)" "Russian")

current_layout=$(hyprctl getoption input:kb_layout -j | jq -r '.str')

selected_index=0
for i in "${!LAYOUT_CODES[@]}"; do
  if [[ "${LAYOUT_CODES[$i]}" == "$current_layout" ]]; then
    selected_index=$i
    break
  fi
done

selected_name=$(printf "%s\n" "${LAYOUT_NAMES[@]}" | rofi -dmenu -p "$PROMPT" -theme "$ROFI_THEME" -selected-row "$selected_index")

[ -z "$selected_name" ] && exit 0

for i in "${!LAYOUT_NAMES[@]}"; do
  if [[ "${LAYOUT_NAMES[$i]}" == "$selected_name" ]]; then
    layout_code=${LAYOUT_CODES[$i]}
    break
  fi
done

hyprctl keyword input:kb_layout "$layout_code"

notify-send "     $selected_name"

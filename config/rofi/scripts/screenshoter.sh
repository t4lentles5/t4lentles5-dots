#!/bin/bash

TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
DIR="$HOME/Pictures/ScreenShots"
FILENAME="$DIR/Shot-${TIMESTAMP}.png"
ROFI_THEME="$HOME/.config/rofi/themes/screenshot.rasi"
PROMPT="Screenshot"

s_full=""
s_select="󰆞"
s_window=""
s_in3="󰔝"
s_in3select="󰆞 󰔝"

rofi_cmd() {
  rofi -dmenu \
    -p "$PROMPT" \
    -mesg "Directory :: $DIR" \
    -theme "$ROFI_THEME"
}

run_rofi() {
  printf "%s\n%s\n%s\n%s\n%s\n" "$s_full" "$s_select" "$s_window" "$s_in3" "$s_in3select" | rofi_cmd
}

show_notification() {
  if [ -e "$FILENAME" ]; then
    dunstify -r 699 -i "$FILENAME" "Screenshot" "Screenshot saved and copied to clipboard"
  else
    dunstify -r 699 -i user-trash "Screenshot" "Screenshot Canceled"
  fi
}

countdown() {
  for sec in $(seq "$1" -1 1); do
    dunstify -r 345 -t 1100 "Taking shot in : $sec"
    sleep 1
  done
}

take_screenshot() {
  mkdir -p "$DIR"

  case "$1" in
  "full")
    grim "$FILENAME"
    ;;
  "select")
    grim -g "$(slurp)" "$FILENAME"
    ;;
  "window")
    BORDER_SIZE=3
    BORDER_ADJUSTMENT=$((BORDER_SIZE * 2))
    WINDOW_GEOMETRY=$(
      hyprctl activewindow -j | jq -r --argjson offset "$BORDER_SIZE" --argjson size_adj "$BORDER_ADJUSTMENT" \
        '"\(.at[0] - $offset),\(.at[1] - $offset) \(.size[0] + $size_adj)x\(.size[1] + $size_adj)"' 2>/dev/null
    )

    if [ -z "$WINDOW_GEOMETRY" ]; then
      dunstify -r 699 -i user-trash "Screenshot" "Screenshot Canceled: No active window found."
      return
    fi

    grim -g "$WINDOW_GEOMETRY" "$FILENAME"
    ;;
  esac

  if [ "$?" -eq 0 ]; then
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga >/dev/null 2>&1
    wl-copy <"$FILENAME"
    show_notification
  else
    show_notification
  fi
}

main() {
  select_option="$(run_rofi)"

  if [ -z "$select_option" ]; then
    exit 0
  fi

  sleep 0.5

  case ${select_option} in
  "$s_full")
    take_screenshot "full"
    ;;
  "$s_select")
    take_screenshot "select"
    ;;
  "$s_window")
    take_screenshot "window"
    ;;
  "$s_in3")
    countdown 3 && take_screenshot "full"
    ;;
  "$s_in3select")
    countdown 3 && take_screenshot "select"
    ;;
  esac
}

main


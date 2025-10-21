#!/bin/bash

timestamp=$(date +%Y-%m-%d-%H%M%S)
dir="$HOME/Pictures/ScreenShots"
filename="$dir/Shot-${timestamp}.png"

mkdir -p "$dir"

BORDER_SIZE=3
BORDER_ADJUSTMENT=$((BORDER_SIZE * 2))

s_full=" "
s_select="󰆞 "
s_window=" "
s_in3="󰔝 "
s_in3select="󰆞 󰔝 "

rofi_cmd() {
  rofi -dmenu \
    -p Screenshot \
    -mesg "Directory :: $dir" \
    -theme "$HOME/.config/rofi/themes/screenshot.rasi"
}

run_rofi() {
  printf "%s\n%s\n%s\n%s\n%s\n" "$s_full" "$s_select" "$s_window" "$s_in3" "$s_in3select" | rofi_cmd
}

show_notification() {
  if [ -e "$filename" ]; then
    dunstify -r 699 -i "$filename" "Screenshot" "Screenshot saved and copied to clipboard"
  else
    dunstify -r 699 -i user-trash "Screenshot" "Screenshot Canceled"
  fi
}

copy_screenshot() {
  wl-copy <"$filename"
}

take_screenshot() {
  mode="$1"

  case "$mode" in
  "full")
    grim "$filename"
    ;;
  "select")
    grim -g "$(slurp)" "$filename"
    ;;
  "window")
    WINDOW_GEOMETRY=$(
      hyprctl activewindow -j | jq -r --argjson offset "$BORDER_SIZE" --argjson size_adj "$BORDER_ADJUSTMENT" \
        '"\(.at[0] - $offset),\(.at[1] - $offset) \(.size[0] + $size_adj)x\(.size[1] + $size_adj)"' 2>/dev/null
    )

    if [ -z "$WINDOW_GEOMETRY" ]; then
      dunstify -r 699 -i user-trash "Screenshot" "Screenshot Canceled: No active window found."
      return
    fi

    grim -g "$WINDOW_GEOMETRY" "$filename"
    ;;
  esac

  if [ "$?" -eq 0 ]; then
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga >/dev/null 2>&1
    copy_screenshot
    show_notification
  else
    show_notification
  fi
}

countdown() {
  for sec in $(seq "$1" -1 1); do
    dunstify -r 345 -t 1100 -i ~/.config/rofi/assets/icon.png "Taking shot in : $sec"
    sleep 1
  done
}

run_cmd() {
  case $1 in
  --now)
    take_screenshot "full"
    ;;
  --sel)
    take_screenshot "select"
    ;;
  --win)
    take_screenshot "window"
    ;;
  --in3)
    countdown 3 && take_screenshot "full"
    ;;
  --in3select)
    countdown 3 && take_screenshot "select"
    ;;
  esac
}

select_option="$(run_rofi)"

if [ -n "$select_option" ]; then
  sleep 0.5
fi

case ${select_option} in
"$s_full") run_cmd --now ;;
"$s_select") run_cmd --sel ;;
"$s_window") run_cmd --win ;;
"$s_in3") run_cmd --in3 ;;
"$s_in3select") run_cmd --in3select ;;
esac

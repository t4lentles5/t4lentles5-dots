#!/bin/bash

export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export XDG_CURRENT_DESKTOP=Hyprland

MODE="$1"
DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
FILENAME="$DIR/Shot-${TIMESTAMP}.png"
LOG="/tmp/screenshot_debug.log"
ICON_PATH="/usr/share/icons/Tela-circle-dracula-dark/scalable/apps/accessories-screenshot.svg"

mkdir -p "$DIR"

pkill -x slurp 2>/dev/null

show_notification() {
  if [ -f "$FILENAME" ]; then
    notify-send -r 699 -i "$FILENAME" "Screenshot" "Copied to clipboard"
  else
    notify-send -r 699 -i "$ICON_PATH" "Screenshot" "Canceled"
  fi
}

play_sound() {
  if command -v paplay &>/dev/null; then
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga >/dev/null 2>&1
  fi
}

take_screenshot() {
  sleep 0.5

  case "$1" in
  "full")
    grim "$FILENAME" >>"$LOG" 2>&1
    ;;

  "area" | "select")
    TIMEOUT=20
    COUNT=0
    GEOM=""

    while [ $COUNT -lt $TIMEOUT ]; do
      GEOM=$(slurp -d 2>>"$LOG")
      RET=$?

      if [ $RET -eq 0 ] && [ -n "$GEOM" ]; then
        break
      fi

      sleep 0.1
      COUNT=$((COUNT + 1))
    done

    if [ -n "$GEOM" ]; then
      grim -g "$GEOM" "$FILENAME" >>"$LOG" 2>&1
    else
      echo "Slurp timed out or canceled" >>"$LOG"
      return 1
    fi
    ;;

  "window")
    sleep 0.5
    RAW_JSON=$(hyprctl activewindow -j 2>>"$LOG")
    WINDOW_GEOMETRY=$(echo "$RAW_JSON" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

    if [ -n "$WINDOW_GEOMETRY" ] && [ "$WINDOW_GEOMETRY" != "null" ]; then
      grim -g "$WINDOW_GEOMETRY" "$FILENAME" >>"$LOG" 2>&1
    else
      return 1
    fi
    ;;
  esac
}

case "$MODE" in
"full_delay" | "area_delay")
  NOTIFY_ID=$(notify-send -p -i "$ICON_PATH" -t 5000 "Screenshot" "Taking shot in 5 seconds...")
  sleep 1
  SILENT=false
  for i in {4..1}; do
    if [ "$SILENT" = false ]; then
      NEW_ID=$(notify-send -p -r $NOTIFY_ID -i "$ICON_PATH" -t 5000 "Screenshot" "Taking shot in $i seconds..." 2>/dev/null)
      if [ -z "$NEW_ID" ] || [ "$NEW_ID" != "$NOTIFY_ID" ]; then
        if [ -n "$NEW_ID" ]; then
          gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.CloseNotification $NEW_ID >/dev/null 2>&1
        fi
        SILENT=true
      fi
    fi
    sleep 1
  done
  gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.CloseNotification $NOTIFY_ID >/dev/null 2>&1
  sleep 0.1
  ACTUAL_MODE=${MODE%_delay}
  take_screenshot "$ACTUAL_MODE"
  ;;
"clipboard")
  sleep 0.5
  GEOM=$(slurp -d 2>>"$LOG")
  if [ -n "$GEOM" ]; then
    grim -g "$GEOM" - | wl-copy --type image/png
    play_sound
    notify-send -r 699 -i "$ICON_PATH" "Screenshot" "Area copied to clipboard"
  else
    notify-send -r 699 -i "$ICON_PATH" "Screenshot" "Canceled"
  fi
  exit 0
  ;;
*)
  take_screenshot "$MODE"
  ;;
esac

if [ $? -eq 0 ] && [ -f "$FILENAME" ]; then
  play_sound
  wl-copy <"$FILENAME"
  show_notification
else
  show_notification
fi

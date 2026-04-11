#!/bin/bash

ICON_DIR="/usr/share/icons/Tela-circle-dracula-dark/22/panel"

if [ -f "/tmp/brightness_notification_id" ]; then
  NOTIFY_ID=$(cat "/tmp/brightness_notification_id")
else
  NOTIFY_ID=0
fi

MIN_BRIGHTNESS=5

CURRENT=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')

case "$1" in
up)
  if [ "$CURRENT" -ge 100 ]; then
    exit 0
  fi
  brightnessctl set 5%+
  ;;
down)
  if [ "$CURRENT" -le "$MIN_BRIGHTNESS" ]; then
    exit 0
  elif [ $((CURRENT - 5)) -lt "$MIN_BRIGHTNESS" ]; then
    brightnessctl set "${MIN_BRIGHTNESS}%"
  else
    brightnessctl set 5%-
  fi
  ;;
esac

BRIGHTNESS=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')

if [ "$BRIGHTNESS" -le 30 ]; then
  ICON="$ICON_DIR/brightness-low.svg"
else
  ICON="$ICON_DIR/brightness-high.svg"
fi

notify-send -p -r "$NOTIFY_ID" -t 1500 -i "$ICON" -h int:value:"$BRIGHTNESS" "Brightness" "${BRIGHTNESS}%" >"/tmp/brightness_notification_id"

#!/bin/bash

ICON_DIR="/usr/share/icons/Tela-circle-dracula-dark/22/panel"

if [ -f "/tmp/volume_notification_id" ]; then
  NOTIFY_ID=$(cat "/tmp/volume_notification_id")
else
  NOTIFY_ID=0
fi

PREV_VOL_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
PREV_VOL=$(echo "$PREV_VOL_INFO" | awk '{printf "%.0f", $2 * 100}')

case "$1" in
up)
  if [ "$PREV_VOL" -ge 100 ]; then
    exit 0
  fi
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0
  ;;
down)
  if [ "$PREV_VOL" -le 0 ]; then
    exit 0
  fi
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
  ;;
mute)
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  ;;
mic-mute)
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
  ;;
esac

VOLUME_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOLUME=$(echo "$VOLUME_INFO" | awk '{printf "%.0f", $2 * 100}')
MUTED=$(echo "$VOLUME_INFO" | grep -q "MUTED" && echo "yes" || echo "no")

if [ "$1" = "mic-mute" ]; then
  if [ -f "/tmp/mic_notification_id" ]; then
    MIC_NOTIFY_ID=$(cat "/tmp/mic_notification_id")
  else
    MIC_NOTIFY_ID=0
  fi
  MIC_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
  MIC_MUTED=$(echo "$MIC_INFO" | grep -q "MUTED" && echo "yes" || echo "no")
  if [ "$MIC_MUTED" = "yes" ]; then
    notify-send -p -r "$MIC_NOTIFY_ID" -t 1500 -i "$ICON_DIR/microphone-sensitivity-muted.svg" "Microphone" "Muted" >"/tmp/mic_notification_id"
  else
    notify-send -p -r "$MIC_NOTIFY_ID" -t 1500 -i "$ICON_DIR/microphone-sensitivity-high.svg" "Microphone" "Unmuted" >"/tmp/mic_notification_id"
  fi
  exit 0
fi

if [ "$MUTED" = "yes" ]; then
  ICON="$ICON_DIR/audio-volume-muted.svg"
  TEXT="Muted"
elif [ "$VOLUME" -le 30 ]; then
  ICON="$ICON_DIR/audio-volume-low.svg"
  TEXT="${VOLUME}%"
elif [ "$VOLUME" -le 70 ]; then
  ICON="$ICON_DIR/audio-volume-medium.svg"
  TEXT="${VOLUME}%"
else
  ICON="$ICON_DIR/audio-volume-high.svg"
  TEXT="${VOLUME}%"
fi

notify-send -p -r "$NOTIFY_ID" -t 1500 -i "$ICON" -h int:value:"$VOLUME" "Volume" "$TEXT" >"/tmp/volume_notification_id"

#!/bin/bash

truncate_text() {
  local text="$1"
  if [ $(printf "%s" "$text" | wc -m) -gt 20 ]; then
    printf "%.15s..." "$text"
  else
    printf "%s" "$text"
  fi
}

players=$(playerctl -l 2>/dev/null)

for player in $players; do
  if [ "$player" = "spotify" ]; then
    artist=$(playerctl -p "$player" metadata xesam:artist 2>/dev/null)
    title=$(playerctl -p "$player" metadata xesam:title 2>/dev/null)

    if [ -n "$artist" ] && [ -n "$title" ]; then
      artist=$(truncate_text "$artist")
      title=$(truncate_text "$title")
      echo " [ $artist - $title ]" | sed 's/&/&amp;/g'
      exit 0
    fi

  elif echo "$player" | grep -qE "chromium"; then
    artist=$(playerctl -p "$player" metadata xesam:artist 2>/dev/null)
    title=$(playerctl -p "$player" metadata xesam:title 2>/dev/null)

    if [ -n "$title" ]; then
      artist=$(truncate_text "${artist:-Unknown}")
      title=$(truncate_text "$title")
      echo " [ $artist - $title ]" | sed 's/&/&amp;/g'
      exit 0
    fi
  fi
done

echo " [ No music ]"
exit 0

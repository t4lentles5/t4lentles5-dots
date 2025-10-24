#!/bin/bash

ICON_OK=" "
ICON_UPDATE=" "
ICON_ERROR=" "

updates_pacman=$(timeout 10 checkupdates 2>/dev/null)
updates_aur=$(timeout 10 yay -Qua 2>/dev/null)

if [ -n "$updates_pacman" ]; then
  count_pacman=$(echo "$updates_pacman" | wc -l)
else
  count_pacman=0
fi

if [ -n "$updates_aur" ]; then
  count_aur=$(echo "$updates_aur" | wc -l)
else
  count_aur=0
fi

total_updates=$((count_pacman + count_aur))

if [[ "$total_updates" -eq 0 ]]; then
  echo "$ICON_OK Updated"
else
  echo "$ICON_UPDATE $total_updates ($count_pacman/$count_aur)"
fi
#!/bin/bash

LAST_LOGIN="$(last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7)"
UPTIME="$(uptime -p | sed -e 's/up //g')"
ROFI_THEME="$HOME/.config/rofi/themes/power-menu.rasi"
PROMPT="Power Menu"

shutdown=''
reboot='󰜉'
lock='󰍁'
suspend=''
logout='󰗽'
yes='Yes'
no='No'

rofi_cmd() {
  rofi -dmenu \
    -p "$PROMPT" \
    -mesg "󰍹 Last Login: $LAST_LOGIN |  Uptime: $UPTIME" \
    -theme "$ROFI_THEME"
}

confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
    -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1; margin: 15px;}' \
    -theme-str 'message {margin: 15px 15px 0 15px;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you sure?' \
    -theme "$ROFI_THEME"
}

confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    case "$1" in
    --shutdown)
      systemctl poweroff
      ;;
    --reboot)
      systemctl reboot
      ;;
    --suspend)
      mpc -q pause 2>/dev/null
      amixer set Master mute 2>/dev/null
      systemctl suspend
      ;;
    --logout)
      hyprctl dispatch exit
      ;;
    esac
  else
    exit 0
  fi
}

main() {
  chosen="$(run_rofi)"
  case ${chosen} in
  "$shutdown")
    run_cmd --shutdown
    ;;
  "$reboot")
    run_cmd --reboot
    ;;
  "$lock")
    hyprlock
    ;;
  "$suspend")
    run_cmd --suspend
    ;;
  "$logout")
    run_cmd --logout
    ;;
  esac
}

main


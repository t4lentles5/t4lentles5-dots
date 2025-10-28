#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper_thumbs"
CURRENT_WALLPAPER="$HOME/.config/wallpaper/current"
PROMPT="Wallpaper Selector"
ROFI_THEME="$HOME/.config/rofi/themes/wall-select.rasi"

generate_thumbnail() {
  local img="$1"
  local name
  name="$(basename "$img")"
  local thumb="$CACHE_DIR/$name"
  local hash_file="$CACHE_DIR/.$name.md5"

  local current_hash
  current_hash=$(xxh64sum "$img" | cut -d' ' -f1)

  if [[ ! -f "$thumb" || ! -f "$hash_file" || "$current_hash" != "$(cat "$hash_file")" ]]; then
    magick "$img" -resize 300x300^ -gravity center -extent 300x300 "$thumb"
    echo "$current_hash" >"$hash_file"
  fi
}

generate_thumbnails() {
  mkdir -p "$CACHE_DIR"
  find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r img; do
    generate_thumbnail "$img" &
  done
  wait
}

run_rofi() {
  find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) |
    sort |
    while read -r img; do
      name=$(basename "$img")
      echo -e "$img\0icon\x1f$CACHE_DIR/$name"
    done |
    rofi -dmenu -p "$PROMPT" -theme "$ROFI_THEME"
}

set_wallpaper() {
  local selection="$1"
  if [[ -n "$selection" ]]; then
    swww img "$selection" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90
    echo "$selection" >"$CURRENT_WALLPAPER"
  fi
}

main() {
  generate_thumbnails
  selection=$(run_rofi)
  set_wallpaper "$selection"
}

main

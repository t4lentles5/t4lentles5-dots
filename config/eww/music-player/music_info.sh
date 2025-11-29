#!/usr/bin/bash

PLAYER="spotify,chromium"

title=$(playerctl --player=$PLAYER metadata title 2>/dev/null)
artist=$(playerctl --player=$PLAYER metadata artist 2>/dev/null)
status=$(playerctl --player=$PLAYER status 2>/dev/null)

if [[ -z "$status" ]] || [[ "$status" == "Stopped" ]]; then
  echo '{"title": "Not Playing", "artist": "No Artist", "status": "Stopped", "art": ""}'
  exit 0
fi

art_url=$(playerctl --player=$PLAYER metadata mpris:artUrl 2>/dev/null)
[[ -z "$art_url" ]] && art_url=$(playerctl --player=$PLAYER metadata xesam:artUrl 2>/dev/null)
[[ -z "$art_url" ]] && art_url=$(playerctl --player=$PLAYER metadata vlc:artUrl 2>/dev/null)

CACHE_DIR="$HOME/.cache/music-art"
mkdir -p "$CACHE_DIR"

art=""

if [[ "$art_url" =~ ^https?:// ]]; then
  hash_name=$(echo -n "$art_url" | md5sum | awk '{print $1}')
  art_file="$CACHE_DIR/$hash_name.jpg"
  
  if [[ ! -f "$art_file" ]]; then
    curl -sL "$art_url" -o "$art_file"
  fi
  
  art="$art_file"

elif [[ "$art_url" =~ ^file:// ]]; then
  art="${art_url#file://}"

elif [[ "$art_url" =~ ^image:// ]]; then
  raw="${art_url#image://}"
  clean="${raw/\?*/}" 
  full_url="https://i.scdn.co/image/$clean"

  hash_name=$(echo -n "$full_url" | md5sum | awk '{print $1}')
  art_file="$CACHE_DIR/$hash_name.jpg"

  if [[ ! -f "$art_file" ]]; then
    curl -sL "$full_url" -o "$art_file"
  fi

  art="$art_file"
fi

jq -n \
  --arg title "$title" \
  --arg artist "$artist" \
  --arg status "$status" \
  --arg art "$art" \
  '{
    title: $title,
    artist: $artist,
    status: $status,
    art: $art
  }'
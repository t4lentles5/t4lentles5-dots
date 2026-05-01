#!/bin/bash

export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export XDG_CURRENT_DESKTOP=Hyprland
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}

LABEL="$1"
shift
CMD=("$@")

ICON_DIR="/usr/share/icons/Tela-circle-dracula-dark/22/actions"
CASE_ICON="system-shutdown.svg"

case "$LABEL" in
"shutdown") CASE_ICON="system-shutdown.svg" ;;
"reboot") CASE_ICON="system-reboot.svg" ;;
"suspend") CASE_ICON="system-suspend.svg" ;;
"logout") CASE_ICON="xfsm-logout.svg" ;;
esac

ICON_PATH="$ICON_DIR/$CASE_ICON"

ACCEPT=false
trap 'ACCEPT=true' USR1

trap 'exit 0' TERM INT

LOG="/tmp/quickshell_power.log"
echo "$(date): Action triggered: ${LABEL}" >"$LOG"

NOTIFY_ID=$(notify-send -p -i "$ICON_PATH" -t 11000 "Power Menu" "Confirming ${LABEL} in 10 seconds...")

if [ -z "$NOTIFY_ID" ]; then

  echo "$(date): Fallback triggered (no ID)" >>"$LOG"
  notify-send -i "$ICON_PATH" -t 11000 "Power Menu" "Confirming ${LABEL} in 10 seconds..."
  sleep 10
  "${CMD[@]}"
  exit 0
fi

SILENT=false
for i in {9..1}; do
  if [ "$ACCEPT" = true ]; then
    echo "$(date): Accepted via signal" >>"$LOG"
    break
  fi
  sleep 1 &
  wait $!
  if [ "$ACCEPT" = true ]; then
    echo "$(date): Accepted via signal after wait" >>"$LOG"
    break
  fi
  if [ "$SILENT" = false ]; then
    NEW_ID=$(notify-send -p -r $NOTIFY_ID -i "$ICON_PATH" -t 11000 "Power Menu" "Confirming ${LABEL} in ${i} seconds..." 2>/dev/null)
    if [ -z "$NEW_ID" ] || [ "$NEW_ID" != "$NOTIFY_ID" ]; then
      echo "$(date): Dismissed by user, continuing silently" >>"$LOG"
      if [ -n "$NEW_ID" ]; then
        gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.CloseNotification $NEW_ID >/dev/null 2>&1
      fi
      SILENT=true
    fi
  fi
done

echo "$(date): Executing: ${CMD[*]}" >>"$LOG"

gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.CloseNotification \
  $NOTIFY_ID >/dev/null 2>&1

"${CMD[@]}"

#!/usr/bin/env bash
set -euo pipefail

SOCKET_PATH="/workspaces/minecraft/playitd.sock"
SECRET_PATH="/workspaces/srv/playit.toml"
LOG_PATH="/workspaces/minecraft/playit.log"
OUT_PATH="/workspaces/minecraft/playit.out"

if playit --socket-path="$SOCKET_PATH" status 2>/dev/null | grep -q "Phase: running"; then
  echo "playitd is already running:"
  playit --socket-path="$SOCKET_PATH" status
  exit 0
fi

if [ -S "$SOCKET_PATH" ]; then
  rm -f "$SOCKET_PATH"
fi

setsid -f playitd \
  --socket-path="$SOCKET_PATH" \
  --secret-path="$SECRET_PATH" \
  --log-path="$LOG_PATH" \
  > "$OUT_PATH" 2>&1

echo "Started playitd. Waiting for connection..."
for _ in $(seq 1 20); do
  if playit --socket-path="$SOCKET_PATH" status 2>/dev/null | grep -q "Phase: running"; then
    playit --socket-path="$SOCKET_PATH" status
    echo
    echo "Latest connection log:"
    grep "playit connected" "$LOG_PATH" | tail -n 1 || true
    exit 0
  fi
  sleep 1
done

echo "playitd did not become reachable within 20 seconds."
echo "Check logs with: tail -n 80 $LOG_PATH"
exit 1

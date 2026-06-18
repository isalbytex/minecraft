#!/usr/bin/env bash
set -euo pipefail

interval_seconds="${1:-600}"
pid_file="/tmp/minecraft-auto-backup.pid"
log_file="${BACKUP_LOG:-/tmp/minecraft-auto-backup.log}"

if [[ -f "$pid_file" ]]; then
  old_pid="$(cat "$pid_file")"
  if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
    echo "Auto-backup sudah jalan dengan PID $old_pid."
    echo "Log: $log_file"
    exit 0
  fi
fi

setsid -f /workspaces/minecraft/auto-backup-loop.sh "$interval_seconds"

sleep 1
new_pid="$(pgrep -f "/workspaces/minecraft/auto-backup-loop.sh $interval_seconds" | tail -1 || true)"

if [[ -n "$new_pid" ]]; then
  echo "$new_pid" > "$pid_file"
  echo "Auto-backup jalan tiap ${interval_seconds} detik. PID: $new_pid"
  echo "Log: $log_file"
else
  echo "Gagal menemukan proses auto-backup setelah start."
  exit 1
fi

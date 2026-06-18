#!/usr/bin/env bash
set -euo pipefail

interval_seconds="${1:-600}"
log_file="${BACKUP_LOG:-/tmp/minecraft-auto-backup.log}"

while true; do
  {
    echo "===== $(date '+%Y-%m-%d %H:%M:%S %Z') ====="
    /workspaces/minecraft/backup-now.sh
  } >>"$log_file" 2>&1 || true

  sleep "$interval_seconds"
done

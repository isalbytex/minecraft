#!/usr/bin/env bash
set -euo pipefail

repo_dir="/workspaces/minecraft"
branch="${BACKUP_BRANCH:-main}"

cd "$repo_dir"

git_cmd=(git -c safe.directory="$repo_dir")

message="$(date +'backup time %A %d %B %Y %H:%M:%S %Z')"

"${git_cmd[@]}" add -A

if "${git_cmd[@]}" diff --cached --quiet; then
  echo "Tidak ada perubahan untuk di-backup."
  exit 0
fi

"${git_cmd[@]}" commit -m "$message"
"${git_cmd[@]}" push origin "$branch"

echo "Backup selesai: $message"

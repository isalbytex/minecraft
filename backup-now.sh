#!/usr/bin/env bash
set -euo pipefail

repo_dir="/workspaces/minecraft"
branch="${BACKUP_BRANCH:-main}"
token_file="${GITHUB_TOKEN_FILE:-/workspaces/srv/github-token}"
lock_file="${BACKUP_LOCK:-/workspaces/srv/minecraft-auto-backup.lock}"

cd "$repo_dir"

git_cmd=(git -c safe.directory="$repo_dir")

message="$(date +'backup time %A %d %B %Y %H:%M:%S %Z')"

exec 9>"$lock_file"
if ! flock -n 9; then
  echo "Backup lain masih berjalan, skip."
  exit 0
fi

add_ok=0
for attempt in 1 2 3 4 5; do
  if "${git_cmd[@]}" add -A --ignore-errors; then
    add_ok=1
    break
  fi

  echo "git add gagal karena file berubah saat dibaca. Retry $attempt/5..."
  sleep 5
done

if [[ "$add_ok" != "1" ]]; then
  echo "Gagal staging perubahan setelah 5 percobaan."
  exit 1
fi

if "${git_cmd[@]}" diff --cached --quiet; then
  echo "Tidak ada perubahan untuk di-backup."
  exit 0
fi

"${git_cmd[@]}" commit -m "$message"

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  token="$GITHUB_TOKEN"
elif [[ -s "$token_file" ]]; then
  token="$(tr -d '\r\n' < "$token_file")"
else
  token=""
fi

if [[ -n "$token" ]]; then
  auth_header="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$token" | base64 -w0)"
  "${git_cmd[@]}" -c "http.https://github.com/.extraheader=$auth_header" push origin "$branch"
else
  "${git_cmd[@]}" push origin "$branch"
fi

echo "Backup selesai: $message"

#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(pwd)"
home="$HOME"

targets=(
  "$home/.config/nvim/init.lua"
  "$home/.config/tmux"
)

for src in "${targets[@]}"; do
  rel_path="${src#$home/}"
  dst="$repo_dir/$rel_path"

  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  cp -a "$src" "$dst"
done

git add .
git commit -m "dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"
git push

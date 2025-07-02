#!/usr/bin/env bash
# Export only init.lua and tmux.conf to the current Git working tree.
set -euo pipefail

repo_dir="$(pwd)"
home="$HOME"

targets=(
  "$home/.config/nvim/init.lua"
  "$home/.config/tmux/tmux.conf"
)

for src in "${targets[@]}"; do
  rel_path="${src#$home/}"          # e.g. ".config/nvim/init.lua"
  dst="$repo_dir/$rel_path"

  mkdir -p "$(dirname "$dst")"
  rm -f  "$dst"
  cp -a  "$src" "$dst"
done

git add .
git commit -m "dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"
git push

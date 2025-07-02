#!/usr/bin/env bash
# Copy only init.lua and tmux.conf into the current Git working tree (no .config hierarchy).
set -euo pipefail

repo_dir="$(pwd)"

sources=(
  "$HOME/.config/nvim/init.lua"
  "$HOME/.config/tmux/tmux.conf"
)

for src in "${sources[@]}"; do
  dst="$repo_dir/$(basename "$src")"   # init.lua  /  tmux.conf
  cp -a "$src" "$dst"
done

git add .
git commit -m "dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"
git push

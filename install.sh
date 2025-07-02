#!/usr/bin/env bash
# Install init.lua and tmux.conf from the repository into their proper locations.
set -euo pipefail

repo_dir="$(pwd)"

install() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
}

install "$repo_dir/init.lua"   "$HOME/.config/nvim/init.lua"
install "$repo_dir/tmux.conf"  "$HOME/.config/tmux/tmux.conf"

#!/usr/bin/env bash
# Push current ~/.config files to the dotfiles repository
set -euo pipefail

repo_dir="$(pwd)"
config_src="$HOME/.config"

if [[ ! -d "$config_src" ]]; then
  echo "Error: ~/.config directory not found"
  exit 1
fi

echo "Syncing ~/.config to repository..."

# Copy config files maintaining directory structure but removing .config prefix
find "$config_src" -type f | while read -r file; do
  # Get relative path from ~/.config
  rel_path="${file#$config_src/}"
  dst_path="$repo_dir/$rel_path"
  
  # Create directory structure
  mkdir -p "$(dirname "$dst_path")"
  
  # Copy file
  cp "$file" "$dst_path"
done

# Git operations
git add .
git commit -m "dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "Dotfiles pushed successfully!"
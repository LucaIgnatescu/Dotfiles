#!/usr/bin/env bash
# Update ~/.config from the dotfiles repository
set -euo pipefail

repo_dir="$(pwd)"
config_dst="$HOME/.config"

echo "Updating ~/.config from repository..."

# Pull latest changes
git pull

# Copy all files from repo to ~/.config, preserving structure
find "$repo_dir" -type f -not -path "$repo_dir/.git/*" -not -name "*.sh" -not -name "*.md" | while read -r file; do
  # Get relative path from repo root
  rel_path="${file#$repo_dir/}"
  dst_path="$config_dst/$rel_path"
  
  # Create directory structure
  mkdir -p "$(dirname "$dst_path")"
  
  # Copy file
  cp "$file" "$dst_path"
done

echo "Dotfiles updated successfully!"
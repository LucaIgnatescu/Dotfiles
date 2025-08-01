#!/usr/bin/env bash
# Push dotfiles from various locations to the repository
set -euo pipefail

repo_dir="$(pwd)"

echo "🔄 Syncing dotfiles to repository..."

# Function to copy files/directories safely
copy_if_exists() {
  local src="$1" dst="$2"
  if [[ -e "$src" ]]; then
    echo "  📂 Copying $src"
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
    return 0
  else
    echo "  ⚠️  Skipping $src (not found)"
    return 1
  fi
}

# Copy ~/.config maintaining directory structure
if [[ -d "$HOME/.config" ]]; then
  echo "📁 Syncing ~/.config..."
  # Only sync specific config directories to avoid bloat
  config_dirs=(
    "nvim"
    "tmux" 
    "kitty"
    "git"
    "zsh"
    "bash"
    "vim"
    "alacritty"
    "wezterm"
  )
  
  for dir in "${config_dirs[@]}"; do
    if [[ -d "$HOME/.config/$dir" ]]; then
      echo "  📂 Copying $HOME/.config/$dir"
      mkdir -p "$repo_dir/$dir"
      cp -r "$HOME/.config/$dir/"* "$repo_dir/$dir/" 2>/dev/null || true
    fi
  done
fi

# Copy ~/.claude directory to claude/ in repo
if [[ -d "$HOME/.claude" ]]; then
  echo "📂 Copying ~/.claude"
  mkdir -p "$repo_dir/claude"
  cp -r "$HOME/.claude/"* "$repo_dir/claude/" 2>/dev/null || true
fi

# Copy common dotfiles from home directory
echo "🏠 Syncing home directory dotfiles..."
home_files=(
  ".zshrc"
  ".bashrc" 
  ".bash_profile"
  ".vimrc"
  ".gitconfig"
  ".gitignore_global"
  ".tmux.conf"
  ".inputrc"
  ".editorconfig"
)

for file in "${home_files[@]}"; do
  copy_if_exists "$HOME/$file" "$repo_dir/$file" || true
done

# Git operations
echo "📤 Committing and pushing changes..."
git add . || { echo "❌ Failed to add files"; exit 1; }

# Check if there are changes to commit
if git diff --staged --quiet; then
  echo "✅ No changes to commit"
else
  echo "📝 Committing changes..."
  git commit -m "dotfiles: $(date '+%Y-%m-%d %H:%M:%S')" || { echo "❌ Failed to commit"; exit 1; }
  echo "🚀 Pushing to remote..."
  git push || { echo "❌ Failed to push"; exit 1; }
  echo "✅ Dotfiles pushed successfully!"
fi
#!/usr/bin/env bash
# Install dotfiles from repository to their proper locations
set -euo pipefail

repo_dir="$(pwd)"
backup_dir="$HOME/.dotfiles-backup-$(date '+%Y%m%d-%H%M%S')"

echo "🔧 Installing dotfiles from repository..."

# Function to safely install files with backup
install_with_backup() {
  local src="$1" dst="$2"
  
  if [[ ! -e "$src" ]]; then
    echo "  ⚠️  Source $src not found, skipping"
    return 1
  fi
  
  # Create backup if destination exists
  if [[ -e "$dst" ]]; then
    echo "  💾 Backing up existing $dst"
    mkdir -p "$backup_dir/$(dirname "${dst#$HOME/}")"
    cp -r "$dst" "$backup_dir/$(dirname "${dst#$HOME/}")/"
  fi
  
  echo "  📦 Installing $src -> $dst"
  mkdir -p "$(dirname "$dst")"
  cp -r "$src" "$dst"
  return 0
}

# Install config directories to ~/.config
echo "📁 Installing config directories..."
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
  if [[ -d "$repo_dir/$dir" ]]; then
    install_with_backup "$repo_dir/$dir" "$HOME/.config/$dir"
  fi
done

# Install claude/CLAUDE.md to ~/.claude/CLAUDE.md
if [[ -f "$repo_dir/claude/CLAUDE.md" ]]; then
  echo "🤖 Installing Claude configuration..."
  install_with_backup "$repo_dir/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
fi

# Install dotfiles to home directory
echo "🏠 Installing home directory dotfiles..."
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
  if [[ -f "$repo_dir/$file" ]]; then
    install_with_backup "$repo_dir/$file" "$HOME/$file"
  fi
done

echo "✅ Installation complete!"
if [[ -d "$backup_dir" ]]; then
  echo "💾 Backups stored in: $backup_dir"
else
  echo "📝 No backups were needed"
fi
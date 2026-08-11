#!/usr/bin/env bash
# Symlinks this repo's files into $HOME. Safe to re-run.
# Uses parallel arrays instead of `declare -A` so it works on macOS's
# stock bash 3.2, not just bash 4+.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# repo-relative source paths
SOURCES=(
  "zsh/zshrc"
  "zsh/zprofile"
  "git/gitconfig"
  "tool-versions"
  "aerospace/aerospace.toml"
  "claude/settings.json"
)

# corresponding $HOME targets, same order as SOURCES
TARGETS=(
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.gitconfig"
  "$HOME/.tool-versions"
  "$HOME/.aerospace.toml"
  "$HOME/.claude/settings.json"
)

for i in "${!SOURCES[@]}"; do
  source_path="$DOTFILES_DIR/${SOURCES[$i]}"
  target="${TARGETS[$i]}"
  mkdir -p "$(dirname "$target")"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing $target -> $backup"
    mv "$target" "$backup"
  fi

  ln -sf "$source_path" "$target"
  echo "Linked $target -> $source_path"
done

echo "Done."

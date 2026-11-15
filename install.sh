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
  "claude/skills"
  "claude/skills"
  "ghostty"
  "mise/config.toml"
)

# corresponding $HOME targets, same order as SOURCES
TARGETS=(
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.gitconfig"
  "$HOME/.tool-versions"
  "$HOME/.aerospace.toml"
  "$HOME/.claude/settings.json"
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"   # same skills, for Codex (and other agents that read ~/.agents)
  "$HOME/.config/ghostty"
  "$HOME/.config/mise/config.toml"
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

  # -n keeps ln from treating an existing symlinked *directory* target as a
  # place to put the new link inside, which would nest a self-referential
  # symlink instead of replacing it.
  ln -sfn "$source_path" "$target"
  echo "Linked $target -> $source_path"
done

echo "Done."

# Packages: system layer via Homebrew, language runtimes via mise.
if command -v brew >/dev/null 2>&1; then
  # Third-party tap casks/formulae are ignored until trusted. Trust only what
  # the Brewfile needs (individual entries), not whole taps.
  echo "Trusting third-party taps..."
  brew trust --cask nikitabobko/tap/aerospace
  brew trust --formula derailed/k9s/k9s

  echo "Installing Homebrew packages..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
else
  echo "Homebrew not found; skipping Brewfile (https://brew.sh)."
fi

if command -v mise >/dev/null 2>&1; then
  echo "Installing runtimes from ~/.tool-versions with mise..."
  mise install
fi

# Optional: company/work-specific config that doesn't belong in this public
# repo. Only runs if that sibling repo actually exists - a plain clone of
# this repo works fine without it.
PRIVATE_INSTALL="$DOTFILES_DIR/../dotfiles-private/install.sh"
if [ -f "$PRIVATE_INSTALL" ]; then
  echo ""
  echo "Found dotfiles-private, running its install.sh too..."
  "$PRIVATE_INSTALL"
fi

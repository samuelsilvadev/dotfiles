# System layer: shell tools, GUI apps and build deps. Run via install.sh, or
# `brew bundle --file=Brewfile`. Language runtimes live in tool-versions (mise).

# ---------- Taps ----------
tap "nikitabobko/tap"   # aerospace
tap "derailed/k9s"      # k9s

# ---------- Core ----------
brew "git"           # newer than Apple's; git/gitconfig is linked by install.sh

# ---------- Version manager ----------
brew "mise"          # node, python, ruby, go, yarn, pnpm (see tool-versions)

# ---------- Shell experience (referenced by zsh/zshrc) ----------
brew "starship"      # prompt
brew "eza"           # ls
brew "bat"           # cat
brew "fzf"           # fuzzy finder, ctrl-t
brew "zoxide"        # z <dir>
brew "atuin"         # shell history, ctrl-r
brew "ripgrep"       # rg (see RIPGREP_CONFIG_PATH)
brew "fd"
brew "jq"
brew "shellcheck"   # scripts/check lints install.sh with it
brew "lazygit"
brew "lazydocker"
brew "derailed/k9s/k9s"   # kubernetes TUI (third-party tap, trusted in install.sh)

# ---------- Ruby build deps (mise compiles Ruby from source) ----------
brew "openssl@3"
brew "libyaml"

# ---------- Postgres client (PATH set in zshrc) ----------
brew "libpq"

# ---------- GUI apps ----------
# adopt: true takes over an app already in /Applications (installed outside
# brew) instead of failing or reinstalling it. A no-op on a fresh machine.
#
# Adopting an app that already exists needs your terminal to have macOS
# "App Management" permission, or brew fails with "chgrp: Operation not
# permitted" on files inside the app. Fix: System Settings > Privacy &
# Security > App Management > enable your terminal (Ghostty), then re-run
# `brew install --cask --adopt <app>`. Not needed on a fresh machine.
#
# Third-party tap casks/formulae must be trusted before brew loads them;
# install.sh does that (see its "Trusting third-party taps" step).
cask "ghostty", args: { adopt: true }
cask "aerospace"
cask "cursor", args: { adopt: true }
cask "font-fira-code-nerd-font"   # icons for starship/eza/lazygit (ghostty/config)

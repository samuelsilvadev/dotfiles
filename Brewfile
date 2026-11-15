# System layer: shell tools, GUI apps and build deps. Run via install.sh, or
# `brew bundle --file=Brewfile`. Language runtimes live in tool-versions (mise).

# ---------- Taps ----------
tap "nikitabobko/tap"   # aerospace
tap "derailed/k9s"      # k9s
tap "danerwilliams/tap" # charcoal
tap "supabase/tap"      # supabase
tap "pulumi/tap"        # pulumi
tap "stripe/stripe-cli" # stripe
tap "tursodatabase/tap" # turso
tap "libsql/sqld"       # sqld
tap "anomalyco/tap"     # hex

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

# ---------- Terminal tools ----------
brew "tmux"
brew "htop"
brew "btop"
brew "wget"
brew "gnupg"
brew "gnu-tar"
brew "superfile"     # terminal file manager
brew "mole"          # mac cleanup

# ---------- Dev tools ----------
brew "gh"
brew "kubernetes-cli"
brew "kind"
brew "podman-compose"
brew "mkcert"
brew "sops"
brew "protobuf"
brew "redis"
brew "rust"
brew "cocoapods"
brew "flyctl"
brew "watchman"
brew "websocat"
brew "ffmpeg"

# ---------- Runtimes / CLIs that used to come from install scripts ----------
brew "bun"           # BUN_INSTALL=~/.bun still holds global packages (zshrc)
brew "uv"
brew "opencode"
brew "herdr"         # agent multiplexer; herdr/config.toml is linked by install.sh

# ---------- Third-party taps (trusted in install.sh) ----------
brew "danerwilliams/tap/charcoal"
brew "supabase/tap/supabase"
brew "pulumi/tap/pulumi"
brew "stripe/stripe-cli/stripe"
brew "tursodatabase/tap/turso"
brew "libsql/sqld/sqld"

# ---------- Ruby build deps (mise compiles Ruby from source) ----------
brew "openssl@3"
brew "libyaml"

# ---------- Postgres (PATH set in zshrc) ----------
brew "libpq"
brew "postgresql@18"

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
cask "gcloud-cli"    # path/completion sourced in zshrc
cask "orbstack"      # docker/linux VMs (zprofile sources its shell init)
cask "ngrok"
cask "keycastr"
cask "anomalyco/tap/hex"

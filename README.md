# dotfiles

Personal configuration, tracked and symlinked into `$HOME`.

## Layout

```
dotfiles/
├── zsh/
│   ├── zshrc
│   └── zprofile
├── git/
│   └── gitconfig
├── claude/
│   ├── settings.json
│   └── skills/         (linked to ~/.claude/skills and ~/.agents/skills; see skills/CREDITS.md)
├── aerospace/
│   └── aerospace.toml
├── mise/
│   └── config.toml
├── scripts/
│   ├── check           (static checks; the pre-commit hook runs it)
│   └── doctor          (checks this machine against the repo)
├── Brewfile            (system tools and apps, via Homebrew)
├── tool-versions       (language runtimes, via mise)
└── install.sh
```

## Install

```bash
git clone git@github.com:<you>/dotfiles.git ~/projects/projects/dotfiles
cd ~/projects/projects/dotfiles
./install.sh
```

`install.sh` symlinks each file into place under `$HOME`, runs `brew bundle` for the `Brewfile`, then `mise install` for `tool-versions`, and enables the pre-commit hook. If something already exists there and isn't already a symlink, it's backed up first (`<file>.backup.<timestamp>`) rather than overwritten.

If `../dotfiles-private` exists next to this repo, `install.sh` runs its `install.sh` too, at the end. That repo is private/company-specific config (not published here) — see [dotfiles-private](https://github.com/<you>/dotfiles-private). Cloning just this repo works fine without it.

## Adding a new file

1. Move the real file into the appropriate topic folder here (create one if needed).
2. Add an entry to the `SOURCES`/`TARGETS` arrays in `install.sh` (same index in both).
3. Re-run `./install.sh`.

## Skills

`claude/skills/` is linked to both `~/.claude/skills` (Claude Code) and
`~/.agents/skills` (Codex and other agents that use the shared `~/.agents`
location), so a skill added here shows up in both. Skills installed with
`npx skills add -g` land in this folder too, through the link.

## Credits

Some of the Claude Code skills under `claude/skills/` were written by other
people and adapted here — see [claude/skills/CREDITS.md](claude/skills/CREDITS.md)
for the full list and links to the originals.

## Notes

- Secrets (npm auth tokens, API keys, etc.) are never committed here — those stay local only.

## Checks

- `scripts/check` runs before every commit: syntax and shellcheck, `SOURCES`/`TARGETS` stay in step, and every command `zshrc` wires up is provided by the `Brewfile` or `tool-versions`.
- `scripts/doctor` compares this machine with the repo: Brewfile satisfied, mise tools installed, symlinks in place, and a fresh login shell resolving each tool correctly.

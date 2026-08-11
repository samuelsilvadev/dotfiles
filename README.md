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
│   └── skills/         (see skills/CREDITS.md for attribution)
├── aerospace/
│   └── aerospace.toml
├── tool-versions
└── install.sh
```

## Install

```bash
git clone git@github.com:<you>/dotfiles.git ~/projects/projects/dotfiles
cd ~/projects/projects/dotfiles
./install.sh
```

`install.sh` symlinks each file into place under `$HOME`. If something already exists there and isn't already a symlink, it's backed up first (`<file>.backup.<timestamp>`) rather than overwritten.

If `../dotfiles-private` exists next to this repo, `install.sh` runs its `install.sh` too, at the end. That repo is private/company-specific config (not published here) — see [dotfiles-private](https://github.com/<you>/dotfiles-private). Cloning just this repo works fine without it.

## Adding a new file

1. Move the real file into the appropriate topic folder here (create one if needed).
2. Add an entry to the `SOURCES`/`TARGETS` arrays in `install.sh` (same index in both).
3. Re-run `./install.sh`.

## Credits

Some of the Claude Code skills under `claude/skills/` were written by other
people and adapted here — see [claude/skills/CREDITS.md](claude/skills/CREDITS.md)
for the full list and links to the originals.

## Notes

- Secrets (npm auth tokens, API keys, etc.) are never committed here — those stay local only.

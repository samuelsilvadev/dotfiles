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
│   └── settings.json
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

## Adding a new file

1. Move the real file into the appropriate topic folder here (create one if needed).
2. Add an entry to the `LINKS` map in `install.sh`.
3. Re-run `./install.sh`.

## Notes

- Secrets (npm auth tokens, API keys, etc.) are never committed here — those stay local only.

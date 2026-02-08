# dotfiles

Personal development environment with custom configs.

## What's Included

- Neovim (managed as a [submodule](https://github.com/anirudhlakkaraju/nvim))
- Tmux
- Zsh (Oh My Zsh)
- AeroSpace (tiling window manager)
- Utility scripts

## Setup

Clone and run the setup script:

```bash
git clone --recursive https://github.com/anirudhlakkaraju/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh
```

> [!NOTE]
> The script is idempotent — safe to run multiple times.

## What the Setup Script Does

1. Installs Homebrew (if missing)
2. Installs core tools (neovim, tmux, fzf, etc.)
3. Installs Oh My Zsh + plugins
4. Installs TPM (tmux plugin manager)
5. Creates symlinks for all configs
6. Installs tmux and nvim plugins

## Customization

- **tmux-sessionizer** (`scripts/tmux-sessionizer`): Quickly create/switch tmux sessions for your projects via fzf. Edit the `find` paths to point to your own project directories.
- **Telescope dotfiles** (`<leader>nc`): Opens a fuzzy finder scoped to `~/dotfiles`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

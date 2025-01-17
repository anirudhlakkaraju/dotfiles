#!/bin/bash

# Make executable and run script for new setups
# chmod +x ~/dotfiles/setup.sh
# ~/dotfiles/setup.sh

# Symlink XDG configs
ln -sf ~/dotfiles/.config/fish ~/.config/fish

# Symlink home directory configs
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/dotfiles/.config/tmux ~/.config/tmux

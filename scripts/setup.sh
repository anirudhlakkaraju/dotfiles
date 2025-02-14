#!/bin/bash

# Make executable and run script for new setups
# chmod +x ~/dotfiles/setup.sh
# ~/dotfiles/setup.sh

# Symlink home directory configs
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/dotfiles/.aerospace.toml ~/.aerospace.toml

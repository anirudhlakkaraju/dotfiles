#!/bin/bash

# Command to run on new setups
# chmod +x ~/DotFiles/setup.sh

# Symlink XDG configs
ln -sf ~/dotfiles/.config/fish ~/.config/fish

# Symlink home directory configs
ln -sf ~/dotfiles/zshrc ~/.zshrc

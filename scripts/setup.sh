#!/bin/bash

set -e

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$DOTFILES/backups"

# ──────────────────────────────────────────────
# Pre-flight checks
# ──────────────────────────────────────────────

# Ensure right OS
os=$(uname)
if [ "$os" != "Darwin" ]; then
    echo "Error: This script only supports macOS"
    exit 1
fi
echo "✓ macOS detected"

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found"
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Create .config dir if not present
mkdir -p "$HOME/.config"

# ──────────────────────────────────────────────
# Install tools via Homebrew
# ──────────────────────────────────────────────

brew_packages=(
    "neovim"
    "tmux"
    "fzf"
    "ripgrep"
    "fd"
)

brew_casks=(
    "nikitabobko/tap/aerospace"
)

for package in "${brew_packages[@]}"; do
    if brew list "$package" &>/dev/null; then
        echo "✓ $package already installed"
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

for cask in "${brew_casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "✓ $cask already installed"
    else
        echo "Installing $cask..."
        brew install --cask "$cask"
    fi
done

# ──────────────────────────────────────────────
# Oh My Zsh + Plugins + Themes Installation
# ──────────────────────────────────────────────

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✓ Oh My Zsh already installed"
else
    echo "Installing Oh My Zsh..."
    # '--unattended' skips the interactive prompts
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

zsh_plugin_names=(
    "zsh-syntax-highlighting"
    "zsh-autosuggestions"
    "you-should-use"
    "zsh-bat"
)

zsh_plugin_urls=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions.git"
    "https://github.com/MichaelAquilina/zsh-you-should-use.git"
    "https://github.com/fdellwing/zsh-bat.git"
)

# Plugin installations
for idx in $(seq 0 $((${#zsh_plugin_names[@]} - 1))); do
    plugin_name=${zsh_plugin_names[$idx]}
    plugin_url=${zsh_plugin_urls[$idx]}
    plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
    if [ -d "$plugin_dir" ]; then
        echo "✓ zsh plugin '$plugin_name' already installed"
    else
        echo "Installing zsh plugin '$plugin_name'..."
        git clone "${plugin_url}" "$plugin_dir"
    fi
done


# Theme installation
theme_name="powerlevel10k"
theme_dir="$ZSH_CUSTOM/themes/$theme_name"
theme_url="https://github.com/romkatv/powerlevel10k.git"
if [ -d "$theme_dir" ]; then
    echo "✓ zsh theme '$theme_name' already installed"
else
    echo "Installing zsh theme '$theme_name'..."
    git clone "${theme_url}" "$theme_dir"
fi

# ──────────────────────────────────────────────
# TPM (Tmux Plugin Manager)
# ──────────────────────────────────────────────

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    echo "✓ TPM already installed"
else
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# ──────────────────────────────────────────────
# Git Submodules
# ──────────────────────────────────────────────

echo "Initializing git submodules..."
git -C "$DOTFILES" submodule update --init --recursive

# ──────────────────────────────────────────────
# Setup Symlinks
# ──────────────────────────────────────────────

# Backup directory for existing configs
mkdir -p "$BACKUP_DIR"

create_symlink() {
    local source=$1
    local target=$2

    # '-L' checks if path is a symlink
    if [ -L "$target" ]; then
        current_link=$(readlink "$target")
        if [ "$current_link" = "$source" ]; then
            echo "✓ $target already linked correctly"
            return
        else
            echo "Removing incorrect symlink: $target → $current_link"
            rm "$target"
        fi
    # '-e' checks if path exists (file or directory)
    elif [ -e "$target" ]; then
        # '$(date +%Y%m%d_%H%M%S)' generates a timestamp: 20260202_143022
        backup_name="$(basename "$target").$(date +%Y%m%d_%H%M%S)"

        # Special handling for .zshrc — ask the user
        read -r -p "$target exists. Backup and replace? (y/n): " answer
            if [ "$answer" != "y" ]; then
                echo "Skipping $target"
                return
            fi

        echo "Backing up $target → $BACKUP_DIR/$backup_name"
        mv "$target" "$BACKUP_DIR/$backup_name"
    fi

    ln -s "$source" "$target"
}

# Call the function for each config
create_symlink "$DOTFILES/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES/.aerospace.toml" "$HOME/.aerospace.toml"
create_symlink "$DOTFILES/.config/nvim" "$HOME/.config/nvim"

# ──────────────────────────────────────────────
# Plugin Installations
# ──────────────────────────────────────────────

# Install tmux plugins via TPM
echo "Installing tmux plugins..."
# Check the script exists before running it
if [ -f "$TPM_DIR/bin/install_plugins" ]; then
    "$TPM_DIR/bin/install_plugins"
fi

# Trigger lazy.nvim plugin install (headless = no UI)
echo "Installing nvim plugins..."
nvim --headless "+Lazy! sync" +qa

echo ""
echo "════════════════════════════════════════════"
echo "  Setup complete! Restart your terminal."
echo "════════════════════════════════════════════"

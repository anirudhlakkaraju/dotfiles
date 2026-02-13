#!/bin/bash

set -e

# ──────────────────────────────────────────────
# Colors and formatting
# ──────────────────────────────────────────────

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$DOTFILES/backups"

# Helper functions for pretty output
info()    { echo -e "  ${BLUE}::${NC} $1"; }
ok()      { echo -e "  ${GREEN}[ok]${NC} $1"; }
warn()    { echo -e "  ${YELLOW}[!!]${NC} $1"; }
fail()    { echo -e "  ${RED}[!!]${NC} $1"; exit 1; }
section() { echo -e "\n${BOLD}$1${NC}"; echo -e "${DIM}────────────────────────────────────────${NC}"; }

# Run a command silently, show output only on failure
quiet() {
    local output
    if output=$("$@" 2>&1); then
        return 0
    else
        echo "$output"
        return 1
    fi
}

# ──────────────────────────────────────────────

section "Pre-flight"

os=$(uname)
if [ "$os" != "Darwin" ]; then
    fail "This script only supports macOS"
fi
ok "macOS detected"

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ok "Homebrew installed"
else
    ok "Homebrew"
fi

mkdir -p "$HOME/.config"

# ──────────────────────────────────────────────

section "Package Installations"

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
        ok "$package"
    else
        info "Installing $package..."
        quiet brew install "$package" || fail "Failed to install $package"
        ok "$package"
    fi
done

for cask in "${brew_casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        ok "$cask"
    else
        info "Installing $cask..."
        quiet brew install --cask "$cask" || fail "Failed to install $cask"
        ok "$cask"
    fi
done

# ──────────────────────────────────────────────

section "Shell (Oh My Zsh)"

if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "Oh My Zsh"
else
    info "Installing Oh My Zsh..."
    quiet sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "Oh My Zsh"
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

for idx in $(seq 0 $((${#zsh_plugin_names[@]} - 1))); do
    plugin_name=${zsh_plugin_names[$idx]}
    plugin_url=${zsh_plugin_urls[$idx]}
    plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
    if [ -d "$plugin_dir" ]; then
        ok "plugin: $plugin_name"
    else
        info "Installing $plugin_name..."
        quiet git clone "$plugin_url" "$plugin_dir" || fail "Failed to clone $plugin_name"
        ok "plugin: $plugin_name"
    fi
done

theme_name="powerlevel10k"
theme_dir="$ZSH_CUSTOM/themes/$theme_name"
theme_url="https://github.com/romkatv/powerlevel10k.git"
if [ -d "$theme_dir" ]; then
    ok "theme: $theme_name"
else
    info "Installing $theme_name..."
    quiet git clone "$theme_url" "$theme_dir" || fail "Failed to clone $theme_name"
    ok "theme: $theme_name"
fi

# ──────────────────────────────────────────────

section "Tmux"

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    ok "TPM"
else
    info "Installing TPM..."
    quiet git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" || fail "Failed to clone TPM"
    ok "TPM"
fi

# ──────────────────────────────────────────────

section "Git Submodules"

info "Initializing submodules..."
quiet git -C "$DOTFILES" submodule update --init --recursive
ok "Submodules ready"

# ──────────────────────────────────────────────

section "Symlinks"

mkdir -p "$BACKUP_DIR"

create_symlink() {
    local source=$1
    local target=$2
    local name
    name=$(basename "$target")

    # Already linked correctly — skip silently
    if [ -L "$target" ]; then
        current_link=$(readlink "$target")
        if [ "$current_link" = "$source" ]; then
            ok "$name"
            return
        else
            echo -e "  ${YELLOW}$name${NC} points to ${DIM}$current_link${NC} (expected ${DIM}$source${NC})"
            read -r -p "  Replace symlink? (y/n): " answer
            if [ "$answer" != "y" ]; then
                warn "$name (skipped)"
                return
            fi
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        backup_name="$name.$(date +%Y%m%d_%H%M%S)"
        echo -e "  ${YELLOW}$name${NC} already exists as a file/directory."
        read -r -p "  Backup and replace? (y/n): " answer
        if [ "$answer" != "y" ]; then
            warn "$name (skipped)"
            return
        fi
        mv "$target" "$BACKUP_DIR/$backup_name"
        info "Backed up to $BACKUP_DIR/$backup_name"
    else
        echo -e "  ${DIM}$name${NC} not found."
        read -r -p "  Create symlink? (y/n): " answer
        if [ "$answer" != "y" ]; then
            warn "$name (skipped)"
            return
        fi
    fi

    ln -s "$source" "$target"
    ok "$name -> $source"
}

create_symlink "$DOTFILES/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES/.aerospace.toml" "$HOME/.aerospace.toml"
create_symlink "$DOTFILES/.config/nvim" "$HOME/.config/nvim"

# ──────────────────────────────────────────────

section "Post-install"

if [ -f "$TPM_DIR/bin/install_plugins" ]; then
    info "Installing tmux plugins..."
    quiet "$TPM_DIR/bin/install_plugins" || warn "TPM plugin install had issues"
    ok "Tmux plugins"
fi

info "Installing nvim plugins..."
quiet nvim --headless "+Lazy! sync" +qa || warn "Nvim plugin install had issues"
ok "Nvim plugins"

# ──────────────────────────────────────────────

echo ""
echo -e "${DIM}────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[done]${NC} ${BOLD}Setup complete.${NC} Restart your terminal."
echo ""

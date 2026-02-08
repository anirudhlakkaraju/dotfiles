export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# PATH to your Oh My Zsh Installation
export ZSH="$HOME/.oh-my-zsh"

# PATH to Go bin
export GOBIN=$HOME/go/bin
export PATH=$GOBIN:$PATH

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    you-should-use
    git
    zsh-bat
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

eval "$(/opt/homebrew/bin/brew shellenv)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

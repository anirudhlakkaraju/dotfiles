# If you come her from bash you must have to change your $PATH
export PATH=$HOME/bin:$HOME/.local/bin:/user/local/bin:$PATH

# PATH to your Oh My Zsh Installation
export ZSH="$HOME/.oh-my-zsh"

# PATH to Go bin
export GOBIN=$HOME/go/bin
export PATH=$GOBIN:$PATH

ZSH_THEME="robbyrussell"

plugins=(
    you-should-use
    git
    zsh-bat
    bundler
    dotenv
    macos
    rake
    rbenv
    ruby
    node
    brew
    pip
    python
    npm
    nvm
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration
export MANPATH="user/local/man:$MANPATH"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# >>> conda initialize >>>
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize >>>

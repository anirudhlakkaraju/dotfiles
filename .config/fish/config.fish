# Define config home
export XDG_CONFIG_HOME="$HOME/.config"

# Set Go path
set -gx PATH $PATH (go env GOPATH)/bin

# Set Homebrew path
/opt/homebrew/bin/brew shellenv | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end

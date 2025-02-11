#!/usr/bin/env bash

# select languages and commands from files and pipe them to fzf
selected=`cat ~/dotfiles/.tmux-cht-langs ~/dotfiles/.tmux-cht-cmds | fzf`

# if nothing is selected, exit
if [[ -z $selected ]]; then
    exit 0
fi

# take user input
read -p "Enter Query: " query

# depending on selected do curl for cheatsheet
if grep -qs "$selected" ~/dotfiles/.tmux-cht-langs; then
    query=`echo $query | tr ' ' '+'`
    tmux neww bash -c "curl -s cht.sh/$selected/$query | bat --paging=always --style=grid,header"
 else
    tmux neww bash -c "curl -s cht.sh/$selected~$query | bat --paging=always --style=plain"
fi

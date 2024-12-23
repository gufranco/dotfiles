#!/usr/bin/env bash

################################################################################
# Aliases
################################################################################
source "$HOME/.dotfiles/zsh/aliases"

################################################################################
# Functions
################################################################################
source "$HOME/.dotfiles/zsh/functions"

################################################################################
# Paths
################################################################################
source "$HOME/.dotfiles/zsh/paths"

################################################################################
# Settings
################################################################################
source "$HOME/.dotfiles/zsh/settings"

################################################################################
# Containers
################################################################################
source "$HOME/.dotfiles/zsh/containers"

################################################################################
# Tmux
################################################################################
if [ -z "$TMUX" ]; then
  tmux new-session -s $$;
else
  export TERM="screen-256color"
fi

################################################################################
# Oh-my-zsh
################################################################################
source "$ZSH/oh-my-zsh.sh"

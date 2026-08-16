#!/usr/bin/env bash

################################################################################
# Core (must load first - provides shared helpers)
################################################################################
source "$HOME/.dotfiles/zsh/core"

################################################################################
# Paths
################################################################################
source "$HOME/.dotfiles/zsh/paths"

################################################################################
# Startup
################################################################################
source "$HOME/.dotfiles/zsh/startup"

################################################################################
# Settings
################################################################################
source "$HOME/.dotfiles/zsh/settings"

################################################################################
# Oh-my-zsh
################################################################################
source "$ZSH/oh-my-zsh.sh"

if typeset -f async_stop_worker >/dev/null 2>&1; then
  functions -c async_stop_worker __async_stop_worker_upstream
  async_stop_worker() { __async_stop_worker_upstream "$@" 2>/dev/null; }
fi

################################################################################
# External tool initialization
################################################################################
# Must run after oh-my-zsh: compinit defines compdef, which these completion
# and hook scripts call. Running them earlier errors and skips completion
# registration.
__cached_eval direnv hook zsh
__cached_eval mise activate zsh
__cached_eval zoxide init zsh
__cached_eval atuin init zsh --disable-up-arrow
__cached_eval thefuck --alias

################################################################################
# Aliases
################################################################################
source "$HOME/.dotfiles/zsh/aliases"

################################################################################
# Domain modules
################################################################################
source "$HOME/.dotfiles/zsh/f5"
source "$HOME/.dotfiles/zsh/disk"
source "$HOME/.dotfiles/zsh/sync-games"
source "$HOME/.dotfiles/zsh/gaming"
source "$HOME/.dotfiles/zsh/alphabetize"
source "$HOME/.dotfiles/zsh/nds-trim"
source "$HOME/.dotfiles/zsh/subs"
source "$HOME/.dotfiles/zsh/infrastructure"

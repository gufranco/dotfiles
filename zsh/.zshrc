#!/usr/bin/env bash

################################################################################
# Core (must load first - provides shared helpers)
################################################################################
source "$HOME/.dotfiles/zsh/config/core"

################################################################################
# Paths
################################################################################
source "$HOME/.dotfiles/zsh/config/paths"

################################################################################
# Startup
################################################################################
source "$HOME/.dotfiles/zsh/config/startup"

################################################################################
# Settings
################################################################################
source "$HOME/.dotfiles/zsh/config/settings"

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
source "$HOME/.dotfiles/zsh/config/aliases"

################################################################################
# Domain modules
################################################################################
source "$HOME/.dotfiles/zsh/modules/f5"
source "$HOME/.dotfiles/zsh/modules/disk"
source "$HOME/.dotfiles/zsh/modules/sync-games"
source "$HOME/.dotfiles/zsh/modules/gaming"
source "$HOME/.dotfiles/zsh/modules/alphabetize"
source "$HOME/.dotfiles/zsh/modules/nds-trim"
source "$HOME/.dotfiles/zsh/modules/subs"
source "$HOME/.dotfiles/zsh/modules/vcd"
source "$HOME/.dotfiles/zsh/modules/infrastructure"

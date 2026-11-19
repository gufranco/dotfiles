#!/usr/bin/env bash

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

# Silence the async worker teardown noise the prompt prints. Wrap only once,
# or a second load makes the wrapper call itself
# shellcheck disable=SC2154
if typeset -f async_stop_worker >/dev/null 2>&1 &&
  [[ "${functions[async_stop_worker]}" != *__async_stop_worker_upstream* ]]; then
  functions -c async_stop_worker __async_stop_worker_upstream
  async_stop_worker() { __async_stop_worker_upstream "$@" 2>/dev/null; }
fi

################################################################################
# Tool hooks (cached, see __cached_eval in settings)
################################################################################
__cached_eval direnv hook zsh
__cached_eval mise activate zsh
__cached_eval zoxide init zsh
__cached_eval atuin init zsh --disable-up-arrow

################################################################################
# Functions
################################################################################
source "$HOME/.dotfiles/zsh/functions"

################################################################################
# Aliases (load last, so the functions above see the plain commands)
################################################################################
source "$HOME/.dotfiles/zsh/aliases"

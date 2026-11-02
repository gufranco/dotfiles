#!/usr/bin/env bash

source "$HOME/.dotfiles/zsh/config/core"
source "$HOME/.dotfiles/zsh/config/paths"
source "$HOME/.dotfiles/zsh/config/startup"
source "$HOME/.dotfiles/zsh/config/settings"
source "$ZSH/oh-my-zsh.sh"

if typeset -f async_stop_worker >/dev/null 2>&1 &&
  [[ "${functions[async_stop_worker]}" != *__async_stop_worker_upstream* ]]; then
  functions -c async_stop_worker __async_stop_worker_upstream
  async_stop_worker() { __async_stop_worker_upstream "$@" 2>/dev/null; }
fi

__cached_eval direnv hook zsh
__cached_eval mise activate zsh
__cached_eval zoxide init zsh
__cached_eval atuin init zsh --disable-up-arrow

source "$HOME/.dotfiles/zsh/modules/f5"
source "$HOME/.dotfiles/zsh/modules/disk"
source "$HOME/.dotfiles/zsh/modules/sync-games"
source "$HOME/.dotfiles/zsh/modules/gaming"
source "$HOME/.dotfiles/zsh/modules/infrastructure"

source "$HOME/.dotfiles/zsh/config/aliases"

#!/usr/bin/env bash
set -euo pipefail

errors=0
for dir in \
  "$HOME/.oh-my-zsh" \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" \
  "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" \
  "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"; do
  if [ -d "$dir/.git" ]; then
    echo "OK: $(basename "$dir")"
  else
    echo "FAIL: $(basename "$dir") not found"
    errors=$((errors + 1))
  fi
done
exit $errors

#!/usr/bin/env bash
set -euo pipefail

errors=0
check() {
  if [ -L "$2" ]; then
    if [ -e "$2" ]; then
      echo "OK: $1"
    else
      echo "FAIL: $1 ($2 is a dangling symlink)"
      errors=$((errors + 1))
    fi
  else
    echo "FAIL: $1 ($2 is not a symlink)"
    errors=$((errors + 1))
  fi
}

# Shell & Editor
check "zshrc"       "$HOME/.zshrc"
check "gitconfig"   "$HOME/.gitconfig"
check "vimrc"       "$HOME/.vimrc"
check "vim"         "$HOME/.vim"
check "tmux.conf"   "$HOME/.tmux.conf"
check "tmux"        "$HOME/.tmux"

# Network
check "curlrc"      "$HOME/.curlrc"
check "wgetrc"      "$HOME/.wgetrc"
check "telnetrc"    "$HOME/.telnetrc"

# Search & Input
check "inputrc"     "$HOME/.inputrc"
check "ripgreprc"   "$HOME/.ripgreprc"
check "fdrc"        "$HOME/.fdrc"

# Node.js
check "npmrc"       "$HOME/.npmrc"
check "yarnrc"      "$HOME/.yarnrc.yml"
check "pnpmrc"      "$HOME/.pnpmrc"

# Email
check "muttrc"      "$HOME/.muttrc"
check "mutt"        "$HOME/.mutt"
check "mailcap"     "$HOME/.mailcap"

# Security
check "gnupg"       "$HOME/.gnupg"
check "ssh"         "$HOME/.ssh"

# App configs
check "htop"        "$HOME/.config/htop/htoprc"
check "ghostty"     "$HOME/.config/ghostty"
check "kitty"       "$HOME/.config/kitty/kitty.conf"
check "bat-config"  "$HOME/.config/bat/config"
check "bat-themes"  "$HOME/.config/bat/themes"
check "eza"         "$HOME/.config/eza"
check "cmus"        "$HOME/.config/cmus/rc"
check "yazi"        "$HOME/.config/yazi"
check "gh"          "$HOME/.config/gh/config.yml"
check "glab"        "$HOME/.config/glab-cli/config.yml"
check "tealdeer"    "$HOME/.config/tealdeer/config.toml"
check "bottom"      "$HOME/.config/bottom/bottom.toml"
check "lazygit"     "$HOME/.config/lazygit/config.yml"
check "lazydocker"  "$HOME/.config/lazydocker/config.yml"
check "k9s"         "$HOME/.config/k9s/config.yml"

# Platform-specific
case "$(uname)" in
  Linux)
    check "conkyrc" "$HOME/.conkyrc"
    ;;
  Darwin)
    check "k9s-skins" "$HOME/.config/k9s/skins"
    ;;
esac

exit $errors

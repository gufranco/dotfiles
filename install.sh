#!/usr/bin/env bash

set -xeo pipefail

DOTFILES="$HOME/.dotfiles"

physical_dir() {
  local dir="$1"
  while [ ! -d "$dir" ]; do
    dir="$(dirname "$dir")"
  done
  (cd -P "$dir" && pwd)
}

require_inside_home() {
  local home_dir target_dir
  home_dir="$(physical_dir "$HOME")"
  target_dir="$(physical_dir "$1")"
  case "$target_dir/" in
    "$home_dir"/*) ;;
    *)
      echo "install: $1 resolves to $target_dir, outside the home folder $home_dir" >&2
      exit 1
      ;;
  esac
}

link() {
  require_inside_home "$(dirname "$2")"
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    mv -v "$2" "$2.backup.$(date +%s)"
  fi
  mkdir -pv "$(dirname "$2")"
  ln -sfnv "$1" "$2"
}

clone() {
  if [ -d "$2/.git" ]; then
    git -C "$2" pull --no-edit || true
  else
    git clone --recursive "$1" "$2"
  fi
}

require_inside_home "$DOTFILES"

if [ "$(uname)" != "Darwin" ]; then
  echo "These dotfiles support macOS only."
  exit 1
fi

if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/pgrep oahd; then
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

if ! command -v brew; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

clone https://github.com/gufranco/dotfiles.git "$DOTFILES"
brew trust gufranco/tap || true
brew bundle --verbose --file "$DOTFILES/Brewfile" || true

for shell in bash zsh; do
  grep -x "$HOMEBREW_PREFIX/bin/$shell" /etc/shells || echo "$HOMEBREW_PREFIX/bin/$shell" | sudo tee -a /etc/shells
done
[ "$SHELL" = "$HOMEBREW_PREFIX/bin/zsh" ] || chsh -s "$HOMEBREW_PREFIX/bin/zsh" || true

clone https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
for repo in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting zsh-users/zsh-completions Aloxaf/fzf-tab; do
  clone "https://github.com/$repo.git" "$HOME/.oh-my-zsh/custom/plugins/${repo#*/}"
done
clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
link "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/vim" "$HOME/.vim"
link "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
link "$DOTFILES/nvim" "$HOME/.config/nvim"
link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES/tmux" "$HOME/.tmux"
link "$DOTFILES/mutt/.muttrc" "$HOME/.muttrc"
link "$DOTFILES/mutt" "$HOME/.mutt"
link "$DOTFILES/mailcap/.mailcap" "$HOME/.mailcap"
link "$DOTFILES/curl/.curlrc" "$HOME/.curlrc"
link "$DOTFILES/wget/.wgetrc" "$HOME/.wgetrc"
link "$DOTFILES/readline/.inputrc" "$HOME/.inputrc"
link "$DOTFILES/ripgrep/.ripgreprc" "$HOME/.ripgreprc"
link "$DOTFILES/fd/.fdrc" "$HOME/.fdrc"
link "$DOTFILES/telnet/.telnetrc" "$HOME/.telnetrc"
link "$DOTFILES/python/.pdbrc" "$HOME/.pdbrc"
link "$DOTFILES/python/pythonrc" "$HOME/.pythonrc"
link "$DOTFILES/python/debughook.py" "$HOME/.config/python/debughook.py"
link "$DOTFILES/nodejs/.npmrc" "$HOME/.npmrc"
link "$DOTFILES/nodejs/.yarnrc.yml" "$HOME/.yarnrc.yml"
link "$DOTFILES/nodejs/.pnpmrc" "$HOME/.pnpmrc"
link "$DOTFILES/nodejs/repl-init.mjs" "$HOME/.config/node/repl-init.mjs"
link "$DOTFILES/clang-tidy/.clang-tidy" "$HOME/.clang-tidy"
link "$DOTFILES/golangci/golangci.yml" "$HOME/.golangci.yml"
link "$DOTFILES/luacheck/luacheckrc" "$HOME/.config/luacheck/.luacheckrc"
link "$DOTFILES/mise/config.toml" "$HOME/.config/mise/config.toml"
link "$DOTFILES/ghostty" "$HOME/.config/ghostty"
link "$DOTFILES/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
link "$DOTFILES/htop/htoprc" "$HOME/.config/htop/htoprc"
link "$DOTFILES/bat/config" "$HOME/.config/bat/config"
link "$DOTFILES/bat/catppuccin/themes" "$HOME/.config/bat/themes"
link "$DOTFILES/cmus/rc" "$HOME/.config/cmus/rc"
link "$DOTFILES/gh/config.yml" "$HOME/.config/gh/config.yml"
link "$DOTFILES/k9s/config.yml" "$HOME/.config/k9s/config.yml"
link "$DOTFILES/k9s/catppuccin/dist" "$HOME/.config/k9s/skins"
link "$DOTFILES/k9s/config.yml" "$HOME/Library/Application Support/k9s/config.yml"
link "$DOTFILES/k9s/catppuccin/dist" "$HOME/Library/Application Support/k9s/skins"
link "$DOTFILES/atuin/config.toml" "$HOME/.config/atuin/config.toml"
link "$DOTFILES/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
link "$DOTFILES/direnv/direnv.toml" "$HOME/.config/direnv/direnv.toml"
link "$DOTFILES/tig/config" "$HOME/.config/tig/config"
link "$DOTFILES/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
link "$DOTFILES/ranger/rifle.conf" "$HOME/.config/ranger/rifle.conf"
link "$DOTFILES/ranger/scope.sh" "$HOME/.config/ranger/scope.sh"
link "$DOTFILES/newsboat/config" "$HOME/.config/newsboat/config"
link "$DOTFILES/newsboat/urls" "$HOME/.config/newsboat/urls"
link "$DOTFILES/asciinema/config.toml" "$HOME/.config/asciinema/config.toml"
link "$DOTFILES/goaccess/goaccess.conf" "$HOME/.config/goaccess/goaccess.conf"
link "$DOTFILES/gnupg" "$HOME/.gnupg"
link "$DOTFILES/gnupg/gpg-agent-macos-$(uname -m).conf" "$HOME/.gnupg/gpg-agent.conf"
link "$DOTFILES/ssh" "$HOME/.ssh"
for tool in clang-tidy clang-format; do
  link "$HOMEBREW_PREFIX/opt/llvm/bin/$tool" "$HOME/.local/bin/$tool"
done

if [ ! -f "$HOME/.config/glab-cli/config.yml" ] || [ -L "$HOME/.config/glab-cli/config.yml" ]; then
  rm -fv "$HOME/.config/glab-cli/config.yml"
  mkdir -pv "$HOME/.config/glab-cli"
  install -v -m 600 "$DOTFILES/glab/config.yml" "$HOME/.config/glab-cli/config.yml"
fi

chmod -v 700 "$HOME/.gnupg" "$HOME/.ssh"
chmod -v 400 "$HOME/.gnupg/keys/"* "$HOME/.ssh/id_"* || true
for key in "$HOME/.gnupg/keys/"*.pgp; do
  [ -f "$key" ] && gpg --batch --yes --import "$key"
done

defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

mise trust "$DOTFILES/mise/config.toml"
bat cache --build

clone https://github.com/gufranco/claude-engineering-rules.git "$HOME/.claude"

echo "Done. Some changes take effect only after a reboot."

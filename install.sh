#!/usr/bin/env bash

set -Eeo pipefail

################################################################################
# Global variables
################################################################################
SCRIPT_START_TIME=$(date +%s)
export SCRIPT_START_TIME

################################################################################
# Load utility functions
################################################################################
# Try to load from local zsh/config/core first
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""

# If core not available locally, download temporarily
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/zsh/config/core" ]; then
  # Running via curl | bash - download core to temp location
  TEMP_UTILITIES=$(mktemp)
  trap 'rm -f "$TEMP_UTILITIES"' EXIT
  if curl -fsSL --connect-timeout 10 --max-time 60 https://raw.githubusercontent.com/gufranco/dotfiles/master/zsh/config/core -o "$TEMP_UTILITIES" 2>/dev/null; then
    # shellcheck source=/dev/null
    source "$TEMP_UTILITIES"
    rm -f "$TEMP_UTILITIES"
    trap - EXIT
  else
    echo "ERROR: Could not download utility functions"
    exit 1
  fi
else
  # Load from local file
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/zsh/config/core"
fi

log_info() { __say "$@"; }
log_success() { __say "$@"; }
log_skip() { __say "$@"; }
log_warning() { __warn install "$@"; }
log_error() { __error install "$@"; }
cmd_exists() { __cmd_exists "$@"; }
safe_link() { __safe_link "$@"; }

brew_install_if_missing() {
  brew list "$1" >/dev/null 2>&1 || brew install "$1"
}

brew_install_cask_if_missing() {
  brew list --cask "$1" >/dev/null 2>&1 || brew install --cask "$1"
}

github_repo_sync() {
  local https_url="$1"
  local target_dir="$2"
  local label="$3"
  local ssh_url="${https_url/https:\/\/github.com\//git@github.com:}"

  log_info "Setting up ${label}..."
  if [ -d "$target_dir/.git" ]; then
    git -C "$target_dir" remote set-url origin "$https_url" 2>/dev/null || true
    git -C "$target_dir" pull --no-edit 2>/dev/null || log_warning "failed to pull ${label}"
    git -C "$target_dir" remote set-url origin "$ssh_url" 2>/dev/null || true
    git -C "$target_dir" submodule update --init --remote --recursive 2>/dev/null || log_warning "submodule update failed"
    log_success "${label} updated"
  else
    git clone --recursive "$https_url" "$target_dir"
    git -C "$target_dir" remote set-url origin "$ssh_url" 2>/dev/null || true
    log_success "${label} cloned"
  fi
}

if [ "$(uname)" != "Darwin" ]; then
  log_error "these dotfiles support macOS only."
  exit 1
fi

################################################################################
# Error handling
################################################################################
trap 'log_error "installation failed at line $LINENO"' ERR

################################################################################
# Installation
################################################################################
log_info "Installing the dotfiles."

################################################################################
# User confirmation (skip in CI)
################################################################################
if [[ -z "$CI" ]]; then
  echo ""
  log_warning "this script will install/update dotfiles and may overwrite existing configurations."
  if ! read -p "Continue? (Y/n) " -n 1 -r </dev/tty; then
    log_error "no terminal to confirm on. Set CI=1 to run without the prompt."
    exit 1
  fi
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n "$REPLY" ]]; then
    log_info "Installation cancelled."
    exit 0
  fi
else
  log_info "Running in CI environment - skipping user interaction."
fi

log_info "System: macOS ($(uname -m))"

############################################################################
# Rosetta 2 (Apple Silicon)
############################################################################
if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
  log_info "Installing Rosetta 2..."
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license 2>/dev/null || true
  log_success "Rosetta 2 installed"
fi

############################################################################
# Homebrew
############################################################################
if ! cmd_exists brew; then
  log_info "Installing Homebrew..."
  CI=1 /bin/bash -c "$(curl -fsSL --connect-timeout 10 --max-time 120 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  log_success "Homebrew installed"
else
  log_skip "Homebrew already installed"
fi

case "$(uname -m)" in
  "arm64") __setup_homebrew "/opt/homebrew" ;;
  "x86_64") __setup_homebrew "/usr/local" ;;
esac

############################################################################
# Dotfiles repository
############################################################################
github_repo_sync "https://github.com/gufranco/dotfiles.git" "$HOME/.dotfiles" "dotfiles"

############################################################################
# Homebrew packages
############################################################################
log_info "Installing Homebrew packages..."
brew update
brew trust gufranco/tap || log_warning "could not trust gufranco/tap"
brew bundle --file "$HOME/.dotfiles/Brewfile" || log_warning "Brewfile sync had failures"
brew bundle cleanup --force --no-taps --file "$HOME/.dotfiles/Brewfile" || true
brew upgrade --greedy --force || log_warning "brew upgrade had failures"
brew cleanup -s || true

while IFS= read -r unlinked_formula; do
  [ -z "$unlinked_formula" ] && continue
  log_info "Linking $unlinked_formula..."
  brew link --overwrite "$unlinked_formula" >/dev/null 2>&1 ||
    log_warning "could not link $unlinked_formula"
done < <(brew bundle check --verbose --file "$HOME/.dotfiles/Brewfile" 2>&1 |
  awk '/needs to be linked/ {print $3}')

for llvm_tool in clang-tidy clang-format; do
  [ -x "$HOMEBREW_PREFIX/opt/llvm/bin/$llvm_tool" ] &&
    safe_link "$HOMEBREW_PREFIX/opt/llvm/bin/$llvm_tool" "$HOME/.local/bin/$llvm_tool"
done

log_success "Homebrew packages updated"

############################################################################
# Bash
############################################################################
if ! grep -q "$HOMEBREW_PREFIX/bin/bash" /etc/shells 2>/dev/null; then
  log_info "Adding Homebrew bash to /etc/shells..."
  echo "$HOMEBREW_PREFIX/bin/bash" | sudo tee -a /etc/shells >/dev/null
  log_success "Bash added to /etc/shells"
fi

############################################################################
# Zsh
############################################################################
if ! grep -q "$HOMEBREW_PREFIX/bin/zsh" /etc/shells 2>/dev/null; then
  log_info "Adding Homebrew zsh to /etc/shells..."
  echo "$HOMEBREW_PREFIX/bin/zsh" | sudo tee -a /etc/shells >/dev/null
  log_success "Zsh added to /etc/shells"
fi

if [ "$SHELL" != "$HOMEBREW_PREFIX/bin/zsh" ]; then
  chsh -s "$HOMEBREW_PREFIX/bin/zsh" || true
  log_success "Shell changed to Zsh"
else
  log_skip "Shell already Zsh"
fi

log_info "Disabling .DS_Store on removable and network volumes..."
if __macos_no_ds_store_on_foreign_volumes; then
  log_success "Finder will not write .DS_Store to USB or network volumes"
else
  log_warning "could not set the Finder defaults"
fi

############################################################################
# Python (debugger + REPL)
############################################################################
if ! cmd_exists torrentzip; then
  log_info "Installing torrentzip..."
  if cmd_exists go; then
    go install github.com/uwedeportivo/torrentzip/cmd/torrentzip@latest
    log_success "torrentzip installed"
  else
    log_warning "Go not found, skipping torrentzip"
  fi
else
  log_skip "torrentzip already installed"
fi

if cmd_exists uv && [ -f "$HOME/.dotfiles/Uvfile" ]; then
  log_info "Installing uv tools..."
  uv_ok=0
  uv_skip=0
  uv_fail=0
  while IFS= read -r pkg || [ -n "$pkg" ]; do
    [ -z "$pkg" ] && continue
    [ "${pkg:0:1}" = '#' ] && continue
    pkg_name="${pkg%%\[*}"
    if uv tool list 2>/dev/null | awk '/^[^-[:space:]]/ {print $1}' | grep -Fqx "$pkg_name"; then
      ((uv_skip++)) || true
    else
      if uv tool install "$pkg" --quiet 2>/dev/null; then
        ((uv_ok++)) || true
      else
        log_warning "failed to install uv tool: $pkg"
        ((uv_fail++)) || true
      fi
    fi
  done <"$HOME/.dotfiles/Uvfile"
  if [ "$uv_fail" -eq 0 ]; then
    log_success "uv tools installed (new: $uv_ok, already present: $uv_skip)"
  else
    log_warning "uv tools installed with $uv_fail failure(s)"
  fi
else
  log_skip "uv not found or Uvfile missing, skipping uv tools"
fi

log_info "Setting up Python debugging configs..."
safe_link "$HOME/.dotfiles/python/.pdbrc" "$HOME/.pdbrc"
safe_link "$HOME/.dotfiles/python/pythonrc" "$HOME/.pythonrc"
safe_link "$HOME/.dotfiles/python/debughook.py" "$HOME/.config/python/debughook.py"
# Richer breakpoint() debuggers. The fallback hook degrades to stdlib pdb when
# these are missing, so this is best-effort and never fatal.
if cmd_exists python3; then
  if python3 -m pip install --user --upgrade --quiet pdbp ipdb >/dev/null 2>&1; then
    log_success "Python debuggers pdbp and ipdb installed"
  else
    log_skip "pdbp/ipdb not installed; breakpoint() falls back to stdlib pdb"
  fi
fi

############################################################################
# Node.js
############################################################################
log_info "Setting up Node.js configs..."
safe_link "$HOME/.dotfiles/nodejs/.npmrc" "$HOME/.npmrc"
safe_link "$HOME/.dotfiles/nodejs/.yarnrc.yml" "$HOME/.yarnrc.yml"
safe_link "$HOME/.dotfiles/nodejs/.pnpmrc" "$HOME/.pnpmrc"
safe_link "$HOME/.dotfiles/nodejs/repl-init.mjs" "$HOME/.config/node/repl-init.mjs"

log_info "Setting up linter configs..."
safe_link "$HOME/.dotfiles/clang-tidy/.clang-tidy" "$HOME/.clang-tidy"
safe_link "$HOME/.dotfiles/golangci/golangci.yml" "$HOME/.golangci.yml"
safe_link "$HOME/.dotfiles/ruff/ruff.toml" "$HOME/.config/ruff/ruff.toml"
safe_link "$HOME/.dotfiles/rubocop/config.yml" "$HOME/.config/rubocop/config.yml"
safe_link "$HOME/.dotfiles/luacheck/luacheckrc" "$HOME/.config/luacheck/.luacheckrc"
safe_link "$HOME/.dotfiles/dart/analysis_options.yaml" "$HOME/analysis_options.yaml"

############################################################################
# mise
############################################################################
log_info "Setting up mise..."
mkdir -p "$HOME/.config/mise"
safe_link "$HOME/.dotfiles/mise/config.toml" "$HOME/.config/mise/config.toml"
if cmd_exists mise; then
  mise trust "$HOME/.dotfiles/mise/config.toml" >/dev/null 2>&1 || true
  if mise install --yes 2>/dev/null; then
    log_success "mise runtimes installed"
  else
    log_warning "mise install had warnings"
  fi
fi

############################################################################
# Oh My Zsh
############################################################################
log_info "Setting up Oh My Zsh..."
safe_link "$HOME/.dotfiles/zsh/.zshrc" "$HOME/.zshrc"

github_repo_sync "https://github.com/robbyrussell/oh-my-zsh.git" "$HOME/.oh-my-zsh" "Oh My Zsh"
github_repo_sync "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "zsh-autosuggestions"
github_repo_sync "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"
github_repo_sync "https://github.com/zsh-users/zsh-completions.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" "zsh-completions"
github_repo_sync "https://github.com/Aloxaf/fzf-tab.git" "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" "fzf-tab"
github_repo_sync "https://github.com/denysdovhan/spaceship-prompt.git" "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" "spaceship-prompt"

safe_link "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

############################################################################
# Git
############################################################################
log_info "Setting up Git..."
safe_link "$HOME/.dotfiles/git/.gitconfig" "$HOME/.gitconfig"

############################################################################
# Vim
############################################################################
log_info "Setting up Vim..."
safe_link "$HOME/.dotfiles/vim" "$HOME/.vim"
safe_link "$HOME/.dotfiles/vim/vimrc" "$HOME/.vimrc"

############################################################################
# Neovim
############################################################################
log_info "Setting up Neovim..."
mkdir -p "$HOME/.config"
safe_link "$HOME/.dotfiles/nvim" "$HOME/.config/nvim"

############################################################################
# GPG
############################################################################
log_info "Setting up GPG..."
safe_link "$HOME/.dotfiles/gnupg" "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg" 2>/dev/null || log_warning "failed to set gnupg permissions"
chmod 400 "$HOME/.gnupg/keys/"* 2>/dev/null || true

safe_link "$HOME/.dotfiles/gnupg/gpg-agent-macos-$(uname -m).conf" "$HOME/.gnupg/gpg-agent.conf"

# Import GPG keys (idempotent - import is safe to repeat)
for key in "$HOME/.gnupg/keys/"*.pgp; do
  [ -f "$key" ] && { gpg --batch --yes --quiet --import "$key" 2>/dev/null || log_warning "failed to import GPG key: $(basename "$key")"; }
done

############################################################################
# SSH
############################################################################
log_info "Setting up SSH..."
safe_link "$HOME/.dotfiles/ssh" "$HOME/.ssh"
chmod 700 "$HOME/.ssh" 2>/dev/null || log_warning "failed to set ssh permissions"
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
chmod 400 "$HOME/.ssh/id_"* 2>/dev/null || true
chmod 644 "$HOME/.ssh/"*.pub 2>/dev/null || true

############################################################################
# Neomutt
############################################################################
log_info "Setting up Neomutt..."
safe_link "$HOME/.dotfiles/mutt/.muttrc" "$HOME/.muttrc"
safe_link "$HOME/.dotfiles/mutt" "$HOME/.mutt"
safe_link "$HOME/.dotfiles/mailcap/.mailcap" "$HOME/.mailcap"

############################################################################
# Tmux
############################################################################
log_info "Setting up Tmux..."
safe_link "$HOME/.dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
safe_link "$HOME/.dotfiles/tmux" "$HOME/.tmux"

############################################################################
# Curl
############################################################################
log_info "Setting up Curl..."
safe_link "$HOME/.dotfiles/curl/.curlrc" "$HOME/.curlrc"

############################################################################
# Wget
############################################################################
log_info "Setting up Wget..."
safe_link "$HOME/.dotfiles/wget/.wgetrc" "$HOME/.wgetrc"

############################################################################
# Readline
############################################################################
log_info "Setting up Readline..."
safe_link "$HOME/.dotfiles/readline/.inputrc" "$HOME/.inputrc"

############################################################################
# htop
############################################################################
log_info "Setting up htop..."
safe_link "$HOME/.dotfiles/htop/htoprc" "$HOME/.config/htop/htoprc"

############################################################################
# Ripgrep
############################################################################
log_info "Setting up Ripgrep..."
safe_link "$HOME/.dotfiles/ripgrep/.ripgreprc" "$HOME/.ripgreprc"

############################################################################
# fd
############################################################################
log_info "Setting up fd..."
safe_link "$HOME/.dotfiles/fd/.fdrc" "$HOME/.fdrc"

############################################################################
# Telnet
############################################################################
log_info "Setting up Telnet..."
safe_link "$HOME/.dotfiles/telnet/.telnetrc" "$HOME/.telnetrc"

############################################################################
# Ghostty
############################################################################
log_info "Setting up Ghostty..."
safe_link "$HOME/.dotfiles/ghostty" "$HOME/.config/ghostty"
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
safe_link "$HOME/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

############################################################################
# Bat
############################################################################
log_info "Setting up Bat..."
safe_link "$HOME/.dotfiles/bat/config" "$HOME/.config/bat/config"
safe_link "$HOME/.dotfiles/bat/catppuccin/themes" "$HOME/.config/bat/themes"

if cmd_exists bat; then bat cache --build >/dev/null 2>&1 || true; fi

############################################################################
# cmus
############################################################################
log_info "Setting up cmus..."
safe_link "$HOME/.dotfiles/cmus/rc" "$HOME/.config/cmus/rc"

############################################################################
# Midnight Commander (mc)
############################################################################
log_info "Setting up Midnight Commander..."
mkdir -p "$HOME/.config/mc"
safe_link "$HOME/.dotfiles/mc/ini" "$HOME/.config/mc/ini"
mkdir -p "$HOME/.local/share/mc/skins"
safe_link "$HOME/.dotfiles/mc/catppuccin/catppuccin.ini" "$HOME/.local/share/mc/skins/catppuccin.ini"

############################################################################
# GitHub CLI
############################################################################
log_info "Setting up GitHub CLI..."
mkdir -p "$HOME/.config/gh"
safe_link "$HOME/.dotfiles/gh/config.yml" "$HOME/.config/gh/config.yml"

############################################################################
# GitLab CLI
############################################################################
log_info "Setting up GitLab CLI..."
mkdir -p "$HOME/.config/glab-cli"
GLAB_CONFIG="$HOME/.config/glab-cli/config.yml"
if [ -L "$GLAB_CONFIG" ]; then
  rm -f "$GLAB_CONFIG"
fi
if [ -e "$GLAB_CONFIG" ]; then
  log_skip "glab config already present"
else
  install -m 600 "$HOME/.dotfiles/glab/config.yml" "$GLAB_CONFIG"
  log_success "Seeded: $GLAB_CONFIG"
fi

############################################################################
# Tealdeer (tldr)
############################################################################
log_info "Setting up Tealdeer..."
mkdir -p "$HOME/.config/tealdeer"
safe_link "$HOME/.dotfiles/tealdeer/config.toml" "$HOME/.config/tealdeer/config.toml"
if cmd_exists tldr; then tldr --update 2>/dev/null || true; fi

############################################################################
# Bottom (btm)
############################################################################
log_info "Setting up Bottom..."
mkdir -p "$HOME/.config/bottom"
safe_link "$HOME/.dotfiles/bottom/bottom.toml" "$HOME/.config/bottom/bottom.toml"

############################################################################
# Lazygit
############################################################################
log_info "Setting up Lazygit..."
mkdir -p "$HOME/.config/lazygit"
safe_link "$HOME/.dotfiles/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
mkdir -p "$HOME/Library/Application Support/lazygit"
safe_link "$HOME/.dotfiles/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"

############################################################################
# Lazydocker
############################################################################
log_info "Setting up Lazydocker..."
mkdir -p "$HOME/.config/lazydocker"
safe_link "$HOME/.dotfiles/lazydocker/config.yml" "$HOME/.config/lazydocker/config.yml"
mkdir -p "$HOME/Library/Application Support/jesseduffield/lazydocker"
safe_link "$HOME/.dotfiles/lazydocker/config.yml" "$HOME/Library/Application Support/jesseduffield/lazydocker/config.yml"

############################################################################
# K9s
############################################################################
log_info "Setting up K9s..."
mkdir -p "$HOME/.config/k9s"
safe_link "$HOME/.dotfiles/k9s/config.yml" "$HOME/.config/k9s/config.yml"
safe_link "$HOME/.dotfiles/k9s/catppuccin/dist" "$HOME/.config/k9s/skins"
mkdir -p "$HOME/Library/Application Support/k9s"
safe_link "$HOME/.dotfiles/k9s/config.yml" "$HOME/Library/Application Support/k9s/config.yml"
safe_link "$HOME/.dotfiles/k9s/catppuccin/dist" "$HOME/Library/Application Support/k9s/skins"

############################################################################
# OpenCode
############################################################################
log_info "Setting up OpenCode..."
safe_link "$HOME/.dotfiles/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

############################################################################
# Atuin
############################################################################
log_info "Setting up Atuin..."
mkdir -p "$HOME/.config/atuin"
safe_link "$HOME/.dotfiles/atuin/config.toml" "$HOME/.config/atuin/config.toml"

############################################################################
# direnv
############################################################################
log_info "Setting up direnv..."
mkdir -p "$HOME/.config/direnv"
safe_link "$HOME/.dotfiles/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
safe_link "$HOME/.dotfiles/direnv/direnv.toml" "$HOME/.config/direnv/direnv.toml"

############################################################################
# tig
############################################################################
log_info "Setting up tig..."
mkdir -p "$HOME/.config/tig"
safe_link "$HOME/.dotfiles/tig/config" "$HOME/.config/tig/config"

############################################################################
# Broot
############################################################################
log_info "Setting up Broot..."
mkdir -p "$HOME/.config/broot"
safe_link "$HOME/.dotfiles/broot/conf.toml" "$HOME/.config/broot/conf.toml"

############################################################################
# Ranger
############################################################################
log_info "Setting up Ranger..."
mkdir -p "$HOME/.config/ranger"
safe_link "$HOME/.dotfiles/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
safe_link "$HOME/.dotfiles/ranger/rifle.conf" "$HOME/.config/ranger/rifle.conf"
safe_link "$HOME/.dotfiles/ranger/scope.sh" "$HOME/.config/ranger/scope.sh"

############################################################################
# Newsboat
############################################################################
log_info "Setting up Newsboat..."
mkdir -p "$HOME/.config/newsboat"
safe_link "$HOME/.dotfiles/newsboat/config" "$HOME/.config/newsboat/config"
safe_link "$HOME/.dotfiles/newsboat/urls" "$HOME/.config/newsboat/urls"

############################################################################
# asciinema
############################################################################
log_info "Setting up asciinema..."
mkdir -p "$HOME/.config/asciinema"
safe_link "$HOME/.dotfiles/asciinema/config.toml" "$HOME/.config/asciinema/config.toml"

############################################################################
# Navi
############################################################################
log_info "Setting up Navi..."
mkdir -p "$HOME/.config/navi"
safe_link "$HOME/.dotfiles/navi/config.yaml" "$HOME/.config/navi/config.yaml"
safe_link "$HOME/.dotfiles/navi/cheats" "$HOME/.config/navi/cheats"

############################################################################
# GoAccess
############################################################################
log_info "Setting up GoAccess..."
mkdir -p "$HOME/.config/goaccess"
safe_link "$HOME/.dotfiles/goaccess/goaccess.conf" "$HOME/.config/goaccess/goaccess.conf"

############################################################################
# Claude Code
############################################################################
github_repo_sync "https://github.com/gufranco/claude-engineering-rules.git" "$HOME/.claude" "Claude engineering rules"

############################################################################
# Cleanup
############################################################################
log_info "Cleaning up..."
brew cleanup -s 2>/dev/null || true

__macos_post_install_cleanup

# TRIM
if [ "$(system_profiler SPSerialATADataType 2>/dev/null | grep 'TRIM Support' | awk '{print $3}')" = "Yes" ]; then
  log_warning "TRIM is supported. To enable, run: sudo trimforce enable"
fi

################################################################################
# Finish
################################################################################
# Calculate total execution time
SCRIPT_END_TIME=$(date +%s)
TOTAL_ELAPSED=$((SCRIPT_END_TIME - SCRIPT_START_TIME))
TOTAL_MINS=$((TOTAL_ELAPSED / 60))
TOTAL_SECS=$((TOTAL_ELAPSED % 60))

log_info "Some changes take effect only after a reboot."
log_success "Installed in ${TOTAL_MINS}m${TOTAL_SECS}s."

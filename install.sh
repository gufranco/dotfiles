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
# Try to load from local zsh/core first
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""

# If core not available locally, download temporarily
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/zsh/core" ]; then
  # Running via curl | bash - download core to temp location
  TEMP_UTILITIES=$(mktemp)
  trap 'rm -f "$TEMP_UTILITIES"' EXIT
  if curl -fsSL --connect-timeout 10 --max-time 60 https://raw.githubusercontent.com/gufranco/dotfiles/master/zsh/core -o "$TEMP_UTILITIES" 2>/dev/null; then
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
  source "$SCRIPT_DIR/zsh/core"
fi

################################################################################
# Wrapper functions (remove __ prefix for install.sh)
################################################################################
log_info() { __log_info "$@"; }
log_success() { __log_success "$@"; }
log_warning() { __log_warning "$@"; }
log_error() { __log_error "$@"; }
log_skip() { __log_skip "$@"; }
cmd_exists() { __cmd_exists "$@"; }
pkg_installed() { __pkg_installed "$@"; }
snap_installed() { __snap_installed "$@"; }
safe_link() { __safe_link "$@"; }
git_sync() { __git_sync "$@"; }
apt_install_if_missing() { __apt_install_if_missing "$@"; }
apt_add_key_and_repo() { __apt_add_key_and_repo "$@"; }
brew_install_if_missing() { __brew_install_if_missing "$@"; }
brew_install_cask_if_missing() { __brew_install_cask_if_missing "$@"; }
github_repo_sync() {
  local https_url="$1"
  local target_dir="$2"
  local label="$3"
  local ssh_url="${https_url/https:\/\/github.com\//git@github.com:}"

  log_info "Setting up ${label}..."
  if [ -d "$target_dir/.git" ]; then
    git -C "$target_dir" remote set-url origin "$https_url" 2>/dev/null || true
    git -C "$target_dir" pull --no-edit 2>/dev/null || log_warning "Failed to pull ${label}"
    git -C "$target_dir" remote set-url origin "$ssh_url" 2>/dev/null || true
    git -C "$target_dir" submodule update --init --recursive 2>/dev/null || log_warning "Submodule update failed"
    log_success "${label} updated"
  else
    git clone --recursive "$https_url" "$target_dir"
    git -C "$target_dir" remote set-url origin "$ssh_url" 2>/dev/null || true
    log_success "${label} cloned"
  fi
}

################################################################################
# Error handling
################################################################################
trap 'log_error "Installation failed at line $LINENO"' ERR

################################################################################
# Installation
################################################################################
echo ""
log_info "==============================================================="
log_info "Dotfiles Installation Script"
log_info "==============================================================="
echo ""

################################################################################
# User confirmation (skip in CI)
################################################################################
if [[ -z "$CI" ]]; then
  echo ""
  log_warning "This script will install/update dotfiles and may overwrite existing configurations."
  read -p "Continue? (Y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n "$REPLY" ]]; then
    log_info "Installation cancelled."
    exit 0
  fi
else
  log_info "Running in CI environment - skipping user interaction."
fi

################################################################################
# OS-specific installation
################################################################################
case "$(uname)" in
  "Linux")
    log_info "System: Linux (Ubuntu/Debian)"
    export DEBIAN_FRONTEND=noninteractive
    export GIT_TERMINAL_PROMPT=0

    ############################################################################
    # System update
    ############################################################################
    log_info "Updating system..."
    sudo add-apt-repository -y universe >/dev/null 2>&1 || true
    sudo apt update -qq
    sudo apt dist-upgrade -y -qq
    log_success "System updated"

    ############################################################################
    # Third-party repositories (latest versions from maintainers)
    ############################################################################
    log_info "Adding third-party repositories..."
    sudo add-apt-repository -y ppa:git-core/ppa >/dev/null 2>&1 || true
    sudo add-apt-repository -y ppa:jonathonf/vim >/dev/null 2>&1 || true
    sudo add-apt-repository -y ppa:neovim-ppa/stable >/dev/null 2>&1 || true
    sudo apt update -qq
    log_success "Repositories configured"

    ############################################################################
    # Basic packages
    ############################################################################
    log_info "Installing basic packages..."
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

    BASIC_PKGS=(
      # Build essentials
      build-essential ca-certificates cmake curl
      git gnupg software-properties-common autoconf automake libtool gettext

      # Compression
      exfatprogs p7zip-full unrar unzip zip zlib1g-dev

      # Shell & Terminal
      bash tmux snapd trash-cli xsel bc

      # Text & Search
      vim neovim ripgrep fd-find jq moreutils patchutils urlview

      # Network
      wget rsync rclone nmap mtr telnet httpie

      # System monitoring
      htop

      # Development
      shellcheck ruby ruby-dev python3-pygments

      # Misc
      ubuntu-restricted-extras
    )

    for pkg in "${BASIC_PKGS[@]}"; do
      apt_install_if_missing "$pkg"
    done

    log_success "Basic packages installed"

    ############################################################################
    # Dotfiles repository
    ############################################################################
    github_repo_sync "https://github.com/gufranco/dotfiles.git" "$HOME/.dotfiles" "dotfiles"

    ############################################################################
    # Zsh
    ############################################################################
    log_info "Installing Zsh..."
    apt_install_if_missing zsh
    apt_install_if_missing zsh-syntax-highlighting

    if ! grep -q "$(command -v zsh)" /etc/shells 2>/dev/null; then
      command -v zsh | sudo tee -a /etc/shells >/dev/null
    fi

    if [ "$SHELL" != "$(command -v zsh)" ]; then
      sudo chsh "$USER" -s "$(command -v zsh)" 2>/dev/null || true
      log_success "Shell changed to Zsh"
    else
      log_skip "Shell already Zsh"
    fi

    ############################################################################
    # Docker
    ############################################################################
    if ! cmd_exists docker; then
      log_info "Installing Docker..."
      apt_add_key_and_repo \
        "https://download.docker.com/linux/ubuntu/gpg" \
        "/etc/apt/keyrings/docker.gpg" \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        "/etc/apt/sources.list.d/docker.list" \
        "docker-ce"
      log_success "Docker installed"
    else
      log_skip "Docker already installed"
    fi

    if ! groups "$USER" | grep -q docker; then
      sudo usermod -a -G docker "$USER"
      log_success "User added to docker group"
    fi

    ############################################################################
    # Node.js 24
    ############################################################################
    if ! cmd_exists node || [ "$(node --version | cut -d. -f1 | tr -d v)" -lt 24 ]; then
      log_info "Installing Node.js 24..."
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL --connect-timeout 10 --max-time 30 https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg 2>/dev/null || true
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list >/dev/null
      sudo apt update -qq
      sudo apt install -y -qq nodejs
      log_success "Node.js installed"
    else
      log_skip "Node.js 24+ already installed"
    fi

    ############################################################################
    # Python (latest from deadsnakes)
    ############################################################################
    log_info "Setting up Python..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1 || true
    sudo apt update -qq
    PYTHON_LATEST=$(apt-cache pkgnames python3. 2>/dev/null | grep -E '^python3\.[0-9]+$' | sort -t. -k2 -n | tail -1)
    if [ -n "$PYTHON_LATEST" ]; then
      if ! cmd_exists "$PYTHON_LATEST"; then
        log_info "Installing ${PYTHON_LATEST}..."
        sudo apt install -y -qq "$PYTHON_LATEST"
        log_success "${PYTHON_LATEST} installed"
      else
        log_skip "${PYTHON_LATEST} already installed"
      fi
    else
      log_warning "Could not determine latest Python version from deadsnakes"
    fi

    ############################################################################
    # Applications
    ############################################################################
    APPS=(
      # File managers & Cloud
      nautilus-dropbox

      # Search & Navigation
      fzf universal-ctags

      # Email & Web
      neomutt lynx

      # Media
      vlc cmus asciinema

      # Desktop
      conky-all kitty fonts-hack-ttf transmission caffeine flameshot

      # Dev tools
      hyperfine tokei tty-clock
    )

    for app in "${APPS[@]}"; do
      if ! pkg_installed "$app"; then
        log_info "Installing $app..."
        sudo apt install -y -qq "$app" 2>/dev/null || log_warning "Failed: $app"
      fi
    done

    ############################################################################
    # GitHub CLI
    ############################################################################
    if ! cmd_exists gh; then
      log_info "Installing GitHub CLI..."
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL --connect-timeout 10 --max-time 30 https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli.gpg >/dev/null
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      sudo apt update -qq
      sudo apt install -y -qq gh
      log_success "GitHub CLI installed"
    else
      log_skip "GitHub CLI already installed"
    fi

    ############################################################################
    # Bat (cat replacement)
    ############################################################################
    if ! cmd_exists bat && ! cmd_exists batcat; then
      log_info "Installing bat..."
      sudo apt install -y -qq bat 2>/dev/null || true
      # Ubuntu uses 'batcat' instead of 'bat'
      if cmd_exists batcat && ! cmd_exists bat; then
        sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
      fi
      log_success "Bat installed"
    else
      log_skip "Bat already installed"
    fi

    ############################################################################
    # eza (ls replacement)
    ############################################################################
    if ! cmd_exists eza; then
      log_info "Installing eza..."
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL --connect-timeout 10 --max-time 30 https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
      sudo apt update -qq
      sudo apt install -y -qq eza
      log_success "eza installed"
    else
      log_skip "eza already installed"
    fi

    ############################################################################
    # Delta (git diff)
    ############################################################################
    apt_install_if_missing git-delta

    ############################################################################
    # Starship prompt
    ############################################################################
    if ! cmd_exists starship; then
      log_info "Installing Starship..."
      curl -sS --connect-timeout 10 --max-time 120 https://starship.rs/install.sh | sh -s -- --yes
      log_success "Starship installed"
    else
      log_skip "Starship already installed"
    fi

    ############################################################################
    # Zoxide (smart cd)
    ############################################################################
    if ! cmd_exists zoxide; then
      log_info "Installing zoxide..."
      curl -sS --connect-timeout 10 --max-time 120 https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
      log_success "zoxide installed"
    else
      log_skip "zoxide already installed"
    fi

    ############################################################################
    # Atuin (shell history)
    ############################################################################
    if ! cmd_exists atuin; then
      log_info "Installing atuin..."
      curl -sS --connect-timeout 10 --max-time 120 https://setup.atuin.sh | bash
      log_success "atuin installed"
    else
      log_skip "atuin already installed"
    fi

    ############################################################################
    # Golang
    ############################################################################
    if ! cmd_exists go; then
      log_info "Installing Go..."
      sudo add-apt-repository -y ppa:longsleep/golang-backports >/dev/null 2>&1 || true
      sudo apt update -qq
      sudo apt install -y -qq golang-go
      log_success "Go installed"
    else
      log_skip "Go already installed"
    fi

    ############################################################################
    # Rust
    ############################################################################
    if ! cmd_exists rustc; then
      log_info "Installing Rust..."
      if snap_installed rustup; then
        log_skip "rustup snap already installed"
      else
        sudo snap install rustup --classic 2>/dev/null || true
      fi
      if cmd_exists rustup; then
        rustup default stable >/dev/null 2>&1
        log_success "Rust installed"
      else
        log_warning "Rust not available via snap"
      fi
    else
      log_skip "Rust already installed"
    fi

    ############################################################################
    # mise
    ############################################################################
    if ! cmd_exists mise; then
      log_info "Installing mise..."
      apt_add_key_and_repo \
        "https://mise.jdx.dev/gpg-key.pub" \
        "/etc/apt/keyrings/mise-archive-keyring.gpg" \
        "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" \
        "/etc/apt/sources.list.d/mise.list" \
        "mise"
      log_success "mise installed"
    else
      log_skip "mise already installed"
    fi

    ############################################################################
    # Desktop apps (skip in CI - no GUI available)
    ############################################################################
    if [[ -z "$CI" ]]; then
      # Spotify
      if ! pkg_installed spotify-client; then
        log_info "Installing Spotify..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL --connect-timeout 10 --max-time 30 https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/spotify.gpg 2>/dev/null || true
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null
        sudo apt update -qq
        sudo apt install -y -qq spotify-client
        log_success "Spotify installed"
      else
        log_skip "Spotify already installed"
      fi

      # Google Chrome
      if ! pkg_installed google-chrome-stable; then
        log_info "Installing Google Chrome..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL --connect-timeout 10 --max-time 30 https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome.gpg 2>/dev/null || true
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
        sudo apt update -qq
        sudo apt install -y -qq google-chrome-stable
        log_success "Chrome installed"
      else
        log_skip "Chrome already installed"
      fi

      # DBeaver
      if ! pkg_installed dbeaver-ce; then
        log_info "Installing DBeaver..."
        sudo add-apt-repository -y ppa:serge-rider/dbeaver-ce >/dev/null 2>&1 || true
        sudo apt update -qq
        sudo apt install -y -qq dbeaver-ce
        log_success "DBeaver installed"
      else
        log_skip "DBeaver already installed"
      fi

      # Visual Studio Code
      if ! pkg_installed code; then
        log_info "Installing VS Code..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL --connect-timeout 10 --max-time 30 https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/visual_studio.gpg 2>/dev/null || true
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/visual_studio.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
        sudo apt update -qq
        sudo apt install -y -qq code
        log_success "VS Code installed"
      else
        log_skip "VS Code already installed"
      fi

      # Snap packages
      if cmd_exists snap; then
        snap_installed beekeeper-studio || { log_info "Installing Beekeeper Studio..."; sudo snap install beekeeper-studio 2>/dev/null || true; }
        snap_installed postman || { log_info "Installing Postman..."; sudo snap install postman 2>/dev/null || true; }
        snap_installed slack || { log_info "Installing Slack..."; sudo snap install slack 2>/dev/null || true; }
        snap_installed discord || { log_info "Installing Discord..."; sudo snap install discord 2>/dev/null || true; }
        snap_installed sublime-text || { log_info "Installing Sublime Text..."; sudo snap install sublime-text --classic 2>/dev/null || true; }
        snap_installed insomnia || { log_info "Installing Insomnia..."; sudo snap install insomnia 2>/dev/null || true; }
        snap_installed steam || { log_info "Installing Steam..."; sudo snap install steam 2>/dev/null || true; }
      fi
    else
      log_skip "Desktop apps (CI environment)"
    fi

    ############################################################################
    # GPG
    ############################################################################
    apt_install_if_missing gpg
    apt_install_if_missing pinentry-curses

    ############################################################################
    # Nerd Fonts (no apt/snap package available, direct download required)
    ############################################################################
    log_info "Installing Nerd Fonts..."
    mkdir -p "$HOME/.local/share/fonts"

    NERD_FONTS_VERSION=$(curl -s --connect-timeout 10 --max-time 30 https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep tag_name | cut -d '"' -f 4)
    NERD_FONTS_VERSION="${NERD_FONTS_VERSION:-v3.3.0}"

    if [ ! -f "$HOME/.local/share/fonts/HackNerdFont-Regular.ttf" ]; then
      curl -#fLo "$HOME/.local/share/fonts/HackNerdFont-Regular.ttf" --connect-timeout 10 --max-time 120 \
        "https://github.com/ryanoasis/nerd-fonts/raw/${NERD_FONTS_VERSION}/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf"
    fi

    if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
      curl -#fLo "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" --connect-timeout 10 --max-time 120 \
        "https://github.com/ryanoasis/nerd-fonts/raw/${NERD_FONTS_VERSION}/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
    fi

    sudo fc-cache -fv >/dev/null 2>&1
    log_success "Fonts installed"

    ############################################################################
    # Conky
    ############################################################################
    safe_link "$HOME/.dotfiles/conky/.conkyrc" "$HOME/.conkyrc"

    ############################################################################
    # Tilix
    ############################################################################
    safe_link "$HOME/.dotfiles/tilix/tokyonight-night-tilix.json" "$HOME/.config/tilix/schemes/tokyonight-night.json"

    ############################################################################
    # GPU drivers (x86_64 only)
    ############################################################################
    if [ "$(dpkg --print-architecture)" = "amd64" ]; then
      log_info "Installing NVIDIA drivers..."
      NVIDIA_VERSION=550
      sudo dpkg --add-architecture i386
      sudo apt update -qq
      sudo apt -y upgrade -qq

      if ! pkg_installed "nvidia-driver-$NVIDIA_VERSION"; then
        sudo apt install -y "nvidia-driver-${NVIDIA_VERSION}" "libnvidia-gl-${NVIDIA_VERSION}:i386"
        log_success "NVIDIA drivers installed"
      else
        log_skip "NVIDIA drivers already installed"
      fi

      # Mesa drivers (point release)
      log_info "Installing Mesa drivers (point release)..."
      sudo add-apt-repository -y ppa:kisak/kisak-mesa >/dev/null 2>&1 || true
      sudo apt update -qq
      sudo apt -y upgrade -qq

      # Mesa drivers (bleeding edge)
      log_info "Installing Mesa drivers (bleeding edge)..."
      sudo add-apt-repository -y ppa:oibaf/graphics-drivers >/dev/null 2>&1 || true
      sudo apt update -qq
      sudo apt -y upgrade -qq
      log_success "GPU drivers configured"
    else
      log_skip "GPU drivers (not supported on $(dpkg --print-architecture))"
    fi

    ;;

  "Darwin")
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
    brew bundle --file "$HOME/.dotfiles/Brewfile" || log_warning "Brewfile sync had failures"
    brew bundle cleanup --force --file "$HOME/.dotfiles/Brewfile" || true
    brew upgrade --greedy --force || log_warning "Brew upgrade had failures"
    brew cleanup -s || true
    log_success "Homebrew packages updated"

    ############################################################################
    # torrentzip (Go, not in Homebrew)
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

    ;;
esac

############################################################################
# Universal configurations (Linux + macOS)
############################################################################

############################################################################
# Node.js
############################################################################
log_info "Setting up Node.js configs..."
safe_link "$HOME/.dotfiles/nodejs/.npmrc" "$HOME/.npmrc"
safe_link "$HOME/.dotfiles/nodejs/.yarnrc.yml" "$HOME/.yarnrc.yml"
safe_link "$HOME/.dotfiles/nodejs/.pnpmrc" "$HOME/.pnpmrc"

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
# Vim & Neovim (shared config)
############################################################################
log_info "Setting up Vim & Neovim..."
safe_link "$HOME/.dotfiles/nvim" "$HOME/.vim"
safe_link "$HOME/.dotfiles/nvim/init.vim" "$HOME/.vimrc"
safe_link "$HOME/.dotfiles/nvim" "$HOME/.config/nvim"

############################################################################
# GPG
############################################################################
log_info "Setting up GPG..."
safe_link "$HOME/.dotfiles/gnupg" "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg" 2>/dev/null || log_warning "Failed to set gnupg permissions"
chmod 400 "$HOME/.gnupg/keys/"* 2>/dev/null || true

case "$(uname)" in
  "Linux")
    safe_link "$HOME/.dotfiles/gnupg/gpg-agent-linux.conf" "$HOME/.gnupg/gpg-agent.conf"
    ;;
  "Darwin")
    safe_link "$HOME/.dotfiles/gnupg/gpg-agent-macos-$(uname -m).conf" "$HOME/.gnupg/gpg-agent.conf"
    ;;
esac

# Import GPG keys (idempotent - import is safe to repeat)
for key in "$HOME/.gnupg/keys/"*.pgp; do
  [ -f "$key" ] && { gpg --batch --yes --quiet --import "$key" 2>/dev/null || log_warning "Failed to import GPG key: $(basename "$key")"; }
done

############################################################################
# SSH
############################################################################
log_info "Setting up SSH..."
safe_link "$HOME/.dotfiles/ssh" "$HOME/.ssh"
chmod 700 "$HOME/.ssh" 2>/dev/null || log_warning "Failed to set ssh permissions"
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
# Kitty
############################################################################
log_info "Setting up Kitty..."
safe_link "$HOME/.dotfiles/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
safe_link "$HOME/.dotfiles/kitty/themes" "$HOME/.config/kitty/themes"

############################################################################
# Ghostty
############################################################################
log_info "Setting up Ghostty..."
safe_link "$HOME/.dotfiles/ghostty" "$HOME/.config/ghostty"
if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  safe_link "$HOME/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
fi

############################################################################
# Bat
############################################################################
log_info "Setting up Bat..."
safe_link "$HOME/.dotfiles/bat/config" "$HOME/.config/bat/config"
safe_link "$HOME/.dotfiles/bat/themes" "$HOME/.config/bat/themes"

if cmd_exists bat; then bat cache --build >/dev/null 2>&1 || true; fi

############################################################################
# eza
############################################################################
log_info "Setting up eza..."
safe_link "$HOME/.dotfiles/eza" "$HOME/.config/eza"

############################################################################
# cmus
############################################################################
log_info "Setting up cmus..."
safe_link "$HOME/.dotfiles/cmus/rc" "$HOME/.config/cmus/rc"

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
safe_link "$HOME/.dotfiles/glab/config.yml" "$HOME/.config/glab-cli/config.yml"

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
if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/lazygit"
  safe_link "$HOME/.dotfiles/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
fi

############################################################################
# Lazydocker
############################################################################
log_info "Setting up Lazydocker..."
mkdir -p "$HOME/.config/lazydocker"
safe_link "$HOME/.dotfiles/lazydocker/config.yml" "$HOME/.config/lazydocker/config.yml"
if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/jesseduffield/lazydocker"
  safe_link "$HOME/.dotfiles/lazydocker/config.yml" "$HOME/Library/Application Support/jesseduffield/lazydocker/config.yml"
fi

############################################################################
# K9s
############################################################################
log_info "Setting up K9s..."
mkdir -p "$HOME/.config/k9s"
safe_link "$HOME/.dotfiles/k9s/config.yml" "$HOME/.config/k9s/config.yml"
safe_link "$HOME/.dotfiles/k9s/skins" "$HOME/.config/k9s/skins"
if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/k9s"
  safe_link "$HOME/.dotfiles/k9s/config.yml" "$HOME/Library/Application Support/k9s/config.yml"
  safe_link "$HOME/.dotfiles/k9s/skins" "$HOME/Library/Application Support/k9s/skins"
fi

############################################################################
# Yazi
############################################################################
log_info "Setting up Yazi..."
safe_link "$HOME/.dotfiles/yazi" "$HOME/.config/yazi"
if cmd_exists ya; then ya pack -i 2>/dev/null || true; fi

############################################################################
# Starship
############################################################################
if cmd_exists starship; then
  log_info "Setting up Starship..."
  safe_link "$HOME/.dotfiles/starship/starship.toml" "$HOME/.config/starship.toml"
fi

############################################################################
# Kanata
############################################################################
log_info "Setting up Kanata..."
mkdir -p "$HOME/.config/kanata"
safe_link "$HOME/.dotfiles/kanata/kanata.kbd" "$HOME/.config/kanata/kanata.kbd"

############################################################################
# OpenCode
############################################################################
log_info "Setting up OpenCode..."
safe_link "$HOME/.dotfiles/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

############################################################################
# Claude Code
############################################################################
github_repo_sync "https://github.com/gufranco/claude-engineering-rules.git" "$HOME/.claude" "Claude engineering rules"

############################################################################
# Cleanup
############################################################################
log_info "Cleaning up..."
case "$(uname)" in
  "Linux")
    sudo apt autoremove -y -qq 2>/dev/null || true
    sudo apt clean 2>/dev/null || true
    ;;
  "Darwin")
    brew cleanup -s 2>/dev/null || true

    __macos_post_install_cleanup

    # TRIM
    if [ "$(system_profiler SPSerialATADataType 2>/dev/null | grep 'TRIM Support' | awk '{print $3}')" = "Yes" ]; then
      log_warning "TRIM is supported. To enable, run: sudo trimforce enable"
    fi
    ;;
esac

################################################################################
# Finish
################################################################################
# Calculate total execution time
SCRIPT_END_TIME=$(date +%s)
TOTAL_ELAPSED=$((SCRIPT_END_TIME - SCRIPT_START_TIME))
TOTAL_MINS=$((TOTAL_ELAPSED / 60))
TOTAL_SECS=$((TOTAL_ELAPSED % 60))

echo ""
log_success "==============================================================="
log_success "Installation completed successfully!"
log_success "==============================================================="
echo ""
log_info "Total execution time: ${TOTAL_MINS}m ${TOTAL_SECS}s"
echo ""
log_warning "Some changes may require a reboot to take effect"
echo ""

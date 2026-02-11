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
# Try to load from local zsh/utilities first
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""

# If utilities not available locally, download them temporarily
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/zsh/utilities" ]; then
  # Running via curl | bash - download utilities to temp location
  TEMP_UTILITIES=$(mktemp)
  if curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/zsh/utilities -o "$TEMP_UTILITIES" 2>/dev/null; then
    # shellcheck source=/dev/null
    source "$TEMP_UTILITIES"
    rm -f "$TEMP_UTILITIES"
  else
    echo "ERROR: Could not download utility functions"
    exit 1
  fi
else
  # Load from local file
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/zsh/utilities"
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
git_clone_or_update() { __git_clone_or_update "$@"; }

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
    # Basic packages
    ############################################################################
    log_info "Installing basic packages..."
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

    BASIC_PKGS=(
      # Build essentials
      apt-transport-https build-essential ca-certificates cmake curl g++ gcc
      git gnupg make software-properties-common autoconf automake libtool gettext

      # Compression
      exfat-fuse exfatprogs p7zip-full p7zip-rar rar unrar unzip zip zlib1g-dev

      # Shell & Terminal
      bash zsh tmux snapd trash-cli xsel bc

      # Text & Search
      ack vim neovim ripgrep fd-find jq moreutils patchutils urlview

      # Network
      curl wget rsync rclone nmap mtr telnet httpie

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
    log_info "Setting up dotfiles..."
    git_clone_or_update "https://github.com/gufranco/dotfiles.git" "$HOME/.dotfiles"
    git -C "$HOME/.dotfiles" remote set-url origin git@github.com:gufranco/dotfiles.git 2>/dev/null || true
    git -C "$HOME/.dotfiles" submodule update --init --recursive 2>/dev/null || true
    log_success "Dotfiles configured"

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
      curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/nodesource.gpg 2>/dev/null || true
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list >/dev/null
      sudo apt update -qq
      sudo apt install -y -qq nodejs
      log_success "Node.js installed"
    else
      log_skip "Node.js 24+ already installed"
    fi

    ############################################################################
    # Python 3.14
    ############################################################################
    if ! cmd_exists python3.14; then
      log_info "Installing Python 3.14..."
      sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1 || true
      sudo apt update -qq
      sudo apt install -y -qq python3.14
      log_success "Python 3.14 installed"
    else
      log_skip "Python 3.14 already installed"
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
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
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
      curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
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
    if ! cmd_exists delta; then
      log_info "Installing delta..."
      DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep tag_name | cut -d '"' -f 4)
      curl -#fLo /tmp/delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" 2>/dev/null || true
      sudo dpkg -i /tmp/delta.deb 2>/dev/null || true
      rm -f /tmp/delta.deb
      log_success "Delta installed"
    else
      log_skip "Delta already installed"
    fi

    ############################################################################
    # Starship prompt
    ############################################################################
    if ! cmd_exists starship; then
      log_info "Installing Starship..."
      curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
      log_success "Starship installed"
    else
      log_skip "Starship already installed"
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
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1
      log_success "Rust installed"
    else
      log_skip "Rust already installed"
    fi

    ############################################################################
    # Spotify
    ############################################################################
    if ! pkg_installed spotify-client; then
      log_info "Installing Spotify..."
      curl -fsSL https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg 2>/dev/null || true
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null
      sudo apt update -qq
      sudo apt install -y -qq spotify-client
      log_success "Spotify installed"
    else
      log_skip "Spotify already installed"
    fi

    ############################################################################
    # Google Chrome
    ############################################################################
    if ! pkg_installed google-chrome-stable; then
      log_info "Installing Google Chrome..."
      curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/google-chrome.gpg 2>/dev/null || true
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
      sudo apt update -qq
      sudo apt install -y -qq google-chrome-stable
      log_success "Chrome installed"
    else
      log_skip "Chrome already installed"
    fi

    ############################################################################
    # DBeaver
    ############################################################################
    if ! pkg_installed dbeaver-ce; then
      log_info "Installing DBeaver..."
      sudo add-apt-repository -y ppa:serge-rider/dbeaver-ce >/dev/null 2>&1 || true
      sudo apt update -qq
      sudo apt install -y -qq dbeaver-ce
      log_success "DBeaver installed"
    else
      log_skip "DBeaver already installed"
    fi

    ############################################################################
    # Visual Studio Code
    ############################################################################
    if ! pkg_installed code; then
      log_info "Installing VS Code..."
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/visual_studio.gpg 2>/dev/null || true
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/visual_studio.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
      sudo apt update -qq
      sudo apt install -y -qq code
      log_success "VS Code installed"
    else
      log_skip "VS Code already installed"
    fi

    ############################################################################
    # Snap packages
    ############################################################################
    if cmd_exists snap; then
      snap_installed postman || { log_info "Installing Postman..."; sudo snap install postman 2>/dev/null || true; }
      snap_installed slack || { log_info "Installing Slack..."; sudo snap install slack 2>/dev/null || true; }
      snap_installed discord || { log_info "Installing Discord..."; sudo snap install discord 2>/dev/null || true; }
      snap_installed sublime-text || { log_info "Installing Sublime Text..."; sudo snap install sublime-text --classic 2>/dev/null || true; }
      snap_installed insomnia || { log_info "Installing Insomnia..."; sudo snap install insomnia 2>/dev/null || true; }
      snap_installed steam || { log_info "Installing Steam..."; sudo snap install steam 2>/dev/null || true; }
    fi

    ############################################################################
    # GPG
    ############################################################################
    apt_install_if_missing gpg
    apt_install_if_missing pinentry-curses

    ############################################################################
    # Nerd Fonts
    ############################################################################
    log_info "Installing Nerd Fonts..."
    mkdir -p "$HOME/.local/share/fonts"

    if [ ! -f "$HOME/.local/share/fonts/HackNerdFont-Regular.ttf" ]; then
      curl -#fLo "$HOME/.local/share/fonts/HackNerdFont-Regular.ttf" \
        https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf
    fi

    if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
      curl -#fLo "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" \
        https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf
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
    # GPU drivers
    ############################################################################
    log_info "Installing NVIDIA drivers..."
    NVIDIA_VERSION=550
    sudo dpkg --add-architecture i386
    sudo apt update -qq
    sudo apt -y upgrade -qq

    if ! pkg_installed "nvidia-driver-$NVIDIA_VERSION"; then
      sudo apt install -y nvidia-driver-$NVIDIA_VERSION libnvidia-gl-$NVIDIA_VERSION:i386
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
      CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      log_success "Homebrew installed"
    else
      log_skip "Homebrew already installed"
    fi

    # Set Homebrew environment
    case "$(uname -m)" in
      "arm64")
        export HOMEBREW_PREFIX="/opt/homebrew"
        export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
        export HOMEBREW_REPOSITORY="/opt/homebrew"
        export HOMEBREW_SHELLENV_PREFIX="/opt/homebrew"
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
        export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
        export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
        ;;
      "x86_64")
        export HOMEBREW_PREFIX="/usr/local"
        export HOMEBREW_CELLAR="/usr/local/Cellar"
        export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
        export HOMEBREW_SHELLENV_PREFIX="/usr/local"
        export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
        export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:"
        export INFOPATH="/usr/local/share/info:${INFOPATH:-}"
        ;;
    esac

    ############################################################################
    # Dotfiles repository
    ############################################################################
    log_info "Setting up dotfiles..."
    if [ -d "$HOME/.dotfiles/.git" ]; then
      git -C "$HOME/.dotfiles" remote set-url origin https://github.com/gufranco/dotfiles.git 2>/dev/null || true
      git -C "$HOME/.dotfiles" pull --no-edit 2>/dev/null || true
      git -C "$HOME/.dotfiles" remote set-url origin git@github.com:gufranco/dotfiles.git 2>/dev/null || true
      git -C "$HOME/.dotfiles" submodule update --init --recursive 2>/dev/null || true
      log_success "Dotfiles updated"
    else
      git clone --recursive --depth=1 https://github.com/gufranco/dotfiles.git "$HOME/.dotfiles"
      git -C "$HOME/.dotfiles" remote set-url origin git@github.com:gufranco/dotfiles.git 2>/dev/null || true
      log_success "Dotfiles cloned"
    fi

    ############################################################################
    # Homebrew packages
    ############################################################################
    log_info "Installing Homebrew packages..."
    brew update
    brew bundle --file "$HOME/.dotfiles/Brewfile" || true
    brew bundle cleanup --force --file "$HOME/.dotfiles/Brewfile" || true
    brew upgrade || true
    cmd_exists brew-cu && brew cu --all --yes --cleanup 2>/dev/null || true
    brew cleanup -s || true
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
mkdir -p "$HOME/.nvm"

############################################################################
# Oh My Zsh
############################################################################
log_info "Setting up Oh My Zsh..."
safe_link "$HOME/.dotfiles/zsh/.zshrc" "$HOME/.zshrc"

git_sync "https://github.com/robbyrussell/oh-my-zsh.git" "$HOME/.oh-my-zsh" 1
git_sync "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" 1
git_sync "https://github.com/zsh-users/zsh-completions.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" 1
git_sync "https://github.com/Aloxaf/fzf-tab.git" "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" 1
git_sync "https://github.com/denysdovhan/spaceship-prompt.git" "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" 1

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
safe_link "$HOME/.dotfiles/vim/.vimrc" "$HOME/.vimrc"

############################################################################
# GPG
############################################################################
log_info "Setting up GPG..."
safe_link "$HOME/.dotfiles/gnupg" "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg" 2>/dev/null || true
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
  [ -f "$key" ] && gpg --batch --yes --quiet --import "$key" 2>/dev/null || true
done

############################################################################
# SSH
############################################################################
log_info "Setting up SSH..."
safe_link "$HOME/.dotfiles/ssh" "$HOME/.ssh"
chmod 700 "$HOME/.ssh" 2>/dev/null || true
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

cmd_exists bat && bat cache --build >/dev/null 2>&1 || true

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
cmd_exists tldr && tldr --update 2>/dev/null || true

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
if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/k9s"
  safe_link "$HOME/.dotfiles/k9s/config.yml" "$HOME/Library/Application Support/k9s/config.yml"
fi

############################################################################
# Claude Code
############################################################################
log_info "Setting up Claude Code..."
safe_link "$HOME/.dotfiles/claude" "$HOME/.claude"

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
log_info "Next steps:"
echo "  1. Review any warnings above"
echo "  2. Restart your terminal or run: source ~/.zshrc"
echo "  3. For Kitty: Press Cmd+F5 to reload config"
echo "  4. For Ghostty: Press Cmd+Shift+, to reload config"
echo ""
log_warning "Some changes may require a reboot to take effect"
log_info "To reboot now: sudo reboot"
echo ""

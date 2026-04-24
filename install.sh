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
    # log_info "Setting up Python..."
    # sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1 || true
    # sudo apt update -qq
    # PYTHON_LATEST=$(apt-cache pkgnames python3. 2>/dev/null | grep -E '^python3\.[0-9]+$' | sort -t. -k2 -n | tail -1)
    # if [ -n "$PYTHON_LATEST" ]; then
    #   if ! cmd_exists "$PYTHON_LATEST"; then
    #     log_info "Installing ${PYTHON_LATEST}..."
    #     sudo apt install -y -qq "$PYTHON_LATEST"
    #     log_success "${PYTHON_LATEST} installed"
    #   else
    #     log_skip "${PYTHON_LATEST} already installed"
    #   fi
    # else
    #   log_warning "Could not determine latest Python version from deadsnakes"
    # fi

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
      curl -sS --connect-timeout 10 --max-time 120 https://setup.atuin.sh | bash -s -- --non-interactive
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
      # Try snap first (works on full Ubuntu installs with systemd)
      if snap list 2>/dev/null | grep -q snapd; then
        if snap_installed rustup; then
          log_skip "rustup snap already installed"
        else
          sudo snap install rustup --classic 2>/dev/null || true
        fi
      fi
      # Fallback: use rustup installer (for containers and systems without snapd)
      if ! cmd_exists rustup; then
        curl --proto '=https' --tlsv1.2 -sSf --connect-timeout 10 --max-time 120 https://sh.rustup.rs | sh -s -- -y 2>/dev/null || true
        [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
      fi
      if cmd_exists rustup; then
        rustup default stable >/dev/null 2>&1
        log_success "Rust installed"
      else
        log_warning "Rust installation failed"
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
    # Desktop apps (apt-based, installed headlessly in CI)
    ############################################################################

    # Spotify
    if ! pkg_installed spotify-client; then
      log_info "Installing Spotify..."
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL --connect-timeout 10 --max-time 30 https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/spotify.gpg 2>/dev/null || true
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

    # Snap packages (require systemd, skip in CI/containers)
    if [[ -z "$CI" ]] && cmd_exists snap; then
      snap_installed beekeeper-studio || { log_info "Installing Beekeeper Studio..."; sudo snap install beekeeper-studio 2>/dev/null || true; }
      snap_installed postman || { log_info "Installing Postman..."; sudo snap install postman 2>/dev/null || true; }
      snap_installed slack || { log_info "Installing Slack..."; sudo snap install slack 2>/dev/null || true; }
      snap_installed discord || { log_info "Installing Discord..."; sudo snap install discord 2>/dev/null || true; }
      snap_installed sublime-text || { log_info "Installing Sublime Text..."; sudo snap install sublime-text --classic 2>/dev/null || true; }
      snap_installed insomnia || { log_info "Installing Insomnia..."; sudo snap install insomnia 2>/dev/null || true; }
    else
      log_skip "Snap packages (CI environment or snapd unavailable)"
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
    # GPU drivers and gaming (x86_64 only)
    ############################################################################
    if [ "$(dpkg --print-architecture)" = "amd64" ]; then
      # Enable 32-bit architecture (required for Steam, Proton, and 32-bit drivers)
      sudo dpkg --add-architecture i386
      sudo apt update -qq
      sudo apt -y upgrade -qq

      # NVIDIA drivers (auto-detect best driver for installed GPU)
      log_info "Installing NVIDIA drivers..."
      apt_install_if_missing ubuntu-drivers-common
      sudo ubuntu-drivers autoinstall 2>/dev/null || log_warning "NVIDIA auto-install had warnings"
      log_success "NVIDIA drivers configured"

      # NVIDIA Prime (hybrid GPU switching for laptops with iGPU + dGPU)
      apt_install_if_missing nvidia-prime

      # Blacklist Nouveau to prevent conflicts with proprietary NVIDIA driver
      NOUVEAU_BLACKLIST="/etc/modprobe.d/blacklist-nouveau.conf"
      if [ ! -f "$NOUVEAU_BLACKLIST" ]; then
        log_info "Blacklisting Nouveau..."
        printf 'blacklist nouveau\noptions nouveau modeset=0\n' | sudo tee "$NOUVEAU_BLACKLIST" >/dev/null
        log_success "Nouveau blacklisted"
      else
        log_skip "Nouveau already blacklisted"
      fi

      # NVIDIA DRM modesetting (required for Wayland, PRIME sync, suspend/resume)
      GRUB_FILE="/etc/default/grub"
      if [ -f "$GRUB_FILE" ] && ! grep -q "nvidia-drm.modeset=1" "$GRUB_FILE"; then
        log_info "Enabling NVIDIA DRM modesetting..."
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' "$GRUB_FILE"
        sudo update-grub 2>/dev/null || log_warning "update-grub had warnings"
        log_success "NVIDIA DRM modesetting enabled"
      else
        log_skip "NVIDIA DRM modesetting already configured"
      fi

      # NVIDIA dynamic power management (dGPU powers down when idle, saves battery)
      NVIDIA_POWER="/etc/modprobe.d/nvidia-power.conf"
      if [ ! -f "$NVIDIA_POWER" ]; then
        log_info "Configuring NVIDIA power management..."
        echo 'options nvidia NVreg_DynamicPowerManagement=0x02' | sudo tee "$NVIDIA_POWER" >/dev/null
        log_success "NVIDIA power management configured"
      else
        log_skip "NVIDIA power management already configured"
      fi

      # Mesa drivers (bleeding edge, includes RADV for AMD iGPU Vulkan)
      log_info "Installing Mesa drivers..."
      sudo add-apt-repository -y ppa:oibaf/graphics-drivers >/dev/null 2>&1 || true
      sudo apt update -qq
      sudo apt -y upgrade -qq
      log_success "Mesa drivers configured"

      # Vulkan support (64-bit + 32-bit for both NVIDIA and AMD GPUs)
      log_info "Installing Vulkan support..."
      VULKAN_PKGS=(
        vulkan-tools
        libvulkan1
        "libvulkan1:i386"
        mesa-vulkan-drivers
        "mesa-vulkan-drivers:i386"
        "libgl1-mesa-dri:i386"
      )
      for pkg in "${VULKAN_PKGS[@]}"; do
        apt_install_if_missing "$pkg"
      done
      log_success "Vulkan support installed"

      # Kernel parameters for gaming (SteamOS-aligned values)
      GAMING_SYSCTL="/etc/sysctl.d/99-gaming.conf"
      if [ ! -f "$GAMING_SYSCTL" ]; then
        log_info "Configuring gaming kernel parameters..."
        sudo tee "$GAMING_SYSCTL" >/dev/null <<'SYSCTL'
# Memory map limit for large games (Unity, Unreal Engine)
vm.max_map_count=2147483642

# Prefer keeping game data in RAM (default 60, lower = less swap)
vm.swappiness=10

# Disable proactive memory compaction (reduces random latency spikes)
vm.compaction_proactiveness=0

# Reduce dirty page ratios to prevent I/O stuttering during gameplay
vm.dirty_ratio=5
vm.dirty_background_ratio=5

# Disable split-lock mitigation (causes severe perf loss in some Proton games)
kernel.split_lock_mitigate=0
SYSCTL
        sudo sysctl --system >/dev/null 2>&1
        log_success "Gaming kernel parameters configured"
      else
        log_skip "Gaming kernel parameters already configured"
      fi

      # Raise file descriptor limits (Wine/Proton can exceed default 1024)
      GAMING_LIMITS="/etc/security/limits.d/99-gaming.conf"
      if [ ! -f "$GAMING_LIMITS" ]; then
        log_info "Configuring file descriptor limits..."
        printf '* soft nofile 1048576\n* hard nofile 1048576\n' | sudo tee "$GAMING_LIMITS" >/dev/null
        log_success "File descriptor limits configured"
      else
        log_skip "File descriptor limits already configured"
      fi

      # Controller support (udev rules for PS4, PS5, Switch, Steam Controller)
      apt_install_if_missing steam-devices

      # Add user to input group for controller access
      if ! groups "$USER" | grep -qw input; then
        sudo usermod -a -G input "$USER"
        log_success "User added to input group"
      fi

      # Gaming performance tools
      log_info "Installing gaming tools..."
      apt_install_if_missing gamemode
      apt_install_if_missing "libgamemodeauto0:i386"
      apt_install_if_missing mangohud
      apt_install_if_missing gamescope
      apt_install_if_missing protontricks
      log_success "Gaming tools installed"

      # Steam (from Valve's official repository)
      if ! pkg_installed steam-launcher; then
        log_info "Installing Steam..."
        echo "steam steam/question select I AGREE" | sudo debconf-set-selections
        echo "steam steam/license note ''" | sudo debconf-set-selections
        echo "steam steam/purge note ''" | sudo debconf-set-selections
        apt_add_key_and_repo \
          "https://repo.steampowered.com/steam/archive/stable/steam.gpg" \
          "/etc/apt/keyrings/steam.gpg" \
          "deb [arch=amd64,i386 signed-by=/etc/apt/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam" \
          "/etc/apt/sources.list.d/steam-stable.list" \
          "steam-launcher"
        log_success "Steam installed"
      else
        log_skip "Steam already installed"
      fi

      # ProtonUp-Qt (manages GE-Proton custom builds for better game compatibility)
      apt_install_if_missing flatpak
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
      if ! flatpak list 2>/dev/null | grep -q "net.davidotek.pupgui2"; then
        log_info "Installing ProtonUp-Qt..."
        flatpak install -y --noninteractive flathub net.davidotek.pupgui2 2>/dev/null || log_warning "ProtonUp-Qt install had warnings"
        log_success "ProtonUp-Qt installed"
      else
        log_skip "ProtonUp-Qt already installed"
      fi

      # GE-Proton (custom Proton with extra game patches, auto-download latest)
      PROTON_GE_DIR="$HOME/.steam/steam/compatibilitytools.d"
      mkdir -p "$PROTON_GE_DIR"
      if [ -z "$(command ls -A "$PROTON_GE_DIR" 2>/dev/null)" ]; then
        log_info "Installing latest GE-Proton..."
        GE_LATEST=$(curl -sL --connect-timeout 10 --max-time 30 \
          https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
          | grep tag_name | cut -d '"' -f 4)
        if [ -n "$GE_LATEST" ]; then
          curl -#fLo "/tmp/${GE_LATEST}.tar.gz" --connect-timeout 10 --max-time 300 \
            "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${GE_LATEST}/${GE_LATEST}.tar.gz"
          tar -xzf "/tmp/${GE_LATEST}.tar.gz" -C "$PROTON_GE_DIR"
          rm -f "/tmp/${GE_LATEST}.tar.gz"
          log_success "GE-Proton ${GE_LATEST} installed"
        else
          log_warning "Could not determine latest GE-Proton version"
        fi
      else
        log_skip "GE-Proton already installed"
      fi
    else
      log_skip "GPU drivers and gaming (not supported on $(dpkg --print-architecture))"
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
    # pipx CLI tools (Pipxfile)
    ############################################################################
    if cmd_exists pipx && [ -f "$HOME/.dotfiles/Pipxfile" ]; then
      log_info "Installing pipx tools..."
      pipx_ok=0
      pipx_skip=0
      pipx_fail=0
      while IFS= read -r pkg || [ -n "$pkg" ]; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if pipx list --short 2>/dev/null | awk '{print $1}' | grep -qx "$pkg"; then
          ((pipx_skip++)) || true
        else
          if pipx install "$pkg" --quiet 2>/dev/null; then
            ((pipx_ok++)) || true
          else
            log_warning "Failed to install pipx package: $pkg"
            ((pipx_fail++)) || true
          fi
        fi
      done < "$HOME/.dotfiles/Pipxfile"
      if [ "$pipx_fail" -eq 0 ]; then
        log_success "pipx tools installed (new: $pipx_ok, already present: $pipx_skip)"
      else
        log_warning "pipx tools installed with $pipx_fail failure(s)"
      fi
    else
      log_skip "pipx not found or Pipxfile missing, skipping pipx tools"
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
# thefuck
############################################################################
log_info "Setting up thefuck..."
mkdir -p "$HOME/.config/thefuck"
safe_link "$HOME/.dotfiles/thefuck/settings.py" "$HOME/.config/thefuck/settings.py"

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
# Navi
############################################################################
log_info "Setting up Navi..."
mkdir -p "$HOME/.config/navi"
safe_link "$HOME/.dotfiles/navi/config.yaml" "$HOME/.config/navi/config.yaml"
safe_link "$HOME/.dotfiles/navi/cheats" "$HOME/.config/navi/cheats"

############################################################################
# Glances
############################################################################
log_info "Setting up Glances..."
mkdir -p "$HOME/.config/glances"
safe_link "$HOME/.dotfiles/glances/glances.conf" "$HOME/.config/glances/glances.conf"

############################################################################
# asciinema
############################################################################
log_info "Setting up asciinema..."
mkdir -p "$HOME/.config/asciinema"
safe_link "$HOME/.dotfiles/asciinema/config.toml" "$HOME/.config/asciinema/config.toml"

############################################################################
# GoAccess
############################################################################
log_info "Setting up GoAccess..."
mkdir -p "$HOME/.config/goaccess"
safe_link "$HOME/.dotfiles/goaccess/goaccess.conf" "$HOME/.config/goaccess/goaccess.conf"

############################################################################
# Taskwarrior
############################################################################
log_info "Setting up Taskwarrior..."
mkdir -p "$HOME/.local/share/task"
safe_link "$HOME/.dotfiles/taskwarrior/taskrc" "$HOME/.taskrc"

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
if [ "$(uname)" = "Linux" ] && [ "$(dpkg --print-architecture 2>/dev/null)" = "amd64" ]; then
  log_warning "GPU and gaming changes require a reboot. Run 'gaming-check' after reboot to verify."
fi
echo ""

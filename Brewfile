# frozen_string_literal: true

################################################################################
# System specifications
################################################################################
architecture = `uname -m`.strip
cpu = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip
serial = `system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $NF}'`.strip
storage = (((`diskutil info /dev/disk0 | awk -F'[()]' '/Disk Size/ {sub(/ Bytes/, "", $2); print $2}'`.strip.to_i / 1073741824) + 255) / 256) * 256

################################################################################
# Homebrew taps
################################################################################
tap 'Arthur-Ficial/tap'
tap 'aws/tap'
tap 'DopplerHQ/cli'
tap 'neomutt/neomutt'
tap 'oven-sh/bun'
tap 'stripe/stripe-cli'
tap 'UltimateNova1203/maxcso'
tap 'ungive/media-control'
tap 'universal-ctags/universal-ctags'
tap 'withgraphite/tap'

################################################################################
# Shell & Terminal
################################################################################
brew 'atuin'
brew 'bash'
brew 'direnv'
brew 'gum'
brew 'starship'
brew 'tealdeer'
brew 'tmux'
brew 'tmuxp'
brew 'zsh'
brew 'zsh-autosuggestions'
brew 'zsh-syntax-highlighting'

################################################################################
# GNU & Core Utilities
################################################################################
brew 'bc'
brew 'binutils'
brew 'coreutils'
brew 'diffutils'
brew 'findutils'
brew 'gawk'
brew 'gnu-indent'
brew 'gnu-tar'
brew 'gnu-time'
brew 'gnu-units'
brew 'gnu-which'
brew 'gpatch'
brew 'grep'
brew 'gsed'
brew 'make'
brew 'moreutils'
brew 'p7zip'
brew 'patchutils'
brew 'unzip'
brew 'zip'

################################################################################
# Libraries & Build Dependencies
################################################################################
brew 'autoconf'
brew 'automake'
brew 'ca-certificates'
brew 'cmake'
brew 'gettext'
brew 'libtool'
brew 'openssl'
brew 'poppler'
brew 'pygments'
brew 'readline'
brew 'shared-mime-info'
brew 'zlib'

################################################################################
# File Navigation & Search
################################################################################
brew 'ack'
brew 'eza'
brew 'fd'
brew 'fzf'
brew 'nnn'
brew 'ripgrep'
brew 'yazi'
brew 'zoxide'

################################################################################
# Text Editors & Data Tools
################################################################################
brew 'bat'
brew 'glow'
brew 'jq'
brew 'neovim'
brew 'vim'
brew 'vint'
brew 'yq'

################################################################################
# Git & Version Control
################################################################################
brew 'delta'
brew 'difftastic'
brew 'gh'
brew 'git'
brew 'glab'
brew 'withgraphite/tap/graphite'
brew 'lazygit'

################################################################################
# Networking & HTTP
################################################################################
brew 'bandwhich'
brew 'curl'
brew 'doggo'
brew 'gping'
brew 'grpcurl'
brew 'httpie'
brew 'lynx'
brew 'mtr'
brew 'nmap'
brew 'sshpass'
brew 'telnet'
brew 'wget'

################################################################################
# Containers & Kubernetes
################################################################################
brew 'colima'
brew 'dive'
brew 'docker'
brew 'docker-compose'
brew 'docker-credential-helper'
brew 'helm'
brew 'k9s'
brew 'kubectl'
brew 'lazydocker'
brew 'lima-additional-guestagents'

################################################################################
# Cloud & Infrastructure
################################################################################
brew 'awscli'
brew 'flyctl'
brew 'opentofu'
brew 'terraform'
brew 'vercel-cli'

################################################################################
# Security & Encryption
################################################################################
brew 'age'
brew 'DopplerHQ/cli/doppler'
brew 'ghidra'
brew 'gitleaks'
brew 'gnupg'
brew 'pinentry-mac'
brew 'radare2'
brew 'semgrep'
brew 'snyk-cli'
brew 'sops'
brew 'trivy'

################################################################################
# Penetration Testing
################################################################################
brew 'dalfox'
brew 'ffuf'
brew 'gobuster'
brew 'hashcat'
brew 'hydra'
brew 'john'
brew 'nikto'
brew 'nuclei'
brew 'sqlmap'

################################################################################
# Languages & Package Managers
################################################################################
brew 'cocoapods'
brew 'golang', link: true
brew 'golangci-lint'
brew 'mise'
brew 'node', link: true
brew 'openjdk@21'
brew 'oven-sh/bun/bun', link: true
brew 'pipx'
brew 'pnpm'
brew 'python', link: true
brew 'ruby', link: true
brew 'rust', link: true
brew 'uv'
brew 'yarn'

################################################################################
# Development Tools
################################################################################
brew 'act'
brew 'actionlint'
brew 'bats'
brew 'entr'
brew 'hyperfine'
brew 'just'
brew 'mkcert'
brew 'shellcheck'
brew 'tokei'
brew 'universal-ctags'
brew 'watchman'
brew 'xcodes'

################################################################################
# Load Testing & Reliability
################################################################################
brew 'k6'
brew 'stress-ng'
brew 'toxiproxy'
brew 'vegeta'

################################################################################
# Database & SaaS CLIs
################################################################################
brew 'libpq'
brew 'mongocli'
brew 'stripe-cli'
brew 'supabase'

################################################################################
# Monitoring & System Info
################################################################################
brew 'bottom'
brew 'cpufetch'
brew 'duf'
brew 'dust'
brew 'fastfetch'
brew 'htop'
brew 'procs'
brew 'tty-clock'

################################################################################
# Email
################################################################################
brew 'mailutils'
brew 'neomutt'
brew 'urlview'

################################################################################
# Media
################################################################################
brew 'asciinema'
brew 'cmus'
brew 'fatsort'
brew 'ffmpeg'
brew 'media-control'
brew 'subliminal'

################################################################################
# Backup & Sync
################################################################################
brew 'rclone'
brew 'restic'
brew 'rsync'

################################################################################
# AI & Local Inference
################################################################################
brew 'arthur-ficial/tap/apfel' if architecture == 'arm64' # Apple Silicon AI benchmark
brew 'llama.cpp' if architecture == 'arm64'
brew 'ollama' if architecture == 'arm64'
brew 'opencode'
brew 'rtk'

################################################################################
# macOS System
################################################################################
brew 'kanata'
brew 'mas'

################################################################################
# Retro Gaming & ROM Tools
################################################################################
# torrentzip: installed via go install (see install.sh)
brew 'internetarchive'
brew 'mame'
brew 'UltimateNova1203/maxcso/maxcso'
brew 'ucon64'

################################################################################
# Casks - Terminals
################################################################################
cask 'ghostty'
cask 'iterm2'
cask 'kitty'

################################################################################
# Casks - Code Editors & IDEs
################################################################################
cask 'android-studio'
cask 'cursor'
cask 'cursor-cli'
cask 'sublime-text'
cask 'textmate'
cask 'visual-studio-code'
cask 'windsurf'

################################################################################
# Casks - AI Tools
################################################################################
cask 'auto-claude'
cask 'claude'
cask 'claude-code'
cask 'claude-devtools'
cask 'claude-island'
cask 'claudebar'
cask 'codex'
cask 'codex-app' if architecture == 'arm64'
cask 'jan' if architecture == 'arm64'
cask 'lm-studio' if architecture == 'arm64'
cask 'opencode-desktop'

################################################################################
# Casks - API & Database
################################################################################
cask 'beekeeper-studio'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'insomnia'
cask 'mongodb-compass'
cask 'ngrok'
cask 'postman'
cask 'proxyman'
cask 'redis-insight'
cask 'session-manager-plugin'

################################################################################
# Casks - Browsers
################################################################################
cask 'firefox'
cask 'google-chrome'

################################################################################
# Casks - Productivity
################################################################################
cask 'clickup'
cask 'granola'
cask 'linear-linear'
cask 'maccy'
cask 'obsidian'
cask 'shottr'

################################################################################
# Casks - Communication
################################################################################
cask 'discord'
cask 'slack'

################################################################################
# Casks - Design
################################################################################
cask 'figma'

################################################################################
# Casks - Security & VPN
################################################################################
cask '1password'
cask 'lastpass'
cask 'nordvpn'
cask 'tunnelblick'
cask 'wireshark-app'

################################################################################
# Casks - System & Hardware
################################################################################
# cask 'displaylink'
cask 'cleanmymac'
cask 'coconutbattery'
cask 'grandperspective'
cask 'logi-options+'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'stats'

################################################################################
# Casks - File Management & Utilities
################################################################################
cask 'balenaetcher'
cask 'cyberduck'
cask 'forklift'
cask 'keka'
cask 'maestral'

################################################################################
# Casks - Media & Entertainment
################################################################################
cask 'audacity'
cask 'calibre'
cask 'gimp'
cask 'handbrake-app'
cask 'inkscape'
cask 'iina'
cask 'jdownloader'
cask 'obs'
cask 'spotify'
cask 'steam'
cask 'transmission'
cask 'vlc'

################################################################################
# Casks - Emulators
################################################################################
cask 'ares-emulator'
cask 'cemu'
cask 'dolphin'
cask 'dosbox-x-app'
cask 'flycast'
cask 'melonds'
cask 'mgba-app'
cask 'openemu'
cask 'pcsx2'
cask 'ppsspp-emulator'
cask 'retroarch'
cask 'scummvm-app'
cask 'snes9x'
cask 'stella-app'
cask 'xemu'

################################################################################
# Casks - Virtualization
################################################################################
# cask 'orbstack'
cask 'crossover'
cask 'parallels' if architecture == 'arm64'

################################################################################
# Fonts
################################################################################
cask 'font-fira-code-nerd-font'
cask 'font-fira-mono-nerd-font'
cask 'font-hack-nerd-font'
cask 'font-jetbrains-mono-nerd-font'
cask 'font-ubuntu-mono-nerd-font'
cask 'font-ubuntu-nerd-font'
cask 'font-ubuntu-sans-nerd-font'

################################################################################
# App Store (skip in CI - no authenticated App Store session)
################################################################################
unless ENV['CI']
  mas 'Xcode', id: 497_799_835
  mas 'Amphetamine', id: 937_984_704
  mas 'Magnet', id: 441_258_766

  ############################################################################

  ############################################################################
  if architecture == 'arm64' && storage >= 2048
    mas 'Cyberpunk 2077', id: 6_633_429_424
    mas 'Death Stranding', id: 6_449_748_961
    mas 'Resident Evil 2', id: 1_640_632_432
    mas 'Resident Evil 3', id: 1_640_630_077
    mas 'Resident Evil 4', id: 6_462_360_082
    mas 'Resident Evil 7', id: 1_640_629_241
    mas 'Resident Evil 8', id: 1_640_627_334
    mas 'Stray', id: 6_451_498_949
  end
end

################################################################################
# Unsupported systems
#
# Macbook Pro 13 Mid 2012:  C02J332HDV30
# Macbook Retina 12 2017:   C02TW09THH29
################################################################################
if ['C02J332HDV30', 'C02TW09THH29'].include?(serial)
  cask 'opencore-patcher'
end

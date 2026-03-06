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
tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'neomutt/neomutt'
tap 'oven-sh/bun'
tap 'stripe/stripe-cli'
tap 'UltimateNova1203/maxcso'
tap 'DopplerHQ/cli'
tap 'ungive/media-control'
tap 'universal-ctags/universal-ctags'
tap 'withgraphite/tap'

################################################################################
# Shell & Terminal
################################################################################
brew 'bash'
brew 'direnv'
brew 'starship'
brew 'tmux'
brew 'zsh'
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

################################################################################
# Text Editors & Viewers
################################################################################
brew 'bat'
brew 'glow'
brew 'gum'
brew 'jq'
brew 'pygments'
brew 'tealdeer'
brew 'universal-ctags'
brew 'vim'
brew 'vint'
brew 'yq'

################################################################################
# Git & Version Control
################################################################################
brew 'delta'
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
brew 'gping'
brew 'httpie'
brew 'lynx'
brew 'mtr'
brew 'nmap'
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
brew 'gitleaks'
brew 'gnupg'
brew 'pinentry-mac'
brew 'snyk-cli'
brew 'sops'
brew 'trivy'

################################################################################
# Languages & Package Managers
################################################################################
brew 'chruby'
brew 'golang', link: true
brew 'golangci-lint'
brew 'node', link: true
brew 'nvm'
brew 'openjdk@17'
brew 'oven-sh/bun/bun', link: true
brew 'pipx'
brew 'pnpm'
brew 'python', link: true
brew 'ruby', link: true
brew 'ruby-install'
brew 'rust', link: true
brew 'uv'
brew 'yarn'

################################################################################
# Development Tools
################################################################################
brew 'act'
brew 'actionlint'
brew 'bats'
brew 'cocoapods'
brew 'entr'
brew 'hyperfine'
brew 'just'
brew 'shellcheck'
brew 'tokei'
brew 'watchman'
brew 'xcodes'

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
# Media & Retro Gaming
################################################################################
brew 'asciinema'
brew 'cmus'
brew 'fatsort'
brew 'media-control'
brew 'UltimateNova1203/maxcso/maxcso'
brew 'ucon64'

################################################################################
# Backup & Sync
################################################################################
brew 'rclone'
brew 'restic'
brew 'rsync'

################################################################################
# macOS
################################################################################
brew 'mas'

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
# AI & Local Inference
################################################################################
brew 'llama.cpp'
brew 'ollama'

################################################################################
# Casks - AI Tools
################################################################################
cask 'claude-code'
cask 'codex'
cask 'codex-app'
cask 'jan'
cask 'lm-studio'

################################################################################
# Casks - API & Database
################################################################################
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
# cask 'raycast'
cask 'clickup'
cask 'granola'
cask 'linear-linear'
cask 'maccy'
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

################################################################################
# Casks - System & Hardware
################################################################################
cask 'cleanmymac'
cask 'coconutbattery'
cask 'displaylink' if /\AApple M[\d]\z/.match?(cpu)
cask 'grandperspective'
cask 'istat-menus'
cask 'logi-options+'
cask 'macs-fan-control' unless /\AApple M[\d]\z/.match?(cpu)
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'

################################################################################
# Casks - File Management & Utilities
################################################################################
cask 'balenaetcher'
cask 'cyberduck'
cask 'keka'
cask 'maestral'

################################################################################
# Casks - Media & Entertainment
################################################################################
cask 'flixtools'
cask 'jdownloader'
cask 'spotify', args: { no_quarantine: true }
cask 'transmission'
cask 'vlc'

################################################################################
# Casks - Virtualization
################################################################################
# cask 'orbstack'
cask 'parallels' if architecture == 'arm64'

################################################################################
# Fonts
################################################################################
cask 'font-geist'
cask 'font-geist-mono'
cask 'font-inter'
cask 'font-0xproto-nerd-font'
cask 'font-3270-nerd-font'
cask 'font-adwaita-mono-nerd-font'
cask 'font-agave-nerd-font'
cask 'font-anonymice-nerd-font'
cask 'font-arimo-nerd-font'
cask 'font-atkynson-mono-nerd-font'
cask 'font-aurulent-sans-mono-nerd-font'
cask 'font-bigblue-terminal-nerd-font'
cask 'font-bitstream-vera-sans-mono-nerd-font'
cask 'font-blex-mono-nerd-font'
cask 'font-caskaydia-cove-nerd-font'
cask 'font-caskaydia-mono-nerd-font'
cask 'font-code-new-roman-nerd-font'
cask 'font-comic-shanns-mono-nerd-font'
cask 'font-commit-mono-nerd-font'
cask 'font-cousine-nerd-font'
cask 'font-d2coding-nerd-font'
cask 'font-daddy-time-mono-nerd-font'
cask 'font-dejavu-sans-mono-nerd-font'
cask 'font-departure-mono-nerd-font'
cask 'font-droid-sans-mono-nerd-font'
cask 'font-envy-code-r-nerd-font'
cask 'font-fantasque-sans-mono-nerd-font'
cask 'font-fira-code-nerd-font'
cask 'font-fira-mono-nerd-font'
cask 'font-geist-mono-nerd-font'
cask 'font-go-mono-nerd-font'
cask 'font-gohufont-nerd-font'
cask 'font-hack-nerd-font'
cask 'font-hasklug-nerd-font'
cask 'font-heavy-data-nerd-font'
cask 'font-hurmit-nerd-font'
cask 'font-im-writing-nerd-font'
cask 'font-inconsolata-go-nerd-font'
cask 'font-inconsolata-lgc-nerd-font'
cask 'font-inconsolata-nerd-font'
cask 'font-intone-mono-nerd-font'
cask 'font-iosevka-nerd-font'
cask 'font-iosevka-term-nerd-font'
cask 'font-iosevka-term-slab-nerd-font'
cask 'font-jetbrains-mono-nerd-font'
cask 'font-lekton-nerd-font'
cask 'font-liberation-nerd-font'
cask 'font-lilex-nerd-font'
cask 'font-m+-nerd-font'
cask 'font-martian-mono-nerd-font'
cask 'font-meslo-lg-nerd-font'
cask 'font-monaspice-nerd-font'
cask 'font-monocraft-nerd-font'
cask 'font-monofur-nerd-font'
cask 'font-monoid-nerd-font'
cask 'font-mononoki-nerd-font'
cask 'font-noto-nerd-font'
cask 'font-opendyslexic-nerd-font'
cask 'font-overpass-nerd-font'
cask 'font-profont-nerd-font'
cask 'font-proggy-clean-tt-nerd-font'
cask 'font-recursive-mono-nerd-font'
cask 'font-roboto-mono-nerd-font'
cask 'font-sauce-code-pro-nerd-font'
cask 'font-sf-mono-nerd-font-ligaturized'
cask 'font-shure-tech-mono-nerd-font'
cask 'font-space-mono-nerd-font'
cask 'font-symbols-only-nerd-font'
cask 'font-terminess-ttf-nerd-font'
cask 'font-tinos-nerd-font'
cask 'font-ubuntu-mono-nerd-font'
cask 'font-ubuntu-nerd-font'
cask 'font-ubuntu-sans-nerd-font'
cask 'font-victor-mono-nerd-font'
cask 'font-zed-mono-nerd-font'

################################################################################
# App Store (skip in CI - no authenticated App Store session)
################################################################################
unless ENV['CI']
  mas 'Xcode', id: 497_799_835
  mas 'Amphetamine', id: 937_984_704
  mas 'Magnet', id: 441_258_766

  ############################################################################
  # App Store - Games
  ############################################################################
  if architecture == 'arm64' && storage >= 512
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
  cask 'aldente'
  cask 'opencore-patcher'
end

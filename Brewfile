# frozen_string_literal: true

################################################################################
# System specifications
################################################################################
model = Utils.safe_popen_read('sysctl', '-n', 'hw.model').strip
disk_bytes = Utils.safe_popen_read('diskutil', 'info', '/dev/disk0')[/\((\d+) Bytes\)/, 1].to_i
storage = ((disk_bytes / 1_073_741_824) + 255) / 256 * 256

################################################################################
# Homebrew taps
################################################################################
tap 'bjarneo/cliamp', trusted: true
tap 'browsh-org/browsh', trusted: true
tap 'clojure/tools', trusted: true
tap 'dciabrin/ngdevkit', trusted: true
tap 'drhelius/geardome', trusted: true
tap 'gufranco/tap', trusted: true
tap 'hashicorp/tap', trusted: true
tap 'oven-sh/bun', trusted: true
tap 'withgraphite/tap', trusted: true

################################################################################
# Shells
################################################################################
brew 'bash'
brew 'zsh'

################################################################################
# Terminal Multiplexers
################################################################################
brew 'screen'
brew 'tmux'
brew 'tmuxp'

################################################################################
# Shell Helpers
################################################################################
brew 'asciinema'
brew 'atuin'
brew 'direnv'
brew 'gum'
brew 'vhs'

################################################################################
# GNU Core Utilities
################################################################################
brew 'bc'
brew 'coreutils'
brew 'diffutils', link: false
brew 'ed'
brew 'findutils'
brew 'gawk'
brew 'gnu-sed'
brew 'gnu-tar'
brew 'gnu-time'
brew 'gnu-units'
brew 'gnu-which'
brew 'gpatch'
brew 'grep'

################################################################################
# Command-Line Utilities
################################################################################
brew 'file-formula'
brew 'man-db'
brew 'moreutils', link: false
brew 'parallel', link: false
brew 'patchutils'
brew 'gufranco/tap/nazuke'
brew 'gufranco/tap/shiwake'
brew 'tty-clock'
brew 'util-linux'

################################################################################
# Archives & Compression
################################################################################
brew 'cpio'
brew 'gzip'
brew 'p7zip'
brew 'gufranco/tap/torrentzip'
brew 'unar'
brew 'unzip'
brew 'zip'
cask 'keka'

################################################################################
# Disks, Filesystems & Disc Images
################################################################################
brew 'gufranco/tap/enban'
brew 'gufranco/tap/kakikomi'
brew 'gufranco/tap/katazuke'
brew 'gufranco/tap/kiyome'
brew 'gufranco/tap/nisemono'
brew 'xorriso'

################################################################################
# File Navigation & Search
################################################################################
brew 'fd'
brew 'fzf'
brew 'ranger'
brew 'ripgrep'
brew 'zoxide'

################################################################################
# Text Editors
################################################################################
brew 'nano'
brew 'neovim'
brew 'vim'

################################################################################
# Pagers & Viewers
################################################################################
brew 'bat'
brew 'glow'
brew 'jless'
brew 'less'
brew 'most'

################################################################################
# JSON & YAML
################################################################################
brew 'jq'
brew 'yq'

################################################################################
# Documents, PDF & OCR
################################################################################
brew 'pandoc'
brew 'poppler'
brew 'tectonic'

################################################################################
# Git
################################################################################
brew 'difftastic'
brew 'git'
brew 'git-absorb'
brew 'git-cliff'
brew 'git-crypt'
brew 'git-delta'
brew 'git-extras'
brew 'git-filter-repo'
brew 'tig'

################################################################################
# Code Hosting CLIs
################################################################################
brew 'gh'
brew 'glab'
brew 'withgraphite/tap/graphite'

################################################################################
# HTTP & Downloads
################################################################################
brew 'curl'
brew 'grpcurl'
brew 'internetarchive'
brew 'wget'
brew 'yt-dlp'

################################################################################
# Network Diagnostics
################################################################################
brew 'bandwhich'
brew 'doggo'
brew 'gping'
brew 'mtr'
brew 'nmap'
brew 'telnet'
brew 'whois'

################################################################################
# Remote Access & Tunnels
################################################################################
brew 'cloudflared'
brew 'sshpass'

################################################################################
# Terminal Web Browsers
################################################################################
brew 'browsh-org/browsh/browsh'
brew 'lynx'

################################################################################
# Mail & News
################################################################################
brew 'mailutils'
brew 'neomutt'
brew 'newsboat'
brew 'urlview'

################################################################################
# Containers
################################################################################
brew 'colima'
brew 'ctop'
brew 'dive'
brew 'docker'
brew 'docker-credential-helper'
brew 'gufranco/tap/kiban'
brew 'lima-additional-guestagents'

################################################################################
# Kubernetes
################################################################################
brew 'helm'
brew 'k9s'
brew 'kubectx'
brew 'kubernetes-cli'

################################################################################
# Infrastructure as Code
################################################################################
brew 'ansible'
brew 'opentofu'
brew 'hashicorp/tap/terraform'
brew 'terraform-docs'

################################################################################
# Cloud & SaaS CLIs
################################################################################
brew 'awscli'
brew 'flyctl'
brew 'stripe-cli'
cask 'session-manager-plugin'
cask 'vercel'

################################################################################
# Databases
################################################################################
brew 'libpq'
brew 'mongocli'
brew 'pgcli'
brew 'supabase'

################################################################################
# Secrets & Encryption
################################################################################
brew 'doppler'
brew 'gufranco/tap/fusho'
brew 'gnupg'
brew 'pinentry-mac'
brew 'sops'

################################################################################
# Security Scanning & Signing
################################################################################
brew 'cosign'
brew 'gitleaks'
brew 'semgrep'
brew 'trivy'
brew 'zizmor'

################################################################################
# Web Security Scanners
################################################################################
brew 'dalfox'
brew 'ffuf'
brew 'nikto'
brew 'nuclei'
brew 'sqlmap'

################################################################################
# Password Cracking
################################################################################
brew 'hashcat'
brew 'hydra'
brew 'john'

################################################################################
# Reverse Engineering
################################################################################
brew 'ghidra'
brew 'radare2'

################################################################################
# Languages & Runtimes
################################################################################
brew 'oven-sh/bun/bun', link: true
brew 'clojure/tools/clojure'
brew 'go', link: true
brew 'node', link: true
brew 'openjdk@21', link: false
brew 'python', link: true
brew 'ruby', link: true
brew 'rust', link: true

################################################################################
# Package & Version Managers
################################################################################
brew 'cocoapods'
brew 'conan'
brew 'mise'
brew 'pnpm'
brew 'uv'
brew 'yarn'

################################################################################
# Compilers & Build Tools
################################################################################
brew 'autoconf'
brew 'automake'
brew 'bear'
brew 'binutils'
brew 'bison'
brew 'cmake'
brew 'gcc'
brew 'gperf'
brew 'libtool'
brew 'llvm'
brew 'm4'
brew 'make'

################################################################################
# Libraries
################################################################################
brew 'ca-certificates'
brew 'gettext'
brew 'libiconv'
brew 'ncurses'
brew 'openssl'
brew 'readline'
brew 'shared-mime-info'
brew 'zlib'

################################################################################
# Linters - Shell, CI & Containers
################################################################################
brew 'actionlint'
brew 'hadolint'
brew 'shellcheck'
brew 'shfmt'
brew 'yamllint'

################################################################################
# Linters - Programming Languages
################################################################################
brew 'ast-grep'
brew 'cppcheck'
brew 'detekt'
brew 'gnu-indent'
brew 'golangci-lint'
brew 'luacheck'
brew 'pmd'
brew 'pyright'
brew 'rubocop'
brew 'swiftlint'
brew 'vint'

################################################################################
# Spelling & Prose
################################################################################
brew 'aspell'
brew 'typos-cli'
brew 'vale'

################################################################################
# Testing & Coverage
################################################################################
brew 'bats-core'
brew 'gcovr'
brew 'lychee'

################################################################################
# Benchmarking & Load Testing
################################################################################
brew 'hyperfine'
brew 'k6'
brew 'stress-ng'
brew 'toxiproxy'

################################################################################
# Developer Utilities
################################################################################
brew 'act'
brew 'entr'
brew 'fswatch'
brew 'mkcert'
brew 'pre-commit'
brew 'pygments'
brew 'universal-ctags'
brew 'watchman'

################################################################################
# System Monitoring
################################################################################
brew 'fastfetch'
brew 'htop'
brew 'macmon' if Hardware::CPU.arm?
brew 'osx-cpu-temp' if Hardware::CPU.intel?

################################################################################
# Log Analysis
################################################################################
brew 'goaccess'
brew 'lnav'

################################################################################
# macOS Integration
################################################################################
brew 'mas'
brew 'media-control'

################################################################################
# Backup & Sync
################################################################################
brew 'rclone'
brew 'rsync'

################################################################################
# Image Processing
################################################################################
brew 'exiftool'
brew 'imagemagick'
brew 'pngquant'
brew 'potrace'

################################################################################
# Video & Subtitles
################################################################################
brew 'ffmpeg'
brew 'gufranco/tap/jimaku'
brew 'gufranco/tap/yakitsuke'

################################################################################
# Terminal Music Players
################################################################################
brew 'bjarneo/cliamp/cliamp'
brew 'cmus'

################################################################################
# Local AI Inference
################################################################################
brew 'apfel' if Hardware::CPU.arm?
brew 'ollama'

################################################################################
# AI Coding CLIs
################################################################################
brew 'rtk'

################################################################################
# Retro Development Toolchains
################################################################################
brew 'cc65'
brew 'gufranco/tap/marsdev'
brew 'dciabrin/ngdevkit/ngdevkit', args: Hardware::CPU.arm? ? ['force-bottle'] : []
brew 'dciabrin/ngdevkit/ngdevkit-toolchain', args: Hardware::CPU.arm? ? ['force-bottle'] : []
brew 'rgbds'
brew 'sdcc'

################################################################################
# Retro ROM, Patch & Media Tools
################################################################################
brew 'gufranco/tap/anypatch'
brew 'gufranco/tap/fdstoolkit'
brew 'gufranco/tap/kirisute'
brew 'gufranco/tap/maeyomi'
brew 'gufranco/tap/maxcso'
brew 'ucon64'

################################################################################
# Terminals
################################################################################
cask 'ghostty'

################################################################################
# Code Editors & IDEs
################################################################################
cask 'android-studio'
cask 'sublime-text'
cask 'visual-studio-code'

################################################################################
# AI Assistants
################################################################################
cask 'claude'
cask 'lm-studio' if Hardware::CPU.arm?

################################################################################
# AI Coding Agents
################################################################################
cask 'claude-code@latest'

################################################################################
# Database Clients
################################################################################
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'mongodb-compass'
cask 'redis-insight'

################################################################################
# Network & HTTP Debugging
################################################################################
cask 'mitmproxy'
cask 'postman'
cask 'wireshark-app'

################################################################################
# Browsers
################################################################################
cask 'firefox'
cask 'google-chrome'

################################################################################
# VPN & Tunnels
################################################################################
cask 'ngrok'
cask 'nordvpn'
cask 'tunnelblick'

################################################################################
# Communication
################################################################################
cask 'discord'
cask 'slack'

################################################################################
# Notes & Planning
################################################################################
cask 'granola'
cask 'linear'
cask 'obsidian'

################################################################################
# Office & Reading
################################################################################
cask 'calibre'
cask 'libreoffice'
cask 'libreoffice-language-pack'

################################################################################
# Desktop Utilities
################################################################################
cask 'maccy'
cask 'shottr'

################################################################################
# System Monitoring
################################################################################
cask 'coconutbattery'
cask 'mx-power-gadget' if Hardware::CPU.arm?
cask 'stats'

################################################################################
# Displays & Peripherals
################################################################################
# cask 'displaylink'
cask 'monitorcontrol'
cask 'openlogi'

################################################################################
# Disk Cleanup
################################################################################
cask 'cleanmymac'
cask 'grandperspective'

################################################################################
# File Transfer & Sync
################################################################################
cask 'cyberduck'
cask 'maestral'

################################################################################
# Downloads
################################################################################
cask 'jdownloader'
cask 'transmission'

################################################################################
# Design & Vector
################################################################################
cask 'figma'

################################################################################
# Image Editing & Painting
################################################################################
cask 'gimp'
cask 'krita'
cask 'gufranco/tap/lazpaint' if Hardware::CPU.intel?

################################################################################
# Pixel Art & Sprites
################################################################################
brew 'gufranco/tap/aseprite', postinstall: '{ [ ! -L /Applications/Aseprite.app ] || rm /Applications/Aseprite.app; } && rsync -a --delete "${HOMEBREW_PREFIX:?}/opt/aseprite/Aseprite.app/" /Applications/Aseprite.app/'
cask 'gufranco/tap/libresprite'
cask 'gufranco/tap/pikopixel' if Hardware::CPU.intel?
cask 'gufranco/tap/pixelorama'

################################################################################
# Electronics & Microcontrollers
################################################################################
brew 'arduino-cli'
cask 'arduino-ide'

################################################################################
# Video Editing & Recording
################################################################################
cask 'handbrake-app'
cask 'keycastr'
cask 'losslesscut'
cask 'obs'

################################################################################
# Media Players
################################################################################
cask 'foobar2000'
cask 'iina'
cask 'spotify'
cask 'vlc'

################################################################################
# DAWs & Audio Editors
################################################################################
cask 'ableton-live-suite'
cask 'audacity'
cask 'gufranco/tap/lmms' if Hardware::CPU.intel?
cask 'gufranco/tap/m-vave-cubesuite' if Hardware::CPU.intel?
cask 'gufranco/tap/m-vave-m-upgrade'
cask 'gufranco/tap/m-vave-midi-suite'
cask 'midi-monitor'
cask 'reaper'

################################################################################
# Trackers & Chiptune
################################################################################
cask 'gufranco/tap/furnace'
cask 'gufranco/tap/sunvox'

################################################################################
# Synthesizers
################################################################################
cask 'gufranco/tap/socalabs-sn76489'
cask 'surge-xt'
cask 'vcv-rack'

################################################################################
# Game Engines
################################################################################
cask 'defold'
cask 'gb-studio'
cask 'gdevelop'
cask 'godot'

################################################################################
# Level Editors
################################################################################
cask 'gufranco/tap/ldtk'
cask 'tiled'

################################################################################
# Emulators - Multi-System & Frontends
################################################################################
brew 'mame'
brew 'mednafen'
cask 'ares-emulator'
cask 'drhelius/geardome/gearcoleco'
cask 'drhelius/geardome/geargrafx'
cask 'drhelius/geardome/gearlynx'
cask 'drhelius/geardome/gearsystem'
cask 'drhelius/geardome/geartowns'
cask 'gufranco/tap/mesen'
cask 'retroarch-metal'

################################################################################
# Emulators - Nintendo
################################################################################
brew 'gufranco/tap/zsnes'
cask 'gufranco/tap/azahar'
cask 'dolphin'
cask 'drhelius/geardome/gearboy'
cask 'mgba-app'
cask 'snes9x'

################################################################################
# Emulators - Sony
################################################################################
cask 'pcsx2' if Hardware::CPU.intel?
cask 'ppsspp-emulator'
cask 'gufranco/tap/rpcs3'
cask 'gufranco/tap/shadps4' if Hardware::CPU.intel?
cask 'gufranco/tap/vita3k'

################################################################################
# Virtualization
################################################################################
# cask 'crossover'
# cask 'parallels' if Hardware::CPU.arm?
# cask 'utm'

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
  mas 'Conji', id: 1_515_014_813
  # mas 'GarageBand', id: 682_658_836
  # mas 'DefleMask Tracker', id: 1_560_048_103
  mas 'Magnet', id: 441_258_766

  if Hardware::CPU.arm? && storage >= 2048
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
# Macbook Pro 13 Mid 2012:  MacBookPro9,2
# Macbook Retina 12 2017:   MacBook10,1
################################################################################
if ['MacBookPro9,2', 'MacBook10,1'].include?(model)
  # cask 'opencore-patcher'
  cask 'aldente'
  cask 'gufranco/tap/opencore-patcher@beta'
end

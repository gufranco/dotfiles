# frozen_string_literal: true

################################################################################
# System specifications
################################################################################
architecture = `uname -m`.strip
cpu = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip
serial = `ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/ {print $4}'`.strip
storage = (((`diskutil info /dev/disk0 | awk -F'[()]' '/Disk Size/ {sub(/ Bytes/, "", $2); print $2}'`.strip.to_i / 1073741824) + 255) / 256) * 256

################################################################################
# Homebrew taps
################################################################################
tap 'bjarneo/cliamp', trusted: true
tap 'browsh-org/browsh', trusted: true
tap 'clojure/tools', trusted: true
tap 'dciabrin/ngdevkit', trusted: true
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
brew 'navi'
brew 'tealdeer'

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
brew 'gufranco/tap/kakikomi'
brew 'gufranco/tap/katazuke'
brew 'gufranco/tap/kiyome'
brew 'xorriso'

################################################################################
# File Navigation & Search
################################################################################
brew 'broot'
brew 'fd'
brew 'fzf'
brew 'midnight-commander'
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
brew 'lazygit'
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
brew 'lazydocker'
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
brew 'dart-sdk'
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
brew 'fvm'
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
brew 'mkcert'
brew 'pre-commit'
brew 'pygments'
brew 'tokei'
brew 'universal-ctags'
brew 'watchman'
brew 'xcodes'

################################################################################
# System Monitoring
################################################################################
brew 'bottom'
brew 'fastfetch'
brew 'htop'
brew 'macmon' if architecture == 'arm64'
brew 'osx-cpu-temp' if architecture == 'x86_64'

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
brew 'apfel' if architecture == 'arm64'
brew 'ollama'

################################################################################
# AI Coding CLIs
################################################################################
brew 'opencode'
brew 'rtk'

################################################################################
# Retro Development Toolchains
################################################################################
brew 'cc65'
brew 'gufranco/tap/marsdev'
brew 'dciabrin/ngdevkit/ngdevkit', args: architecture == 'arm64' ? ['force-bottle'] : []
brew 'dciabrin/ngdevkit/ngdevkit-toolchain', args: architecture == 'arm64' ? ['force-bottle'] : []
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
cask 'iterm2'

################################################################################
# Code Editors & IDEs
################################################################################
cask 'android-studio'
cask 'devin-desktop'
cask 'sublime-text'
cask 'visual-studio-code'

################################################################################
# AI Assistants
################################################################################
cask 'chatgpt'
cask 'claude'
cask 'lm-studio' if architecture == 'arm64'

################################################################################
# AI Coding Agents
################################################################################
cask 'claude-code@latest'
cask 'coderabbit'
cask 'codex'
cask 'opencode-desktop'

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
cask 'tailscale-app'
cask 'tunnelblick'

################################################################################
# Communication
################################################################################
cask 'discord'
cask 'keybase'
cask 'signal'
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
cask 'mx-power-gadget' if architecture == 'arm64'
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
cask 'inkscape'

################################################################################
# Image Editing & Painting
################################################################################
cask 'gimp'
cask 'krita'
cask 'gufranco/tap/lazpaint' if architecture == 'x86_64'

################################################################################
# Pixel Art & Sprites
################################################################################
brew 'gufranco/tap/aseprite', postinstall: '{ [ ! -L /Applications/Aseprite.app ] || rm /Applications/Aseprite.app; } && rsync -a --delete "${HOMEBREW_PREFIX:?}/opt/aseprite/Aseprite.app/" /Applications/Aseprite.app/'
cask 'gufranco/tap/libresprite'
cask 'gufranco/tap/pikopixel' if architecture == 'x86_64'
cask 'gufranco/tap/pixelorama'

################################################################################
# Electronics & Microcontrollers
################################################################################
brew 'arduino-cli'
cask 'kicad'

################################################################################
# Video Editing & Recording
################################################################################
cask 'handbrake-app'
cask 'losslesscut'
cask 'obs'

################################################################################
# Media Players
################################################################################
cask 'foobar2000'
cask 'spotify'
cask 'vlc'

################################################################################
# DAWs & Audio Editors
################################################################################
cask 'audacity'
cask 'gufranco/tap/lmms' if architecture == 'x86_64'
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
cask 'surge-xt'
cask 'vcv-rack'

################################################################################
# Notation & Live Coding
################################################################################
cask 'musescore'
cask 'sonic-pi'

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
cask 'gufranco/tap/mesen'
cask 'retroarch-metal'

################################################################################
# Emulators - Nintendo
################################################################################
brew 'gufranco/tap/zsnes'
cask 'gufranco/tap/azahar'
cask 'dolphin'
cask 'mgba-app'
cask 'snes9x'

################################################################################
# Emulators - Sony
################################################################################
cask 'pcsx2' if architecture == 'x86_64'
cask 'ppsspp-emulator'
cask 'gufranco/tap/rpcs3'
cask 'gufranco/tap/shadps4' if architecture == 'x86_64'
cask 'gufranco/tap/vita3k'

################################################################################
# Emulators - Computers & Xbox
################################################################################
cask 'fs-uae-emulator'
cask 'fs-uae-launcher'
cask 'xemu'

################################################################################
# Games
################################################################################
cask 'scummvm-app'
cask 'steam'

################################################################################
# Virtualization
################################################################################
cask 'crossover'
cask 'parallels' if architecture == 'arm64'
cask 'utm'

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

if storage >= 512
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
  cask 'font-geist'
  cask 'font-geist-mono'
  cask 'font-geist-mono-nerd-font'
  cask 'font-go-mono-nerd-font'
  cask 'font-gohufont-nerd-font'
  cask 'font-hasklug-nerd-font'
  cask 'font-heavy-data-nerd-font'
  cask 'font-hurmit-nerd-font'
  cask 'font-im-writing-nerd-font'
  cask 'font-inconsolata'
  cask 'font-inconsolata-go-nerd-font'
  cask 'font-inconsolata-lgc-nerd-font'
  cask 'font-inconsolata-nerd-font'
  cask 'font-inter'
  cask 'font-intone-mono-nerd-font'
  cask 'font-iosevka-nerd-font'
  cask 'font-iosevka-term-nerd-font'
  cask 'font-iosevka-term-slab-nerd-font'
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
  cask 'font-victor-mono-nerd-font'
  cask 'font-zed-mono-nerd-font'
end

################################################################################
# App Store (skip in CI - no authenticated App Store session)
################################################################################
unless ENV['CI']
  mas 'Xcode', id: 497_799_835
  mas 'Amphetamine', id: 937_984_704
  mas 'MIDI Connect', id: 6_476_070_288
  mas 'Magnet', id: 441_258_766

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
  # cask 'opencore-patcher'
  cask 'aldente'
  cask 'gufranco/tap/opencore-patcher@beta'
end

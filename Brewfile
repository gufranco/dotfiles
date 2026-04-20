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
tap 'Arthur-Ficial/tap'                                   # Apfel AI benchmarking tool
tap 'aws/tap'                                             # AWS tools
tap 'browsh-org/homebrew-browsh'                          # Browsh terminal web browser
tap 'DopplerHQ/cli'                                       # Doppler secrets manager CLI
tap 'espanso/espanso'                                     # Espanso text expander
tap 'kdash-rs/kdash'                                      # KDash Kubernetes dashboard
tap 'koekeishiya/formulae'                                # Yabai and skhd
tap 'neomutt/neomutt'                                     # NeoMutt email client
tap 'oven-sh/bun'                                         # Bun JavaScript runtime
tap 'stripe/stripe-cli'                                   # Stripe CLI
tap 'UltimateNova1203/maxcso'                             # MaxCSO PSP ISO compressor
tap 'ungive/media-control'                                # macOS media control utility
tap 'universal-ctags/universal-ctags'                     # Universal Ctags
tap 'withgraphite/tap'                                    # Graphite stacking workflow

################################################################################
# Shell & Terminal
################################################################################
brew 'atuin'                                              # Searchable, synced shell history
brew 'bash'                                               # Bourne Again Shell
brew 'direnv'                                             # Directory-specific environment variables
brew 'gum'                                                # Tool for glamorous shell scripts
brew 'starship'                                           # Cross-shell prompt with rich info
brew 'tealdeer'                                           # Fast tldr client for command examples
brew 'thefuck'                                            # Auto-correct mistyped commands
brew 'tmux'                                               # Terminal multiplexer
brew 'tmuxp'                                              # Tmux session manager via YAML
brew 'zsh'                                                # Z shell
brew 'zsh-autosuggestions'                                # Fish-like autosuggestions for zsh
brew 'zsh-syntax-highlighting'                            # Syntax highlighting for zsh commands

################################################################################
# GNU & Core Utilities
################################################################################
brew 'bc'                                                 # Arbitrary precision calculator
brew 'binutils'                                           # GNU binary tools (nm, objdump, strings)
brew 'coreutils'                                          # GNU core utilities (gls, gcp, gmv)
brew 'diffutils'                                          # GNU file comparison utilities
brew 'findutils'                                          # GNU find, xargs, and locate
brew 'gawk'                                               # GNU awk text processing
brew 'gnu-indent'                                         # GNU source code indenter
brew 'gnu-tar'                                            # GNU tar archiver
brew 'gnu-time'                                           # GNU time command with verbose output
brew 'gnu-units'                                          # GNU unit conversion tool
brew 'gnu-which'                                          # GNU which command
brew 'gpatch'                                             # GNU patch utility
brew 'grep'                                               # GNU grep with PCRE support
brew 'gsed'                                               # GNU stream editor
brew 'make'                                               # GNU make build tool
brew 'moreutils'                                          # Extra Unix tools (sponge, parallel, ts)
brew 'p7zip'                                              # 7-Zip file archiver
brew 'patchutils'                                         # Patch manipulation tools (filterdiff, lsdiff)
brew 'trash-cli'                                          # Move files to trash instead of rm
brew 'tree'                                               # Directory listing as tree structure
brew 'unzip'                                              # Decompression utility for zip archives
brew 'watch'                                              # Execute a program periodically
brew 'zip'                                                # Compression utility for zip archives

################################################################################
# Libraries & Build Dependencies
################################################################################
brew 'autoconf'                                           # Automatic configure script builder
brew 'automake'                                           # Makefile generator
brew 'ca-certificates'                                    # Mozilla CA certificate bundle
brew 'cmake'                                              # Cross-platform build system generator
brew 'gcc'                                                # GNU compiler collection (C, C++, Fortran)
brew 'gettext'                                            # GNU internationalization library
brew 'libtool'                                            # Generic library support script
brew 'openssl'                                            # Cryptography and SSL/TLS toolkit
brew 'poppler'                                            # PDF rendering library
brew 'pygments'                                           # Syntax highlighter written in Python
brew 'readline'                                           # Library for command-line editing
brew 'shared-mime-info'                                   # MIME type database
brew 'zlib'                                               # General-purpose lossless compression

################################################################################
# File Navigation & Search
################################################################################
brew 'ack'                                                # Code search tool optimized for source code
brew 'broot'                                              # Interactive tree view and file navigator
brew 'eza'                                                # Modern ls replacement with icons and git status
brew 'fd'                                                 # Fast and user-friendly find alternative
brew 'fzf'                                                # Fuzzy file finder and filtering
brew 'jdupes'                                             # Duplicate file finder and remover
brew 'nnn'                                                # Tiny, fast terminal file manager
brew 'ranger'                                             # Terminal file manager with vi keybindings
brew 'ripgrep'                                            # Fast regex search tool (better grep)
brew 'sd'                                                 # Intuitive find and replace (better sed)
brew 'yazi'                                               # Blazing fast terminal file manager in Rust
brew 'zoxide'                                             # Smart cd that learns your habits

################################################################################
# Text Editors & Data Tools
################################################################################
brew 'bat'                                                # Cat clone with syntax highlighting and git integration
brew 'glow'                                               # Render Markdown in the terminal
brew 'jq'                                                 # Lightweight JSON processor
brew 'most'                                               # Multi-window scroll pager (better less)
brew 'neovim'                                             # Hyperextensible Vim-based text editor
brew 'pandoc'                                             # Universal document converter (Markdown, LaTeX, HTML)
brew 'vim'                                                # Vi Improved text editor
brew 'vint'                                               # Vim script linter
brew 'yq'                                                 # YAML/XML/TOML processor (like jq for YAML)

################################################################################
# Git & Version Control
################################################################################
brew 'delta'                                              # Syntax-highlighting pager for git diffs
brew 'difftastic'                                         # Structural diff tool that understands syntax
brew 'gh'                                                 # GitHub CLI
brew 'git'                                                # Distributed version control system
brew 'git-crypt'                                          # Transparent file encryption in git repos
brew 'git-extras'                                         # Extra git commands (summary, effort, changelog)
brew 'glab'                                               # GitLab CLI
brew 'withgraphite/tap/graphite'                          # Stacking workflow for git branches
brew 'lazygit'                                            # Terminal UI for git commands
brew 'tig'                                                # Text-mode interface for git with blame and log

################################################################################
# Networking & HTTP
################################################################################
brew 'aria2'                                              # Multi-protocol download accelerator
brew 'bandwhich'                                          # Bandwidth utilization by process
brew 'curl'                                               # Command-line HTTP client
brew 'doggo'                                              # DNS lookup client (better dig)
brew 'gping'                                              # Ping with real-time graph
brew 'grpcurl'                                            # curl for gRPC servers
brew 'httpie'                                             # User-friendly HTTP client
brew 'lynx'                                               # Text-based web browser
brew 'mtr'                                                # Traceroute and ping in a single tool
brew 'nmap'                                               # Network exploration and port scanning
brew 'sshpass'                                            # Non-interactive SSH password authentication
brew 'telnet'                                             # Telnet client
brew 'wget'                                               # File retrieval via HTTP/HTTPS/FTP

################################################################################
# Containers & Kubernetes
################################################################################
brew 'colima'                                             # Container runtime for macOS (Docker alternative)
brew 'ctop'                                               # Top-like interface for container metrics
brew 'dive'                                               # Explore Docker image layers and efficiency
brew 'docker'                                             # Container runtime
brew 'docker-compose'                                     # Multi-container Docker applications
brew 'docker-credential-helper'                           # Docker credential store helper
brew 'helm'                                               # Kubernetes package manager
brew 'k9s'                                                # Kubernetes TUI for cluster management
brew 'kdash'                                              # Kubernetes dashboard TUI
brew 'kubectl'                                            # Kubernetes CLI
brew 'lazydocker'                                         # Terminal UI for Docker management
brew 'lima-additional-guestagents'                        # Lima VM guest agents for Colima

################################################################################
# Cloud & Infrastructure
################################################################################
brew 'ansible'                                            # Configuration management and automation
brew 'awscli'                                             # Amazon Web Services CLI
brew 'flyctl'                                             # Fly.io deployment CLI
brew 'opentofu'                                           # Open-source Terraform fork
brew 'terraform'                                          # Infrastructure as code
brew 'vercel-cli'                                         # Vercel deployment CLI

################################################################################
# Security & Encryption
################################################################################
brew 'age'                                                # Simple, modern file encryption tool
brew 'bcrypt'                                             # File encryption using Blowfish
brew 'bettercap'                                          # Network attack and monitoring framework
brew 'clamav'                                             # Open-source antivirus engine
brew 'dnscrypt-proxy'                                     # Proxy for encrypted DNS communication
brew 'DopplerHQ/cli/doppler'                              # Secrets manager CLI
brew 'ghidra'                                             # NSA reverse engineering framework
brew 'gitleaks'                                           # Git secret scanner
brew 'gnupg'                                              # GNU Privacy Guard encryption suite
brew 'lynis'                                              # Security auditing tool for Unix systems
brew 'pinentry-mac'                                       # GPG pin entry dialog for macOS
brew 'radare2'                                            # Reverse engineering framework
brew 'rkhunter'                                           # Rootkit detection tool
brew 'semgrep'                                            # Static analysis for finding bugs and vulnerabilities
brew 'snyk-cli'                                           # Dependency vulnerability scanner
brew 'sops'                                               # Encrypted file editor for secrets management
brew 'trivy'                                              # Container and filesystem vulnerability scanner

################################################################################
# Penetration Testing
################################################################################
brew 'dalfox'                                             # XSS vulnerability scanner
brew 'ffuf'                                               # Fast web fuzzer for directories and parameters
brew 'gobuster'                                           # Directory and DNS brute-force tool
brew 'hashcat'                                            # Advanced password recovery tool
brew 'hydra'                                              # Network login brute-force tool
brew 'john'                                               # John the Ripper password cracker
brew 'nikto'                                              # Web server vulnerability scanner
brew 'nuclei'                                             # Template-based vulnerability scanner
brew 'sqlmap'                                             # SQL injection detection and exploitation

################################################################################
# Languages & Package Managers
################################################################################
brew 'cocoapods'                                          # Dependency manager for Swift and Objective-C
brew 'golang', link: true                                 # Go programming language
brew 'golangci-lint'                                      # Go linters aggregator
brew 'lua'                                                # Lua programming language
brew 'luarocks'                                           # Lua package manager
brew 'mise'                                               # Polyglot runtime version manager
brew 'node', link: true                                   # Node.js JavaScript runtime
brew 'openjdk@21'                                         # Java Development Kit 21
brew 'oven-sh/bun/bun', link: true                        # Fast JavaScript runtime and bundler
brew 'pipx'                                               # Install Python CLI tools in isolated environments
brew 'pnpm'                                               # Fast, disk-efficient Node.js package manager
brew 'python', link: true                                 # Python interpreter
brew 'ruby', link: true                                   # Ruby programming language
brew 'rust', link: true                                   # Rust programming language
brew 'uv'                                                 # Fast Python package installer (pip replacement)
brew 'yarn'                                               # Node.js dependency manager

################################################################################
# Development Tools
################################################################################
brew 'act'                                                # Run GitHub Actions locally
brew 'actionlint'                                         # GitHub Actions workflow linter
brew 'bats'                                               # Bash Automated Testing System
brew 'entr'                                               # Run command when files change
brew 'hyperfine'                                          # Command-line benchmarking tool
brew 'just'                                               # Task runner with simple syntax (better make)
brew 'mkcert'                                             # Local HTTPS certificate generator
brew 'scrcpy'                                             # Display and control Android devices
brew 'shellcheck'                                         # Shell script static analysis tool
brew 'terminal-notifier'                                  # Send macOS notifications from terminal
brew 'tokei'                                              # Count lines of code by language
brew 'ttygif'                                             # Convert terminal recordings to GIF
brew 'universal-ctags'                                    # Source code indexing and tag generation
brew 'watchman'                                           # File system change watcher for dev servers
brew 'xcodes'                                             # Xcode version manager

################################################################################
# Load Testing & Reliability
################################################################################
brew 'k6'                                                 # Modern JavaScript-based load testing tool
brew 'stress-ng'                                          # Stress test tool for CPU, memory, I/O
brew 'toxiproxy'                                          # Simulate adverse network conditions
brew 'vegeta'                                             # HTTP load testing tool with constant rate
brew 'wrk'                                                # HTTP benchmarking tool with Lua scripting

################################################################################
# Database & SaaS CLIs
################################################################################
brew 'libpq'                                              # PostgreSQL client library and tools
brew 'mongocli'                                           # MongoDB Atlas CLI
brew 'stripe-cli'                                         # Stripe API CLI for testing webhooks
brew 'supabase'                                           # Supabase local development CLI

################################################################################
# Monitoring & System Info
################################################################################
brew 'bmon'                                               # Bandwidth monitor with real-time graph
brew 'bottom'                                             # Cross-platform system monitor (better htop)
brew 'cpufetch'                                           # CPU architecture info with ASCII art
brew 'dua-cli'                                            # Disk usage analyzer with interactive mode
brew 'duf'                                                # Disk usage utility with colors (better df)
brew 'dust'                                               # Intuitive disk usage tool (better du)
brew 'fastfetch'                                          # System info display (better neofetch)
brew 'glances'                                            # Cross-platform system monitor with web UI
brew 'goaccess'                                           # Real-time web log analyzer and viewer
brew 'htop'                                               # Interactive process viewer
brew 'procs'                                              # Modern process viewer (better ps)
brew 'speedtest-cli'                                      # Internet speed test from terminal
brew 'tty-clock'                                          # Terminal clock display

################################################################################
# Email
################################################################################
brew 'mailutils'                                          # GNU mail utilities
brew 'neomutt'                                            # Terminal email client (better mutt)
brew 'urlview'                                            # Extract and open URLs from text

################################################################################
# Media
################################################################################
brew 'asciinema'                                          # Record and share terminal sessions
brew 'cmus'                                               # Lightweight terminal music player
brew 'exiftool'                                           # Read, write, and edit EXIF metadata
brew 'fatsort'                                            # Sort FAT filesystem for media players
brew 'ffmpeg'                                             # Audio/video conversion and streaming
brew 'media-control'                                      # macOS media playback control utility
brew 'subliminal'                                         # Subtitle downloader for movies and series

################################################################################
# CLI Productivity
################################################################################
brew 'aspell'                                             # Spell checker with multiple language support
brew 'browsh'                                             # Text-based web browser with graphics support
brew 'buku'                                               # Browser-independent bookmark manager
brew 'ddgr'                                               # DuckDuckGo search from terminal
brew 'khal'                                               # Calendar client for the terminal
brew 'navi'                                               # Interactive cheatsheet browser
brew 'newsboat'                                           # RSS and Atom feed reader
brew 'pass'                                               # Unix password manager using GPG
brew 'pv'                                                 # Pipe viewer with progress bar and ETA
brew 'task'                                               # Taskwarrior CLI task management
brew 'tmate'                                              # Instant terminal sharing via internet

################################################################################
# Backup & Sync
################################################################################
brew 'borgbackup'                                         # Deduplicating, encrypted backup program
brew 'rclone'                                             # Manage cloud storage from command line
brew 'restic'                                             # Fast, encrypted, verifiable backup program
brew 'rsync'                                              # Fast, versatile file synchronization

################################################################################
# AI & Local Inference
################################################################################
brew 'arthur-ficial/tap/apfel' if architecture == 'arm64' # Apple Silicon AI benchmark
brew 'llama.cpp' if architecture == 'arm64'               # LLM inference engine
brew 'ollama' if architecture == 'arm64'                  # Run LLMs locally
brew 'opencode'                                           # AI-powered coding assistant CLI
brew 'rtk'                                                # Rust Token Killer, token-optimized CLI proxy

################################################################################
# macOS System
################################################################################
brew 'iproute2mac'                                        # macOS port of Linux ip and ss commands
brew 'kanata'                                             # Software keyboard remapper
brew 'm-cli'                                              # macOS management Swiss Army knife CLI
brew 'mas'                                                # Mac App Store CLI
brew 'skhd'                                               # Simple hotkey daemon for macOS
brew 'yabai'                                              # Tiling window manager for macOS

################################################################################
# CLI Fun
################################################################################
brew 'cowsay'                                             # Talking ASCII cow
brew 'figlet'                                             # Large ASCII art text banners
brew 'lolcat'                                             # Rainbow colorizer for terminal output
brew 'pipes-sh'                                           # Animated pipes terminal screensaver

################################################################################
# Retro Gaming & ROM Tools
################################################################################
# torrentzip: installed via go install (see install.sh)
brew 'internetarchive'                                    # Internet Archive command-line tool
brew 'mame'                                               # Multi-purpose emulation framework
brew 'UltimateNova1203/maxcso/maxcso'                     # PSP ISO compressor
brew 'ucon64'                                             # ROM tool for various consoles

################################################################################
# Casks - Terminals
################################################################################
cask 'ghostty'                                            # GPU-accelerated terminal emulator
cask 'iterm2'                                             # Feature-rich terminal emulator for macOS
cask 'kitty'                                              # GPU-based terminal emulator

################################################################################
# Casks - Code Editors & IDEs
################################################################################
cask 'android-studio'                                     # IDE for Android development
cask 'boop'                                               # Text transformation scratchpad
cask 'coteditor'                                          # Lightweight plain-text editor for macOS
cask 'cursor'                                             # AI-powered code editor
cask 'cursor-cli'                                         # Cursor command-line tools
cask 'sourcetree'                                         # Git visual client by Atlassian
cask 'sublime-text'                                       # Fast, lightweight text editor
cask 'textmate'                                           # macOS text editor with bundles
cask 'visual-studio-code'                                 # Microsoft code editor
cask 'windsurf'                                           # AI-powered code editor by Codeium

################################################################################
# Casks - AI Tools
################################################################################
cask 'auto-claude'                                        # Automated Claude Code launcher
cask 'claude'                                             # Claude desktop app
cask 'claude-code'                                        # Claude Code desktop app
cask 'claude-devtools'                                    # Claude developer tools
cask 'claude-island'                                      # Claude island mode
cask 'claudebar'                                          # Claude menubar app
cask 'codex'                                              # OpenAI Codex CLI
cask 'codex-app' if architecture == 'arm64'               # OpenAI Codex desktop app
cask 'jan' if architecture == 'arm64'                     # Local AI assistant with GUI
cask 'lm-studio' if architecture == 'arm64'               # Local LLM runner with GUI
cask 'opencode-desktop'                                   # OpenCode desktop app

################################################################################
# Casks - API & Database
################################################################################
cask 'beekeeper-studio'                                   # SQL database GUI client
cask 'db-browser-for-sqlite'                              # SQLite database browser
cask 'dbeaver-community'                                  # Universal database client
cask 'insomnia'                                           # REST and GraphQL API client
cask 'mongodb-compass'                                    # MongoDB GUI client
cask 'ngrok'                                              # Reverse proxy for sharing localhost
cask 'postman'                                            # API development and testing platform
cask 'proxyman'                                           # HTTP debugging proxy for macOS
cask 'redis-insight'                                      # Redis GUI client
cask 'session-manager-plugin'                             # AWS Session Manager plugin

################################################################################
# Casks - Browsers
################################################################################
cask 'chromium'                                           # Open-source web browser
cask 'firefox'                                            # Mozilla web browser
cask 'google-chrome'                                      # Google web browser
cask 'orion'                                              # WebKit-based browser by Kagi with extension support

################################################################################
# Casks - Productivity
################################################################################
cask 'clickup'                                            # Project management
cask 'espanso'                                            # Cross-platform text expander with match rules
cask 'granola'                                            # AI meeting notes
cask 'linear-linear'                                      # Linear project management
cask 'maccy'                                              # Lightweight clipboard manager
cask 'obsidian'                                           # Knowledge base and note-taking with backlinks
cask 'shottr'                                             # Screenshot tool with annotations and OCR

################################################################################
# Casks - Communication
################################################################################
cask 'discord'                                            # Voice and text chat platform
cask 'proton-mail-bridge'                                 # ProtonMail IMAP/SMTP bridge for email clients
cask 'signal'                                             # End-to-end encrypted messaging
cask 'slack'                                              # Team communication platform

################################################################################
# Casks - Design
################################################################################
cask 'figma'                                              # Collaborative design tool

################################################################################
# Casks - Creative Tools
################################################################################
cask 'audacity'                                           # Audio editor and recorder
cask 'gimp'                                               # Image editor (Photoshop alternative)
cask 'inkscape'                                           # Vector graphics editor (Illustrator alternative)
cask 'shotcut'                                            # Open-source video editor

################################################################################
# Casks - Security & VPN
################################################################################
cask '1password'                                          # Password manager
cask 'burp-suite'                                         # Web application security testing platform
cask 'gpg-suite'                                          # GPG encryption tools for macOS
cask 'lastpass'                                           # Password manager
cask 'little-snitch'                                      # Application firewall and network monitor
cask 'nordvpn'                                            # VPN client
cask 'zap'                                                # Web application security scanner
cask 'protonvpn'                                          # ProtonVPN client
cask 'santa'                                              # Binary authorization system for macOS
cask 'tunnelblick'                                        # OpenVPN client for macOS
cask 'veracrypt'                                          # Disk and file encryption (TrueCrypt successor)
cask 'wireshark-app'                                      # Network protocol analyzer and packet capture

################################################################################
# Casks - System & Hardware
################################################################################
# cask 'displaylink'                                      # DisplayLink USB display driver
# cask 'istat-menus'                                      # System monitoring in menubar
cask 'alt-tab'                                            # Windows-style alt-tab window switcher
cask 'anybar'                                             # Custom programmable menubar status icons
cask 'cleanmymac'                                         # Mac cleaning and optimization utility
cask 'coconutbattery'                                     # Battery health and cycle count monitor
cask 'finicky'                                            # Per-URL default browser rules
cask 'grandperspective'                                   # Disk usage visualization as treemap
cask 'hiddenbar'                                          # Hide and show menubar icons
cask 'logi-options+'                                      # Logitech device configuration
cask 'mjolnir'                                            # Lightweight window manager using Lua scripts
cask 'monitorcontrol'                                     # Control external monitor brightness and volume
cask 'mx-power-gadget' if architecture == 'arm64'         # Apple Silicon power monitoring
cask 'openinterminal'                                     # Open terminal from Finder toolbar
cask 'stats'                                              # System resource monitor in menubar

################################################################################
# Casks - File Management & Utilities
################################################################################
cask 'balenaetcher'                                       # USB/SD card image flasher
cask 'calibre'                                            # E-book management, conversion, and reader
cask 'cyberduck'                                          # Cloud storage, FTP, and SFTP client
cask 'forklift'                                           # Dual-pane file manager and FTP client
cask 'keka'                                               # File archiver and extractor
cask 'maestral'                                           # Lightweight open-source Dropbox client
cask 'mountain-duck'                                      # Mount cloud storage as local disk
cask 'tresorit'                                           # End-to-end encrypted cloud storage
cask 'vorta'                                              # BorgBackup GUI for scheduled backups

################################################################################
# Casks - Media & Entertainment
################################################################################
cask 'handbrake-app'                                      # Video transcoder
cask 'iina'                                               # Modern macOS media player
cask 'jdownloader'                                        # Download manager with auto-extraction
cask 'obs'                                                # Screen recording and live streaming
cask 'spotify'                                            # Music streaming
cask 'steam'                                              # Game distribution platform
cask 'transmission'                                       # Lightweight BitTorrent client
cask 'vlc'                                                # Universal media player

################################################################################
# Casks - Emulators
################################################################################
cask 'ares-emulator'                                      # Multi-system emulator (accuracy-focused)
cask 'cemu'                                               # Wii U emulator
cask 'dolphin'                                            # GameCube and Wii emulator
cask 'dosbox-x-app'                                       # DOS emulator with enhancements
cask 'flycast'                                            # Dreamcast emulator
cask 'melonds'                                            # Nintendo DS emulator
cask 'mgba-app'                                           # Game Boy Advance emulator
cask 'openemu'                                            # Multi-system retro game emulator for macOS
cask 'pcsx2'                                              # PlayStation 2 emulator
cask 'ppsspp-emulator'                                    # PlayStation Portable emulator
cask 'retroarch'                                          # Multi-system emulator frontend (libretro)
cask 'scummvm-app'                                        # Classic adventure game engine
cask 'snes9x'                                             # Super Nintendo emulator
cask 'stella-app'                                         # Atari 2600 emulator
cask 'xemu'                                               # Original Xbox emulator

################################################################################
# Casks - Virtualization
################################################################################
# cask 'orbstack'                                         # Docker and Linux VM manager
cask 'crossover'                                          # Run Windows apps on macOS via Wine
cask 'parallels' if architecture == 'arm64'               # Virtual machine manager

################################################################################
# Casks - QuickLook Plugins
################################################################################
cask 'qlcolorcode'                                        # Syntax highlighting for source code
cask 'qlmarkdown'                                         # Markdown file preview
cask 'qlprettypatch'                                      # Diff and patch file preview
cask 'qlstephen'                                          # Plain text files without extension
cask 'quicklook-video'                                    # Video thumbnails and playback preview
cask 'quicklook-csv'                                      # CSV file table preview
cask 'quickjson'                                          # JSON tree view
cask 'webpquicklook', args: { require_sha: false }        # WebP image preview

################################################################################
# Casks - Privacy
################################################################################
cask 'ledger-wallet'                                      # Crypto hardware wallet manager

################################################################################
# Fonts
################################################################################
cask 'font-fira-code-nerd-font'
cask 'font-fira-mono-nerd-font'
cask 'font-hack-nerd-font'
cask 'font-inconsolata'
cask 'font-jetbrains-mono-nerd-font'
cask 'font-meslo-lg-nerd-font'
cask 'font-ubuntu-mono-nerd-font'
cask 'font-ubuntu-nerd-font'
cask 'font-ubuntu-sans-nerd-font'

################################################################################
# App Store (skip in CI - no authenticated App Store session)
################################################################################
unless ENV['CI']
  mas 'Xcode', id: 497_799_835           # Apple development IDE and tools
  mas 'Amphetamine', id: 937_984_704     # Keep Mac awake on schedule
  mas 'Magnet', id: 441_258_766          # Window snapping and tiling manager

  ############################################################################
  # App Store - Games
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
  # cask 'aldente'
  cask 'opencore-patcher'
end

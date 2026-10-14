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
tap 'bjarneo/cliamp', trusted: true # Source of cliamp, the Winamp-style terminal music player
tap 'browsh-org/browsh', trusted: true # Source of browsh, the text-based browser
tap 'clojure/tools', trusted: true # Official Clojure CLI tools
tap 'dciabrin/ngdevkit', trusted: true if architecture == 'arm64' # Source of ngdevkit, the open source Neo-Geo SDK
tap 'gufranco/fdstoolkit', 'https://github.com/gufranco/fdstoolkit', trusted: true # Own tap: fdstoolkit for Famicom Disk System media
tap 'gufranco/maeyomi', 'https://github.com/gufranco/maeyomi', trusted: true # Own tap: maeyomi, printable Barcode Battler cards
tap 'gufranco/osm', 'https://github.com/gufranco/osm', trusted: true # Own tap: osm, encrypted messages over any chat with SSH keys
tap 'hashicorp/tap', trusted: true # Terraform, which left homebrew/core after the license change
tap 'neomutt/neomutt', trusted: true # Upstream NeoMutt builds
tap 'oven-sh/bun', trusted: true # Source of the Bun JavaScript runtime
tap 'stripe/stripe-cli', trusted: true # Source of the Stripe CLI
tap 'UltimateNova1203/maxcso', 'https://github.com/SammyCola/maxcso.git', trusted: true # Source of maxcso, the CSO/ZSO disc image compressor
tap 'ungive/media-control', trusted: true # Source of media-control, the now-playing CLI
tap 'universal-ctags/universal-ctags', trusted: true # Upstream universal-ctags builds
tap 'withgraphite/tap', trusted: true # Source of the Graphite stacked-PR CLI

################################################################################
# Shell & Terminal
################################################################################
brew 'atuin' # Shell history in SQLite with full-text search and optional sync
brew 'bash' # Current Bash; macOS ships 3.2
brew 'direnv' # Loads and unloads environment variables per directory from .envrc
brew 'gum' # Prompts, spinners and styled output for shell scripts
brew 'navi' # Interactive command cheatsheets in the terminal
brew 'tealdeer' # Fast tldr client: short example-based man pages
brew 'thefuck' # Corrects the previous mistyped command
brew 'tmux' # Terminal multiplexer: sessions, windows and panes
brew 'tmuxp' # Tmux session manager from YAML or JSON layouts
brew 'zsh' # Current Z shell
brew 'zsh-autosuggestions' # Fish-like command suggestions from history for zsh
brew 'zsh-syntax-highlighting' # Fish-like syntax highlighting while typing in zsh

################################################################################
# Core Utilities
################################################################################
brew 'bc' # Arbitrary precision calculator language
brew 'binutils' # GNU binary tools: objdump, readelf, nm, strings and more
# brew 'coreutils'
# brew 'diffutils'
# brew 'findutils'
brew 'gawk' # GNU awk
brew 'gnu-indent' # C code formatter
brew 'gnu-tar' # GNU tar, installed as gtar
brew 'gnu-time' # GNU time with resource usage reports, installed as gtime
brew 'gnu-units' # Unit conversion and calculation
brew 'gnu-which' # GNU which, installed as gwhich
brew 'gpatch' # GNU patch: applies a diff to the original files
brew 'grep' # GNU grep, egrep and fgrep
brew 'gsed' # GNU sed, installed as gsed
brew 'make' # GNU make, installed as gmake
brew 'moreutils' # Extra Unix tools: sponge, ts, vipe, parallel, chronic and more
brew 'p7zip' # 7-Zip archiver for the command line
brew 'patchutils' # Tools for patch files: filterdiff, interdiff, combinediff
brew 'unar' # Extracts almost any archive format: rar, 7z, lzh, sit and more
brew 'unzip' # Extracts .zip archives
brew 'uutils-coreutils' # Rust rewrite of GNU coreutils, on PATH in place of the GNU ones
brew 'uutils-diffutils' # Rust rewrite of GNU diffutils: diff and cmp
brew 'uutils-findutils' # Rust rewrite of GNU findutils: find and xargs
brew 'zip' # Creates .zip archives

################################################################################
# Libraries & Build Dependencies
################################################################################
brew 'autoconf' # Generates configure scripts for building from source
brew 'automake' # Generates Makefile.in files for autoconf projects
brew 'ca-certificates' # Mozilla CA certificate bundle used by Homebrew tools
brew 'cmake' # Cross-platform build system generator
brew 'conan' # C and C++ package manager
brew 'gettext' # GNU i18n and l10n library and tools
brew 'libtool' # Portable shared library build support
brew 'openssl' # OpenSSL cryptography and TLS toolkit
brew 'poppler' # PDF rendering library with pdftotext, pdfinfo and pdfimages
brew 'pygments' # Syntax highlighter library and pygmentize CLI
brew 'readline' # Line editing library for interactive programs
brew 'shared-mime-info' # Database of common MIME types
brew 'tesseract' # OCR engine: extracts text from images
brew 'zlib' # Deflate compression library

################################################################################
# File Navigation & Search
################################################################################
brew 'ast-grep' # Structural code search, lint and rewrite by syntax tree patterns
brew 'broot' # Navigable directory tree with fuzzy search
# brew 'eza'
brew 'fd' # Fast, user-friendly alternative to find
brew 'fzf' # Command-line fuzzy finder
brew 'midnight-commander' # Two-pane terminal file manager
brew 'ranger' # Vim-style terminal file manager
brew 'ripgrep' # Fast recursive grep that respects .gitignore
brew 'yazi' # Fast async terminal file manager with previews
brew 'zoxide' # Smarter cd that jumps to frequently used directories

################################################################################
# Text Editors & Data Tools
################################################################################
brew 'bat' # cat with syntax highlighting and Git integration
brew 'glow' # Renders Markdown in the terminal
brew 'jless' # Interactive pager for JSON and YAML
brew 'jq' # Command-line JSON processor
brew 'neovim' # Extensible Vim fork
brew 'vim' # Vi improved; macOS ships an older build
brew 'vint' # Linter for Vim script
brew 'yq' # jq-style processor for YAML, JSON, XML, CSV and TOML

################################################################################
# Git & Version Control
################################################################################
brew 'delta' # Syntax-highlighting pager for git diff output
brew 'difftastic' # Diff that compares syntax trees instead of lines
brew 'gh' # GitHub CLI
brew 'git' # Current Git; macOS ships an older build
brew 'git-absorb' # Creates fixup commits for staged changes automatically
brew 'git-cliff' # Changelog generator from conventional commits
brew 'glab' # GitLab CLI
brew 'lazygit' # Terminal UI for git
brew 'tig' # Text-mode interface for browsing Git history
brew 'withgraphite/tap/graphite' # Graphite CLI for stacked pull requests on GitHub

################################################################################
# Networking & HTTP
################################################################################
brew 'bandwhich' # Shows bandwidth use per process and connection
brew 'browsh-org/browsh/browsh' # Text-based browser that renders modern pages through headless Firefox
brew 'cloudflared' # Cloudflare Tunnel client
brew 'curl' # HTTP client; newer than the macOS build
brew 'doggo' # Human-friendly DNS client
brew 'gping' # Ping with a live graph
brew 'grpcurl' # curl for gRPC servers
brew 'lynx' # Text-based web browser
brew 'mtr' # traceroute and ping combined in one live view
brew 'nmap' # Network and port scanner
brew 'sshpass' # Non-interactive SSH password authentication
brew 'telnet' # Telnet client; macOS no longer ships one
brew 'wget' # Downloads files over HTTP, HTTPS and FTP

################################################################################
# Containers & Kubernetes
################################################################################
brew 'colima' # Container runtime VM for Docker on macOS
brew 'dive' # Explores Docker image layers and wasted space
brew 'docker' # Docker CLI; the engine runs inside Colima
brew 'docker-compose' # Multi-container apps defined in compose files
brew 'docker-credential-helper' # Stores Docker registry credentials in the macOS Keychain
brew 'helm' # Kubernetes package manager
brew 'k9s' # Terminal UI for Kubernetes clusters
brew 'kubectl' # Kubernetes command-line client
brew 'kubectx' # Switches kubectl contexts and namespaces quickly
brew 'lazydocker' # Terminal UI for Docker and Compose
brew 'lima-additional-guestagents' # Extra Lima guest agents so Colima can run non-native architectures

################################################################################
# Cloud & Infrastructure
################################################################################
brew 'ansible' # Agentless configuration management and deployment
brew 'awscli' # AWS command-line interface
brew 'flyctl' # Fly.io command-line interface
brew 'opentofu' # Open source Terraform fork
brew 'hashicorp/tap/terraform' # HashiCorp Terraform infrastructure as code
brew 'terraform-docs' # Generates documentation from Terraform modules
brew 'vercel' # Vercel command-line interface

################################################################################
# Security & Encryption
################################################################################
brew 'age' # Simple modern file encryption
brew 'cosign' # Signs and verifies container images and artifacts
brew 'doppler' # Doppler secrets manager CLI
brew 'ghidra' # NSA software reverse engineering suite
brew 'gitleaks' # Scans git repositories for leaked secrets
brew 'gnupg' # GNU Privacy Guard: OpenPGP encryption and signing
brew 'gufranco/fdstoolkit/fdstoolkit' # Reads, judges, reconstructs and writes Famicom Disk System media
brew 'gufranco/osm/osm' # Sends encrypted messages through any chat using published SSH keys
brew 'pinentry-mac' # macOS passphrase dialog for GnuPG
brew 'qrencode' # Generates QR codes
brew 'radare2' # Reverse engineering framework and disassembler
brew 'semgrep' # Static analysis with semantic code patterns
brew 'sops' # Edits encrypted secrets files in YAML, JSON and env formats
brew 'trivy' # Vulnerability scanner for images, filesystems and repositories

################################################################################
# Penetration Testing
################################################################################
brew 'dalfox' # XSS scanner
brew 'ffuf' # Fast web fuzzer for paths, parameters and hosts
brew 'hashcat' # GPU password hash cracker
brew 'hydra' # Network login brute-forcer for many protocols
brew 'john' # John the Ripper password cracker
brew 'nikto' # Web server vulnerability scanner
brew 'nuclei' # Template-based vulnerability scanner
brew 'sqlmap' # Automated SQL injection detection and exploitation

################################################################################
# Languages & Package Managers
################################################################################
brew 'clojure/tools/clojure' # Clojure language and CLI tools
brew 'cocoapods' # Dependency manager for iOS and macOS projects
brew 'fvm' # Flutter SDK version manager per project
brew 'golang', link: true # Go programming language
brew 'golangci-lint' # Runs many Go linters in parallel
brew 'mise' # Runtime version manager for many languages
brew 'node', link: true # Node.js JavaScript runtime
brew 'openjdk@21' # Java 21 development kit
brew 'oven-sh/bun/bun', link: true # Bun JavaScript runtime, bundler, test runner and package manager
brew 'pnpm' # Fast disk-efficient JavaScript package manager
brew 'python', link: true # Python interpreter
brew 'ruby', link: true # Ruby interpreter; newer than the macOS build
brew 'rust', link: true # Rust compiler and cargo
brew 'uv' # Fast Python package and project manager
brew 'yarn' # JavaScript package manager

################################################################################
# Development Tools
################################################################################
brew 'act' # Runs GitHub Actions workflows locally
brew 'actionlint' # Linter for GitHub Actions workflow files
brew 'bats' # Bash Automated Testing System
brew 'bear' # Generates compile_commands.json for clang tooling
brew 'entr' # Runs a command when watched files change
brew 'hadolint' # Dockerfile linter
brew 'hyperfine' # Command-line benchmarking tool
brew 'kcov' # Code coverage for compiled programs, Python and shell scripts
brew 'lychee' # Fast link checker for Markdown, HTML and websites
brew 'mkcert' # Creates locally trusted development TLS certificates
brew 'pre-commit' # Manages multi-language git pre-commit hooks
brew 'shellcheck' # Static analysis for shell scripts
brew 'shfmt' # Shell script formatter
brew 'tokei' # Counts lines of code by language
brew 'typos-cli' # Source code spell checker
brew 'universal-ctags' # Generates tag indexes for source navigation
brew 'vale' # Prose linter with style guides
brew 'zizmor' # Finds security issues in GitHub Actions workflows
# brew 'watchman'

################################################################################
# Load Testing & Reliability
################################################################################
brew 'k6' # Load testing scripted in JavaScript
brew 'stress-ng' # Stress tests CPU, memory, I/O and more
brew 'toxiproxy' # TCP proxy that simulates network faults for chaos testing

################################################################################
# Database & SaaS CLIs
################################################################################
brew 'libpq' # PostgreSQL client library with psql and pg_dump
brew 'mongocli' # MongoDB Atlas and Ops Manager CLI
brew 'pgcli' # PostgreSQL CLI with autocompletion and syntax highlighting
brew 'stripe-cli' # Stripe CLI: webhooks, events and API calls
brew 'supabase' # Supabase CLI for local development and migrations

################################################################################
# Monitoring & System Info
################################################################################
brew 'bottom' # Graphical process and system monitor, run as btm
brew 'fastfetch' # Fast system information display
brew 'goaccess' # Real-time web server log analyzer
brew 'htop' # Interactive process viewer
brew 'lnav' # Log file viewer with search, filters and SQL
brew 'macmon' if architecture == 'arm64' # Sudoless Apple Silicon CPU, GPU and power monitor; feeds the tmux CPU temperature
brew 'osx-cpu-temp' if architecture == 'x86_64' # Prints the Intel Mac CPU temperature
brew 'tty-clock' # Digital clock in the terminal

################################################################################
# Email
################################################################################
brew 'neomutt' # Terminal email client
brew 'newsboat' # Terminal RSS and Atom feed reader
brew 'terminal-notifier' # Sends macOS notifications from the command line
brew 'urlview' # Extracts and opens URLs from text, used by neomutt

################################################################################
# Media
################################################################################
brew 'asciinema' # Records and shares terminal sessions
brew 'bjarneo/cliamp/cliamp' # Retro terminal music player inspired by Winamp 2
brew 'cmus' # Terminal music player
brew 'fatsort' # Sorts FAT16 and FAT32 directory entries for devices that play in disk order
brew 'ffmpeg' # Records, converts and streams audio and video
brew 'ffmpeg-full' # FFmpeg built with every optional codec and library
brew 'imagemagick' # Image CLI: reduce colors, slice sprite sheets into tiles, remap onto a fixed console palette
brew 'media-control' # Controls and reads macOS now-playing media from the command line
brew 'mjpegtools' # MPEG and MJPEG video tools, used for Video CD encoding
brew 'pngquant' # Lossy PNG quantizer that reduces an image to a limited color palette
brew 'subliminal' # Searches and downloads subtitles
brew 'vcdimager' # Authors Video CD and Super Video CD images
brew 'whisper.cpp' # Local speech-to-text with OpenAI Whisper models in C++
brew 'yt-dlp' # Downloads audio and video from YouTube and many other sites

################################################################################
# Backup & Sync
################################################################################
brew 'rclone' # Syncs files with cloud storage providers
brew 'restic' # Fast encrypted deduplicating backups
brew 'rsync' # Incremental file transfer; newer than the macOS build

################################################################################
# AI & Local Inference
################################################################################
brew 'ollama' if architecture == 'arm64' # Runs large language models locally
brew 'opencode' # AI coding agent for the terminal
brew 'rtk' # CLI proxy that trims command output to save LLM tokens

################################################################################
# macOS System
################################################################################
brew 'kanata' # Software keyboard remapper with layers
brew 'mas' # Mac App Store CLI; installs the mas entries below

################################################################################
# Game Development & Retro Gaming
################################################################################
# torrentzip: installed via go install (see install.sh)
brew 'cc65' # 6502 C compiler and assembler for NES, Atari, C64 and Apple II; no graphics converter
brew 'internetarchive' # Internet Archive CLI for search, download and upload
brew 'gufranco/maeyomi/maeyomi' # Prints playable cards for Barcode Battler machines and barcode games
brew 'mame' # Multi-system arcade and computer emulator
brew 'UltimateNova1203/maxcso/maxcso' # Fast CSO and ZSO compressor for PSP and PS2 disc images
brew 'mednafen' # Accurate multi-system emulator
brew 'rgbds' # Game Boy and Game Boy Color toolchain; rgbgfx turns a PNG into 2bpp tiles and palettes
brew 'sdcc' # Small Device C Compiler for Z80, 8051 and similar CPUs
brew 'tectonic' # Self-contained TeX engine; renders the n64-mr-backup-z64-python catalogue
brew 'dciabrin/ngdevkit/ngdevkit', args: ['force-bottle'] if architecture == 'arm64' # Open source Neo-Geo development kit
brew 'dciabrin/ngdevkit/ngdevkit-toolchain', args: ['force-bottle'] if architecture == 'arm64' # GCC toolchain for ngdevkit: m68k and z80
brew 'ucon64' # ROM backup tool: converts, patches and inspects console ROMs
brew 'xorriso' # Creates and edits ISO 9660 images and burns discs
cask 'ares-emulator' # Accuracy-focused multi-system emulator

################################################################################
# Casks - Terminals
################################################################################
cask 'ghostty' # GPU-accelerated native terminal emulator

################################################################################
# Casks - Code Editors & IDEs
################################################################################
cask 'android-studio' # Android IDE and SDK manager
cask 'devin-desktop' # Devin agentic IDE
cask 'sublime-text' # Fast text and code editor
cask 'visual-studio-code' # Microsoft code editor

################################################################################
# Casks - AI Tools
################################################################################
cask 'claude' # Claude desktop app
cask 'claude-code@latest' # Claude Code terminal coding agent, latest channel
cask 'codex' # OpenAI Codex terminal coding agent
cask 'coderabbit' # CodeRabbit AI code review CLI
cask 'codex-app' if architecture == 'arm64' # OpenAI Codex desktop app for managing coding agents
cask 'lm-studio' if architecture == 'arm64' # Downloads and runs local LLMs with a GUI
cask 'opencode-desktop' # opencode coding agent desktop client

################################################################################
# Casks - API & Database
################################################################################
cask 'db-browser-for-sqlite' # GUI for SQLite databases
cask 'dbeaver-community' # Universal database client and SQL editor
cask 'mitmproxy' # Intercepts, inspects and replays HTTP and HTTPS traffic
cask 'mongodb-compass' # MongoDB GUI
cask 'postman' # API client for building and testing requests
cask 'redis-insight' # Redis GUI
cask 'session-manager-plugin' # AWS CLI plugin for SSM Session Manager shells

################################################################################
# Casks - Browsers
################################################################################
cask 'firefox' # Mozilla Firefox browser
cask 'google-chrome' # Google Chrome browser

################################################################################
# Casks - Productivity
################################################################################
cask 'granola' # AI meeting notepad
cask 'linear' # Linear issue tracker app
cask 'maccy' # Clipboard history manager
cask 'obsidian' # Markdown knowledge base over local files
cask 'shottr' # Screenshot tool with measurement and annotation

################################################################################
# Casks - Communication
################################################################################
cask 'discord' # Voice and text chat
cask 'slack' # Team chat

################################################################################
# Casks - Design
################################################################################
cask 'figma' # Collaborative interface design tool
cask 'kicad' # Schematic and PCB design; kicad-cli runs ERC, DRC and Gerber export for the psone-cdr-unlock board
cask 'tiled' # Tilemap and level editor; exports maps as TMX, JSON or CSV for game engines

################################################################################
# Casks - Security & VPN
################################################################################
# cask '1password'
cask 'keybase' # End-to-end encrypted chat, files and identity
# cask 'lastpass'
cask 'nordvpn' # NordVPN client
cask 'tailscale-app' # WireGuard mesh VPN
cask 'tunnelblick' # OpenVPN client
cask 'wireshark-app' # Network protocol analyzer

################################################################################
# Casks - System & Hardware
################################################################################
# cask 'displaylink'
cask 'coconutbattery' # Battery health for Mac, iPhone and iPad
cask 'grandperspective' # Visual disk usage treemap
cask 'jordanbaird-ice' # Menu bar manager that hides icons
cask 'keycastr' # Shows keystrokes on screen for recordings
cask 'monitorcontrol' # Controls external monitor brightness and volume
cask 'mx-power-gadget' if architecture == 'arm64' # Apple Silicon power and frequency monitor
cask 'openlogi' # Local-first Logitech Options+ alternative for HID++ devices
cask 'stats' # System monitor in the menu bar

################################################################################
# Casks - File Management & Utilities
################################################################################
cask 'balenaetcher' # Flashes OS images to SD cards and USB drives
cask 'cyberduck' # FTP, SFTP and cloud storage browser
cask 'keka' # File archiver
cask 'maestral' # Open source Dropbox client

################################################################################
# Casks - Media & Entertainment
################################################################################
cask 'audacity' # Multi-track audio editor and recorder
cask 'calibre' # E-book library manager and converter
cask 'foobar2000' # Audio player
cask 'gimp' # General-purpose raster image editor; handles sprites but is not pixel-art focused
cask 'handbrake-app' # Video transcoder
cask 'inkscape' # Vector graphics editor
cask 'jdownloader' # Download manager
cask 'krita' # Digital painting app; usable for sprites but not pixel-art focused
cask 'losslesscut' # Trims video and audio without re-encoding
cask 'obs' # Screen recording and live streaming
cask 'spotify' # Music streaming
cask 'transmission' # BitTorrent client
cask 'vlc' # Media player for almost any format

################################################################################
# Casks - Virtualization
################################################################################
# cask 'orbstack'
cask 'parallels' if architecture == 'arm64' # Virtual machines for Windows and Linux

################################################################################
# Fonts
################################################################################
cask 'font-fira-code-nerd-font' # Fira Code with ligatures and Nerd Font icons
cask 'font-fira-mono-nerd-font' # Fira Mono with Nerd Font icons
cask 'font-hack-nerd-font' # Hack with Nerd Font icons
cask 'font-jetbrains-mono-nerd-font' # JetBrains Mono with Nerd Font icons
cask 'font-ubuntu-mono-nerd-font' # Ubuntu Mono with Nerd Font icons
cask 'font-ubuntu-nerd-font' # Ubuntu with Nerd Font icons
cask 'font-ubuntu-sans-nerd-font' # Ubuntu Sans with Nerd Font icons

################################################################################
# App Store (skip in CI - no authenticated App Store session)
################################################################################
unless ENV['CI']
  mas 'Xcode', id: 497_799_835 # Apple IDE and SDKs
  mas 'Amphetamine', id: 937_984_704 # Keeps the Mac awake
  mas 'Magnet', id: 441_258_766 # Window snapping

  if architecture == 'arm64' && storage >= 2048
    mas 'Cyberpunk 2077', id: 6_633_429_424 # Game
    mas 'Death Stranding', id: 6_449_748_961 # Game
    mas 'Resident Evil 2', id: 1_640_632_432 # Game
    mas 'Resident Evil 3', id: 1_640_630_077 # Game
    mas 'Resident Evil 4', id: 6_462_360_082 # Game
    mas 'Resident Evil 7', id: 1_640_629_241 # Game
    mas 'Resident Evil 8', id: 1_640_627_334 # Game
    mas 'Stray', id: 6_451_498_949 # Game
  end
end

################################################################################
# Unsupported systems
#
# Macbook Pro 13 Mid 2012:  C02J332HDV30
# Macbook Retina 12 2017:   C02TW09THH29
################################################################################
if ['C02J332HDV30', 'C02TW09THH29'].include?(serial)
  cask 'opencore-patcher' # Runs current macOS on unsupported Macs
end

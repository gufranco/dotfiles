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
tap 'Arthur-Ficial/tap' if architecture == 'arm64'
tap 'browsh-org/browsh'
tap 'clojure/tools'
tap 'dciabrin/ngdevkit' if architecture == 'arm64'
tap 'DopplerHQ/cli'
tap 'gufranco/osm', 'https://github.com/gufranco/osm'
tap 'hashicorp/tap'
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
brew 'navi'
brew 'tealdeer'
brew 'thefuck'
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
brew 'conan'
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
brew 'ast-grep'
brew 'broot'
brew 'eza'
brew 'fd'
brew 'fzf'
brew 'midnight-commander'
brew 'ranger'
brew 'ripgrep'
brew 'yazi'
brew 'zoxide'

################################################################################
# Text Editors & Data Tools
################################################################################
brew 'bat'
brew 'glow'
brew 'jless'
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
brew 'git-absorb'
brew 'git-cliff'
brew 'glab'
brew 'lazygit'
brew 'tig'
brew 'withgraphite/tap/graphite'

################################################################################
# Networking & HTTP
################################################################################
brew 'bandwhich'
brew 'browsh-org/browsh/browsh'
brew 'cloudflared'
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
brew 'kubectx'
brew 'lazydocker'
brew 'lima-additional-guestagents'
brew 'stern'

################################################################################
# Cloud & Infrastructure
################################################################################
brew 'ansible'
brew 'awscli'
brew 'flyctl'
brew 'opentofu'
brew 'hashicorp/tap/terraform'
brew 'terraform-docs'
brew 'vercel-cli'

################################################################################
# Security & Encryption
################################################################################
brew 'age'
brew 'cosign'
brew 'DopplerHQ/cli/doppler'
brew 'ghidra'
brew 'gitleaks'
brew 'gnupg'
brew 'gufranco/osm/osm'
brew 'grype'
brew 'pinentry-mac'
brew 'qrencode'
brew 'radare2'
brew 'semgrep'
brew 'snyk-cli'
brew 'sops'
brew 'syft'
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
brew 'clojure/tools/clojure'
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
brew 'bear'
brew 'entr'
brew 'hadolint'
brew 'hyperfine'
brew 'just'
brew 'kcov'
brew 'lychee'
brew 'mkcert'
brew 'pre-commit'
brew 'shellcheck'
brew 'shfmt'
brew 'task'
brew 'tokei'
brew 'typos-cli'
brew 'universal-ctags'
brew 'vale'
brew 'zizmor'
# brew 'watchman'

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
brew 'pgcli'
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
brew 'glances'
brew 'goaccess'
brew 'htop'
brew 'lnav'
brew 'procs'
brew 'tty-clock'

################################################################################
# Email
################################################################################
brew 'neomutt'
brew 'newsboat'
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
brew 'whisper-cpp'
brew 'yt-dlp'

################################################################################
# Backup & Sync
################################################################################
brew 'croc'
brew 'rclone'
brew 'restic'
brew 'rsync'

################################################################################
# AI & Local Inference
################################################################################
brew 'arthur-ficial/tap/apfel' if architecture == 'arm64'
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
brew 'dciabrin/ngdevkit/ngdevkit', args: ['force-bottle'] if architecture == 'arm64'
brew 'dciabrin/ngdevkit/ngdevkit-toolchain', args: ['force-bottle'] if architecture == 'arm64'
brew 'ucon64'
brew 'xorriso'

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
cask 'devin-desktop'
cask 'sublime-text'
cask 'textmate'
cask 'visual-studio-code'

################################################################################
# Casks - AI Tools
################################################################################
cask 'claude'
cask 'claude-code@latest'
cask 'codex'
cask 'coderabbit'
cask 'codex-app' if architecture == 'arm64'
cask 'jan' if architecture == 'arm64'
cask 'lm-studio' if architecture == 'arm64'
cask 'opencode-desktop'

################################################################################
# Casks - API & Database
################################################################################
cask 'beekeeper-studio'
cask 'bruno'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'mitmproxy'
cask 'mongodb-compass'
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
cask 'linear'
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
cask 'tailscale-app'
cask 'tunnelblick'
cask 'wireshark-app'

################################################################################
# Casks - System & Hardware
################################################################################
# cask 'displaylink'
cask 'cleanmymac'
cask 'coconutbattery'
cask 'grandperspective'
cask 'jordanbaird-ice'
cask 'keycastr'
cask 'logi-options+'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'pearcleaner'
cask 'stats'

################################################################################
# Casks - File Management & Utilities
################################################################################
cask 'balenaetcher'
cask 'cyberduck'
cask 'keka'
cask 'localsend'
cask 'maestral'
cask 'marta'
cask 'nimble-commander'

################################################################################
# Casks - Media & Entertainment
################################################################################
cask 'audacity'
cask 'calibre'
cask 'foobar2000'
cask 'gimp'
cask 'handbrake-app'
cask 'iina'
cask 'inkscape'
cask 'jdownloader'
cask 'losslesscut'
cask 'obs'
cask 'spotify'
cask 'steam'
cask 'swinsian'
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

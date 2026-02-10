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
tap 'ungive/media-control'
tap 'universal-ctags/universal-ctags'
tap 'withgraphite/tap'

################################################################################
# Homebrew packages
################################################################################
brew 'ack'
brew 'act'
brew 'actionlint'
brew 'age'
brew 'asciinema'
brew 'autoconf'
brew 'automake'
brew 'awscli'
brew 'bash'
brew 'bat'
brew 'bc'
brew 'binutils'
brew 'bottom'
brew 'ca-certificates'
brew 'chruby'
brew 'cmake'
brew 'cmus'
brew 'cocoapods'
brew 'colima'
brew 'coreutils'
brew 'cpufetch'
brew 'curl'
brew 'delta'
brew 'diffutils'
brew 'direnv'
brew 'dive'
brew 'docker-compose'
brew 'docker-credential-helper'
brew 'docker'
brew 'duf'
brew 'dust'
brew 'eza'
brew 'entr'
brew 'fastfetch'
brew 'fatsort'
brew 'fd'
brew 'findutils'
brew 'flyctl'
brew 'fzf'
brew 'gawk'
brew 'gettext'
brew 'gh'
brew 'git'
brew 'gitleaks'
brew 'glab'
brew 'gnu-indent'
brew 'gnu-tar'
brew 'gnu-time'
brew 'gnu-units'
brew 'gnu-which'
brew 'gnupg'
brew 'golang', link: true
brew 'golangci-lint'
brew 'gpatch'
brew 'gping'
brew 'graphite'
brew 'grep'
brew 'gsed'
brew 'gum'
brew 'helm'
brew 'htop'
brew 'httpie'
brew 'hyperfine'
brew 'jq'
brew 'just'
brew 'k9s'
brew 'kubectl'
brew 'lazydocker'
brew 'lazygit'
brew 'libpq'
brew 'libtool'
brew 'lima-additional-guestagents'
brew 'lynx'
brew 'mailutils'
brew 'make'
brew 'mas'
brew 'mcfly'
brew 'media-control'
brew 'moreutils'
brew 'mtr'
brew 'neomutt'
brew 'neovim'
brew 'nmap'
brew 'node', link: true
brew 'nvm'
brew 'openjdk@17'
brew 'openssl'
brew 'oven-sh/bun/bun', link: true
brew 'p7zip'
brew 'patchutils'
brew 'pipx'
brew 'pnpm'
brew 'procs'
brew 'pygments'
brew 'python', link: true
brew 'rclone'
brew 'restic'
brew 'readline'
brew 'ripgrep'
brew 'rsync'
brew 'ruby-install'
brew 'ruby', link: true
brew 'rust', link: true
brew 'shared-mime-info'
brew 'shellcheck'
brew 'snyk-cli'
brew 'starship'
brew 'stripe-cli'
brew 'tealdeer'
brew 'telnet'
brew 'terraform'
brew 'tmux'
brew 'tokei'
brew 'trivy'
brew 'tty-clock'
brew 'ucon64'
brew 'uv'
brew 'UltimateNova1203/maxcso/maxcso'
brew 'universal-ctags'
brew 'unzip'
brew 'urlview'
brew 'vim'
brew 'vint'
brew 'watchman'
brew 'wget'
brew 'yq'
brew 'yarn'
brew 'zoxide'
brew 'zip'
brew 'zlib'
brew 'zsh-syntax-highlighting'
brew 'zsh'

################################################################################
# Homebrew casks
################################################################################
# cask '1password'
# cask 'cursor-cli'
# cask 'cursor'
# cask 'iterm2'
# cask 'kitty'
cask 'android-studio'
cask 'balenaetcher'
cask 'claude-code'
cask 'cleanmymac'
cask 'clickup'
cask 'coconutbattery'
cask 'cyberduck'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'displaylink' if /\AApple M[\d]\z/.match?(cpu)
cask 'figma'
cask 'firefox'
cask 'flixtools'
cask 'ghostty'
cask 'google-chrome'
cask 'grandperspective'
cask 'insomnia'
cask 'istat-menus'
cask 'jdownloader'
cask 'keka'
cask 'lastpass'
cask 'linear-linear'
cask 'logi-options+'
cask 'maccy'
cask 'macs-fan-control' unless /\AApple M[\d]\z/.match?(cpu)
cask 'maestral'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'ngrok'
cask 'nordvpn'
cask 'parallels' if architecture == 'arm64'
cask 'postman'
cask 'shottr'
cask 'slack'
cask 'spotify', args: { no_quarantine: true }
cask 'sublime-text'
cask 'textmate'
cask 'transmission'
cask 'tunnelblick'
cask 'visual-studio-code'
cask 'vlc'

################################################################################
# Homebrew fonts
################################################################################
cask 'font-fira-code-nerd-font'
cask 'font-fira-mono-nerd-font'
cask 'font-hack-nerd-font'
cask 'font-jetbrains-mono-nerd-font'
cask 'font-ubuntu-mono-nerd-font'
cask 'font-ubuntu-nerd-font'
cask 'font-ubuntu-sans-nerd-font'

################################################################################
# App Store - Apps
################################################################################
mas 'Xcode', id: 497_799_835
mas 'Amphetamine', id: 937_984_704
mas 'Magnet', id: 441_258_766

################################################################################
# App Store - Games
################################################################################
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

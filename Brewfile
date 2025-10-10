# frozen_string_literal: true

# System specs
architecture = `uname -m`.strip
cpu = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip
serial = `system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $NF}'`.strip
storage = (`diskutil info /dev/disk0 | awk -F'[()]' '/Disk Size/ {sub(/ Bytes/, "", $2); print $2}'`.strip.to_i / 1073741824)

# Serials
macbook_retina_12_2017_serial = 'C02TW09THH29'
macbook_pro_13_mid_2012_serial = 'C02J332HDV30'

tap 'universal-ctags/universal-ctags'
tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'neomutt/neomutt'
tap 'UltimateNova1203/maxcso'

brew 'ack'
brew 'act'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'bc'
brew 'ca-certificates'
brew 'cdrtools'
brew 'cmake'
brew 'colima'
brew 'coreutils'
brew 'curl'
brew 'docker-compose'
brew 'docker-credential-helper'
brew 'docker'
brew 'fd'
brew 'ffmpeg'
brew 'fzf'
brew 'gawk'
brew 'git'
brew 'gnupg'
brew 'golang'
brew 'golangci-lint'
brew 'gsed'
brew 'jq'
brew 'libpq'
brew 'lima-additional-guestagents'
brew 'lynx'
brew 'mas'
brew 'neomutt'
brew 'node', link: true
brew 'nvm'
brew 'openssl'
brew 'p7zip'
brew 'pnpm'
brew 'python', link: true
brew 'rclone'
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'ruby', link: true
brew 'shared-mime-info'
brew 'shellcheck'
brew 'tmux'
brew 'UltimateNova1203/maxcso/maxcso'
brew 'universal-ctags'
brew 'urlview'
brew 'vcdimager'
brew 'vim'
brew 'vint'
brew 'wget'
brew 'zlib'
brew 'zsh-syntax-highlighting'
brew 'zsh'

cask '1password'
cask 'aldente' if [macbook_retina_12_2017_serial, macbook_pro_13_mid_2012_serial].include?(serial)
cask 'arc'
cask 'cleanmymac'
cask 'coconutbattery'
cask 'cursor-cli'
cask 'cursor'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'displaylink' if /\AApple M[\d]\z/.match?(cpu)
cask 'figma'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'google-chrome'
cask 'grandperspective'
cask 'istat-menus'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'lastpass'
cask 'linear-linear'
cask 'maccy'
cask 'maestral'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'nordvpn'
cask 'opencore-patcher' if [macbook_retina_12_2017_serial, macbook_pro_13_mid_2012_serial].include?(serial)
cask 'paragon-camptune' if architecture == 'x86_64'
cask 'parallels'
cask 'postman'
cask 'shottr'
cask 'slack'
cask 'spotify', args: { no_quarantine => true }
cask 'sublime-text'
cask 'textmate'
cask 'transmission'
cask 'tunnelblick'
cask 'vlc'

# App Store apps
mas 'Xcode', id: 497_799_835
mas 'Amphetamine', id: 937_984_704
mas 'Magnet', id: 441_258_766

# App Store games
mas 'Cyberpunk 2077', id: 6_633_429_424 if architecture == 'arm64' && storage >= 512
mas 'Death Stranding', id: 6_449_748_961 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 2', id: 1_640_632_432 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 3', id: 1_640_630_077 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 4', id: 6_462_360_082 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 7', id: 1_640_629_241 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 8', id: 1_640_627_334 if architecture == 'arm64' && storage >= 512
mas 'Stray', id: 6_451_498_949 if architecture == 'arm64' && storage >= 512

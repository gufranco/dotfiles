# frozen_string_literal: true

# System
architecture = `uname -m`.strip
cpu_model = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip
serial = `system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $NF}'`.strip

# Serials
macbook_12_serial = 'C02TW09THH29'
macbook_pro_13_serial = 'C02J332HDV30'

tap 'universal-ctags/universal-ctags'
tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'homebrew/bundle'
tap 'homebrew/services'
tap 'neomutt/neomutt'

brew 'ack'
brew 'act'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'bc'
brew 'ca-certificates'
brew 'cdrtools' # contains genisoimage
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
brew 'ucon64'
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

cask 'aldente' if [macbook_12_serial, macbook_pro_13_serial].include?(serial)
cask 'balenaetcher'
cask 'cleanmymac'
cask 'coconutbattery'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'displaylink' if /\AApple M[\d]\z/.match?(cpu_model)
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'google-chrome'
cask 'istat-menus'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'maestral'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'opencore-patcher' if [macbook_12_serial, macbook_pro_13_serial].include?(serial)
cask 'parallels' if architecture == 'arm64'
cask 'postman'
cask 'slack'
cask 'spotify', args: { 'no-quarantine' => true }
cask 'transmission'
cask 'tunnelblick'
cask 'virtualbox' if architecture == 'x86_64'
cask 'visual-studio-code'
cask 'vlc'

mas 'Amphetamine', id: 937_984_704
mas 'Magnet', id: 441_258_766
# mas 'Resident Evil 4', id: 6_462_360_082 if architecture == 'arm64'
# mas 'Resident Evil 7', id: 1_640_629_241 if architecture == 'arm64'
# mas 'Resident Evil 8', id: 1_640_627_334 if architecture == 'arm64'
# mas 'Stray', id: 6_451_498_949 if architecture == 'arm64'
mas 'Xcode', id: 497_799_835

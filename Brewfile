# frozen_string_literal: true

# System
architecture = `uname -m`.strip
cpu_model = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip
serial = `system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $NF}'`.strip

# Serials
macbook_pro_D_serial = 'J6WCV57T0W'
macbook_pro_B_serial = 'LFHY7WDM00'
macbook_12_serial = 'C02TW09THH29'
macbook_pro_13_serial = ''

tap 'UltimateNova1203/maxcso'
tap 'universal-ctags/universal-ctags'
tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'homebrew/bundle'
tap 'homebrew/services'
tap 'neomutt/neomutt'
tap 'oven-sh/bun'

brew 'ack'
brew 'act'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'bash'
brew 'bat'
brew 'bc'
brew 'bun'
brew 'ca-certificates'
brew 'chruby'
brew 'cmake'
brew 'cocoapods'
brew 'coreutils'
brew 'curl'
brew 'fastfetch'
brew 'fd'
brew 'ffmpeg'
brew 'fzf'
brew 'gawk'
brew 'gh'
brew 'git'
brew 'glab'
brew 'gnupg'
brew 'golang'
brew 'gsed'
brew 'java11'
brew 'jq'
brew 'kubectl'
brew 'lynx'
brew 'mas'
brew 'maxcso'
brew 'neomutt'
brew 'neovim'
brew 'node', link: true
brew 'nowplaying-cli'
brew 'nvm'
brew 'openssl'
brew 'p7zip'
brew 'pnpm'
brew 'postgresql@15' if serial == macbook_pro_D_serial
brew 'python', link: true
brew 'rclone'
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'rsync'
brew 'ruby-install'
brew 'ruby', link: true
brew 'shared-mime-info'
brew 'shellcheck'
brew 'snyk-cli'
brew 'tmux'
brew 'universal-ctags'
brew 'urlview'
brew 'vim'
brew 'vint'
brew 'wget'
brew 'zlib'
brew 'zsh-syntax-highlighting'
brew 'zsh'

cask 'aldente' if architecture == 'x86_64'
cask 'android-studio'
cask 'coconutbattery'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'displaylink' if /\AApple M[\d]\z/.match?(cpu_model)
cask 'docker' if serial != macbook_pro_D_serial
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'google-chrome'
cask 'handbrake'
cask 'istat-menus'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'maestral'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'opencore-patcher' if [macbook_12_serial, macbook_pro_13_serial].include?(serial)
cask 'openlens' if serial == macbook_pro_D_serial
cask 'parallels' if architecture == 'arm64' && ![macbook_pro_D_serial, macbook_pro_B_serial].include?(serial)
cask 'postman'
cask 'rancher' if serial == macbook_pro_D_serial
cask 'shottr'
cask 'slack'
cask 'spotify'
cask 'transmission'
cask 'tunnelblick'
cask 'virtualbox' if architecture == 'x86_64'
cask 'visual-studio-code'
cask 'vlc'

mas 'Amphetamine', id: 937_984_704
mas 'CleanMyDrive 2', id: 523_620_159
mas 'Magnet', id: 441_258_766
mas 'Resident Evil 4', id: 6_462_360_082 if architecture == 'arm64' && ![macbook_pro_D_serial, macbook_pro_B_serial].include?(serial)
mas 'Resident Evil 7', id: 1_640_629_241 if architecture == 'arm64' && ![macbook_pro_D_serial, macbook_pro_B_serial].include?(serial)
mas 'Resident Evil 8', id: 1_640_627_334 if architecture == 'arm64' && ![macbook_pro_D_serial, macbook_pro_B_serial].include?(serial)
mas 'Stray', id: 6_451_498_949 if architecture == 'arm64' && ![macbook_pro_D_serial, macbook_pro_B_serial].include?(serial)
mas 'Xcode', id: 497_799_835

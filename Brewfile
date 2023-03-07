# frozen_string_literal: true

architecture = `uname -m`.strip
cpu_model = `sysctl -n machdep.cpu.brand_string`.strip

tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'homebrew/bundle'
tap 'homebrew/cask'
tap 'homebrew/cask-drivers'
tap 'homebrew/cask-fonts'
tap 'homebrew/cask-versions'
tap 'homebrew/core'
tap 'neomutt/neomutt'
tap 'universal-ctags/universal-ctags'

brew 'ack'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'binutils'
brew 'cmake'
brew 'coreutils'
brew 'curl'
brew 'findutils'
brew 'git'
brew 'gnu-sed'
brew 'gnupg'
brew 'golang'
brew 'htop'
brew 'lynx'
brew 'mas'
brew 'moreutils'
brew 'neomutt'
brew 'neovim'
brew 'node', link: true
brew 'openssl'
brew 'python', link: true
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'rsync'
brew 'ruby', link: true
brew 'shared-mime-info'
brew 'shellcheck'
brew 'tmux'
brew 'universal-ctags/universal-ctags/universal-ctags', args: ['HEAD']
brew 'urlview'
brew 'vim'
brew 'wget'
brew 'yarn'
brew 'zlib'
brew 'zsh'
brew 'zsh-syntax-highlighting'

# cask 'aldente'
# cask 'cleanmymac'
# cask 'corsair-icue'
# cask 'drivedx'
# cask 'itau'
cask '8bitdo-firmware-updater'
cask 'db-browser-for-sqlite'
cask 'aethersx2'
cask 'android-platform-tools'
cask 'balenaetcher'
cask 'citra'
cask 'coconutbattery'
cask 'cyberduck'
cask 'dbeaver-community'
cask 'discord'
cask 'docker'
cask 'dolphin-beta'
cask 'dropbox'
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'google-chrome'
cask 'google-cloud-sdk'
cask 'huiontablet'
cask 'insomnia'
cask 'intel-power-gadget' if cpu_model.include?('Core(TM) i')
cask 'istat-menus'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'logitech-camera-settings'
cask 'mongodb-compass'
cask 'openemu'
cask 'paragon-ntfs' if architecture == 'x86_64'
cask 'parallels'
cask 'plex-media-server'
cask 'slack'
cask 'spotify'
cask 'the-unarchiver'
cask 'transmission'
cask 'tunnelblick'
cask 'utm'
cask 'virtualbox-beta'
cask 'visual-studio-code'
cask 'vlc'
cask 'xemu'

mas 'Amphetamine', id: 937_984_704
mas 'CleanMyDrive 2', id: 523_620_159
mas 'Magnet', id: 441_258_766
mas 'Resident Evil Village', id: 1_640_627_334 if architecture == 'arm64'

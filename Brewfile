# frozen_string_literal: true

architecture = `uname -m`.strip
cpu_model = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip

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
brew 'binwalk'
brew 'chruby'
brew 'cmake'
brew 'coreutils'
brew 'curl'
brew 'findutils'
brew 'git'
brew 'gnu-sed'
brew 'gnupg'
brew 'golang'
brew 'htop'
brew 'libpq'
brew 'lynx'
brew 'mas'
brew 'moreutils'
brew 'neomutt'
brew 'neovim'
brew 'node@18', link: true
brew 'openssl'
brew 'postgresql@14'
brew 'python', link: true
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'rsync'
brew 'ruby-install'
brew 'ruby', link: true
brew 'shared-mime-info'
brew 'shellcheck'
brew 'telnet'
brew 'tmux'
brew 'universal-ctags/universal-ctags/universal-ctags', args: ['HEAD']
brew 'urlview'
brew 'vim'
brew 'wget'
brew 'yarn'
brew 'zlib'
brew 'zsh-syntax-highlighting'
brew 'zsh'

cask '8bitdo-ultimate-software'
cask 'aethersx2' if architecture == 'arm64'
cask 'aldente' if model == 'MacBookPro9,2'
cask 'balenaetcher'
cask 'blueharvest'
cask 'citra'
cask 'cleanmymac'
cask 'coconutbattery'
cask 'cyberduck'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'docker'
cask 'dolphin-beta'
cask 'dropbox'
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'google-chrome'
cask 'hex-fiend'
cask 'huiontablet'
cask 'insomnia'
cask 'intel-power-gadget' if cpu_model.include?('Core(TM) i')
cask 'istat-menus'
cask 'itau'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'openemu'
cask 'paragon-ntfs' if architecture == 'x86_64'
cask 'parallels' if architecture == 'arm64'
cask 'plex-media-server'
cask 'shottr'
cask 'slack'
cask 'spotify'
cask 'transfer'
cask 'transmission'
cask 'tunnelblick'
cask 'utm'
cask 'virtualbox' if architecture == 'x86_64'
cask 'visual-studio-code'
cask 'vlc'
cask 'xemu'
cask 'zoom'

mas 'Amphetamine', id: 937_984_704
mas 'Magnet', id: 441_258_766
mas 'Resident Evil Village', id: 1_640_627_334 if architecture == 'arm64'

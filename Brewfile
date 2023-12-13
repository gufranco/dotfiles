# frozen_string_literal: true

architecture = `uname -m`.strip
cpu_model = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip

tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'homebrew/bundle'
tap 'homebrew/cask-fonts'
tap 'homebrew/cask-versions'
tap 'neomutt/neomutt'
tap 'stripe/stripe-cli'
tap 'universal-ctags/universal-ctags'

brew 'ack'
brew 'act'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'binwalk'
brew 'bottom'
brew 'ca-certificates'
brew 'chruby'
brew 'cmake'
brew 'cocoapods'
brew 'curl'
brew 'fd'
brew 'gcc'
brew 'git'
brew 'gnupg'
brew 'golang'
brew 'htop'
brew 'java11'
brew 'lynx'
brew 'mas'
brew 'neomutt'
brew 'node', link: true
brew 'nvm'
brew 'openssl'
brew 'pnpm'
brew 'python', link: true
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'rsync'
brew 'ruby', link: true
brew 'ruby-install'
brew 'shared-mime-info'
brew 'shellcheck'
brew 'stripe'
brew 'telnet'
brew 'tmux'
brew 'universal-ctags/universal-ctags/universal-ctags', args: ['HEAD']
brew 'urlview'
brew 'vim'
brew 'wget'
brew 'yarn'
brew 'zlib'
brew 'zsh'
brew 'zsh-syntax-highlighting'

# cask 'cleanmymac'
# cask 'huiontablet'
# cask 'paragon-ntfs' if architecture == 'x86_64'
cask '8bitdo-ultimate-software'
cask 'aethersx2' if architecture == 'arm64'
cask 'aldente' if model == 'MacBookPro9,2'
cask 'android-studio'
cask 'balenaetcher'
cask 'burn'
cask 'citra'
cask 'coconutbattery'
cask 'cyberduck'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'displaylink' if architecture == 'arm64'
cask 'docker'
cask 'dolphin-beta'
cask 'figma'
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'gitkraken'
cask 'google-chrome'
cask 'handbrake'
cask 'insomnia'
cask 'intel-power-gadget' if cpu_model.include?('Core(TM) i')
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'istat-menus'
cask 'itau'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'maestral'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'openemu'
cask 'parallels' if architecture == 'arm64'
cask 'postman'
cask 'ppsspp'
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

mas 'Amphetamine', id: 937_984_704
mas 'CleanMyDrive 2', id: 523_620_159
mas 'Magnet', id: 441_258_766
mas 'Resident Evil Village for Mac', id: 1_640_627_334 if architecture == 'arm64'
mas 'Xcode', id: 497_799_835

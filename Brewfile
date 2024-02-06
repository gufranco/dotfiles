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
tap 'universal-ctags/universal-ctags'

brew 'ack'
brew 'act'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'bat'
brew 'ca-certificates'
brew 'cairo' # Canvas dependency
brew 'chruby'
brew 'cmake'
brew 'cocoapods'
brew 'curl'
brew 'fd'
brew 'fzf'
brew 'giflib' # Canvas dependency
brew 'git'
brew 'gnupg'
brew 'java11'
brew 'jpeg' # Canvas dependency
brew 'libpng' # Canvas dependency
brew 'librsvg' # Canvas dependency
brew 'lynx'
brew 'mas'
brew 'neomutt'
brew 'neovim'
brew 'node', link: true
brew 'nvm'
brew 'openssl'
brew 'pango' # Canvas dependency
brew 'pixman' # Canvas dependency
brew 'pkg-config' # Canvas dependency
brew 'pnpm'
brew 'python', link: true
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'ruby', link: true
brew 'ruby-install'
brew 'shared-mime-info'
brew 'shellcheck'
brew 'telnet'
brew 'tmux'
brew 'universal-ctags/universal-ctags/universal-ctags', args: ['HEAD']
brew 'urlview'
brew 'vim'
brew 'vint'
brew 'wget'
brew 'yarn'
brew 'zlib'
brew 'zsh'
brew 'zsh-syntax-highlighting'

cask '8bitdo-ultimate-software'
cask 'aldente' if ['MacBookAir2,1', 'MacBookPro9,2', 'MacBook10,1'].include?(model)
cask 'android-studio'
cask 'balenaetcher'
cask 'burn'
cask 'coconutbattery'
cask 'cyberduck'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'displaylink' if architecture == 'arm64'
cask 'docker'
cask 'figma'
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'gitkraken'
cask 'google-chrome'
cask 'handbrake'
cask 'insomnia'
cask 'istat-menus'
cask 'itau'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'maestral'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'paragon-ntfs' if architecture == 'x86_64'
cask 'parallels' if architecture == 'arm64'
cask 'podman-desktop'
cask 'postman'
cask 'shottr'
cask 'slack'
cask 'spotify'
cask 'transfer'
cask 'transmission'
cask 'tunnelblick'
cask 'virtualbox' if architecture == 'x86_64'
cask 'visual-studio-code'
cask 'vlc'

mas 'Amphetamine', id: 937_984_704
mas 'CleanMyDrive 2', id: 523_620_159
mas 'Magnet', id: 441_258_766
mas 'Resident Evil 4', id: 6_462_360_082 if architecture == 'arm64'
mas 'Resident Evil Village', id: 1_640_627_334 if architecture == 'arm64'
mas 'Xcode', id: 497_799_835

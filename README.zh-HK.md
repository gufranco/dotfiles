<div align="center">

<strong>一個指令建立 macOS 和 Linux 的開發環境：zsh、Vim、tmux 和 56 套工具設定，全部採用 Catppuccin Mocha 配色。</strong>

[English](README.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | 繁體中文 (香港)

[![Install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![Lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/gufranco/dotfiles?style=flat-square&label=release)](https://github.com/gufranco/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square)](LICENSE)

</div>

---

[`Brewfile`](Brewfile) 宣告了 231 個 formula、91 個 cask 和 12 個 Mac App Store 應用程式，23 個工具共用 Catppuccin Mocha 主題，Git 設有 60 個別名。

## 用法

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL 5432 in Docker through Colima
fde                    # fuzzy-pick a running container and open a shell in it
lt                     # tree view of the current directory with eza
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

## 快速開始

### 先決條件

| 工具 | 安裝 |
|:-----|:--------|
| macOS 或 Ubuntu | 全新安裝的系統即可 |
| Git | macOS 已內置；Ubuntu 上執行 `sudo apt install git` |
| curl | 兩個系統都已內置 |

### 安裝

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh) 會偵測作業系統和架構。在 macOS 上，它會安裝 Homebrew 並執行 Brewfile；在 Linux 上，它使用 apt、snap 和直接下載。

### 驗證

```bash
exec zsh
bat --version
zoxide --version
```

兩個指令都會顯示版本號碼。如果出現 `command not found`，代表安裝中途停止了。每個步驟都是冪等的，再執行一次 `install.sh` 即可。

## 安裝內容

### Shell

| 功能 | 實作 |
|:--------|:---------------|
| Shell | 使用 Oh My Zsh 和 Spaceship 提示字元的 Zsh |
| 模糊搜尋 | 附 bat 預覽和 Catppuccin Mocha 配色的 fzf |
| Tab 自動完成 | fzf-tab |
| 語法突顯 | zsh-syntax-highlighting |
| 智能 cd | 按使用頻率和最近存取排序的 zoxide |
| Shell 歷史記錄 | 可搜尋、可同步的 atuin |
| 按目錄設定環境變數 | 在 `cd` 時載入 `.envrc` 的 direnv |
| 執行環境 | mise：Node.js LTS、最新的 Python 和 Ruby，專案層級的覆寫寫在 `.mise.toml` |
| macOS 上的 GNU 工具 | coreutils、findutils、grep、sed、tar 和 make 在 PATH 中優先於 BSD 版本 |

### 現代工具替代

每個別名只會在對應工具已安裝時才定義，工具缺少時會沿用系統指令：

| 別名 | 工具 |
|:------|:-----|
| `cat` | `bat`，經管道輸出時為純文字 |
| `ls` | 附圖示、目錄排先的 `eza` |
| `lt` | 兩層深的 `eza` 樹狀檢視 |
| `top` | `btm` |
| `ping` | `gping`，只限 macOS |
| `stats` | `tokei`，只限 macOS |

### 編輯器

以 vim-plug 管理 31 個插件的 Vim：

| 類別 | 插件 |
|:---------|:--------|
| 語言支援 | coc.nvim, vim-polyglot, vim-matchup, rainbow_csv |
| 導覽 | fzf, fzf.vim, vim-sneak, vim-fetch |
| Git | vim-signify, vim-fugitive, conflict-marker.vim |
| 編輯 | vim-surround, vim-visual-multi, vim-pasta, targets.vim, vim-unimpaired, vim-repeat, vim-abolish, splitjoin.vim |
| 檔案 | vim-eunuch |
| 介面 | lightline, vim-devicons, undotree, vim-cool, vim-search-pulse, winresizer |
| 主題 | catppuccin/vim，同時負責配色方案和 lightline |
| 預設設定 | vim-sensible, vim-opinion |
| 整合 | vim-tmux, vim-tmux-navigator |

[`vim/vimrc`](vim/vimrc) 有 33 行 `Plug`。其中 3 行分別指向同一個 fzf 的 Homebrew、`/usr/local` 和 `~/.fzf` 副本，只會載入機器上實際存在的那一個。

CoC 擴充功能：TypeScript、ESLint、Prettier、CSS、JSON、Shell、snippets 和 import-cost。

Neovim 在 [`nvim/`](nvim) 有一套以 lazy.nvim 為基礎的獨立 Lua 設定。

### 除錯

Python 使用標準程式庫的 `pdb`，配合功能更豐富的 [`python/.pdbrc`](python/.pdbrc)。別名 `dir`、`attrs`、`vars`、`src` 和 `loc` 可在提示字元下檢查物件和區域變數，改編自 Trey Hunner 的 [Customizing pdb with .pdbrc](https://treyhunner.com/2026/04/customizing-pdb-with-pdbrc/)。`breakpoint()` 經由 [`python/debughook.py`](python/debughook.py)，依次優先選用 pdbp、ipdb，最後才用標準的 `pdb`，因此在兩者都未安裝的 virtualenv 中也能運作。[`python/pythonrc`](python/pythonrc) 是 `PYTHONSTARTUP` 檔案，提供持久保存的 REPL 歷史記錄和格式化輸出。

Node.js 使用內置的 V8 Inspector。別名 `ni`、`nib` 和 `niw` 執行 `node inspect` 和 `--inspect-brk`，用於在終端機和 Chrome DevTools 中除錯。`jsr` 從 [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) 開啟一個支援深層彩色檢查的 REPL。

### 終端機多工器

附 19 個插件和 Vim 風格快捷鍵的 tmux，插件由 tpm 安裝：

| 插件 | 用途 |
|:-------|:-------------|
| catppuccin/tmux | 狀態列、視窗列表和窗格樣式 |
| tmux-sensible-revamped | 按 tmux 版本、作業系統和終端機調整的預設設定：全彩、OSC 52 剪貼簿、焦點事件 |
| tmux-pain-control-revamped | Vim 風格的窗格分割、導覽、調整大小和視窗移動 |
| tmux-launcher-revamped | 在彈出視窗或新視窗中開啟 lazygit、lazydocker 等 TUI |
| tmux-tiling-revamped | 類似 i3 的 BSP 平鋪、窗格標記和浮動暫存區 |
| tmux-scroll-revamped | 應用程式需要滾輪時交給應用程式，否則進入 copy-mode |
| tmux-reorder-revamped | 在狀態列上拖動視窗標籤，標籤會滑到指標所在位置 |
| tmux-fzf-revamped | 以模糊搜尋切換或關閉任何工作階段、視窗或窗格 |
| tmux-extract-revamped | 從窗格中以模糊搜尋擷取網址、路徑、字詞或整行並貼上 |
| tmux-autoreload-revamped | 設定變更時重新載入 |
| tmux-persist-revamped | 儲存工作階段，並在伺服器啟動時還原 |
| tmux-cpu, ram, disk, battery, git, time, music and weather revamped | 狀態列的各個區段 |

除 Catppuccin 主題外，所有插件都來自 [tmux-revamped](https://github.com/tmux-revamped) 系列。`tmux-persist-revamped` 取代了 tmux-resurrect 和 tmux-continuum，而且不會寫入任何暫存檔。

### Git

[`git/.gitconfig`](git/.gitconfig) 有 60 個別名，常用的包括：

| 別名 | 指令 |
|:------|:--------|
| `st` | `status -sb` |
| `lg` | 彩色的 `log --graph --decorate` |
| `fork` | `checkout -q -b` |
| `publish` | `push -u origin HEAD` |
| `force` | `push --force-with-lease` |
| `cleanup` | 刪除已合併的本機分支，保留 `main`、`master` 和 `develop` |
| `today` | `log --since=midnight --oneline` |
| `sw` | `switch` |

提交和標籤預設以 GPG 簽署。Delta 用作 diff 分頁器，顯示行號和超連結，並使用 Catppuccin Mocha 主題。設定亦指定了 histogram diff 演算法、`zdiff3` 衝突標記，以及附 autostash 的 pull 時 rebase。

### Docker 服務

Docker 在 Colima 中運行，虛擬機的規格按主機的 CPU 數量和記憶體決定。在 Apple Silicon 上使用 Apple 的 Virtualization.framework，並透過 Rosetta 2 運行 x86_64 映像檔。

| 服務 | 指令 | 連接埠 |
|:--------|:--------|:-----|
| PostgreSQL | `postgres-init` | 5432 |
| MongoDB | `mongo-init` | 27017 |
| Redis | `redis-init` | 6379 |
| Valkey | `valkey-init` | 7000 |
| Redict | `redict-init` | 6379 |
| Ubuntu | `ubuntu-init` | 無 |

每項服務還有 `-start`、`-stop`、`-purge` 和 `-terminal` 函數，所有連接埠只綁定到 `127.0.0.1`。`fde`、`fdl` 和 `fds` 以 fzf 選擇一個運行中的容器，分別開啟 shell、追蹤日誌或停止容器。

### 自家工具

同一作者編寫的 6 個命令行工具，在 macOS 上透過 [gufranco/tap](https://github.com/gufranco/homebrew-tap) 這個 Homebrew tap 安裝。在 Linux 上，[`install.sh`](install.sh) 會安裝除 fusho 以外的所有工具。

| 工具 | 用途 |
|:-----|:-------------|
| [fusho](https://github.com/gufranco/fusho) | 以 GitHub 用戶名稱為收件人，透過任何聊天工具傳送加密訊息 |
| [jimaku](https://github.com/gufranco/jimaku) | 為資料夾內每段影片下載字幕，儲存為 UTF-8，語言由 `JIMAKU_LANGUAGE` 指定 |
| [kakikomi](https://github.com/gufranco/kakikomi) | 把映像檔寫入磁碟片、Zip 碟、USB 手指和硬碟，逐塊驗證，從不掛載 |
| [kiyome](https://github.com/gufranco/kiyome) | 以 5 種經驗證的模式清除磁碟，並指出出錯的位元線 |
| [shiwake](https://github.com/gufranco/shiwake) | 按首字母把資料夾內的檔案分到 A 至 Z 的子資料夾，從不覆寫現有檔案 |
| [yakitsuke](https://github.com/gufranco/yakitsuke) | 把任何影片轉換成分佈於多張光碟的 VCD 映像檔，並按每行字幕下方的畫面調整字幕樣式 |

### Linux 遊戲

為配備 NVIDIA 混合顯示卡的手提電腦而設的 Steam 和 Proton 環境，功能與 SteamOS 看齊。在 `amd64` 的 Ubuntu 上會自動安裝，在 ARM 上則會略過。

| 組件 | 用途 |
|:----------|:-------------|
| 來自 graphics-drivers PPA 的 NVIDIA 驅動程式 | 最新分支；Turing 及較新的顯示卡使用開源內核模組，較舊的 MX 晶片使用專有驅動程式 |
| NVIDIA Prime | 混合顯示卡切換：內置顯示卡負責桌面，獨立顯示卡運行遊戲 |
| 暫停與恢復強化 | 在手提電腦暫停期間保留顯示記憶體內容 |
| 內置顯示卡媒體堆疊 | 按機器使用 Intel 的 `media-va-driver` 或 AMD 的 `mesa-va-drivers` |
| 來自 oibaf PPA 的 Mesa | 最新的 RADV 和 ANV Vulkan 驅動程式 |
| Vulkan，64 位元和 32 位元 | 為兩張顯示卡提供完整的 Vulkan 堆疊 |
| XanMod 內核 | 用於穩定 Proton 幀時間的 fsync 和 winesync，HZ=500，完全搶佔 |
| scx_lavd 排程器 | Valve 和 CachyOS 採用、注重延遲的 sched_ext 排程器 |
| zram 與 sysctl 調校 | 壓縮記憶體交換，並為 zram 調整虛擬記憶體參數 |
| earlyoom | 在系統凍結前結束佔用最多的程序，保護 Steam 和 Proton |
| ananicy-cpp | 降低背景程序的優先次序，令它們不會搶佔遊戲 |
| GameMode | 遊戲運行時切換 CPU 調速策略並提高優先次序 |
| MangoHud 和 GOverlay | 附受管理設定的 FPS 和幀時間疊加層 |
| vkBasalt | 附受管理設定的 CAS 銳化 |
| Gamescope | Valve 的微型合成器，支援 FSR 升頻 |
| Steam 和 GE-Proton | 原生 Steam；GE-Proton 會自動下載，proton-cachyos 可經 ProtonUp-Qt 取得 |
| Heroic、Lutris 和 Bottles | 透過 Flatpak 安裝的 Epic、GOG、Amazon 等啟動器 |
| 手掣驅動程式 | 來自 steam-launcher 的 udev 規則，以及 Xbox 手掣用的 xpadneo 和 xone DKMS 模組 |
| NVIDIA 著色器快取環境變數 | 持久且不會被清理的著色器快取，避免遊戲因重新編譯而卡頓 |

> [!IMPORTANT]
> 首次安裝後請重新開機，以啟動 XanMod 內核並載入 scx_lavd，然後執行 `gaming-check` 檢查所有組件。

`gaming-launch-options` 會顯示每個遊戲建議的 Steam 啟動選項。大部分遊戲使用：

```bash
prime-run gamemoderun mangohud %command%
```

這些顯示卡是沒有 Tensor 核心和 RT 核心的 GTX 和 MX 型號，因此 DLSS 和硬件光線追蹤並不適用。提升效能的方法是透過 Gamescope 進行 FSR 升頻：以低於原生的解像度渲染再放大。

在 Steam 中開啟「設定」下的「相容性」，啟用「為所有其他產品啟用 Steam Play」，然後選擇「Proton Experimental」或某個 GE-Proton 版本。「設定」下「下載」中的著色器預先快取保持開啟。

`f5` 會令 GE-Proton 保持最新版本，並在內核更新後重新建置手掣的 DKMS 模組。遊戲無法運行時，可以在該遊戲的相容性設定中改用 GE-Proton，查閱 [ProtonDB](https://www.protondb.com/)，或執行 `protontricks <appid> --gui` 安裝缺少的 Windows 組件。[Are We Anti-Cheat Yet](https://areweanticheatyet.com/) 列出了哪些多人遊戲可以在 Proton 下運行。

## Catppuccin Mocha 主題

23 個工具使用 [Catppuccin](https://catppuccin.com) 的 Mocha 風格，強調色為 mauve。如果工具能從路徑載入主題，就以 git 子模組的形式引入官方移植版本；否則從官方移植版本或調色盤直接寫入設定：

| 工具 | 方式 |
|:-----|:-------|
| Ghostty | 內置的 `Catppuccin Mocha` 主題 |
| Bat | `catppuccin/bat` 子模組的 tmTheme |
| Delta | `catppuccin/delta` 子模組的 feature |
| Git | `[color]` 區段中的 Mocha 十六進制顏色 |
| Vim | `catppuccin/vim` 插件和 lightline |
| Neovim | `catppuccin/nvim` 插件和 lualine |
| Tmux | `catppuccin/tmux` 插件 |
| fzf | 官方的 Mocha `--color` |
| zsh-autosuggestions | 建議文字使用 Mocha 的柔和前景色 |
| eza | 來自 `catppuccin/eza` 的 Mocha mauve [`eza/theme.yml`](eza/theme.yml) |
| ripgrep | [`ripgrep/.ripgreprc`](ripgrep/.ripgreprc) 中的 Mocha 配色 |
| Bottom | 官方的 Mocha `[styles]` |
| K9s | `catppuccin/k9s` 子模組的外觀 |
| Lazygit | 官方的 Mocha mauve `gui.theme` |
| Lazydocker | 官方的 Mocha mauve 主題 |
| tig | 按調色盤製作的 Mocha 十六進制顏色 |
| broot | [`broot/conf.toml`](broot/conf.toml) 中的 Mocha 外觀 |
| Midnight Commander | `catppuccin/mc` 子模組的外觀 |
| NeoMutt | `catppuccin/neomutt` 子模組 |
| Newsboat | [`newsboat/config`](newsboat/config) 中的 Mocha 配色 |
| Taskwarrior | [`taskwarrior/taskrc`](taskwarrior/taskrc) 中的 Mocha 配色 |
| Tealdeer | [`tealdeer/config.toml`](tealdeer/config.toml) 中的 Mocha RGB |
| cmus | cmus 不支援 24 位元色彩，因此 [`cmus/rc`](cmus/rc) 使用最接近的 256 色 Mocha 值 |

GoAccess 沒有 Catppuccin 移植版本，其 HTML 報告只提供淺色和深色兩種內置主題，因此使用深色。主題子模組追蹤上游的 `main`，由 `f5` 透過 `git submodule update --remote` 更新。

## 系統更新

`f5` 執行一次便會更新所有內容：

1. 拉取 dotfiles 及其子模組
2. 更新 AWS 設定和 Claude 工程規則
3. 更新 Vim 插件、CoC 擴充功能和 Neovim 插件
4. 更新 Oh My Zsh、Zsh 插件和 Tmux 插件
5. 重新整理 tldr 快取等工具資料
6. 升級 mise 管理的執行環境
7. 在 macOS 上：執行 `brew update`、`brew bundle`、會解除安裝 Brewfile 以外所有內容的 `brew bundle cleanup --force --zap`、`brew upgrade --greedy`，移除從 gufranco/tap 安裝的應用程式的隔離標記，並更新 Mac App Store 應用程式
8. 在 Linux 上：執行 `apt update`、`apt dist-upgrade` 和 `apt autoremove`，重新建置 xpadneo 和 xone 模組，並更新獨立工具、Nerd Fonts、Flatpak 應用程式和 GE-Proton
9. 安裝、升級並清理 [`Uvfile`](Uvfile) 列出的 uv 工具
10. 收回快取空間：清除 Homebrew 下載快取，並修剪 npm、pnpm、yarn、uv 和 Go 的快取；在 macOS 上亦會清除 Xcode 的 `DerivedData`、清理 CocoaPods 快取並刪除無法使用的模擬器。Docker 和 Colima 虛擬機磁碟保持不變，運行中的容器不受影響
11. 重新載入 Tmux 和 Zsh 設定

## 符號連結一覽

`install.sh` 以 `safe_link` 連結所有設定。`safe_link` 是冪等的，會建立上層目錄，並在連結前把現有的檔案或目錄移到 `<path>.backup.<timestamp>`。

<details>
<summary><strong>完整的符號連結一覽</strong></summary>

| 來源 | 目標 |
|:-------|:-------|
| [`zsh/.zshrc`](zsh/.zshrc) | `~/.zshrc` |
| [`git/.gitconfig`](git/.gitconfig) | `~/.gitconfig` |
| [`vim`](vim) | `~/.vim` |
| [`vim/vimrc`](vim/vimrc) | `~/.vimrc` |
| [`nvim`](nvim) | `~/.config/nvim` |
| [`tmux/.tmux.conf`](tmux/.tmux.conf) | `~/.tmux.conf` |
| [`tmux`](tmux) | `~/.tmux` |
| [`ghostty`](ghostty) | `~/.config/ghostty` |
| [`bat/config`](bat/config) | `~/.config/bat/config` |
| `bat/catppuccin/themes` | `~/.config/bat/themes` |
| [`eza`](eza) | `~/.config/eza` |
| [`kanata/kanata.kbd`](kanata/kanata.kbd) | `~/.config/kanata/kanata.kbd` |
| [`mise/config.toml`](mise/config.toml) | `~/.config/mise/config.toml` |
| [`bottom/bottom.toml`](bottom/bottom.toml) | `~/.config/bottom/bottom.toml` |
| [`lazygit/config.yml`](lazygit/config.yml) | `~/.config/lazygit/config.yml` |
| [`lazydocker/config.yml`](lazydocker/config.yml) | `~/.config/lazydocker/config.yml` |
| [`k9s/config.yml`](k9s/config.yml) | `~/.config/k9s/config.yml` |
| `k9s/catppuccin/dist` | `~/.config/k9s/skins` |
| [`tealdeer/config.toml`](tealdeer/config.toml) | `~/.config/tealdeer/config.toml` |
| [`htop/htoprc`](htop/htoprc) | `~/.config/htop/htoprc` |
| [`gh/config.yml`](gh/config.yml) | `~/.config/gh/config.yml` |
| [`gnupg`](gnupg) | `~/.gnupg` |
| `gnupg/gpg-agent-linux.conf` 或 `gnupg/gpg-agent-macos-<arch>.conf` | `~/.gnupg/gpg-agent.conf` |
| [`ssh`](ssh) | `~/.ssh` |
| [`nodejs/.npmrc`](nodejs/.npmrc) | `~/.npmrc` |
| [`nodejs/.yarnrc.yml`](nodejs/.yarnrc.yml) | `~/.yarnrc.yml` |
| [`nodejs/.pnpmrc`](nodejs/.pnpmrc) | `~/.pnpmrc` |
| [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) | `~/.config/node/repl-init.mjs` |
| [`clang-tidy/.clang-tidy`](clang-tidy/.clang-tidy) | `~/.clang-tidy` |
| [`golangci/golangci.yml`](golangci/golangci.yml) | `~/.golangci.yml` |
| [`ruff/ruff.toml`](ruff/ruff.toml) | `~/.config/ruff/ruff.toml` |
| [`rubocop/config.yml`](rubocop/config.yml) | `~/.config/rubocop/config.yml` |
| [`luacheck/luacheckrc`](luacheck/luacheckrc) | `~/.config/luacheck/.luacheckrc` |
| [`dart/analysis_options.yaml`](dart/analysis_options.yaml) | `~/analysis_options.yaml` |
| [`python/.pdbrc`](python/.pdbrc) | `~/.pdbrc` |
| [`python/pythonrc`](python/pythonrc) | `~/.pythonrc` |
| [`python/debughook.py`](python/debughook.py) | `~/.config/python/debughook.py` |
| [`mutt/.muttrc`](mutt/.muttrc) | `~/.muttrc` |
| [`mutt`](mutt) | `~/.mutt` |
| [`mailcap/.mailcap`](mailcap/.mailcap) | `~/.mailcap` |
| [`curl/.curlrc`](curl/.curlrc) | `~/.curlrc` |
| [`wget/.wgetrc`](wget/.wgetrc) | `~/.wgetrc` |
| [`readline/.inputrc`](readline/.inputrc) | `~/.inputrc` |
| [`ripgrep/.ripgreprc`](ripgrep/.ripgreprc) | `~/.ripgreprc` |
| [`fd/.fdrc`](fd/.fdrc) | `~/.fdrc` |
| [`telnet/.telnetrc`](telnet/.telnetrc) | `~/.telnetrc` |
| [`cmus/rc`](cmus/rc) | `~/.config/cmus/rc` |
| [`mc/ini`](mc/ini) | `~/.config/mc/ini` |
| `mc/catppuccin/catppuccin.ini` | `~/.local/share/mc/skins/catppuccin.ini` |
| [`atuin/config.toml`](atuin/config.toml) | `~/.config/atuin/config.toml` |
| [`direnv/direnv.toml`](direnv/direnv.toml) | `~/.config/direnv/direnv.toml` |
| [`direnv/direnvrc`](direnv/direnvrc) | `~/.config/direnv/direnvrc` |
| [`thefuck/settings.py`](thefuck/settings.py) | `~/.config/thefuck/settings.py` |
| [`tig/config`](tig/config) | `~/.config/tig/config` |
| [`broot/conf.toml`](broot/conf.toml) | `~/.config/broot/conf.toml` |
| [`ranger/rc.conf`](ranger/rc.conf) | `~/.config/ranger/rc.conf` |
| [`ranger/rifle.conf`](ranger/rifle.conf) | `~/.config/ranger/rifle.conf` |
| [`ranger/scope.sh`](ranger/scope.sh) | `~/.config/ranger/scope.sh` |
| [`newsboat/config`](newsboat/config) | `~/.config/newsboat/config` |
| [`newsboat/urls`](newsboat/urls) | `~/.config/newsboat/urls` |
| [`navi/config.yaml`](navi/config.yaml) | `~/.config/navi/config.yaml` |
| [`navi/cheats`](navi/cheats) | `~/.config/navi/cheats` |
| [`asciinema/config.toml`](asciinema/config.toml) | `~/.config/asciinema/config.toml` |
| [`goaccess/goaccess.conf`](goaccess/goaccess.conf) | `~/.config/goaccess/goaccess.conf` |
| [`taskwarrior/taskrc`](taskwarrior/taskrc) | `~/.taskrc` |
| [`opencode/opencode.json`](opencode/opencode.json) | `~/.config/opencode/opencode.json` |
| [`conky/.conkyrc`](conky/.conkyrc) | `~/.conkyrc`，只限 Linux |
| [`gamemode/gamemode.ini`](gamemode/gamemode.ini) | `~/.config/gamemode.ini`，Linux 遊戲 |
| [`mangohud/MangoHud.conf`](mangohud/MangoHud.conf) | `~/.config/MangoHud/MangoHud.conf`，Linux 遊戲 |
| [`vkbasalt/vkBasalt.conf`](vkbasalt/vkBasalt.conf) | `~/.config/vkBasalt/vkBasalt.conf`，Linux 遊戲 |
| [`nvidia/99-gaming-nvidia.conf`](nvidia/99-gaming-nvidia.conf) | `~/.config/environment.d/99-gaming-nvidia.conf`，Linux 遊戲 |

在 macOS 上，lazygit、lazydocker、k9s 和 Ghostty 亦會在 `~/Library/Application Support/` 下建立連結。

[`glab/config.yml`](glab/config.yml) 在首次安裝時會複製而非連結到 `~/.config/glab-cli/config.yml`，因為 `glab auth login` 會把權杖寫入這個檔案。

</details>

<details>
<summary><strong>專案結構</strong></summary>

| 路徑 | 內容 |
|:-----|:---------|
| [`asciinema/`](asciinema) | Asciinema 終端機錄影工具 |
| [`atuin/`](atuin) | Atuin shell 歷史記錄 |
| [`bat/`](bat) | Bat 設定和 Catppuccin Mocha 主題 |
| [`bottom/`](bottom) | Bottom 系統監察工具 |
| [`broot/`](broot) | Broot 檔案管理工具 |
| [`clang-tidy/`](clang-tidy) | clang-tidy 預設設定，以及 C 和 C++ 的不可變性檢查 |
| [`cmus/`](cmus) | cmus 音樂播放器 |
| [`conky/`](conky) | Conky 系統監察工具，Linux |
| [`curl/`](curl) | curl |
| [`dart/`](dart) | 包含不可變性 lint 的 Dart 分析器預設設定 |
| [`direnv/`](direnv) | direnv |
| [`eza/`](eza) | eza 及其 Catppuccin Mocha 主題 |
| [`fd/`](fd) | fd |
| [`gamemode/`](gamemode) | GameMode 的 CPU 調速策略和優先次序調整，Linux 遊戲 |
| [`gh/`](gh) | GitHub CLI |
| [`ghostty/`](ghostty) | Ghostty 終端機 |
| [`git/`](git) | Git 設定、提交訊息範本和 60 個別名 |
| [`glab/`](glab) | GitLab CLI |
| [`gnupg/`](gnupg) | GPG 設定和金鑰 |
| [`goaccess/`](goaccess) | GoAccess 網頁日誌分析工具 |
| [`golangci/`](golangci) | golangci-lint 標準檢查器，以及 Go 的不可變性檢查器 |
| [`htop/`](htop) | htop |
| [`k9s/`](k9s) | K9s Kubernetes 儀表板及其 Catppuccin Mocha 外觀 |
| [`kanata/`](kanata) | Kanata 鍵盤重新對應工具 |
| [`lazydocker/`](lazydocker) | Lazydocker |
| [`lazygit/`](lazygit) | Lazygit |
| [`luacheck/`](luacheck) | 禁止 Lua 隱含全域變數的 luacheck 預設設定 |
| [`mailcap/`](mailcap) | Mailcap |
| [`mangohud/`](mangohud) | MangoHud 疊加層，Linux 遊戲 |
| [`mc/`](mc) | Midnight Commander 及其 Catppuccin Mocha 外觀 |
| [`mise/`](mise) | mise 執行環境管理工具 |
| [`mutt/`](mutt) | NeoMutt 電郵程式及其 Catppuccin Mocha 主題 |
| [`navi/`](navi) | Navi 速查表管理工具和自訂速查表 |
| [`newsboat/`](newsboat) | Newsboat RSS 閱讀器 |
| [`nodejs/`](nodejs) | npm、yarn 和 pnpm 設定，以及以 GPG 加密的權杖 |
| [`nvidia/`](nvidia) | NVIDIA 的 Xorg 和著色器快取附加設定，Linux 遊戲 |
| [`nvim/`](nvim) | Neovim，以 lazy.nvim 為基礎的獨立 Lua 設定 |
| [`opencode/`](opencode) | OpenCode |
| [`python/`](python) | pdb 設定、`PYTHONSTARTUP` 和 `breakpoint()` 掛鈎 |
| [`ranger/`](ranger) | Ranger 檔案管理工具 |
| [`readline/`](readline) | Readline |
| [`ripgrep/`](ripgrep) | ripgrep |
| [`rubocop/`](rubocop) | RuboCop 預設設定和不可變性 cop |
| [`ruff/`](ruff) | Ruff 預設設定和不可變性規則 |
| [`ssh/`](ssh) | SSH 設定和金鑰 |
| [`taskwarrior/`](taskwarrior) | Taskwarrior 工作管理工具 |
| [`tealdeer/`](tealdeer) | tldr 用戶端 Tealdeer |
| [`telnet/`](telnet) | Telnet |
| [`tests/`](tests) | 除錯掛鈎和 REPL 啟動檔案的 Python 單元測試 |
| [`thefuck/`](thefuck) | thefuck 指令修正工具 |
| [`tig/`](tig) | Git 的 TUI 工具 tig |
| [`tmux/`](tmux) | tmux 設定和 19 個插件 |
| [`tmuxp/`](tmuxp) | tmuxp 工作階段版面 |
| [`vim/`](vim) | Vim 設定和 31 個插件 |
| [`vkbasalt/`](vkbasalt) | vkBasalt CAS 銳化 |
| [`wget/`](wget) | Wget |
| [`zsh/`](zsh) | Zsh：[`config/`](zsh/config) 存放按載入次序排列的 shell 設定，[`modules/`](zsh/modules) 存放指令 |
| [`Brewfile`](Brewfile) | Homebrew 的 formula、cask、字型和 Mac App Store 應用程式 |
| [`Uvfile`](Uvfile) | 以 uv 安裝的命令行工具 |
| [`install.sh`](install.sh) | 跨平台安裝程式 |

</details>

## 新增設定

1. 建立一個目錄，例如 `myapp/`，把設定檔放進去。
2. 在 [`install.sh`](install.sh) 中加入連結：

   ```bash
   safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
   ```

3. 執行與 CI 相同的檢查：

   ```bash
   shellcheck install.sh
   python3 -m unittest discover -s tests -v
   ```

[lint 工作流程](.github/workflows/lint.yml) 亦會執行 shfmt、zsh 語法檢查、actionlint、YAML 和 TOML 檢查，以及 gitleaks 機密資料掃描。[安裝工作流程](.github/workflows/install.yml) 在 Ubuntu 和 macOS 上各執行兩次 `install.sh`，以證明它是冪等的。`master` 上的 Lint 通過後，[發佈工作流程](.github/workflows/release.yml) 會執行 semantic-release：讀取上一個標籤之後的 Conventional Commits，決定下一個版本，寫入 [`CHANGELOG.md`](CHANGELOG.md)，並發佈 GitHub release。

## 安全

[`ssh/`](ssh) 和 `gnupg/keys/` 中的 SSH 與 GPG 私密金鑰納入了版本控制，每條都受密碼短語保護。其他憑證透過 [`.gitignore`](.gitignore) 排除。API 權杖以 GPG 加密檔案的形式儲存，在 shell 啟動時解密並快取。

GnuPG 在驗證簽署時從不從網絡取得金鑰。自動取得會讓第三方得知正在閱讀哪些訊息，因此金鑰以 `gpg --recv-keys` 明確取得。

### 郵件簽署

外寄郵件預設會簽署，簽署以內嵌方式寫在內文中，而不是附加 `signature.asc`。延後寄出的草稿會加密，因此加密訊息的草稿永遠不會以明文形式存放在郵件伺服器上。

內嵌簽署需要 NeoMutt 的傳統 PGP 後端，因為 GPGME 後端無法產生內嵌訊息。兩種後端都已設定，[`mutt/.muttrc`](mutt/.muttrc) 中 Crypto 區段開首的一行決定使用哪一個：

| 設定 | 後端 | 載入的設定檔 |
|:--------|:--------|:----------------|
| `set my_pgp_inline = yes` | 傳統 PGP，內嵌簽署 | [`mutt/crypto/inline.muttrc`](mutt/crypto/inline.muttrc) |
| 把這一行註解掉 | GPGME，附受保護標頭的 PGP/MIME | [`mutt/crypto/gpgme.muttrc`](mutt/crypto/gpgme.muttrc) |

切換後端需要重新啟動 NeoMutt，因為以互動方式設定 `crypt_use_gpgme` 不會生效。

傳統後端只以名稱呼叫 `pgpewrap` 來展開多個收件人。`pgpewrap` 位於 NeoMutt 的 `libexec` 目錄，[`zsh/config/paths`](zsh/config/paths) 會在 Linux 和 macOS 上把該目錄加入 `PATH`。

帳戶套用的每項設定在 [`mutt/normalize.muttrc`](mutt/normalize.muttrc) 中都有對應的 `reset`，切換帳戶時會先執行。如果在帳戶檔案中加入設定卻沒有對應的 reset，該設定會洩漏到下一個帳戶。

## 授權

自 2014 年起採用 [MIT](LICENSE) 授權。

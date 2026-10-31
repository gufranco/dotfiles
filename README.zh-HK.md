<div align="center">

<strong>一個指令建立 macOS 和 Linux 的開發環境：zsh、Vim、tmux 和 54 套工具設定，全部採用 Catppuccin Mocha 配色。</strong>

[English](README.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | 繁體中文 (香港)

[![install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![release](https://img.shields.io/github/v/release/gufranco/dotfiles?style=flat-square&label=release)](https://github.com/gufranco/dotfiles/releases/latest)
[![license](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square&label=license)](LICENSE)

</div>

---

這是我的 dotfiles。一個腳本就能把一部全新的 Mac 或 Ubuntu 電腦變成我的工作環境：shell、編輯器、終端機工具、Docker，在 Linux 上還有一套用來玩遊戲的 Steam 環境。安裝和連結的所有內容都列在 [REFERENCE.md](REFERENCE.md)，以英文撰寫。

## 所需條件

- macOS，或在 x86_64 或 ARM 上執行的 Ubuntu。Linux 部分依賴 apt，因此不支援其他發行版。
- Git 和 curl。macOS 已內置這兩個工具；在 Ubuntu 上執行 `sudo apt install git curl`。
- 一個可以使用 `sudo` 的帳戶。

## 安裝

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh) 會把這個儲存庫複製到 `~/.dotfiles`，並把每套設定連結到位。在 macOS 上，它會安裝 Homebrew 以及 [`Brewfile`](Brewfile) 中的全部內容；在 Ubuntu 上，它使用 apt、snap 和各項目自己的安裝程式。每個步驟都是冪等的，所以中途停止的安裝只需再執行一次便可修復。

如果連結目標已有檔案，它會被移到 `<path>.backup.<timestamp>`，絕不會被刪除。

然後開啟一個新的 shell，確認工具已經就緒：

```bash
exec zsh
bat --version
zoxide --version
```

兩個指令都會顯示版本號碼。

## 日常使用

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL on 127.0.0.1:5432 in Docker through Colima
fde                    # pick a running container with fzf and open a shell in it
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

需要記住的指令只有 `f5`。它會拉取這個儲存庫，更新 Vim、Neovim、Zsh 和 Tmux 的插件，升級 mise 的執行環境和所有系統套件，並清理套件快取。它只在開始時詢問一次密碼，完成時放棄 root 權限，所以之後的 `sudo` 會再次詢問密碼。它本身不輸出任何訊息，只顯示工具本身的輸出；只要有步驟失敗，便會傳回 1。它不會觸碰 Docker 和 Colima 虛擬機，所以正在執行的容器不受影響。執行完畢後執行 `exec zsh`，便可載入新的 shell 設定。

在 macOS 上，`f5` 會執行 `brew bundle cleanup --force --zap`，解除安裝所有不在 [`Brewfile`](Brewfile) 中的 formula、cask 和應用程式。手動安裝套件之前，請先把它加進 Brewfile，否則下一次 `f5` 會把它移除。

## 包含內容

**Shell。** 配合 Oh My Zsh 和 Spaceship 提示字元的 Zsh、fzf 與 fzf-tab、zoxide、atuin 歷史記錄、direnv，以及管理 Node.js、Python 和 Ruby 的 mise。在 macOS 上，GNU 版本的 coreutils、sed、grep、tar 和 make 排在 `PATH` 的最前面。

**編輯器。** 裝有 31 個插件並以 CoC 提供語言支援的 Vim，以及 [`nvim/`](nvim) 中一套以 lazy.nvim 為基礎、用 Lua 編寫的獨立 Neovim 設定。

**Tmux。** 19 個插件，使用 Vim 風格的按鍵。除 Catppuccin 主題外，全部來自 [tmux-revamped](https://github.com/tmux-revamped) 系列，其中包括工作階段的儲存與還原。

**Git。** [`git/.gitconfig`](git/.gitconfig) 中的 60 個別名，以 GPG 簽署的提交和標籤，以及用作 diff 分頁器的 delta。

**Docker。** 由 Colima 執行 Docker，資源按電腦的 CPU 和記憶體分配。`postgres-init`、`mongo-init`、`redis-init`、`valkey-init`、`redict-init` 和 `ubuntu-init` 各自啟動一個容器，連接埠只綁定到 `127.0.0.1`。

**自家工具。** 我編寫的六個命令列工具。在 macOS 上透過 [gufranco/tap](https://github.com/gufranco/homebrew-tap) 這個 Homebrew tap 安裝，在 Linux 上從原始碼建置：

- [fusho](https://github.com/gufranco/fusho) 以 GitHub 用戶名稱為收件人，透過任何聊天工具傳送加密訊息。
- [jimaku](https://github.com/gufranco/jimaku) 為資料夾中的每段影片下載字幕。
- [kakikomi](https://github.com/gufranco/kakikomi) 把磁碟映像寫入磁碟片、Zip 磁碟、USB 手指和硬碟，並逐塊驗證。
- [kiyome](https://github.com/gufranco/kiyome) 以五種經過驗證的模式抹除磁碟。
- [shiwake](https://github.com/gufranco/shiwake) 把資料夾中的檔案按 A 至 Z 分到子資料夾。
- [yakitsuke](https://github.com/gufranco/yakitsuke) 把任何影片轉換成 VCD 映像。

**主題。** 22 個工具採用以 mauve 為強調色的 Catppuccin Mocha，凡有官方移植版本的都採用官方版本。

**Linux 遊戲。** 在 x86_64 的 Ubuntu 上，安裝程式會加入一套仿照 SteamOS 的 Steam 和 Proton 環境，適用於配備 NVIDIA 混合顯示卡的手提電腦：附 Prime 顯示卡切換的 NVIDIA 驅動程式、XanMod 核心、scx_lavd 排程器、GameMode、MangoHud、Gamescope 和 GE-Proton。首次安裝後請重新開機，然後執行 `gaming-check`。ARM 電腦會略過這部分。

## 加入設定

把檔案放進一個新目錄，例如 `myapp/`，然後在 [`install.sh`](install.sh) 中連結它：

```bash
safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
```

推送之前，執行 CI 會執行的檢查：

```bash
shellcheck install.sh
python3 -m unittest discover -s tests -v
```

## 測試

[install 工作流程](.github/workflows/install.yml) 在最新的 Ubuntu LTS 和 Apple Silicon 上的 macOS Tahoe 上各執行兩次 `install.sh`，然後檢查每個連結，並確認主要指令都在 `PATH` 中。第二次執行用來證明腳本是冪等的。[lint 工作流程](.github/workflows/lint.yml) 執行 ShellCheck、shfmt、zsh 語法檢查、actionlint、YAML 和 TOML 檢查，以及 gitleaks 機密掃描。

## 限制

- Linux 部分只支援 Ubuntu。
- Linux 遊戲需要 x86_64；ARM 上不會安裝 NVIDIA 和 Mesa 驅動程式。
- 這個儲存庫中的 SSH 和 GPG 私密金鑰屬於我，並以我的密碼短語加密。在 fork 後使用之前，請刪除 [`ssh/`](ssh) 和 `gnupg/keys/`。

## 授權

[MIT](LICENSE)

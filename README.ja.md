<div align="center">

<strong>macOSとLinux向けの、コマンド1つで整う開発環境です。zsh、Vim、tmuxと56のツール設定を、Catppuccin Mochaの1つのパレットで統一しています。</strong>

[English](README.md) | 日本語 | [简体中文](README.zh-Hans.md) | [繁體中文 (香港)](README.zh-HK.md)

[![Install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![Lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/gufranco/dotfiles?style=flat-square&label=release)](https://github.com/gufranco/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square)](LICENSE)

</div>

---

[`Brewfile`](Brewfile)には231のformula、91のcask、12のMac App Storeアプリが宣言されています。23のツールがCatppuccin Mochaテーマを共有し、Gitには60のエイリアスがあります。

## 使い方

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL 5432 in Docker through Colima
fde                    # fuzzy-pick a running container and open a shell in it
lt                     # tree view of the current directory with eza
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

## クイックスタート

### 前提条件

| ツール | インストール |
|:-----|:--------|
| macOSまたはUbuntu | クリーンインストールの状態で動作します |
| Git | macOSには標準で入っています。Ubuntuでは`sudo apt install git`を実行します |
| curl | どちらにも標準で入っています |

### インストール

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh)はOSとアーキテクチャを判定します。macOSではHomebrewをインストールしてBrewfileを実行します。Linuxではapt、snap、直接ダウンロードを使います。

### 動作確認

```bash
exec zsh
bat --version
zoxide --version
```

どちらのコマンドもバージョン番号を表示します。`command not found`と出た場合はインストールが途中で止まっています。各ステップは冪等なので、`install.sh`をもう一度実行してください。

## インストールされるもの

### シェル

| 機能 | 実装 |
|:--------|:---------------|
| シェル | Oh My ZshとSpaceshipプロンプトを使ったZsh |
| ファジーファインダー | batのプレビューとCatppuccin Mochaの配色を使ったfzf |
| タブ補完 | fzf-tab |
| シンタックスハイライト | zsh-syntax-highlighting |
| スマートなcd | 使用頻度と最近さで順位付けするzoxide |
| シェル履歴 | 検索と同期ができるatuin |
| ディレクトリごとの環境変数 | `cd`時に`.envrc`を読み込むdirenv |
| ランタイム | mise：Node.js LTS、最新のPythonとRuby、プロジェクトごとの上書きは`.mise.toml`に書きます |
| macOSのGNUツール | coreutils、findutils、grep、sed、tar、makeがPATH上でBSD版より優先されます |

### モダンなツールへの置き換え

各エイリアスは対応するツールがインストールされているときだけ定義されます。ツールがなければシステムのコマンドがそのまま使われます。

| エイリアス | ツール |
|:------|:-----|
| `cat` | `bat`、パイプ時はプレーン出力 |
| `ls` | アイコン付き、ディレクトリ優先の`eza` |
| `lt` | 2階層までの`eza`ツリー |
| `top` | `btm` |
| `ping` | `gping`、macOSのみ |
| `stats` | `tokei`、macOSのみ |

### エディター

vim-plugで管理する31のプラグインを入れたVimです。

| 分類 | プラグイン |
|:---------|:--------|
| 言語サポート | coc.nvim, vim-polyglot, vim-matchup, rainbow_csv |
| ナビゲーション | fzf, fzf.vim, vim-sneak, vim-fetch |
| Git | vim-signify, vim-fugitive, conflict-marker.vim |
| 編集 | vim-surround, vim-visual-multi, vim-pasta, targets.vim, vim-unimpaired, vim-repeat, vim-abolish, splitjoin.vim |
| ファイル | vim-eunuch |
| UI | lightline, vim-devicons, undotree, vim-cool, vim-search-pulse, winresizer |
| テーマ | カラースキームとlightlineを担うcatppuccin/vim |
| デフォルト設定 | vim-sensible, vim-opinion |
| 連携 | vim-tmux, vim-tmux-navigator |

[`vim/vimrc`](vim/vimrc)には`Plug`行が33行あります。そのうち3行は同じfzfのHomebrew版、`/usr/local`版、`~/.fzf`版を指しており、マシンに存在する1つだけが読み込まれます。

CoC拡張：TypeScript、ESLint、Prettier、CSS、JSON、Shell、snippets、import-cost。

Neovimは[`nvim/`](nvim)に、lazy.nvimを使った独立したLuaの設定があります。

### デバッグ

Pythonは標準ライブラリの`pdb`を、機能を拡張した[`python/.pdbrc`](python/.pdbrc)と組み合わせて使います。エイリアス`dir`、`attrs`、`vars`、`src`、`loc`でプロンプトからオブジェクトやローカル変数を調べられます。これはTrey Hunnerの[Customizing pdb with .pdbrc](https://treyhunner.com/2026/04/customizing-pdb-with-pdbrc/)を元にしています。`breakpoint()`は[`python/debughook.py`](python/debughook.py)を経由し、pdbp、ipdb、標準の`pdb`の順に選ぶため、どちらも入っていないvirtualenvでも動きます。[`python/pythonrc`](python/pythonrc)は`PYTHONSTARTUP`ファイルで、REPLの履歴を保存し、出力を整形して表示します。

Node.jsは組み込みのV8 Inspectorを使います。エイリアス`ni`、`nib`、`niw`は、ターミナルとChrome DevToolsでのデバッグ用に`node inspect`と`--inspect-brk`を実行します。`jsr`は[`nodejs/repl-init.mjs`](nodejs/repl-init.mjs)から、深い階層までカラー表示するREPLを開きます。

### ターミナルマルチプレクサー

19のプラグインとVim風のキーバインドを入れたtmuxです。プラグインはtpmでインストールします。

| プラグイン | 役割 |
|:-------|:-------------|
| catppuccin/tmux | ステータスバー、ウィンドウ一覧、ペインのスタイル |
| tmux-sensible-revamped | tmuxのバージョン、OS、ターミナルに合わせたデフォルト設定：トゥルーカラー、OSC 52クリップボード、フォーカスイベント |
| tmux-pain-control-revamped | Vim風のペイン分割、移動、サイズ変更、ウィンドウ移動 |
| tmux-launcher-revamped | lazygit、lazydockerなどのTUIをポップアップか新しいウィンドウで開きます |
| tmux-tiling-revamped | i3風のBSPタイリング、ペインのマーク、フローティングのスクラッチパッド |
| tmux-scroll-revamped | アプリがホイールを必要とするときはアプリに渡し、それ以外はcopy-modeに入ります |
| tmux-reorder-revamped | ステータスバーのウィンドウタブをドラッグすると、ポインターの位置に移動します |
| tmux-fzf-revamped | セッション、ウィンドウ、ペインをあいまい検索で切り替えたり終了したりします |
| tmux-extract-revamped | ペインからURL、パス、単語、行をあいまい検索で取り出して貼り付けます |
| tmux-autoreload-revamped | 設定が変わると読み込み直します |
| tmux-persist-revamped | セッションを保存し、サーバー起動時に復元します |
| tmux-cpu, ram, disk, battery, git, time, music and weather revamped | ステータスバーの各セグメント |

Catppuccinテーマ以外のプラグインはすべて[tmux-revamped](https://github.com/tmux-revamped)ファミリーのものです。`tmux-persist-revamped`はtmux-resurrectとtmux-continuumを置き換え、一時ファイルを書きません。

### Git

[`git/.gitconfig`](git/.gitconfig)に60のエイリアスがあります。主なものは次のとおりです。

| エイリアス | コマンド |
|:------|:--------|
| `st` | `status -sb` |
| `lg` | カラー表示の`log --graph --decorate` |
| `fork` | `checkout -q -b` |
| `publish` | `push -u origin HEAD` |
| `force` | `push --force-with-lease` |
| `cleanup` | マージ済みのローカルブランチを削除します。`main`、`master`、`develop`は残します |
| `today` | `log --since=midnight --oneline` |
| `sw` | `switch` |

コミットとタグはデフォルトでGPG署名されます。差分のページャーはDeltaで、行番号、ハイパーリンク、Catppuccin Mochaテーマを使います。ほかにhistogram差分アルゴリズム、`zdiff3`形式のコンフリクトマーカー、autostash付きのpull時rebaseを設定しています。

### Dockerサービス

DockerはColimaで動かし、VMのサイズはホストのCPU数とメモリから決めます。Apple SiliconではAppleのVirtualization.frameworkを使い、x86_64イメージはRosetta 2で動かします。

| サービス | コマンド | ポート |
|:--------|:--------|:-----|
| PostgreSQL | `postgres-init` | 5432 |
| MongoDB | `mongo-init` | 27017 |
| Redis | `redis-init` | 6379 |
| Valkey | `valkey-init` | 7000 |
| Redict | `redict-init` | 6379 |
| Ubuntu | `ubuntu-init` | なし |

各サービスには`-start`、`-stop`、`-purge`、`-terminal`の関数もあり、ポートはすべて`127.0.0.1`にのみバインドされます。`fde`、`fdl`、`fds`は実行中のコンテナをfzfで選び、シェルを開く、ログを追う、停止する、のいずれかを行います。

### 自作ツール

同じ作者による6つのコマンドラインツールを、macOSでは[gufranco/tap](https://github.com/gufranco/homebrew-tap)のHomebrew tapからインストールします。Linuxでは[`install.sh`](install.sh)がfusho以外のすべてをインストールします。

| ツール | 役割 |
|:-----|:-------------|
| [fusho](https://github.com/gufranco/fusho) | GitHubのユーザー名を宛先に、任意のチャットで暗号化メッセージを送ります |
| [jimaku](https://github.com/gufranco/jimaku) | フォルダー内のすべての動画の字幕を、`JIMAKU_LANGUAGE`で指定した言語のUTF-8でダウンロードします |
| [kakikomi](https://github.com/gufranco/kakikomi) | フロッピー、Zipディスク、USBメモリ、ハードディスクにイメージを書き込みます。チャンクごとに検証し、マウントはしません |
| [kiyome](https://github.com/gufranco/kiyome) | 検証付きの5つのパターンでディスクを消去し、不良のビット線を特定します |
| [shiwake](https://github.com/gufranco/shiwake) | フォルダー内のファイルを頭文字ごとにAからZのサブフォルダーへ振り分けます。既存のファイルを上書きすることはありません |
| [yakitsuke](https://github.com/gufranco/yakitsuke) | 任意の動画を複数のディスクに分けたビデオCDイメージに変換し、各行の下の映像に合わせて字幕のスタイルを調整します |

### Linuxゲーミング

ハイブリッドNVIDIAグラフィックスのノートPC向けに、SteamOSと同等のSteamとProtonの環境を構築します。`amd64`のUbuntuでは自動でインストールされ、ARMではスキップされます。

| コンポーネント | 役割 |
|:----------|:-------------|
| graphics-drivers PPAのNVIDIAドライバー | 最新ブランチ。Turing以降はオープンカーネルモジュール、古いMXチップはプロプライエタリ版 |
| NVIDIA Prime | ハイブリッド切り替え：デスクトップはiGPU、ゲームはdGPUで動かします |
| サスペンドとレジュームの強化 | ノートPCのサスペンドをまたいでVRAMの内容を保持します |
| iGPUのメディアスタック | マシンに応じてIntelの`media-va-driver`かAMDの`mesa-va-drivers` |
| oibaf PPAのMesa | 最新のRADVとANVのVulkanドライバー |
| Vulkan、64ビットと32ビット | 両方のGPU向けの完全なVulkanスタック |
| XanModカーネル | Protonのフレーム時間を安定させるfsyncとwinesync、HZ=500、完全プリエンプション |
| scx_lavdスケジューラー | ValveとCachyOSが採用している、レイテンシーを考慮したsched_extスケジューラー |
| zramとsysctlの調整 | zram向けにVMを調整した、圧縮RAMスワップ |
| earlyoom | フリーズする前に最も大きなプロセスを終了させ、SteamとProtonは守ります |
| ananicy-cpp | バックグラウンドプロセスの優先度を下げ、ゲームを妨げないようにします |
| GameMode | ゲーム実行中はCPUガバナーを切り替えて優先度を上げます |
| MangoHudとGOverlay | 設定を管理したFPSとフレーム時間のオーバーレイ |
| vkBasalt | 設定を管理したCASシャープニング |
| Gamescope | FSRアップスケーリングに対応したValveのマイクロコンポジター |
| SteamとGE-Proton | ネイティブのSteam。GE-Protonは自動でダウンロードされ、proton-cachyosはProtonUp-Qtから入れられます |
| Heroic、Lutris、Bottles | Flatpakで入れるEpic、GOG、Amazonなどのランチャー |
| コントローラードライバー | steam-launcherのudevルールと、Xboxパッド用のxpadneoとxoneのDKMSモジュール |
| NVIDIAシェーダーキャッシュの環境変数 | 削除されない永続的なシェーダーキャッシュで、再コンパイルによるカクつきを防ぎます |

> [!IMPORTANT]
> 初回インストール後は再起動してXanModカーネルを起動し、scx_lavdを読み込んでください。その後`gaming-check`を実行すると、すべてのコンポーネントを確認できます。

`gaming-launch-options`は、ゲームごとに推奨するSteamの起動オプションを表示します。ほとんどのゲームでは次を使います。

```bash
prime-run gamemoderun mangohud %command%
```

対象のGPUはTensorコアもRTコアもないGTXとMXのため、DLSSとハードウェアレイトレーシングは使えません。性能を引き出す手段はGamescopeによるFSRアップスケーリングで、ネイティブより低い解像度で描画して拡大します。

Steamで「設定」から「互換性」を開き、「他のすべてのタイトルでSteam Playを有効化」をオンにして、「Proton Experimental」かGE-Protonのバージョンを選んでください。「設定」の「ダウンロード」にあるシェーダーのプリキャッシュはオンのままにします。

`f5`はGE-Protonを最新に保ち、カーネル更新後にコントローラーのDKMSモジュールを再ビルドします。ゲームが動かない場合は、そのゲームの互換性設定でGE-Protonに切り替えるか、[ProtonDB](https://www.protondb.com/)を確認するか、`protontricks <appid> --gui`を実行して足りないWindowsコンポーネントを入れてください。[Are We Anti-Cheat Yet](https://areweanticheatyet.com/)には、Protonで動くマルチプレイヤーゲームが載っています。

## Catppuccin Mochaテーマ

23のツールが、アクセントカラーをmauveにした[Catppuccin](https://catppuccin.com)のMochaフレーバーを使います。ツールがパスからテーマを読み込める場合は公式ポートをgitサブモジュールとして取り込み、そうでない場合は公式ポートかパレットから設定に直接書き込んでいます。

| ツール | 方法 |
|:-----|:-------|
| Ghostty | 組み込みの`Catppuccin Mocha`テーマ |
| Bat | `catppuccin/bat`サブモジュールのtmTheme |
| Delta | `catppuccin/delta`サブモジュールのfeature |
| Git | `[color]`セクションにMochaの16進カラー |
| Vim | `catppuccin/vim`プラグインとlightline |
| Neovim | `catppuccin/nvim`プラグインとlualine |
| Tmux | `catppuccin/tmux`プラグイン |
| fzf | 公式のMocha `--color` |
| zsh-autosuggestions | 候補表示にMochaの控えめな前景色 |
| eza | `catppuccin/eza`由来のMocha mauveの[`eza/theme.yml`](eza/theme.yml) |
| ripgrep | [`ripgrep/.ripgreprc`](ripgrep/.ripgreprc)にMochaの配色 |
| Bottom | 公式のMocha `[styles]` |
| K9s | `catppuccin/k9s`サブモジュールのスキン |
| Lazygit | 公式のMocha mauve `gui.theme` |
| Lazydocker | 公式のMocha mauveテーマ |
| tig | パレットから作ったMochaの16進カラー |
| broot | [`broot/conf.toml`](broot/conf.toml)にMochaのスキン |
| Midnight Commander | `catppuccin/mc`サブモジュールのスキン |
| NeoMutt | `catppuccin/neomutt`サブモジュール |
| Newsboat | [`newsboat/config`](newsboat/config)にMochaの配色 |
| Taskwarrior | [`taskwarrior/taskrc`](taskwarrior/taskrc)にMochaの配色 |
| Tealdeer | [`tealdeer/config.toml`](tealdeer/config.toml)にMochaのRGB |
| cmus | cmusは24ビットカラーに対応していないため、[`cmus/rc`](cmus/rc)に最も近い256色のMocha |

GoAccessにはCatppuccinのポートがなく、HTMLレポートには明るい組み込みテーマと暗い組み込みテーマしかないため、暗いほうを使います。テーマのサブモジュールは上流の`main`を追跡し、`f5`が`git submodule update --remote`で更新します。

## システムの更新

`f5`は1回の実行ですべてを更新します。

1. dotfilesとそのサブモジュールをpullします
2. AWSの設定とClaudeのエンジニアリングルールを更新します
3. Vimプラグイン、CoC拡張、Neovimプラグインを更新します
4. Oh My Zsh、Zshプラグイン、Tmuxプラグインを更新します
5. tldrのキャッシュなどのツールデータを更新します
6. miseのランタイムをアップグレードします
7. macOSでは、`brew update`、`brew bundle`、Brewfileにないものをアンインストールする`brew bundle cleanup --force --zap`、`brew upgrade --greedy`、gufranco/tapからインストールしたアプリの検疫フラグの解除、Mac App Storeの更新を行います
8. Linuxでは、`apt update`、`apt dist-upgrade`、`apt autoremove`、xpadneoとxoneのモジュールの再ビルド、スタンドアロンツール、Nerd Fonts、Flatpakアプリ、GE-Protonの更新を行います
9. [`Uvfile`](Uvfile)に記載したuvのツールをインストール、アップグレード、整理します
10. キャッシュ領域を回収します。Homebrewのダウンロードキャッシュを消去し、npm、pnpm、yarn、uv、Goのキャッシュを整理します。macOSではさらにXcodeの`DerivedData`を消去し、CocoaPodsのキャッシュを掃除し、使えないシミュレーターを削除します。DockerとColimaのVMディスクには触れないため、実行中のコンテナはそのまま残ります
11. TmuxとZshの設定を読み込み直します

## シンボリックリンクの一覧

`install.sh`はすべての設定を`safe_link`でリンクします。`safe_link`は冪等で、親ディレクトリを作成し、既存のファイルやディレクトリはリンクの前に`<path>.backup.<timestamp>`へ退避します。

<details>
<summary><strong>シンボリックリンクの全一覧</strong></summary>

| リンク元 | リンク先 |
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
| `gnupg/gpg-agent-linux.conf`または`gnupg/gpg-agent-macos-<arch>.conf` | `~/.gnupg/gpg-agent.conf` |
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
| [`conky/.conkyrc`](conky/.conkyrc) | `~/.conkyrc`、Linuxのみ |
| [`gamemode/gamemode.ini`](gamemode/gamemode.ini) | `~/.config/gamemode.ini`、Linuxゲーミング |
| [`mangohud/MangoHud.conf`](mangohud/MangoHud.conf) | `~/.config/MangoHud/MangoHud.conf`、Linuxゲーミング |
| [`vkbasalt/vkBasalt.conf`](vkbasalt/vkBasalt.conf) | `~/.config/vkBasalt/vkBasalt.conf`、Linuxゲーミング |
| [`nvidia/99-gaming-nvidia.conf`](nvidia/99-gaming-nvidia.conf) | `~/.config/environment.d/99-gaming-nvidia.conf`、Linuxゲーミング |

macOSでは、lazygit、lazydocker、k9s、Ghosttyのリンクが`~/Library/Application Support/`の下にも作られます。

[`glab/config.yml`](glab/config.yml)は初回インストール時にリンクではなくコピーで`~/.config/glab-cli/config.yml`に置かれます。`glab auth login`がこのファイルにトークンを書き込むためです。

</details>

<details>
<summary><strong>プロジェクトの構成</strong></summary>

| パス | 内容 |
|:-----|:---------|
| [`asciinema/`](asciinema) | Asciinemaターミナルレコーダー |
| [`atuin/`](atuin) | Atuinシェル履歴 |
| [`bat/`](bat) | Batの設定とCatppuccin Mochaテーマ |
| [`bottom/`](bottom) | Bottomシステムモニター |
| [`broot/`](broot) | Brootファイルマネージャー |
| [`clang-tidy/`](clang-tidy) | clang-tidyのデフォルト設定と、C/C++向けのイミュータビリティチェック |
| [`cmus/`](cmus) | cmus音楽プレーヤー |
| [`conky/`](conky) | Conkyシステムモニター、Linux |
| [`curl/`](curl) | curl |
| [`dart/`](dart) | イミュータビリティのlintを含むDartアナライザーのデフォルト設定 |
| [`direnv/`](direnv) | direnv |
| [`eza/`](eza) | ezaとそのCatppuccin Mochaテーマ |
| [`fd/`](fd) | fd |
| [`gamemode/`](gamemode) | GameModeのCPUガバナーと優先度の調整、Linuxゲーミング |
| [`gh/`](gh) | GitHub CLI |
| [`ghostty/`](ghostty) | Ghosttyターミナル |
| [`git/`](git) | Gitの設定、コミットメッセージのテンプレート、60のエイリアス |
| [`glab/`](glab) | GitLab CLI |
| [`gnupg/`](gnupg) | GPGの設定と鍵 |
| [`goaccess/`](goaccess) | GoAccess Webログアナライザー |
| [`golangci/`](golangci) | golangci-lintの標準リンターと、Go向けのイミュータビリティリンター |
| [`htop/`](htop) | htop |
| [`k9s/`](k9s) | K9s KubernetesダッシュボードとそのCatppuccin Mochaスキン |
| [`kanata/`](kanata) | Kanataキーボードリマッパー |
| [`lazydocker/`](lazydocker) | Lazydocker |
| [`lazygit/`](lazygit) | Lazygit |
| [`luacheck/`](luacheck) | Luaの暗黙のグローバル変数を禁止するluacheckのデフォルト設定 |
| [`mailcap/`](mailcap) | Mailcap |
| [`mangohud/`](mangohud) | MangoHudオーバーレイ、Linuxゲーミング |
| [`mc/`](mc) | Midnight CommanderとそのCatppuccin Mochaスキン |
| [`mise/`](mise) | miseランタイムマネージャー |
| [`mutt/`](mutt) | NeoMuttメールクライアントとそのCatppuccin Mochaテーマ |
| [`navi/`](navi) | Naviチートシートマネージャーと独自のチートシート |
| [`newsboat/`](newsboat) | Newsboat RSSリーダー |
| [`nodejs/`](nodejs) | npm、yarn、pnpmの設定とGPGで暗号化したトークン |
| [`nvidia/`](nvidia) | NVIDIAのXorgとシェーダーキャッシュの追加設定、Linuxゲーミング |
| [`nvim/`](nvim) | Neovim、lazy.nvimを使った独立したLuaの設定 |
| [`opencode/`](opencode) | OpenCode |
| [`python/`](python) | pdbの設定、`PYTHONSTARTUP`、`breakpoint()`のフック |
| [`ranger/`](ranger) | Rangerファイルマネージャー |
| [`readline/`](readline) | Readline |
| [`ripgrep/`](ripgrep) | ripgrep |
| [`rubocop/`](rubocop) | RuboCopのデフォルト設定とイミュータビリティのcop |
| [`ruff/`](ruff) | Ruffのデフォルト設定とイミュータビリティのルール |
| [`ssh/`](ssh) | SSHの設定と鍵 |
| [`taskwarrior/`](taskwarrior) | Taskwarriorタスクマネージャー |
| [`tealdeer/`](tealdeer) | tldrクライアントのTealdeer |
| [`telnet/`](telnet) | Telnet |
| [`tests/`](tests) | デバッグフックとREPL起動ファイルのPythonユニットテスト |
| [`thefuck/`](thefuck) | thefuckコマンド修正ツール |
| [`tig/`](tig) | GitのTUIであるtig |
| [`tmux/`](tmux) | tmuxの設定と19のプラグイン |
| [`tmuxp/`](tmuxp) | tmuxpのセッションレイアウト |
| [`vim/`](vim) | Vimの設定と31のプラグイン |
| [`vkbasalt/`](vkbasalt) | vkBasaltのCASシャープニング |
| [`wget/`](wget) | Wget |
| [`zsh/`](zsh) | Zsh：[`config/`](zsh/config)は読み込み順に並べたシェルの設定、[`modules/`](zsh/modules)はコマンド |
| [`Brewfile`](Brewfile) | Homebrewのformula、cask、フォント、Mac App Storeアプリ |
| [`Uvfile`](Uvfile) | uvでインストールするCLIツール |
| [`install.sh`](install.sh) | クロスプラットフォームのインストーラー |

</details>

## 設定の追加

1. `myapp/`のようなディレクトリを作り、設定ファイルを入れます。
2. [`install.sh`](install.sh)からリンクします。

   ```bash
   safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
   ```

3. CIと同じチェックを実行します。

   ```bash
   shellcheck install.sh
   python3 -m unittest discover -s tests -v
   ```

[lintワークフロー](.github/workflows/lint.yml)はほかに、shfmt、zshの構文チェック、actionlint、YAMLとTOMLのlint、gitleaksによるシークレットスキャンも実行します。[インストールワークフロー](.github/workflows/install.yml)はUbuntuとmacOSで`install.sh`を2回実行し、冪等であることを確かめます。`master`でLintが通ると、[リリースワークフロー](.github/workflows/release.yml)がsemantic-releaseを実行し、前回のタグ以降のConventional Commitsから次のバージョンを決め、[`CHANGELOG.md`](CHANGELOG.md)を書き、GitHubリリースを公開します。

## セキュリティ

[`ssh/`](ssh)と`gnupg/keys/`にあるSSHとGPGの秘密鍵はリポジトリで管理しており、それぞれパスフレーズで保護しています。その他の認証情報は[`.gitignore`](.gitignore)で除外しています。APIトークンはGPGで暗号化したファイルとして保存し、シェル起動時に復号してキャッシュします。

GnuPGは署名の検証中にネットワークから鍵を取得しません。自動取得すると、どのメッセージを読んでいるかが第三者に伝わるため、鍵は`gpg --recv-keys`で明示的に取得します。

### メールの署名

送信メールはデフォルトで署名され、署名は`signature.asc`の添付ではなく本文中にインラインで書かれます。保存した下書きは暗号化されるため、暗号化メッセージの下書きが平文でメールサーバーに保存されることはありません。

インライン署名にはNeoMuttの従来型PGPバックエンドが必要です。GPGMEバックエンドではインラインのメッセージを作れないためです。両方のバックエンドを設定してあり、[`mutt/.muttrc`](mutt/.muttrc)のCryptoセクション先頭の1行で切り替えます。

| 設定 | バックエンド | 読み込むプロファイル |
|:--------|:--------|:----------------|
| `set my_pgp_inline = yes` | 従来型PGP、インライン署名 | [`mutt/crypto/inline.muttrc`](mutt/crypto/inline.muttrc) |
| この行をコメントアウト | GPGME、保護されたヘッダー付きのPGP/MIME | [`mutt/crypto/gpgme.muttrc`](mutt/crypto/gpgme.muttrc) |

`crypt_use_gpgme`は対話的に設定しても効果がないため、バックエンドを切り替えるにはNeoMuttの再起動が必要です。

従来型バックエンドは、複数の宛先を展開するために`pgpewrap`をコマンド名だけで呼び出します。`pgpewrap`はNeoMuttの`libexec`ディレクトリに含まれており、[`zsh/config/paths`](zsh/config/paths)がLinuxとmacOSの両方でこのディレクトリを`PATH`に追加します。

アカウントが適用する設定にはすべて、[`mutt/normalize.muttrc`](mutt/normalize.muttrc)に対応する`reset`があり、アカウントを切り替えるときに最初に実行されます。対応するresetなしでアカウントファイルに設定を追加すると、その設定は次のアカウントに引き継がれてしまいます。

## ライセンス

2014年から[MIT](LICENSE)です。

<div align="center">

<strong>macOSとLinux向けの、コマンド1つで整う開発環境です。zsh、Vim、tmuxと54のツール設定を、Catppuccin Mochaの1つのパレットで統一しています。</strong>

[English](README.md) | 日本語 | [简体中文](README.zh-Hans.md) | [繁體中文 (香港)](README.zh-HK.md)

[![install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![release](https://img.shields.io/github/v/release/gufranco/dotfiles?style=flat-square&label=release)](https://github.com/gufranco/dotfiles/releases/latest)
[![license](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square&label=license)](LICENSE)

</div>

---

これは私のdotfilesです。1つのスクリプトで、新しいMacやUbuntuのマシンを私の作業環境に仕上げます。シェル、エディター、ターミナルツール、Docker、そしてLinuxではゲーム用のSteam環境まで含みます。インストールとリンクの対象はすべて[REFERENCE.md](REFERENCE.md)に英語で載せています。

## 必要なもの

- macOS、またはx86_64かARMのUbuntu。Linuxではaptを使うため、ほかのディストリビューションには対応していません。
- Gitとcurl。macOSには最初から入っています。Ubuntuでは`sudo apt install git curl`を実行してください。
- `sudo`を使えるアカウント。

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh)はこのリポジトリを`~/.dotfiles`にクローンし、各設定をリンクします。macOSではHomebrewと[`Brewfile`](Brewfile)のすべてをインストールします。Ubuntuではapt、snap、各プロジェクトの公式インストーラーを使います。どの手順も冪等なので、途中で止まった場合はもう一度実行すれば直ります。

リンク先にすでにファイルがある場合は、削除せずに`<path>.backup.<timestamp>`へ移動します。

そのあと新しいシェルを開き、ツールが入っていることを確認します。

```bash
exec zsh
bat --version
zoxide --version
```

どちらもバージョン番号を表示します。

## 日常の使い方

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL on 127.0.0.1:5432 in Docker through Colima
fde                    # pick a running container with fzf and open a shell in it
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

覚えておくコマンドは`f5`だけです。このリポジトリをpullし、Vim、Neovim、Zsh、Tmuxのプラグインを更新し、miseのランタイムとすべてのシステムパッケージをアップグレードして、パッケージのキャッシュを削除します。パスワードは最初に一度だけ尋ね、終了時にroot権限を手放すので、次の`sudo`ではまたパスワードを尋ねられます。独自のメッセージは表示せず、ツール自身の出力だけを表示します。失敗したステップがあると1を返します。DockerとColimaのVMには触れないので、動いているコンテナはそのまま残ります。終わったら`exec zsh`を実行すると、新しいシェルの設定が読み込まれます。

macOSでは、`f5`が`brew bundle cleanup --force --zap`を実行し、[`Brewfile`](Brewfile)にないformula、cask、アプリをアンインストールします。手動でインストールする前にBrewfileへ追加してください。追加しないと次の`f5`で削除されます。

## 含まれるもの

**シェル。** Oh My ZshとSpaceshipプロンプトを使ったZsh、fzfとfzf-tab、zoxide、atuinの履歴、direnv、そしてNode.js、Python、Ruby用のmiseです。macOSでは、GNU版のcoreutils、sed、grep、tar、makeが`PATH`の先頭に来ます。

**エディター。** 31のプラグインと言語サポート用のCoCを入れたVimと、[`nvim/`](nvim)にあるlazy.nvimベースの独立したLua製Neovim設定です。

**Tmux。** Vim風のキー操作と19のプラグインです。Catppuccinテーマ以外はすべて[tmux-revamped](https://github.com/tmux-revamped)ファミリーのもので、セッションの保存と復元も含みます。

**Git。** [`git/.gitconfig`](git/.gitconfig)の60のエイリアス、GPG署名付きのコミットとタグ、diffページャーとしてのdeltaです。

**Docker。** ColimaがDockerを動かし、マシンのCPUとメモリに合わせてサイズを決めます。`postgres-init`、`mongo-init`、`redis-init`、`valkey-init`、`redict-init`、`ubuntu-init`はそれぞれコンテナを起動し、ポートは`127.0.0.1`だけにバインドします。

**自作ツール。** 私が書いた6つのコマンドラインツールです。macOSでは[gufranco/tap](https://github.com/gufranco/homebrew-tap)のHomebrew tapから入れ、Linuxではソースからビルドします。

- [fusho](https://github.com/gufranco/fusho)は、GitHubのユーザー名を宛先にして、どのチャットでも暗号化したメッセージを送ります。
- [jimaku](https://github.com/gufranco/jimaku)は、フォルダー内のすべての動画の字幕をダウンロードします。
- [kakikomi](https://github.com/gufranco/kakikomi)は、ディスクイメージをフロッピー、Zipディスク、USBメモリ、ハードディスクに書き込み、チャンクごとに検証します。
- [kiyome](https://github.com/gufranco/kiyome)は、検証付きの5つのパターンでディスクを消去します。
- [shiwake](https://github.com/gufranco/shiwake)は、フォルダー内のファイルをAからZのサブフォルダーに振り分けます。
- [yakitsuke](https://github.com/gufranco/yakitsuke)は、どんな動画もビデオCDのイメージに変換します。

**テーマ。** 22のツールが、mauveをアクセントにしたCatppuccin Mochaを使います。公式の移植版があるものはそれを使っています。

**Linuxでのゲーム。** x86_64のUbuntuでは、インストーラーがSteamOSを手本にしたSteamとProtonの環境を追加します。対象はNVIDIAのハイブリッドグラフィックスを積んだノートPCです。PrimeによるGPU切り替え付きのNVIDIAドライバー、XanModカーネル、scx_lavdスケジューラー、GameMode、MangoHud、Gamescope、GE-Protonを含みます。初回のインストール後に再起動し、`gaming-check`を実行してください。ARMのマシンではこの部分を飛ばします。

## 設定の追加

新しいディレクトリ、たとえば`myapp/`にファイルを置き、[`install.sh`](install.sh)からリンクします。

```bash
safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
```

pushする前に、CIと同じチェックを実行してください。

```bash
shellcheck install.sh
python3 -m unittest discover -s tests -v
```

## テスト

[installワークフロー](.github/workflows/install.yml)は、最新のUbuntu LTSと、Apple Silicon上のmacOS Tahoeで`install.sh`を2回実行し、すべてのリンクと主要なコマンドが`PATH`にあることを確認します。2回目の実行でスクリプトが冪等であることを確かめます。[lintワークフロー](.github/workflows/lint.yml)は、ShellCheck、shfmt、zshの構文チェック、actionlint、YAMLとTOMLのlint、gitleaksによるシークレットのスキャンを実行します。

## 制限

- Linuxで対応しているのはUbuntuだけです。
- Linuxでのゲームにはx86_64が必要です。ARMにはNVIDIAとMesaのドライバーを入れません。
- このリポジトリにあるSSHとGPGの秘密鍵は私のもので、私のパスフレーズで暗号化されています。フォークして使う前に、[`ssh/`](ssh)と`gnupg/keys/`を削除してください。

## ライセンス

[MIT](LICENSE)

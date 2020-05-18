---
title: MacのHomebrewとは？仕組み・使い方と用語整理
description: MacのHomebrewとは？GitHubやFormulaやCellerなどの用語からそれらの仕組みやinstallやlist,info,outdatedやupgradeやservices関連コマンドなどの使い方やkeg-onlyやtapなど細かな部分について説明する記事です。
categories: mac homebrew
tags: mac homebrew
image:
  path: /assets/images/2020-05-18-mac-homebrew-basic/eyecatch.png
---
便利だけど穴にハマると痛い目見て詰むパッケージ管理マネージャーです。

インストールや使い方だけでなく、どのような仕組みでパッケージがインストールされているのか大まかな図式で説明します。

## Homebrewとは？
macOS用パッケージマネージャーです。  
Macで使えるソフトウェア(パッケージ)の検索(search)、追加(install)、更新(update)、削除(uninstall)を司ります。
類似アプリにMacPortsがあります。

[Homebrew公式](https://brew.sh/)

## Homebrewのインストールと用語と仕組み

### インストール
ターミナルを開いて次のコマンドを実行するとHomebrewのインストールが始まります。

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

{% page_image 1.png , 100% , Homebrew インストールフロー %}

### 用語

- Homebrew: home-brew(自家製ビール)
- brew: (自動)醸造する, (名)ビール
- Formula: 製法
- Celler: 酒貯蔵室

### 仕組み
[Homebrew/brew](https://github.com/Homebrew/brew)からクライアントソフトをインストール
[Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core/)からFormulaをダウンロード
Formulaにはインストール手順が書いてあるため、それに従ってインストールされます。

例えばnginxだと次のような手順書になっています。[homebrew-core/nginx.rb](https://github.com/Homebrew/homebrew-core/blob/master/Formula/nginx.rb)

インストールしたら`/usr/local/Celler`に配置して、`/usr/local/bin`にシンボリックリンクを貼ることでどこからでも呼べるようにします。

「酒造方法が公開された様々な自家製ビールを製造して自分の酒貯蔵室に入れる」ってイメージです。

ざっくり流れを表すとこんな感じです。

{% page_image 2.png , 100% , Homebrew formula install flow %}

最後(6)のシンボリックリンクもHomebrewがやります。


## searchコマンド
Syntax: `brew search [formula]`

例えば`nginx`で調べた場合です。
```sh
$ brew search nginx
==> Formulae
nginx ✔
```

## infoコマンド
Syntax: `brew info [formula...]`


例えば`nginx`の場合です。

```sh
$ brew info nginx
nginx: stable 1.17.10 (bottled), HEAD
HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server
https://nginx.org/
/usr/local/Cellar/nginx/1.17.8 (25 files, 2MB) *
  Poured from bottle on 2020-02-20 at 03:07:40
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/nginx.rb
==> Dependencies
Required: openssl@1.1 ✔, pcre ✔
==> Options
--HEAD
	Install HEAD version
==> Caveats
Docroot is: /usr/local/var/www

The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
nginx can run without sudo.

nginx will load all files in /usr/local/etc/nginx/servers/.

To have launchd start nginx now and restart at login:
  brew services start nginx
Or,if you dont want/need a background service you can just run:
  nginx
  ==> Analytics
install: 33,169 (30 days), 103,486 (90 days), 410,718 (365 days)
install-on-request: 32,184 (30 days), 100,197 (90 days), 394,782 (365 days)
build-error: 0 (30 days)
```

この表示の元となる情報は[Formula](https://github.com/Homebrew/homebrew-core/blob/master/Formula/nginx.rb)になります。

## installコマンド
Syntax: `brew install [formula...]`

指定されたFormulaをインストールします。

例えば`bash-completion`の場合です。

```sh
$ brew install bash-completion
Updating Homebrew...
==> Auto-updated Homebrew!
Updated Homebrew from 9fcaa46cd to ca5eac845.
Updated 2 taps (homebrew/core and homebrew/cask).
==> New Formulae
erlang@22                                                    spotify-tui                                                  spotifyd
==> Updated Formulae
ffmpeg ✔            code-server         erlang              git-absorb          mariadb             opencv              pianobar            unpaper             yaws
x264 ✔              contentful-cli      ffmpeg2theora       gst-plugins-ugly    mgba                opencv@2            pipx                vapoursynth-sub
caffe               couchdb             ffmpeg@2.8          komposition         minidlna            opencv@3            qcli                vcs
cgns                dungeon             ffmpegthumbnailer   libav               mpd                 openimageio         scrcpy              whistle
chromaprint         ejabberd            ffms2               libwebsockets       mpv                 pdfsandwich         siril               wrangler
==> Updated Casks
cryo                                         graphicconverter                             mini-program-studio                          whalebird

==> Downloading https://homebrew.bintray.com/bottles/bash-completion-1.3_3.mojave.bottle.tar.gz
######################################################################## 100.0%
==> Pouring bash-completion-1.3_3.mojave.bottle.tar.gz
==> Caveats
Add the following line to your ~/.bash_profile:
  [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

Bash completion has been installed to:
  /usr/local/etc/bash_completion.d
==> Summary
🍺  /usr/local/Cellar/bash-completion/1.3_3: 189 files, 607.8KB
```

インストールした後に追加で必要な設定や追加のインストールなど重要な情報が載っている場合があります。
この場合は、`.bash_profile`に処理を追加するよう書いてます。

## list(ls)コマンド
Syntax: `brew list` または `brew ls`

`brew list`または`brew ls`でインストール済みのパッケージを確認します。  
`ls`コマンド同様に`-l`オプションを渡すことで縦に一覧化します。

## uninstallコマンド
Syntax: `brew uninstall formula...`

Formulaをアンインストールします。

## outdatedコマンド
Syntax: `brew outdated [formula...]`

新バージョン差異を確認する。  
バージョン差異がなければ何も表示されない。
引数で`formula`無指定だとインストールしている全てのformulaを対象。

## upgradeコマンド
Syntax: `brew upgrade [formula...]`

formulaを新しいバージョンに更新する。
引数で`formula`無指定だとインストールしている全てのformulaを対象。

## servicesコマンド群でlaunchd制御
自動起動の登録制御です。  
インストールしたソフトウェアによっては自動起動をサポートするものもあります。

`services`コマンド群はそれらを`launchctl`コマンドや`~/Library/LaunchAgents`ディレクトリにplistファイルを配置せずに
`services start`, `stop`, `list`コマンドを使って`launchd`デーモンを制御できるようになります。

### services startコマンド
Syntax: `brew services start formula`

渡したコマンドを自動起動します。

例えば`mysql@5.6`formulaを`brew info`で見ると次のように案内があります。

```
To have launchd start mysql@5.6 now and restart at login:
  brew services start mysql@5.6
Or, if you don't want/need a background service you can just run:
  /usr/local/opt/mysql@5.6/bin/mysql.server start
```

`mysql.server start`コマンドでMySQLサーバーをその都度起動するか、
もしくは、`brew services start mysql@5.6`コマンドで自動起動させるか方法を提示してます。

### services listコマンド
Syntax: `brew services list` or `ls`

現在自動起動中になっているformula一覧を確認します。

例えば手元のPCだとこうなります。

```sh
$ brew services ls
Name                       Status  User    Plist
mysql@5.6                  stopped
nginx                      started mothule /Users/mothule/Library/LaunchAgents/homebrew.mxcl.nginx.plist
php                        started mothule /Users/mothule/Library/LaunchAgents/homebrew.mxcl.php.plist
postgresql                 started mothule /Users/mothule/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
redis                      started mothule /Users/mothule/Library/LaunchAgents/homebrew.mxcl.redis.plist
selenium-server-standalone started mothule /Users/mothule/Library/LaunchAgents/homebrew.mxcl.selenium-server-standalone.plist
```

### services stopコマンド
Syntax: `brew services stop formula`

自動起動を解除します。


先程のnginxの自動起動を止めた場合です。

```sh
$ brew services stop nginx
Stopping `nginx`... (might take a while)
==> Successfully stopped `nginx` (label: homebrew.mxcl.nginx)
```

### services runコマンド
Syntax: `brew services run formula`

自動起動の登録せずにサービスとして起動します。


## Homebrew caskでGUIアプリの制御
紹介したコマンドに`brew`とコマンドの間に`cask`を入れるとGUIアプリケーションの制御となります。  
caskとはお酒を入れる木製の大樽です。

Syntax: `brew cask commands ...`

つまりこういうことです。

- `brew cask search formula`
- `brew cask info formula`
- `brew cask install formula`
- `brew cask list` or `ls`
- `brew cask uninstall`
- `brew cask outdated`
- `brew cask upgrade`

## keg-onlyとは
時折brew infoなどで`keg-only`という単語を見かけます。

例えば`brew info mysql@5.6`にも`key-only`とあります。
これは大抵が上書きリスクのあるformulaについてます。
例えばMacに標準インストールされているコマンドのGNU版などです。

これはインストールして`/usr/local/Celler`に配置まではしたが、  
`/usr/local/bin`へシンボリックリンクを繋いでいない状態です。

`brew link`することでリンクされて使えるようになります。  
しかし、既存コマンドのパスが変わる可能性が高いので、慎重に行うことを推奨します。

## formulaが見つからない
手元のhomebrewが古い可能性があります。  
`brew update`で更新することで見つかるかもしれません。

しかし、手元の古いバージョンは破棄することがあるので、  
今まで偶然残っていたお陰で動いてたコマンドがバージョンが最新のみになったことでパスが通らなくなり知らぬところでエラーが発生することもあるので注意が必要です。

## 再インストール
インストール済みのソフトウェアが何かの拍子におかしくなった場合、  
再インストールを促されることがあります。  
Homebrewの場合は`brew reinstall`コマンドがあります。

## tapってコマンドが出てきた
デフォルトのformula一覧とは別の場所からformulaを取ってきたい場合に使うコマンドです。  
この`tap`コマンドを使うことでタップした先からもformulaをインストールすることが出来ます。  
`tap`とは蛇口です。樽に蛇口を差し込んだイメージが丁度いいです。

## 基本は簡単だけど運用は難しい
Homebrewの説明は以上です。ある程度網羅かつシンプルな説明にはなっていますが、
実際に使っていくと最初はよくても後半の方で色々とformulaの依存関係が衝突を起こしたりして
自力で解決を迫られることが多くあります。
**何気なくbrew upgrade** を実行したら色々なformulaが最新化されて、  
それを使ってた物が動かなくなるなんてことは普通にあります…

- OpenSSLのバージョンが変わって旧バージョンのパスが消えたRubyが動かなくなる「{% post_link_text 2020-02-20-tools-rbenv-ssl-load-error %}」
- readlineの更新でtigが動かなくなった「{% post_link_text 2019-07-23-mac-homebrew-how-to-downgrade %}」

など他にも記事にはしてませんが、Pythonのバージョンにより[HTTPie](https://blog.mothule.com/tools/httpie/recommend-httpie)が動かなくなる件など。

brewは便利なパッケージ管理マネージャーですが、扱っているパッケージ(コマンド)のインストール先や呼び出される仕組みを理解しておかないと、
シェルコマンドはパスという糸つなぎのようなものなので、自力で追いかけられなくなります。

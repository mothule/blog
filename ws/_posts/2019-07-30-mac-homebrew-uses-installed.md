---
title: Homebrewのpackage依存関係を確認する
categories: mac homebrew
tags: mac homebrew
image:
  path: /assets/images/2019-07-30-mac-homebrew-uses-installed.png
---
長いことHomebrewに色々とインストールしてると、たまにもう使っていないフォーミュラ（パッケージ）を削除したいなと思いませんか？
`$ brew list -l` で一覧出して眺めて、「もうこれは使っていないな」と分かるパッケージは消していきますが、
「これ何で入れたんだっけ？」と思うパッケージが結構います。


## brew lsでインストールしてるパッケージを確認

まずは自分の環境にインストールされているパッケージ一覧を確認してみます。  
インストール済みパッケージは、`brew list`コマンドで確認することができてフォーマットは次の通りです。

`Usage: brew list, ls [options] [formula]`

`brew list`や`brew ls`でインストール済みパッケージを表示します。

他にも`brew ls`に機能が備わっていますが、この記事のテーマから外れるので詳細は省きます。

{% comment %}
brew listの詳細解説記事を書いたらここからリンクを貼る
{% endcomment %}

```sh
$ brew list
apr				carthage			fribidi				gobject-introspection		jpeg				libvterm			msgpack				pcre				pyenv				selenium-server-standalone	xcparse
apr-util			chisel				fzf				graphite2			jq				libyaml				mysql@5.6			pcre2				python				sqlite				xctool
argon2				circleci			gd				graphviz			lame				libzip				neovim				perl				python@2			the_silver_searcher		xvid
aspell				cmake				gdbm				harfbuzz			libffi				lua				nginx				phantomjs			python@3.8			tig				xz
autoconf			ctags				gettext				heroku				libpng				luajit				node				php				rbenv				tree				yarn
automake			curl				git				heroku-node			libpq				lzo				nvm				pixman				rbspy				unibilium
awscli				ffmpeg				git-flow			httpie				libsodium			mas				oniguruma			pkg-config			readline			unixodbc
bash				firebase-cli			glib				hugo				libtermkey			mcrypt				openssl				plantuml			redis				vim
bat				fontconfig			gmp				icu4c				libtiff				mhash				openssl@1.1			pngpaste			rsync				webp
bitrise				freetds				gnu-getopt			imagemagick			libtool				mkcert				pango				postgresql			ruby				wget
cairo				freetype			gnu-sed				jemalloc			libuv				mono				parallel			pstree				ruby-build			x264
```

### -lオプションでリスト表示にする

`-l`オプションでAZ順のリスト表示になります。  
ブログで全部表示すると量が多いので一部となります。

```sh
$ brew list -l
total 0
drwxr-xr-x  3 mothule  admin   96 Jul  1  2018 apr
drwxr-xr-x  3 mothule  admin   96 Jul  1  2018 apr-util
drwxr-xr-x  3 mothule  admin   96 Jul  1  2018 argon2
drwxr-xr-x  3 mothule  admin   96 Jul  1  2018 aspell
drwxr-xr-x  3 mothule  admin   96 Mar  1  2017 autoconf
...
drwxr-xr-x  3 mothule  staff   96 Jul 22  2019 vim
drwxr-xr-x  4 mothule  admin  128 Jul  1  2018 webp
drwxr-xr-x  3 mothule  admin   96 Aug 14  2017 wget
drwxr-xr-x  3 mothule  admin   96 Sep 20  2017 x264
drwxr-xr-x  3 mothule  admin   96 Apr 15 14:38 xcparse
drwxr-xr-x  3 mothule  admin   96 Mar 30  2017 xctool
drwxr-xr-x  3 mothule  admin   96 Sep 20  2017 xvid
drwxr-xr-x  3 mothule  admin   96 Mar  5  2019 xz
drwxr-xr-x  3 mothule  admin   96 Jul  1  2018 yarn
```

## brew depsで依存してるパッケージを確認

`brew deps`コマンドで渡したパッケージが、どのパッケージを使っているのか確認することができます。
フォーマットは次の通りです。

`Usage: brew deps [options] [formula]`

例えば下記はRubyバージョン管理パッケージであるrbenvがどのパッケージを使っているのか確認した結果になります。

```sh
$ brew deps rbenv
autoconf
openssl
pkg-config
ruby-build
```

### --treeオプションでツリー構造で依存関係を表示

`brew deps`に`--tree`オプションを渡すことで依存パッケージをツリー形式で表示することができます。

```sh
$ brew deps --tree rbenv
rbenv
├── autoconf
├── openssl
├── pkg-config
└── ruby-build
    ├── autoconf
    ├── pkg-config
    └── readline
```
ツリー形式で表示することで`ruby-build`はさらに3つのパッケージに依存してることが分かります。

### --full-nameオプションで具体的な名前を表示

`brew deps`に`--full-name`オプションを渡すことで省略表示されているパッケージを実際の名前で表示することが出来ます。

```sh
$ brew deps --full-name rbenv
autoconf
openssl@1.1
pkg-config
ruby-build
```

このように`openssl`が1.1バージョンを使っていることが分かります。

### オプションは組み合わせ可能

オプションは複数使うことで同時に複数効果を得られます。  
次の例は`--full-name`と`--tree`を使った結果になります。

```sh
$ brew deps --full-name --tree rbenv
rbenv
├── autoconf
├── openssl@1.1
├── pkg-config
└── ruby-build
    ├── autoconf
    ├── pkg-config
    └── readline
```

## brew usesで依存されてるパッケージを確認

先程`rbenv`が依存してるパッケージ一覧を確認しました。  
では今度は逆にこの`rbenv`を使っているパッケージが存在するか調べてみましょう。
`brew uses`コマンドを使うことで調べられます。フォーマットは次の通りです。

`Usage: brew uses [options] formula`

この`brew uses`コマンドで`rbenv`を使っているパッケージを調べた結果が次になります。

```sh
$ brew uses rbenv
rbenv-aliases                     rbenv-bundler                     rbenv-communal-gems               rbenv-gemset                      rbenv-whatis
rbenv-binstubs                    rbenv-bundler-ruby-version        rbenv-ctags                       rbenv-use
rbenv-bundle-exec                 rbenv-chefdk                      rbenv-default-gems                rbenv-vars
```

`rbenv`のプラグインらしきものが並びますね。

### パッケージ依存をインストール済みに限定する
`brew uses`コマンドはデフォルトでは`Homebrew`で管理されている全てのパッケージが検索対象となります。  
**これを`--installed`オプションをつけることで自分のインストール済みに制限できます。**  
このオプションをつけてもう一度`brew uses rbenv`を実行してみます。

```sh
$ brew uses --installed rbenv

```

今度は結果が空になりました。これはインストール済みパッケージには、**`rbenv`を使ったパッケージがないことを表しています。**

## brewの依存関係を確認できるコマンド整理

「依存してる」「依存されてる」と「brew deps」「brew uses」ちょっと混乱してしまい、実際に使う時に「どっちがどっちだっけ？」なりそうです。  
なので最後に整理します。

|目的|コマンド|便利なオプション|
|---|---|---|
|何が入ってる？|`brew ls`|`-l`|
|これ誰が使ってる？|`brew uses`|`--installed`|
|これ何が必要？|`brew deps`|`--tree`|

### 最後にPackageではなくFormula
最後に、パッケージ(package)という用語で説明していますが、HomebrewではパッケージではなくFormula(フォーミュラ)といいます。製法・調合法という意味です。Homebrew(home-brew)が自家醸造酒という意味なのでビール製法って意味ですね。

Homebrewに不慣れな方は、パッケージという用語で検索が多いのでニーズに合わせてこちらの用語を使いました。

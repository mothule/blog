---
title: MacユーザがCentOS8にRuby環境を構築する
description: 普段Mac上でrbenvやRuby環境を構築はできてるがCentOSなどLinux環境には構築したことがない人向けにCentOS8上にrbenvとRuby環境を構築する手順を説明します。
categories: linux centos
tags: linux centos ruby
image:
  path: /assets/images/2021-02-19-linux-centos-build-ruby-env-on-centos/eyecatch.png
---
Mac上にrbenvによるRuby環境を構築したりRailsアプリを作ったことあるが、Linux(CentOS8)ではまだの人向けに記事を書きました。

## Linux自体の初期セットアップは済ませておく
ローカルPCであれば問題はないですが、VPSなど外部にLinuxサーバを立てた場合は、Ruby環境の前にLinux自体のセキュリティセットアップを実施することをおすすめします。

セットアップに関しては、「{% post_link_text 2021-02-19-linux-centos-centos8-setup-secure-server %}」にまとめてあります。

## Macと違ってHomebrewがない
Mac環境下ではrbenvはHomebrewを使ってインストールします。
しかし、CentOSではHomebrewがありません。
しかもCentOS用パッケージ管理ソフトウェアであるyumにもrbenvがありません。

### GitHubからrbenvを直接ダウンロードする
CentOS8ではgitを使いGitHubから直接rbenvやrbenv用プラグインをインストールします。
rbenvのプラグインにあたるruby-buildも同様です。

## Ruby環境構築の流れ
gitのインストールから始まり、rbenvとRubyのインストールするまでの流れになります。

1. yumでgitをインストール
1. GitHubからrbenvとruby-buildをインストール
1. yumで依存パッケージをインストール
1. rbenvでRubyをインストール

## CentOS8にyumでgitをインストール
最初にGitHubからダウンロードに必要なgitをyumからインストールします。yumでなくともdnfでも問題ありません。
```sh
$ sudo yum -y install git
$ git --version
git version 2.27.0
```

## GitHubからrbenvをインストール
gitが使えるようになったら、GitHubからrbenvとプラグインとなるruby-buildをダウンロード(クローン)します。
ダウンロード先はrbenv、Rubyを実行したいユーザーのhomeディレクトリ(~)にします。
```sh
$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
$ git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

### rbenvとsstephensonの違い
ネット記事ではURLが`https://github.com/sstephenson/rbenv.git`となっている記事を多数見かけますが、ブラウザでアクセスすると分かりますが、rbenvにリダイレクトされています。なのでどちらも同じものと見て良いです。
個人的には`sstephenson`よりも`rbenv`のほうが覚えやすいです。

### rbenvを初期化
rbenv, ruby-buildをダウンロードしたら、普段Macで叩いてるrbenvが、`~/.rbenv/bin/rbenv`に配置されています。
これに`init`を渡して実行するとセットアップ方法が表示されます。

```sh
$ .rbenv/bin/rbenv init
# Load rbenv automatically by appending
# the following to ~/.bash_profile:

eval "$(rbenv init -)"
```

指示に従って`~/.bash_profile`に`eval "$(rbenv init -)"`を記入して`.bash_profile`をリロードするとエラーが発生します。

```sh
$ source .bash_profile
-bash: rbenv: コマンドが見つかりません
```

理由は`rbenv`にパスが通っていないためです。`eval "$(rbenv init -)"` を動かすには rbenvにパスを通す必要があります。パス設定を`eval "$(rbenv init -)"`の手前に追加して、rbenvにパスを通します。
`.bash_profile`の末尾に次の2行がある状態です。

```sh
export PATH="~/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
```

この状態でもう一度`.bash_profile`をリロードすれば今度はエラーは発生しないはずです。
Linux上のログインシェルをzshにしてる方は適宜置き換えてください。  
`.bash_profile` → `.zshrc` or `.zprofile`

これでCentOS上にrbenvのインストールが完了しました。
MacではHomebrewがパス周りをいい感じにやってくれてるし、インストール後のセットアップ処理もbrewのインストール完了したら表示してくれるので優しいし楽ですね。

## yumで依存パッケージをインストール
rbenvがインストールできたら後はMac同様にrbenvを使ってRubyをインストールするだけ…って感じではなさそうです。
Rubyをビルドするために必要なパッケージをyumからインストールが必要です。

```sh
$ sudo yum -y install bzip2 gcc openssl-devel readline-devel zlib-devel
```

なおいくつかのパッケージ名の後ろについている`-devel`とはデビル(devil)ではなくdevelopの短縮文字です。
通常と比べて開発に必要なヘッダーファイル等が含まれます。

## rbenvからRubyをインストール
準備が整ったらrbenvを使ってRubyをインストールします。
MacでもCentOS(Linux)でもrbenvのコマンドの使い方に違いはありません。(全部確認はしていませんが)

### インストール可能なバージョンを確認

```sh
$ rbenv install --list
2.5.8
2.6.6
2.7.2
3.0.0
```

### Rubyバージョン指定してインストール
今回は`2.7.2`をインストールします。
Mac同様Rubyのインストールには時間がかかります。

```sh
$ rbenv install 2.7.2
Downloading ruby-2.7.2.tar.bz2...
-> https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.2.tar.bz2
Installing ruby-2.7.2...
```

### デフォルトのバージョンを設定
インストールされたRubyバージョンをglobalを設定しておきます。

```sh
$ rbenv versions
  2.7.2
$ rbenv global 2.7.2
$ ruby -v
ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-linux]
```

local(`.ruby-version`)で上書きされない限りはこのバージョンが使われます。

### rubygemsを更新する
Rubyに付属するRuby用パッケージマネージャーRubygemsを更新します。

```sh
$ gem update --system
```

## Ruby動作確認する
Rubyのインストールが完了したら、最後にねんのためコード実行して動作確認します。

```sh
$ mkdir test
$ echo 'puts "hello world"' > test/helloworld.rb
$ ruby test/helloworld.rb
hello world
```

ここまで通ればCentOSにrbenvとRubyのインストールは完了です。

## CentOS8上にnginxとPumaとRailsアプリを構築する
Ruby環境が整ったら、次のステップとしてはRailsアプリをCentOS8上にデプロイして動かしてみることです。
また実際のアプリではPumaがWebサーバとして動くのではなくnginxを前段においてリバースプロキシが一般的です。
それらをAnsibleやCapistranoを使わずgitとSSHなど手作業で構築することは体系的な知識構築に大いに貢献できます。

それらに関する記事を「{% post_link_text 2021-02-19-ruby-rails-build-nginx-puma-rails-on-centos %}」にまとめてあります。

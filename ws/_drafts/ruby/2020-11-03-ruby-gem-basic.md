---
title: RubyのgemやRubyGemsやgemコマンドなど曖昧基礎を整理する
description: RubyのgemやRubyGems、gemコマンドなどgemという言葉一つに類似や同名だけど意味の事なる言葉が関連しているせいで体系的な知識を得にくいRubyのgem。RubyやRailsでは頻発するgemを曖昧な知識のままにせずきちんと整理した記事です。
categories: ruby gem
tags: ruby gem
---
RubyやRailsを使うなら頻繁に使用するgemについて一定の基礎知識は持っておいたほうがいいです。  
この記事ではRubyのgemと関連用語や基礎的な知識について整理し、曖昧な知識を棚卸しすることで体系的な知識へと昇華をサポートする記事です。

## Rubyのgemとは？
RubyGemsによって管理された**Rubyプログラム**を指します。  
Rubyコードをパッケージングすることで、様々なプログラムで流用することができ再利用性が高まります。

### RubyGemsとは？
RubyGemsとは、Rubyのためのパッケージマネージャです。  
gemは一塊のRubyプログラムとして管理されており、一般公開することで誰でもgemをインストールし利用することが可能となります。  
公開されているgemは[RubyGems.org](https://rubygems.org/)から探すことが出来ます。  
インストールやアンインストールはgemコマンドから制御します。  
またgemコマンドからもgem名で検索したり、サマリーも確認できます。

### gemコマンドとは？
gemパッケージのビルド、アップロード、ダウンロード、インストールなどが出来るシェルコマンドの総称です。

## RubyGemsについて仕組みを理解する
RubyGemsはパッケージマネージャーですが、実際にはgemコマンドで操作することが大半なため、  
口頭ではgemコマンドと呼ばれることが多いです。  
用語が似ていたり、Ruby自体との関連に曖昧なのでここで整理します。

- gem: Rubyプログラム、gemライブラリとか、gemパッケージと呼ばれたりもする。
- RubyGems: Ruby用パッケージマネージャ、gemを管理する。**gemの配布サーバ機能も持つ。**
- gemコマンド: RubyGemsを操作するシェルコマンドの総称

例えばbashから`gem install xxx`を実行した場合のフローを図で表すと下図のようになります。

{% page_image 1.png , 100% , rubygems system design %}

### RubyGems.orgとは？
`RubyGems.org`はデフォルトのgemサーバです。ほぼ大抵のgemはここで公開されており、gemコマンドでのインストール`source`もここを指しています。  

### RubyGems.org以外のgemサーバ
図にある `YourGems.com`のように自前でgemサーバを立ち上げることもでき、gemインストール時に`source`を指定することで、そっちからインストールも出来るようになります。  
このgemサーバは、RubyGemsの機能として用意されてます。

### gemのインストール場所を確認する
インストールされたgemは、`$ gem environment`コマンドで確認できます。  
これの`INSTALLATION DIRECTORY`がgemがインストールされているパスになります。

```sh
$ gem environment
RubyGems Environment:
  - RUBYGEMS VERSION: 3.0.3
  - RUBY VERSION: 2.6.3 (2019-04-16 patchlevel 62) [universal.x86_64-darwin19]
  - INSTALLATION DIRECTORY: /Library/Ruby/Gems/2.6.0
  - USER INSTALLATION DIRECTORY: /Users/mothule/.gem/ruby/2.6.0
  - RUBY EXECUTABLE: /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby
  - GIT EXECUTABLE: /usr/bin/git
  - EXECUTABLE DIRECTORY: /usr/local/bin
...略...
```
このパスは、システム環境によって変化します。先程はステムで管理されたRubyですが、rbenvで管理された場合は次のように変わります。

```sh
$ gem environment
RubyGems Environment:
  - RUBYGEMS VERSION: 3.1.4
  - RUBY VERSION: 2.6.5 (2019-10-01 patchlevel 114) [x86_64-darwin19]
  - INSTALLATION DIRECTORY: /Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0
  - USER INSTALLATION DIRECTORY: /Users/mothule/.gem/ruby/2.6.0
  - RUBY EXECUTABLE: /Users/mothule/.rbenv/versions/2.6.5/bin/ruby
  - GIT EXECUTABLE: /usr/bin/git
  - EXECUTABLE DIRECTORY: /Users/mothule/.rbenv/versions/2.6.5/bin
...略...  
```

なお各PCやOSなどによってパスも異なります。

## Rubyのgemをインストールする
Rubyのgemをインストールするにはgemコマンドの`gem install`コマンドを使います。  
`gem install`のフォーマットは次の通りです。

`$ gem install GEMNAME [GEMNAME ...] [options] -- --build-flags [options]`

- GEMNAME: gem名を指定します。スペース区切りすることで同時に複数gemをインストールできます。
- options: インストール関する細かな設定を指定できます。
- --build-flags [options]: ビルドを必要とするgemでビルドオプションを渡します。

### 複数gemを同時インストール

一度に複数のgemをインストールするには、空白区切りでgem名を並べます。

```sh
$ gem install GEMNAME-1 GEMNAME-2
```

### ビルドに使うライブラリのパスを指定する

例えばMySQL用のgem mysql2をインストールする場合、OpenSSLが原因でエラーが出る場合は、  
OpenSSLのパスを渡す必要があります。  
その場合は次のように`--build-flags`を使い、OpenSSLのディレクトリパスを渡します。

```sh
$ gem install mysql2 --with-opt-dir=/usr/local/opt/openssl
```

mysql2 gemのOpenSSLエラーについては「{% post_link_text ruby-rails-mysql56-mysql2-error-fix %}」の記事をどうぞ。

### プラットフォーム指定
`--platform PLATFORM`オプションを使うことで、そのプラットフォーム向けのパッケージが選択されるようになります。

例： Windows環境でsqlite3をインストールする。
```sh
$ gem install sqlite3 --platform mswin
```

### 指定バージョンのgemをインストールする
デフォルトでは最新バージョンがインストールされます。  
もし最新ではなく特定のバージョンをインストールしたい場合は、`--version VERSION`オプションで指定します。

```sh
$ gem install rails --version "5.2.4.4"
```

また省略形も使えます。

```sh
$ gem install rails -v "5.2.4.4"
```

## インストール済みのgem一覧を確認する
現在のRubyバージョン内にインストールされているgem一覧を確認するには、`gem list`コマンドを使います。  
フォーマットは`$ gem list [REGEXP ...] [options]`となっています。

```sh
$ gem list

*** LOCAL GEMS ***

bigdecimal (default: 1.4.1)
bundler (default: 1.17.2)
CFPropertyList (2.3.6)
cmath (default: 1.0.0)
csv (default: 3.0.9)
date (default: 2.0.0)
dbm (default: 1.0.0)
did_you_mean (1.3.0)
...省略...
```

正規表現で絞り込みすることもできます。

```sh
$ gem list ^w.*$

*** LOCAL GEMS ***

webrick (default: 1.4.2)
websocket-driver (0.7.3)
websocket-extensions (0.1.5)
```

## Rubyのgemをアンインストールする
Rubyのgemをアンインストールするにはgemコマンドの`gem uninstall`コマンドを使います。  
`gem uninstall`のフォーマットは次の通りです。

`gem uninstall GEMNAME [GEMNAME ...] [options]`

`gem install`コマンド同様に一度に複数gemの指定や、バージョン指定もできます。

## Rubyのgemを利用する

Rubyのgemの使い方について説明します。  
gemは種類によって利用方法が異なります。

- コマンドライン上からシェルコマンドとして呼び出すgem
- Rubyスクリプト上で呼び出すgem
- もしくは両方サポート

### gemをシェルコマンドとして利用する
Rubyのgemは前述で説明したようにRubyコードの塊です。  
そしてターミナル上でRubyとgemへのパスが通っていれば、ターミナル上からgem名を指定することでRubyスクリプトが実行されて、  
gemとしての機能を果たします。

例:  
```sh
$ bundle install
```

### gemをRubyコードから利用する
gem内には関数のみが定義されていて、関数を実行しない限りは動かないgemもあります。  
その場合は`require`ディレクティブ等でgemをロードし、関数を呼ぶ必要があります。

例:
```ruby
require 'active_support/all'

''.blank? # blank?はactive_support内で定義されているメソッド
```

## 更新が必要なgem一覧を確認する
現在ローカルにインストールされているgemに新しいバージョンが公開されて、  
更新可能なgem一覧を調べるには、`gem outdated`コマンドを使います。

```sh
$ gem outdated
CFPropertyList (2.3.6 < 3.0.2)
bigdecimal (1.4.1 < 2.0.0)
bundler (1.17.2 < 2.1.4)
csv (3.0.9 < 3.1.7)
date (2.0.0 < 3.0.1)
dbm (1.0.0 < 1.1.0)
did_you_mean (1.3.0 < 1.4.0)
etc (1.0.1 < 1.1.0)
fileutils (1.1.0 < 1.4.1)
forwardable (1.2.0 < 1.3.1)
io-console (0.4.7 < 0.5.6)
...省略...
```

## Rubyのgemを更新する
gemを更新するには`gem update`コマンドを使います。  
フォーマットは次の通りです。

`$ gem update GEMNAME [GEMNAME ...] [options]`

`gem install`や`gem uninstall`と同じフォーマットですね。  
ただし注意点として、gem指定しない場合は全てのgemを更新します。  

## RubyGemsを更新する
gemを管理するRubyGems自身も一つのソフトウェアです。  
これを更新するには、`gem update`コマンドに`--system`オプションをつけます。

`$ gem update --system`

とすることで、RubyGems自身の更新が実行されます。

## RubyのgemやRubyGemsやgemコマンドなど曖昧基礎を整理するメリット
この記事を読み解くことで、gemがなんなのか？gemの周りにある似たような名前はなんなのか？など関連や立ち位置が把握できたかと思います。  
gemは使い方だけ知ってるだけでもgemを使うことはできます。しかし、RubyやRailsを専門に扱うエンジニアであれば、その知識レベルにとどまらずgem自体をきちんと理解することはエンジニアとして一歩前にスキルアップにつながるかと思います。  
この記事ではgemの全体のなかの合間今部分を浅く広く整理した記事となります。そのためこの記事では説明されていない要素も多く含まれます。  
この記事ではその入り口として捉え、継続して知識吸収することが大事です。

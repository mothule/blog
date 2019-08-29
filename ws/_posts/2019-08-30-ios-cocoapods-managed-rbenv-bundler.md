---
title: CocoaPodsをrbenv+bundlerで管理する
description: iOS開発をする上で必要になってくるCocoaPods。これはRubyで書かれたPodという単位でiOSライブラリを管理するライブラリ管理ソフトウェアです。CocoaPods単体であれば特に考えず `$ gem install cocoapods` で直接現在のRubyのバージョンのCocoaPodsを入れておしまいですが、fastlaneやslatherなどRubyで書かれたエコシステムも使うとなると、Rubyバージョンを意識する必要が出てきます。なぜなら、個人開発であれば大抵開発環境は1つであるため問題は起きませんが、チーム開発となると環境を揃えず闇雲にその時点の最新バージョンをインストールしていては人によって挙動が異なるなど、人依存(環境依存)の不具合が発生するためです。このようなどうでもいい部分で開発を妨害されないために、今回はCocoaPodsなどRuby製ツールをまとめて管理する方法についてまとめました。
date: 2019-08-30
categories: ios cocoapods
tags: ios cocoapods rbenv bundler
image:
  path: /assets/images/2019-08-30-ios-cocoapods-managed-rbenv-bundler.png
---
iOS開発をする上で必要になってくるCocoaPods。これはRubyで書かれたPodという単位でiOSライブラリを管理するライブラリ管理ソフトウェアです。
CocoaPods単体であれば特に考えず `$ gem install cocoapods` で直接現在のRubyのバージョンのCocoaPodsを入れておしまいですが、
fastlaneやslatherなどRubyで書かれたエコシステムも使うとなると、Rubyバージョンを意識する必要が出てきます。

なぜなら、個人開発であれば大抵開発環境は1つであるため問題は起きませんが、
チーム開発となると環境を揃えず闇雲にその時点の最新バージョンをインストールしていては
人によって挙動が異なるなど、人依存(環境依存)の不具合が発生するためです。

このようなどうでもいい部分で開発を妨害されないために、今回はCocoaPodsなどRuby製ツールをまとめて管理する方法についてまとめました。

## 結論

```sh
$ xcode-select --install
$ brew install rbenv ruby-build
rbenv install --list でインストールしたいバージョンを決める
$ rbenv install [Ruby version]
$ gem install bundler
$ bundle init
Gemfileに gem 'cocoapods' を追加.バージョン指定はCocoaPodsと同じ.
$ git clone git://github.com/ianheggie/rbenv-binstubs.git ~/.rbenv/plugins/rbenv-binstubs
$ bundle install --path=vendor/bundle --binstubs=vendor/bin
$ pod install
```

## rbenvでRuby管理してgem管理はbundler

bundlerの前にRubyバージョンを管理するためにrbenvを入れて、RubyバージョンとbundlerバージョンとCocoaPodsバージョンをあわせます。

- rbenv が Ruby 管理
- Ruby の bundler gem が CocoaPods gem 管理

って感じです。 これだけだと分からないので、一つずつ説明していきます。

### gemとはRubyが提供するライブラリ単位

gemはRubyが提供するライブラリの単位です。
これはRubyのバージョン毎にgemが管理されています。
例えば Ruby 2.3のgem一覧と Ruby 2.6のgem一覧はインストールされているgemは異なります。

現在のRubyのバージョンは `$ ruby -v` で確認できます。
そして、このバージョンにインストールされているgem一覧は、`$ gem list` で確認できます。
例えば自分が作っているアプリの環境は次のような感じです。

```sh
$ ruby -v
ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin18]

$ gem list

*** LOCAL GEMS ***

bigdecimal (default: 1.3.4)
bundler (1.17.3)
cmath (default: 1.0.0)
csv (default: 1.0.0)
date (default: 1.0.0)
dbm (default: 1.0.0)
did_you_mean (1.2.0)
etc (default: 1.0.0)
fcntl (default: 1.0.0)
fiddle (default: 1.0.0)
fileutils (default: 1.0.2)
gdbm (default: 2.0.0)
io-console (default: 0.4.6)
ipaddr (default: 1.2.0)
json (default: 2.1.0)
minitest (5.10.3)
net-telnet (0.1.1)
openssl (default: 2.1.2)
power_assert (1.1.1)
psych (default: 3.0.2)
rake (12.3.0)
rdoc (default: 6.0.1)
scanf (default: 1.0.0)
sdbm (default: 1.0.0)
stringio (default: 0.0.1)
strscan (default: 1.0.0)
test-unit (3.2.7)
webrick (default: 1.4.2)
xmlrpc (0.3.0)
zlib (default: 1.0.0)
```

上記見ると分かるように`bundler`も一つのgemです。
このbundlerを使うことで他のgemのバージョン管理を行うことができます。

### Rubyバージョン毎にgemがインストールされている
**つまりRubyバージョンも合わせる必要があります。**

例えばAさんが環境構築したとき`Ruby`バージョンは`2.0`でした。
`CocoaPods`は`Ruby 2.0`の構文で書かれたバージョンをインストールできるようになります。
2年後,Bさんがチーム参画し、環境構築したら`Ruby`バージョンは`2.5`でした。
`CocoaPods`は`Ruby 2.5`の構文で書かれたバージョンをインストールできるようになります。
その結果、Aさんの`CocoaPods`の最新バージョン`1.2`ですが、Bさんの`CocoaPods`は最新バージョンは`2.1`でした。
Bさんは`CocoaPods`をAさんと同じ`1.2`に合わせたくとも、`Ruby 2.5`では動かず...なんてことが起こりえます。

**そのため、Rubyバージョンをあわせておく必要があります。**

※↑例なので、バージョンや互換性は適当です。


## Rubyバージョン管理はrbenv

`rbenv`は`Homebrew`でインストールできます。
```sh
$ brew install rbenv ruby-build
```
(もしxcrunとかでエラーが出るようであれば `$ xcode-select --instal` を実行して xcodeパッケージツールのインストールをしてみてください。)

`$ rbenv versions`を実行すると、今rbenvが管理してるRubyのバージョン一覧が表示され、 `*` がつくバージョンが現在のRubyバージョンになります。
```sh
$ rbenv versions
  system
  2.1.10
  2.1.2
  2.2.1
* 2.3.0 (set by /Users/mothule/.rbenv/version)
  2.3.6
  2.3.7
  2.4.4
  2.5.1
  2.5.3
  2.6.2
```
これをiOSプロジェクトだけ2.5.3にしたい場合は、次のコマンドを実行して生成されたファイルをiOSプロジェクト配下(git管理下)においてください。
```sh
$ rbenv local 2.5.3
```
このコマンドを実行すると `.ruby-version`というファイルが生成され、もう一度Rubyバージョンを確認すると次のようになります。
```sh
$ rbenv versions
  system
  2.1.10
  2.1.2
  2.2.1
  2.3.0
  2.3.6
  2.3.7
  2.4.4
  2.5.1
* 2.5.3 (set by /Users/mothule/workspace/ios-project/.ruby-version)
  2.6.2
```
このようにRubyバージョン2.5.3が動くようになっています。 これは `.ruby-version`でバージョン指定されているためです。
ちなみに `.ruby-version`は `2.5.3` と書いてあるだけです。
**この `.ruby-version`をgit管理し、各開発環境がrbenvを使えば、Rubyバージョンを合わせることができます。**

## bundler で CocoaPodsを動かす

### bundlerでCocoaPodsをインストールする

`$ gem install cocoapods`ではなく`bundle install`で`cocoapods`をインストールします。
そのためにbundlerが管理するファイル`Gemfile`を`$ bundle init`で作ります。
エディタで`Gemfile`を開くと次のようにgemを追加します。
```ruby
gem "cocoapods"
```
保存後に `$ bunlder install --path=vendor/bundle`を実行すると, `cocoapods`がインストールされます。
`--path=vendor/bundle`とはgemのインストール場所を示すオプションで、iosプロジェクト配下にvendor/bundleフォルダを作成し、その中に `cocoapods` のコードがインストールされます。
この `vendor/` は Gemfileがあれば再現可能なので git管理下から外しても構いません。

### bundlerでCocoaPodsを動かす

bundler配下のgemを動かすには`$ bunlder exec command`のフォーマットに従わなくてはなりません。
例えば `pod install`のインストールを実行するには、 `$ bundle exec pod install` となります。
これは少し手間ですね。次のプラグインをインストールすることで `bundle exec`の部分を省くことができます。

## rbenv に binstubs をインストール
直接CocoaPodsをインストールした場合は、パスが通っているため `pod install`のように実行することができますが、
`bundler`によってインストールした場合は、パスが通っていないため `pod install` を実行しても違うCocoaPodsのgemが動いてしまいます。(直接インストールしたCocoaPodsが動く)
これをパスを通してくれるようになるプラグインが rbenv-binstubsです。`bundle exec`が不要になります。
プラグインインストールは次の場所にgit cloneで配置するだけです。
```sh
git clone git://github.com/ianheggie/rbenv-binstubs.git ~/.rbenv/plugins/rbenv-binstubs
```

また`bundle install` にオプションを追加して再実行します。
```sh
bundle install --path=vendor/bundle --binstubs=vendor/bin
```

こうすることで、 `bundler` によってインストールgemにもパスが通るようになるため`pod install`だけで、bundler管轄のcocoapodsが呼べるようになります。

## CocoaPodsのバージョンアップはbundler操作
bundlerによって管理されたcocoapodsをバージョンアップする場合は、
`$ bundler update`で管轄gemをバージョン指定ルールに従った最新版にアップデートします。

## Rubyバージョンはrbenv操作
CocoaPodsや別ソフトウェアによりRubyバージョンを上げる必要がある場合は、 rbenv で新しくインストールし `.ruby-version`を変更することでバージョンを変えることができます。
Rubyバージョンを更新した場合は、 `$ gem install bunlder` で `bundler` のインストール後に `$ bundle install`で新しいRubyバージョンでのbundlerとcocoapodsのインストールが必要になります。


## まとめ
iOS開発で便利なツールにはRuby製のものも多く、サーバーサイドがRailsなどで実装されているのであれば、iOSエンジニアであれどRuby環境を理解しておくだけで、
今回のような開発環境整備に役立てることができるようになります。

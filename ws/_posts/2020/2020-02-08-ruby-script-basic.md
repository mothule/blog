---
title: iOSエンジニアでもRubyでスクリプトを書いて時間のかかる手作業からの卒業
categories: ruby
tags: ruby ios bundler shellscript tools rbenv
image:
  path: /assets/images/2020-02-08-ruby-script-basic.png
---
iOSエンジニアでもスクリプトがかければ生産性は上がります。  
ちょっとしたツールを作るだけでコーディング以外の作業を効率化できるからです。  
**この記事ではセットアップとよく使う関数の紹介や何がスクリプトに適してるか説明します。**

## なぜiOSエンジニアがRubyなのか？
Rails使うだけがRubyではありません。サーバーサイド専用言語でもありません。  
**fastlaneやCocoaPodsはRubyで書かれています。** iOSエンジニアとってRubyは意外と身近な存在です。

## どこでRubyスクリプトは生産性を上げるのか？
下記の一覧は私が個人や業務などで作ったスクリプトです。

- テストのためにFirestoreへの大量データの登録
- 強制バージョンアップの値変更
- BigQuery内View(SQL)の自動バックアップ
- テストのためにAPIへの複数アクセスで疑似ユーザーのエミュレート
- 当サイトのアイキャッチの記事タイトル付き画像の自動生成
- 当サイトの記事作成フローやデプロイ、記事の簡易分析
- 当サイトの記事投稿前のバリデーション
- 記事作成時のスクショから画像最適化して所定位置に配置

始めからfastlaneやCocoaPodsのような複雑で大きなツールを作る必要はありません。  
**ちょっとした手間を自動化で解決してくれるスクリプトでも十分効果を発揮します。**

## この記事の対象読者

- Rubyを少しでもかじった。
- 日常業務にコーディング以外が多いのでなんとかしたい


## Rubyでスクリプト書く準備

Rubyでスクリプト作成には、他Ruby環境から影響を避けるため次の準備が必要です。

- rbenvで**Rubyバージョンを固定**する
- Bundlerで**gemバージョンを固定**する
  - Active Support gemでRubyをより使いやすくする

次の構成がRubyでスクリプトを書く準備が整った状態です。

```sh
$ tree -L 1
.
├── Gemfile
├── Gemfile.lock
├── main
└── vendor

1 directory, 3 files

$ ls -l | grep main
-rwx--x--x  1 mothule  staff   55  2  8 21:36 main

$ cat main
#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'active_support/all'

puts 'Hello world'
puts `ruby -v`
```

順を追って説明します。

### rbenvでRubyバージョンを固定する
どの言語にも言えますが、言語バージョンが異なると実行結果に影響与えます。  
そのためRubyのバージョン管理ソフトrbenvを使って、Rubyバージョンを他Rubyアプリから影響受けないようにします。

(rbenvインストールについては検索すれば出てくるのでそちらを参考にしてください。)

Rubyバージョンを固定するため次のコマンドを実行します。
```sh
$ rbenv local <version>
```
特に理由がなければ最新バージョンを使います。  
実行すれば `.ruby-version` が作成されます。  
指定バージョンがrbenvになければインストールしてください。

これでRubyバージョン固定できました。

### Bundlerでgemバージョンを固定する

**スクリプトでgemを使う場合はBundlerを使いましょう。※1**  
Bundlerを準備するのは簡単です。
```sh
$ bundle init
```
これだけです。
実行すれば Gemfile が作成されるので、ここに使うgemを入れていきます。

#### ※1 Bundler使わず直接インストールするリスク
Bundlerを使わず直接gemをインストールすると、もし同一バージョンの別Rubyアプリがあり、そちらでも直接gemを使ってたら片方の都合でgemが更新するともう片方も影響を与えてしまい、気づかぬうちに動作しなくなるリスクがあります。  
Swiftなどコンパイル言語であればコンパイルエラーで検知できますが、Rubyはランタイムに問題となるコードが実行されないとエラーにならないので、気づかぬうちに深刻な不具合が潜伏します。

#### インストール時はgem先を指定する

```sh
$ bundle install --path=vender/bundle -j4
```
gemの準備ができたらインストールですが、gemのインストール先を `vender/bundle` に指定することでカレントディレクトリにgemsがインストールされるようになり、使われているgemsに対して検索やコードリーディングなどしやすくなります。

`-j4` はインストールジョブが4つ同時に走るのでインストールが早く終わります。

#### Active Support gemでRubyをより使いやすくする

RailsでRubyを書いてる書き方はActive Support gemのお陰で便利にコーディングできます。  
これをRailsなしのスクリプトでも使えるようにするには、`activesupport` gemが必要です。    
*Gemfile* に `gem 'activesupport'` を追記しましょう。

## RailsなしでBundlerを使うには？

Rubyでは当然のようにBundlerを使ってgem管理を行い, gemを追加すればすぐ使えるものばかりですが、
Railsなしの場合は、require を自分で呼ぶ必要があります。
`require 'rubygems'` と `require 'bundler/setup'` を入れます。  

*main*
```rb
#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
```

### rbenvのRubyパス(shebang)について
前述コードのshebangは、rbenvを使う場合は、 `#!/usr/bin/env ruby` にします。


## chmodでスクリプトに実行権限を与える
作成したファイルのままでは実行権限が不十分です。
`chmod` コマンドで誰でも実行できるように権限付与します。
```sh
$ chmod 711 main
```
(権限エラーの場合はsudoをつけて再実行)

## ０から準備まで工程を列挙する

```sh
$ mkdir hoge && cd $_
$ rbenv local 2.7.0
$ bundle init
$ echo "gem 'activesupport'" >> Gemfile
$ bundle install -j4 --path=vendor/bundle
$ touch main
$ chmod 711 main
$ vim main
```

*main* ファイルに下記を追加する。
```rb
#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'active_support/all'

puts 'Hello world'
puts `ruby -v`
```

これでRubyでスクリプトを書く準備が整います。

## よく使う関数やシェルコマンド
Rubyにはシェル操作関数があります。
つまりRubyから`cd` や `cp` といったシェルコマンドや、 `curl` や `http` といったHomebrewで落としたコマンドラインツールも実行することができます。

スクリプトを作るときに比較的よく使う関数やシェルコマンドを紹介します。

- ARGV
  - 実行時に渡された引数情報です
- puts
  - 標準出力関数
- exit
  - 終了ステータスの発行
- File.read
  - 外部ファイルの一括読み込み
- File.write
  - 外部ファイルの一括書き込み
- gem 'parallel'
  - スレッドやプロセスの並列処理
- OptionParser
  - ARGVのパーサー
- YAML
  - yamlファイルの制御
- ERB
  - erbファイルの制御
- %x(cmd)
  - シェルコマンドの実行

## スクリプト化の気づき

どういった作業がスクリプトしたほうがいいのかを少しだけ紹介します。

### マウスのポチポチ作業はスクリプト化の可能性あり
iOSエンジニアといえど、XcodeとSwiftで完結はしません。
テスト準備などiOSアプリ開発以外で「これプログラム書いたほうが楽そうだな」と思うことはあります。  
そのときスクリプトの書き方を知っておいて、取り掛かりやすくしておけば、ササっとスクリプトが書いて楽ができます。

### 定期的な確認はcron+スクリプトで検討してみる
定期的に変更されているかなど確認が必要な場合は、その確認作業をスクリプトで完結できないかを検討してみましょう。  
もしできそうなら続けてcronでそのスクリプトを走らせることでこちらから意識せずとも確認をし続けてくれるようになります。  
またcronではなくともCircleCIやBitriseのNightly実行でも問題ありません。


## まとめ
iOSエンジニアいえどエンジニアです。iOSの知識とSwiftのコーディングスキル, iPhoneの特性だけを理解するだけでは、つぶしの効かず、限界が早めに来ます。  
大事なのはエンジニアとしての強みを理解し、自分の代わりにプログラムが解決してくれないかを考えることです。

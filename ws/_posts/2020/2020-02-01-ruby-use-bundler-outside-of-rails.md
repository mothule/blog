---
title: Rails以外でBundlerを使う方法
categories: ruby bundler
tags: ruby bundler
image:
  path: /assets/images/2020-02-01-ruby-use-bundler-outside-of-rails.png
---
仕事柄バックエンドはRailsでフロントエンドのエコシステムではRubyベースのツールもあり、
なるべく自前スクリプトでもRubyで書くようにしてます。

だけど毎度Railsを使わずBundlerを使う場合に一部躓くのでメモとしてまとめました。


## 段取り

1. スクリプトで使うバージョン指定
1. (Option)bundlerインストール
1. Gemfile用意
1. bundle install
1. スクリプトでbundle内gemをrequire

Rails外で使う上で特別必要な処理って最後の項目だけなので、
そこだけ知りたい人はざざっと一番下へどうぞ。

## スクリプトで使うバージョン指定

```sh
$ rbenv local [ruby version]
```

## (Option)bundlerインストール

```sh
$ gem install bundler -v "2.0.2"
```
バージョン指定する場合は`-v "[bundler version]"`を入れます。  
最新でいいなら指定不要です。

## Gemfile用意

```sh
$ bundle init
```

Gemfileが作成されるので、中に必要なgemを追加します。

## bundle install

```sh
$ bundle install -j4 --path=vendor/bundle
```

Gemfileで指定されたgemsをインストールします。

## スクリプト内でbundle内gemをrequire

エントリーファイルが `main.rb` であれば, `main.rb` の頭に

```ruby
require 'rubygems'
require 'bundler/setup'
```

と書きます。

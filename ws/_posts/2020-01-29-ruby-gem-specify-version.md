---
title: Gemで指定バージョンをインストール
categories: ruby gem
tags: ruby gem
image:
  path: /assets/images/2020-01-29-ruby-gem-specify-version.png
---
Rubyのバージョンが上がるたび、そのバージョンのgemsをインストールします。
BundlerだとGemfile.lockの指定されたバージョンでインストールします。

たまにしか使わない、でも絶対知っていないといけないGemで指定バージョンをインストールについてメモしておきます。

## 構文
```sh
$ gem install [gem name] -v version
```

### Bundlerの場合

`2.0.2`をインストールする場合

```sh
$ gem install bundler -v "2.0.2"
```

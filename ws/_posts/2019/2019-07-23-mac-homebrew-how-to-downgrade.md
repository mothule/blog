---
title: Homebrewで過去バージョンにダウングレードする2つの方法
categories: mac homebrew
tags: mac homebrew
image:
  path: /assets/images/2019-07-23-mac-homebrew-how-to-downgrade.png
---

* 以前 `brew upgrade` で tig のバージョンを最新にして raedline のバージョンズレを解決しました。
* 以前 `brew switch` で readline のバージョンを8から7にして、byebug などのバージョンズレを解決しました。

今、 tig や vim の最新バージョンが readline 8 を求めていて立ち上がらなくなりました。 😭
原因は上記で述べたとおり明らかです。

なので今回はtigのバージョンを戻す方法についてまとめました。

## 旧バージョンに戻すには2つの方法がある

1つは `brew switch` こちらはローカル環境に既にバージョンがある場合に有効な手段で、対応方法も一番楽です。
もう1つは Homebrewが管理するFormulaのディレクトリに移動して過去コミットからインストールする方法です。

### 戻したいバージョンがあるかどうか確認する方法

**バージョンが複数個ある場合**
```sh
$ brew info readline
readline: stable 8.0.0 (bottled) [keg-only]
Library for command-line editing
https://tiswww.case.edu/php/chet/readline/rltop.html
/usr/local/Cellar/readline/7.0.3 (46 files, 2MB)
  Poured from bottle on 2017-03-01 at 12:13:07
/usr/local/Cellar/readline/7.0.3_1 (46 files, 1.5MB)
  Poured from bottle on 2017-07-24 at 15:28:46
/usr/local/Cellar/readline/8.0.0_1 (48 files, 1.5MB)
  Poured from bottle on 2019-07-20 at 00:58:47
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/readline.rb
```

このように複数のバージョンが並びます。

**バージョンが1つしかない場合**
```sh
$ brew info vim
vim: stable 8.1.1700 (bottled), HEAD
Vi 'workalike' with many additional features
https://www.vim.org/
Conflicts with:
  ex-vi (because vim and ex-vi both install bin/ex and bin/view)
  macvim (because vim and macvim both install vi* binaries)
/usr/local/Cellar/vim/8.1.1700 (1,858 files, 31.6MB) *
  Poured from bottle on 2019-07-22 at 14:17:51
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/vim.rb
```
このように1つしかありません。


## brew switch で過去バージョンに戻す

例えば先程のraedlineパッケージではバージョンが 7.0.3, 7.0.3_1, 8.0.0_1 の 3つがありました。
7.0.3のバージョンに戻したい場合は
```sh
$ brew switch readline 7.0.3
```
とするだけです。とても簡単です。

## 過去コミットから過去バージョンに戻す

### 1. Homebrewが管理してるFormulra ディレクトリまで移動
```sh
$ cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/
```

### 2. 対象コミットをログから探す
パッケージコミッターにも依存はする方法ですが、大抵のコミットコメントにはバージョンが記載されているのでそれを判断材料として使います。

下記はtigの過去コミットを見る方法です。
```sh
$ git log --oneline tig.rb
d78647bc40 tig: update 2.4.1_1 bottle.
fbe673161b tig: revision for readline
e95a3b91ab tig: remove options
df6f2b649a tig: update 2.4.1 bottle.
facc8a40ea tig: update 2.4.1 bottle.
009a1200d7 tig 2.4.1
41252c196e tig: update 2.4.0 bottle.
3b28425d00 tig 2.4.0
512758e6eb Rubocop 0.57.1 style fixes (#28754)
4c2daf9fcc tig: update 2.3.3 bottle.
e411457d18 tig 2.3.3
1991799148 tig: depend on asciidoc and xmlto at build time for head (#23125)
44e7d526bb tig: update 2.3.2_1 bottle.
49e5f3c6df tig: always install the man page
c4e608238a tig: update 2.3.2 bottle.
df952f5043 tig 2.3.2
183cd1cbff tig: update 2.3.1 bottle.
297d3e1fe3 tig 2.3.1
16ebe5f184 Use “squiggly” heredocs.
4656c441f0 tig: update homepage (#18797)
6785440dfc tig: update 2.3.0 bottle.
7df31fa61e tig 2.3.0
b40258bbe9 tig: update 2.2.2 bottle.
7474d02246 tig: update 2.2.2 bottle.
e8c547a5d9 tig 2.2.2
920db41da7 (grafted) youtube-dl: update 2017.02.28 bottle.
```

各行先頭の英数字羅列はgit の revision番号です。その後ろがコミット時のコメントです。
どのバージョンに戻すのは分かっている場合は、コメントを参考にバージョンを見つけ、そのrevision番号を使いますが、
今回はどのバージョンで回復するのか分かりにくいので１つ前のバージョン 2.4.0 に戻します。

この場合、 `41252c196e tig: update 2.4.0 bottle.` これが前のバージョンだと思われます。

### 3. revisionを使って状態を戻す

先程目星をつけたrevision番号(`41252c196e`)を使います。

```sh
$ git checkout 41252c196e tig.rb
```
これでtigは古いバージョンをインストールする状態になりました。

### 4. brew install で古いバージョンをインストール

```sh
$ brew install tig
```

既にインストール済みだと怒られ、その後親切に unlink しろと言われるので従います。

```sh
$ brew unlink tig
```

改めてインストールします

```sh
$ brew install tig
```

無事成功したら確認します。

```sh
$ brew info tig
tig: stable 2.4.0 (bottled), HEAD
Text interface for Git repositories
https://jonas.github.io/tig/
/usr/local/Cellar/tig/2.4.0 (15 files, 855.4KB) *
  Poured from bottle on 2019-07-23 at 13:04:55
/usr/local/Cellar/tig/2.4.1_1 (15 files, 855.7KB)
  Poured from bottle on 2019-07-22 at 14:09:16
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/tig.rb
```

バージョンが2つ並び `*` がついてる方が現在のバージョンになります。
ちなみに `$ git checkout 41252c196e tig.rb` で `tig.rb` が古いファイルになっていますが、
これは戻しても問題ありません。

ちなみに戻すと `$ brew info tig` の最初の1行目のバージョンも変わります。

```sh
$ git reset head && git checkout .
Unstaged changes after reset:
M	Formula/tig.rb
```

```sh
$ brew info tig
tig: stable 2.4.1 (bottled), HEAD
```

これでようやくreadlineの乱とはおさらばできそうです。 😇

[参考](https://qiita.com/nghryuki/items/7d65d8f55ea65b95310d)

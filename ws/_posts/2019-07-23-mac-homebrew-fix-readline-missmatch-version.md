---
title: readlineの更新でエラーが出るようになったらbrew switchでその場しのぎ
description: readlineの更新でエラーが出るようになったらbrew switchでその場しのぎ
date: 2019-07-23
categories: mac homebrew
tags: mac homebrew
draft: true
---
以前[tigが動かなくなる件]({% post_url 2019-07-22-fix-tig-lib-not-loaded %})をbrew upgradeで解決しましたが、今回は開発で使われてるgemなど更新が簡単にできないパッケージが動かなくなったので、その場しのぎとしての解決方法をまとめました。

## 追記：`brew switch` と `brew upgrade` 混ぜたことによる悲報と朗報について追記
`brew switch` を試す前に↓の記事の冒頭を呼んで状況判断することをオススメします。
じゃないと無駄な作業が発生することになります。 😭

[Homebrewで過去バージョンにダウングレードする2つの方法]({% post_url 2019-07-23-mac-homebrew-how-to-downgrade %})



## byebug が動かなくなっていた
bundle exec rspec で動かしたのですが、下記エラーログが出て失敗するようになっていました。

```
Sorry, you can't use byebug without Readline. To solve this, you need to
rebuild Ruby with Readline support. If using Ubuntu, try `sudo apt-get
install libreadline-dev` and then reinstall your Ruby.
```

## readlineが7から8に変わってる

readline が バージョン7から8にメジャーアップデートされたことによりエラーが出るようになっています。
brew にはいくつかのバージョンを持っており、 それを確認することができます。

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
```
自分の環境では、7.0.3, 7.0.3_1, 8.0.0_1 の3つでした。
現在の使われているバージョンは 8.0.0 でした。(0_1とついていないのが気になりますが今回は気にしない）

リンクのほうもバージョン8系が使われていました。
```sh
$ ls -la /usr/local/opt/readline/lib
-r--r--r-- libhistory.8.0.dylib
lrwxr-xr-x libhistory.8.dylib -> libhistory.8.0.dylib
-r--r--r-- libhistory.a
lrwxr-xr-x libhistory.dylib -> libhistory.8.0.dylib
-r--r--r-- libreadline.8.0.dylib
lrwxr-xr-x libreadline.8.dylib -> libreadline.8.0.dylib
-r--r--r-- libreadline.a
lrwxr-xr-x libreadline.dylib -> libreadline.8.0.dylib
```

## brew switch でバージョンを戻す
シンボリックリンクを7に変えることで解決する方法が各方面のissuesからは出ていますが、
Macならbrew switchでバージョンを切り替えることで簡単に解決できます。

```sh
$ brew switch readline 7.0.3_1
Cleaning /usr/local/Cellar/readline/8.0.0_1
Cleaning /usr/local/Cellar/readline/7.0.3
Cleaning /usr/local/Cellar/readline/7.0.3_1
Opt link created for /usr/local/Cellar/readline/7.0.3_1
```

リンクのほうも7系に切り替わっています。
```sh
$ ls -la /usr/local/opt/readline/lib
total 1408
-r--r--r-- libhistory.7.0.dylib
lrwxr-xr-x libhistory.7.dylib -> libhistory.7.0.dylib
-r--r--r-- libhistory.a
lrwxr-xr-x libhistory.dylib -> libhistory.7.0.dylib
-r--r--r-- libreadline.7.0.dylib
lrwxr-xr-x libreadline.7.dylib -> libreadline.7.0.dylib
-r--r--r-- libreadline.a
lrwxr-xr-x libreadline.dylib -> libreadline.7.0.dylib
```

---
title: "dylod: Library not loaded でtigが起動しない状態から動くまで"
categories: tools tig
tags: git tig homebrew tools
image:
  path: /assets/images/2019-07-22-fix-tig-lib-not-loaded.png
---

特にアップグレード類の操作はしていないけれど、tigが立ち上がらなくなったので、動くようになるまでの流れを記載しました。

## 追記 `brew switch` で解決できる方法も追加しました。
この記事の方法で解決が難しい場合は、「{% post_link_text 2019-07-23-mac-homebrew-fix-readline-missmatch-version %}」の方法を参考にしてみてください。



## tig起動時にLibrary not loaded readlineが出る

```sh
$ tig
dyld: Library not loaded: /usr/local/opt/readline/lib/libreadline.7.dylib
  Referenced from: /usr/local/bin/tig
  Reason: image not found
Abort trap: 6
```

readlineは入っているはずなので確認してみたら

```sh
$ brew info readline
readline: stable 8.0.0 (bottled) [keg-only]
...
```
バージョンが8で、tigは7でズレていました。
なので tig をアップグレードしてみました。

```sh
$ brew upgrade tig
```

無事起動できました。😇

## tigでコミット時にLibrary not loaded Pythonが出る

しかし、commitしようとしたら今度は違うエラーが.... 😱

```sh
$ tig
dyld: Library not loaded: /usr/local/opt/python/Frameworks/Python.framework/Versions/3.6/Python
  Referenced from: /usr/local/bin/vim
  Reason: image not found
error: vim died of signal 6
error: There was a problem with the editor 'vim'.
Please supply the message using either -m or -F option.
Press Enter to continue
```

vim と書いてあるので、tigのコミット時に立ち上がるvimでPythonライブラリが見つからないのかな？と思ったので
vimもアップグレードしてみました。

```sh
$ brew upgrade vim
```

無事vimも起動でき、コミットできました。 🎉

## 根本原因は分からず

今の所無事動いていますが、また違うツール起動しようとしたら動かないとかありそうです。
なぜ金曜日までは動いていたのに週明けに動かなくなったのか記憶曖昧もあり原因不明です。

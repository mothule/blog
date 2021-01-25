---
title: ln -sでシンボリックリンクを作る
description: lnコマンドで-sオプションを使いシンボリックリンクを作る方法と作成されたか確認する方法、不要になったシンボリックリンクをunlinkで解除する方法についてまとめた記事。
categories: tools ln
tags: tools ln
image:
  path: /assets/images/2020-05-18-tools-ln-guide/0.png
---
Windowsでいうショートカットに似た何か。

## ln -sでシンボリックリンクを構築

Syntax: `ln -s リンク対象パス リンク作成先のディレクトリパス`

自分の中で「リンク」ってワードが邪魔して  
src/destどっちがどっちか分からなくなることが頻発する。

```sh
$ ln -s ~/オレの/最強の/凄いコマンド /usr/local/bin/
```

## ls -lでシンボリックを確認

シンボリックリンクはファイル名とリンク先が「`name -> original path`」形式で表示されます。

```sh
$ ln -s ~/オレの/最強の/凄いコマンド /usr/local/bin/
$ ls -l /usr/local/bin/
凄いコマンド -> ~/オレの/最強の/凄いコマンド
```

## unlinkでシンボリックリンクを解除

Syntax: `unlink シンボリックのパス`

```sh
$ unlink /usr/local/bin/使い物にならない自作コマンド
```

せめて`ln -d`とかにしてほしかったな。

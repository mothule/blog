---
title: たまに必要なGitの操作tips
description: 普段使いでは使うことはない操作だけど、一定間隔で訪れてしかも必ず必要な操作がGitにはあり、その操作集を集めた記事です。
categories: tools git
tags: tools git
image:
  path: /assets/images/2020-07-29-tools-git-tips/0.png
---
普段使いでは使うことはない操作だけどたまに必要になる操作集を集めてます。
順次増やしていきます。

## リモートのみファイル削除

```sh
$ git rm --cached [ファイル名]
```

### フォルダ削除

```sh
$ git rm --cached -r [ディレクトリ名]
```

## 最新のみclone(シャロークローン)

```sh
$ git clone --depth 1 [Git URL]
```

## 指定ワードを含むコミットを検索

```sh
$ git log -S [検索ワード] --patch
```

`--patch`をつけない場合はログ一覧が並びます。

## コミットした人で検索
```sh
$ git log --author [コミットした人の名前]
```

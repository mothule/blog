---
title: tigでこれどうやるの？逆引き集
description: ActiveRecordでpluckとselectしてpluckに変化はあるか？
date: 2019-08-05
categories: tools git tig
tags: tools git tig
---

gitツールtigを使って色々できるけど、普段は同じような操作しかしないので、いざ必要になると操作方法を忘れてしまうので、メモ代わりに集めていくことにしました。


使われているかどうか調べる方法

### git log -S で探す
```bash
$ git log -S "hogehoge" --patch
```

### git tag --contains でコミットがいつリリースされたか特定する
↑で該当コミットを見つけたら
```bash
$ git log -l --contains 'hashhash'
```

### コミッタ名で絞り込む
$ git log --author

### 全コミットから削除/更新されたリビジョンが分かる
$ git log -S"hogehoge"

### tig版
$ tig -S"hogehoge"

### 現時点で存在する行が最後に更新されたリビジョンが分かる
$ git blame


指定範囲の改修ファイル一覧を出す方法

```sh
git diff --stat=256 master..develop | sed -e "s/eeyore\///" -e "s/ eeyoreTests.*//" -e '/^$/d' -e 's/|.*$//g' | sort
```

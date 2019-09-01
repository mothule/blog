---
title: p4mergeでgit mergeの衝突を解決する
categories: tools git
tags: tools git p4merge
image:
  path: /assets/images/2019-09-02-git-merge-p4merge.png
---
gitを使っていると必ず出くわすことになるコンフリクト。
機械的なマージでは解決できない場合にユーザー自身の手で解決を丸投げする面倒くさいあれです。
衝突してるファイルをエディタで見ると、いつ見ても見慣れないセパレータで表現されておりますます嫌になります。
今回はGUIでグラフィカルに衝突解決を行うツール**p4merge**について紹介します。

## GUIでマージするならp4merge

p4mergeをGitの衝突解決ツールとして設定すると、衝突時にp4mergeでグラフィカルにマージを行うことができます。

### p4merge のいいところ
- 衝突位置にだけ移動するショートカットが用意されている
- 衝突ソース毎に背景色が違うので見分けがつく

## インストール方法

[公式サイト](https://www.perforce.com/ja/zhipin/helix-core-apps/merge-diff-tool-p4merge)からOSを選んでダウンロードします。


## p4mergeが起動するように設定


`.gitconfig` を次のように設定します。他の無関係な設定は省いています。

```sh
[merge]
  tool = p4merge
  keepBackup = false;

[mergetool "p4merge"]
  path = /Applications/p4merge.app/Contents/MacOS/p4merge
  cmd = p4merge "$BASE" "$LOCAL" "$REMOTE" "$MERGED"
  keepTemporaries = false
  trustExitCode = false
  keepBackup = false
```
このように設定すると、 `$ git mergetool` と実行すれば、 p4merge　が起動します。

もし、マージではなく比較でも p4merge を使いたい場合は次のように設定します。


```sh
[diff]
  tool = vimdiff

[difftool]
	prompt = false

[difftool "p4merge"]
	cmd = /Applications/p4merge.app/Contents/MacOS/p4merge \"$LOCAL\" \"$REMOTE\"
	trustExitCode = false
```

この設定では、
- `$ git diff` を実行すればユニファイド型式で表示され、
- `$ git difftool`を実行すれば vimdiff で表示され、
- `$ git difftool -t p4merge`を実行すれば p4merge で表示されます。

## p4mergeの設定

p4merge自身の設定についてです。デフォルトでも使うことは可能ですが、いくつか設定をしておくことで余計な穴にハマらず使えるかと思います。

{% page_image -1.png 75% %}

- フォントは日本語対応フォントにする
- 文字が重なる場合はフォントを等倍にする
- encode は utf-8(厳密にはファイルと合わせる)
- 改行タイプはシステムと合わせる(厳密にはgit commit時に自動変換オプションもあるのでそっちの兼ね合いも必要)
- `Comparison method` は 改行差異とスペース幅を無視する(ここは好みの問題でもある)

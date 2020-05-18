---
title: MacのGoogle日本語入力で変換候補ポップアップが左下とか左上など隅っこに表示される
description: MacのGoogle日本語入力で変換候補ポップアップが左下とか左上など隅っこに表示される不具合バグが発生したのでプロセス探して終了させる解決方法をまとめた記事です。
categories: mac google-japanese-input
tags: mac google-japanese-input
image:
  path: /assets/images/2020-05-13-mac-goolge-japanese-input-bug-fix/eyecatch.png
---
プロセスを再起動すれば直る。

この記事ではMacのGoogle日本語入力で変換候補ポップアップがおかしくなったので調査して解決方法をまとめたものです。  
なお解決にはシェルコマンドをいくつか叩くのでターミナル.appなどターミナルアプリが必要です。

## MacでGoogle日本語入力がおかしくなる

正常稼働してるGoogle日本語入力は、次の画像のようにタイプしてる文字の近くに変換候補が並んだポップアップが表示される。
これがおかしくなると、ポップアップの位置が画面の四隅に固定されてしまう現象が発生する。

### 正常時

正常時は、タイプしてる文字の近くに表示される。

{% page_image 1.png 50% GoogleJapaneseInput %}

### 異常時

問題がおきると、これが隅っこで表示される。

{% page_image 2.gif 50% GoogleJapaneseInputWithBug %}

### 分かってること

- 自分が立ち上げているアプリケーションを全て終了しても解決しない
- 再起動すると解決する

### 仮説
プロセス再起動で解決するのでは？

## Macのプロセス一覧でGoogle日本語入力を探す

Macでプロセス一覧を見るには`ps`コマンドを使う。

{% comment %}psコマンドに関する記事を書いたらここにリンクを貼る{% endcomment %}

ターミナルで`ps aux | grep GoogleJapaneseInput`を実行
このときGoogle Chromeは閉じておく

```sh
$ ps x | grep GoogleJapaneseInput
  879   ??  S      1:23.75 /Library/Input Methods/GoogleJapaneseInput.app/Contents/MacOS/GoogleJapaneseInput
 1213   ??  S      1:40.55 /Library/Input Methods/GoogleJapaneseInput.app/Contents/Resources/GoogleJapaneseInputRenderer.app/Contents/MacOS/GoogleJapaneseInputRenderer
 2059   ??  S      1:15.08 /Library/Input Methods/GoogleJapaneseInput.app/Contents/Resources/GoogleJapaneseInputConverter.app/Contents/MacOS/GoogleJapaneseInputConverter
99614 s001  S+     0:00.00 grep GoogleJapaneseInput
```

`GoogleJapaneseInput`, `GoogleJapaneseInputRenderer`, `GoogleJapaneseInputConverter`のプロセスがヒットする。  
(最後のプロセスはgrepプロセスなので無関係)

おそらく名前からしてこうだろう。

- `GoogleJapaneseInput` : 設定全般 or 統括
- `GoogleJapaneseInputRenderer` : 描画関係
- `GoogleJapaneseInputConverter` : 変換関係

変換自体はうまく動いているので、おかしいのは変換以外の2つだと思われる。
もっとも怪しいのは描画を司っているであろう`GoogleJapaneseInputRenderer`だと予想。

## Macのプロセスをkillコマンドで終了させる

Macでプロセスを終了させるには`kill`コマンドを使う。  
`kill`コマンドにプロセスIDを渡すとIDに紐づくプロセスにシグナルが送信され終了する。

### GoogleJapaneseInputRendererプロセスのプロセスIDを探す
`ps`コマンドの結果は表形式でプロセスが並ぶ。
１つ目のカラムはプロセスIDを表す。

先程の表で`GoogleJapaneseInputRenderer`のプロセスIDは`1213`になる。  
なおこのプロセスIDはいつもこの値ではないので注意。

### killコマンドでGoogleJapaneseInputRendererを終了させる
`GoogleJapaneseInputRenderer`のプロセスIDが分かったので最終的には、  
`$ kill 1213`をターミナル上で実行すれば`GoogleJapaneseInputRenderer`が終了する。

## MacのGoogle日本語入力が直った
仮説と予想は的中し、`GoogleJapaneseInputRenderer`プロセスを終了し、再度テキストエディで文字入力したら`GoogleJapaneseInputRenderer`が立ち上がり変換候補ポップアップが文字の近くに戻ってきた。

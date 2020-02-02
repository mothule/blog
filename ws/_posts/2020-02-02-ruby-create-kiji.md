---
title: 記事タイトルの入ったTwitterサマリーカード用画像を生成できるスクリプトを作った
categories: ruby
tags: ruby kiji
image:
  path: /assets/images/2020-02-02-ruby-create-kiji/2.png
---
こないだ[Twitter](https://twitter.com/mothule/status/1215116021805117440)でもつぶやいたのですが、

{% page_image 1.png 75% %}

最近Qiitaやはてブロの記事をTwitterで見かけると、次のような記事タイトルが画像に組み込まれたTwitterサマリーカードを見かけます。

{% page_image 0.png 50% %}

これこのブログでも使えたら便利だなーと思って、今回作ってみました。

[mothule/kiji - GitHub](https://github.com/mothule/kiji)

Twitter(鳥)の記事(雉)用画像を生成ってことで、ネーミングは適当です。  
ロゴ画像はそれこそ適当の塊です...

## ざっくりフロー考える

1. テンプレエンジンにかませるhtmlの骨組みを用意
1. 骨組みに介入したい要素をセットしhtml生成
1. 生成したhtmlを描画エンジンのヘッドレスで描画
1. それをキャプチャして外部ファイル化

という流れで当初考えてました。
言語はRubyを使うことは決めてました。

1~2はRubyのERBを使えば簡単です。  
3については何を使うのか少し調べる必要があるなと思い調べていたら。  
[wkhtmltoimage](https://wkhtmltopdf.org/)というツールがあることが分かりました。  
これをrubyで使えるgemとして[IMGKit](https://github.com/csquared/IMGKit)があります。

## も少し具体的なフローを考える

1. erbなhtml/cssで骨組み
1. html から image の変換は wkhtmltoimage をRubyで使えるIMGKit gemを使う
1. RubyからERBを介して記事タイトルを流し込んでhtml生成
1. IMGKit gemに流し込む

という感じになります。

## 躓いたところ

IMGKit gem など先人のお陰もあり、躓きは少なかったです。  
ただ1つだけ大きく躓いた部分があり、ツールの実装の8割はこの部分で費やしてます。

### 描画エンジンの仕様に依存する
wkhtmltoimage はhtml描画エンジンhtmlの描画結果をキャプチャしてます。  
自分が当初考えてたざっくりフローと同じですね。

で、そのエンジンにはQtWebKitが使われています。
そのためレンダリング結果はQtWebKitの描画仕様に準拠します。

ChromeやSafariでは想定通りの挙動でも、QtWebKitでは表示されないなどありました。
なので実装や使ってるgem自体の躓きというよりは、QtWebKitの仕様との戦いでした。

## まとめ

今後はブログで画像指定しない場合は、このスクリプトを使っていこうかと思います。

gem化などは考えていません。しかし、使っていくうちに改良するとは思うので、  
その蓄積で充実してきたらgem化するかもしれません。

---
title: 中堅でも間違えるクラス名のSimpleやEasyは内部構造と比例しない話
description: SimpleやEasyと名付けられたクラス名が内部構造までもシンプルとは限りません。クラスがもたらす提供機能とその実現方法の隠蔽による関心事の分離を理解していないと中堅でも間違える人は間違える話について綴ります。
categories: notebook program-design
tags: program-design notebook
image:
  path: /assets/images/2018-10-21-design-simple-class-is-not-simple-code.png
---
**クラス名にSimpleとかEasyが入っていても、内部構造が単純とは限りません**

## クラス名は特徴や総称、役割を表すもの
**「やりたいことが単純でも実現方法がめんどくさい」** ケースはたくさんあります。
iOSアプリエンジニアが読者だとSwiftだと日付制御や文字列制御というと納得できると思います。

例えば下記のような場面に出くわす人は多いのではないでしょうか。

- あるSDKやライブラリが使いにくい
- 公開されているIFが低レイヤーのみでプロダクトで使うには手続きが多くなり呼出元には無関係な情報が漏れ出てしまい、関心事の分離ができなくなるし、可読性やメンテナンス性に影響を与えかねない。
- 他場所でも使うと一瞬にしてたちの悪いDRY違反が生まれる

そして、大抵はリファクタリング活動として、次のクラスを構築する方も多いのではないでしょうか。

複雑な処理を扱いやすくするために動作のみを公開。複雑な処理は内部化させることで簡易性を出すクラスを用意することで上記問題を解決。そんなクラス名には特徴として「複雑→シンプル」による簡易性が強みなのでSimpleとかEasyといったネーミングがつくこともあります。

それとは別に簡単な動作のみしか提供していない機能自体がシンプルといった意味合いでSimpleといったネーミングがつくこともあります。

## SimpleやEasyにおいてクラス名は体を表すとは限らない
そのためクラス名にSimpleやEasyがついてる場合は次のいずれかによりネーミングされていることになります。

1. 提供してる**機能自体**がシンプル
2. 提供してる**機能の使い方**がシンプル
3. ラッピング対象が「シンプル」とネーミングしてる

少なくとも3つの意味があります。

ここで「クラス名にSimpleだからといってクラス内コードがシンプル」と決めつけるのは、設計観点において

- 「できること」とその「実現方法」の隠蔽化による **関心ごとの分離** を理解できていない
- クラス名の活用意図を間違えている

と言えてしまいます。

### 提供してる機能自体がシンプル

何か高機能なサービスをラッパーして使いたい機能のみを提供するクラスなどによく見かける。
汎用性を殺し特化することでコードをシンプルにし可読性を上げる場合に作られるかと思います。

### 提供してる機能の使い方がシンプル

スレッド操作や並列処理、直接扱おうとするとコードが複雑になり、ボイラープレートコードなどで埋め尽くされるのを１つのクラスに隠蔽化することで、手段を簡単に扱えるようにさせる場合に使われやすい。

### ラッピング対象が「シンプル」とネーミングしてる
単純にクラス内に閉じ込めたい対象が「シンプル」とついてるだけです。

またシンプルと名付けられてるからといっても、絶対にコードがシンプルなわけではありません。単なる偶然です。

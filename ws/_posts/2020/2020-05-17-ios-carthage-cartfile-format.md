---
title: CarthageのCartfileの書き方と個別更新方法
description: CarthageのCartfileのバージョンの書き方や個別でライブラリ更新方法やビルド済みライブラリのスキップなどCarthageでライブラリを管理する運用で必要になってくるライブラリバージョン制御についてまとめた記事です。
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2020-05-17-ios-carthage-cartfile-format/0.png
---
Podfileと書き方が微妙に異なるので注意です。カンマは使いません。

ライブラリを導入したら新しいバージョンが公開されたら追従しなければいけません。
この記事ではCarthageで管理してるライブラリのバージョン追従方法について説明します。

## Cartfileでバージョンを指定する

例えばCartfileでは次のようにライブラリのバージョンを指定することができます。

```
github "SwiftyJSON" ~> 4.2.0
github "Hoge" >= 4.2.0
github "Fuga" == 4.2.0
github "Nuga" "develop"
github "Moga" "ab12c3ef4"
```

それぞれ順に説明していきます。

### ~>で範囲指定する
最も多く使われてるであろう書き方です。
例えばバージョン履歴が下記だった場合で説明します。

- 4.2.0
- 4.2.1
- 4.3.0
- 5.0.0

このときにCartfileで`github "Hoge" ~> 4.2.0`が記入された状態で  
`update`を実行したら`4.2.1`までアップデートします。  
もし`github "Hoge" ~> 4.2`が記入されてたら`4.3.0`までアップデートします。

なかなか範囲が覚えにくいと思いますが、最後の数字が`x`に置き換えて見れば分かりやすくなります。  
例えば `github "Hoge" ~> 4.2.0`であれば`4.2.x`系です。  
`4.2`なら`4.x`系です。つまり4系バージョンですね。

### >= で指定バージョン以上

指定バージョン値以上のバージョンを指定します。  
Cartfileに`github "Hoge" >= 4.2.1`と記入された状態で  
バージョン履歴が下記だった場合は、`5.0.0`がインストールされます。

- 4.2.0
- 4.2.1
- 4.3.0
- 5.0.0

この書き方は少し破壊変更リスクが伴うため使う側としてはオススメしないです。  
こっちよりも前述した範囲指定のほうが安全性をそれなりに維持できます。

### == で指定バージョンのみ

もっとも安全なバージョン指定方法です。  
Cartfileに`github "Hoge" == 4.2.1`と記入されていたら  
他にバージョンが出ていても `4.2.1`しかインストールされません。

丁寧にバージョンアップをしたいライブラリや開発運用に適した方法です。

### revisionでコミット指定

GitHub上のコミットを名指しでインストールします。コミットで発行されているrevisionを使います。  
またrevisionだけでなくブランチ名でも使えます。

使っていたライブラリに不具合や脆弱性、iOS最新版が出たけどライブラリ側がバージョンを切っていない状態など  
緊急時で使うことがあるので覚えておいたほうがいいです。

[Carthage公式のVersion requirement](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement)でも英語ですが説明セクションはあります。

## ライブラリの個別更新
更新したいライブラリをCartfileに書いて`carthage update`を実行すると、更新不要なライブラリも更新対象となります。

`carthge update`ではライブラリ名を渡せばそのライブラリのみを更新してくれます。
SwiftyJSONのみを更新する場合

```sh
$ carthage update SwiftyJSON --platform iOS
```

## ビルド済みライブラリのスキップ
先程と同じテーマですが、`--cache-builds`オプションを渡すことでビルド済みのライブラリの場合はスキップしてくれます。
この場合は個別でライブラリ名を指定は必要ありません。

```sh
$ carthage update --platform iOS --cache-builds
```

## もっと体系的に理解する

この記事では、記事の読みやすいよう導入に絞ってます。
もしチーム運用、git管理、CocoaPodsとの違いなど使い続けたら必要になる部分は別記事に分けており、  
「{% post_link_text 2019-09-15-ios-carthage %}」からまとめて知ることができます。

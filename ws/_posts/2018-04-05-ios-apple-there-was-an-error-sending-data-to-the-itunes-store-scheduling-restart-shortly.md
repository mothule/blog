---
title: App Storeへのアップロードで There was an error sending data to the iTunes Store. Scheduling restart shortly が出たので解決した
date: 2018-04-05
categories: ios
tags: ios
image:
  path: /assets/images/ios-apple-there-was-an-error-sending-data-to-the-itunes-store-scheduling-restart-shortly.png
---

いつもと同じ手順でXcodeのOrganizerでApp Storeへアップロードしたら次のエラーが出ました。

```
There was an error sending data to the iTunes Store. Scheduling restart shortly...
```

考えてみた所いくつか前回と異なる点がありました。

## いつもと違うところ

- Sierra から High Sierra にバージョンアップした
- iTunes Connect や Xcode 内 Accounts がログイン期限切れしてた

おそらく一番の要因は最初のOSバージョンだと思います。その次のログインの期限切れも影響していると思います。

## やったこと

- 時間を置いた（約4時間）
- iTunes Connect に入ったら何故か認証エラーになっていたので再ログインした

2つ目が正直謎です。
というのもアップロードする前に対象バージョンの枠を作るために一度 iTunes Connect に接続できているためです。

確実な解決方法は分かっていませんが、同様に起きている場合は一度認証が必要な箇所を一通りチェックしてみてはいかがでしょうか？

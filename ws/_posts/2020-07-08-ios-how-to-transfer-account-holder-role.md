---
title: Apple Developer ProgramのAccount Holderを譲渡する方法
categories: ios
tags: ios
image:
  path: /assets/images/2020-07-08-ios-how-to-transfer-account-holder-role/eyecatch.png
---
Account Holderを譲渡する珍しい機会があったので簡単ですがまとめました。

## 前提

- 自身がAccount Holderである
- 譲渡先が同じチームに招待済み

## 流れ

1. Membershipを開く
1. Transfer Your Account Holder Roleを選択
1. 譲渡先のメンバーを選択
1. 確認画面が出るので同意
1. 譲渡先のメール通知
1. 同意すれば完了

至って単純です。

## Membershipを開く

[Apple Developer PrgramのMembership](https://developer.apple.com/account/#/membership)を開く

## Transfer Your Account Holder Roleを選択

{% page_image 1.png 100% iOS-Transfer-Account-Holder-Role %}

画面下部の `Transfer Your Account Holder Role` を選択
> If needed, you can transfer your Account Holder role to another person on your team who has the legal authority to bind your organization to Apple Developer Program legal agreements. Once confirmed, you will no longer be the Account Holder and will remain on the team as a Developer.

別の人物にAccount Holderの役割を譲渡します。
譲渡後は開発者の役割または複数ロールを持っていれば残ったロールに変更されます。

## 譲渡先のメンバーを選択

{% page_image 2.png 100% iOS-Transfer-Account-Holder-Role-Confirm %}

確認画面が出るので同意する。
あとは譲渡先の人が同意をすれば完了です。

## 取り消しや再送する場合
Membershipの上部にオレンジ帯が出てくるので、
取り消す場合は Withdraw Request
再送信する場合は Resend Request
のボタンになります。


以上です。とても単純ではありますが、滅多にすることはないので記事にしました。

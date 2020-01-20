---
title: iOSのRemote Notificationの実装方法
categories: ios
tags: ios
---
一度しか実装しないけど、必ず実装することになる機能の一つ、APNsの対応についてまとめました。

近年アプリでは必ず対応されているAPNsいわゆるプッシュ通知ですが、基本的なフローは一度実装すれば後で実装を大きく変更することはなく、あったとしてもiOSのRemote Notification周りのAPI変更に合わせるぐらいです。  
なかなか実装するタイミングがない人もいますし、自分も過去に実装したきりでだいぶAPI仕様も変わったので今回自分で実装することにしました。

## APNs(Apple Push Notification service)のメッセージフロー説明

## 大まかな流れ

1. サンプルプロジェクト用意
1. APNs証明書の登録
1. 証明書をプッシュサービスや自前サーバーに展開
1. iOSアプリのCapabilitiesでRemote NotificationsとBackground fetchをON
1. iOSアプリ内でユーザーにプッシュ通知許可を得る
1. 受諾後に受け取るトークンをプッシュサービスまたは自前サーバーに送信

## サンプルプロジェクト用意

まずはプッシュの受取先としてアプリを用意します。

## 参考
- [Apple Developer - Generating a Remote Notification](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification)

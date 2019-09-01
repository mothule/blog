---
title: iPhoneからMac上のRailsアプリにlocalhostでアクセスする方法
date: 2019-08-02
categories: mac
tags: ruby rails ios mac
---
MacでサーバーサイドとiPhoneやAndroidなどのクライアントサイドを同時に開発していると、デバッグをしながらフットワーク軽く開発をしたいですよね。
わざわざテストサーバーにデプロイして動作確認するよりも前に、開発中にMac上に立ち上げてるRailsアプリに対して、iPhoneから接続できたほうが楽ですよね。
今回はその方法についてまとました。

## localhost接続には条件があります

この方法には１つ条件があります。

MacとiPhoneのネット回線が**同じWi-Fi環境下**であること

満たさないと今回説明する方法では実現できません。

## Macのシステム環境設定で共有を設定する

<a href="/assets/images/2019-08-02-how-to-access-localhost-from-ios-1.png"><img src="/assets/images/2019-08-02-how-to-access-localhost-from-ios-1.png" width="100%" alt="システム環境設定の共有画面"></a>


上図はシステム環境設定の共有を開いた画面になります。

### 共有を有効にする
まず左側のチェックボックスの**いずれか**をONにしてください。
1つだけでいいですし、例えば下図のように実質共有不可能にしても構いません。

<a href="/assets/images/2019-08-02-how-to-access-localhost-from-ios-2.png"><img src="/assets/images/2019-08-02-how-to-access-localhost-from-ios-2.png" width="100%" alt="共有の有効"></a>

### ローカルホスト名を設定する

<a href="/assets/images/2019-08-02-how-to-access-localhost-from-ios-3.png"><img src="/assets/images/2019-08-02-how-to-access-localhost-from-ios-3.png" width="100%" alt="ローカルホスト名の設定"></a>

例えば上図のようになっていた場合、**ローカルホスト名とは「mothule-mbp.local」**のことを言います。
これが実際のアドレス代わりとなり、`http://mothule-mbp.local:3000` のようにアクセスするとポート3000に対して `GET /` リクエストを投げます。

**しかし注意事項があります。**  
上記のようにハイフン(`-`)が入ってると動かないので取り除く必要があります。

画面右の「編集...」ボタンからローカルホスト名を変更することができるので、ハイフンを除去した名前にしてください。

これでローカルネットワークにおいてアドレスの準備が済みました。
しかしこのままでは何も反応しないので、上モノとしてRailsアプリを用意します。
ちなみにRailsアプリでなくともPHPアプリでも何でもいいです。

## Railsアプリを適当に用意する

今回の目的はlocalhostへのアクセスなので、ここは適当なアプリを用意していいです。

ただし立ち上げ時のオプションに `-b` つまりバインディングを次のように指定してください。
`-b 0.0.0.0`

```sh
$ bin/rails s -b 0.0.0.0
=> Booting Puma
=> Rails 5.2.3 application starting in development
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.6.2-p47), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://0.0.0.0:3000
Use Ctrl-C to stop
```

アプリを起動すると `localhost:3000`ではなく`0.0.0.0:3000` でリッスンしました。
ここで先程設定した**ローカルホスト名**を使います。
仮にローカルホスト名が「mothule.local」だとして、`http://mothule.local:3000/` にアクセスしてみます。

<a href="/assets/images/2019-08-02-how-to-access-localhost-from-ios-4.jpg"><img src="/assets/images/2019-08-02-how-to-access-localhost-from-ios-4.jpg" width="50%" alt="サーバー起動画面"></a>

無事アクセスできました。

### `-b 0.0.0.0` の意味

これはデフォルトでは `localhost` になっており、localhost経路以外でのアクセスはできません。
しかし 0.0.0.0 を指定することでこれを全公開することになり、同一ネットーワークでかつIPが分かれば、どの端末でも誰でもアクセスできます。
そのため注意事項としては、公共のWi-Fi環境下ではやらないほうがいいです。


## ローカルネットワークのIPアドレス直でもアクセスできる

今回はローカルホスト名を使いましたが、そもそも上記で説明したように全公開になっているので、Railsアプリが立ち上がっているPCのIPアドレスでもアクセスできます。
「http://192.168.11.3:3000」みたいに。 IPは ifconfig で確認できます。




## SafariではなくアプリならATS無効化する

もしiPhoneアプリからRailsアプリに接続する場合は、 ATSを無効化することでアクセスできます。

下図はXcodeでInfo.plistを開いた画像です。

<a href="/assets/images/2019-08-02-how-to-access-localhost-from-ios-5.png"><img src="/assets/images/2019-08-02-how-to-access-localhost-from-ios-5.png" width="100%" alt="ATS一部無効化設定"></a>

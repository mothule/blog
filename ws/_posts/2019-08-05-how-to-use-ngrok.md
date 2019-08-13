---
title: "ngrokで楽にATS無効化せずローカルAPIにHTTPSでアクセスする"
description: ngrokでATS有効なままローカルAPIにHTTPSでアクセスする
date:   2019-08-10 17:38:18 +0900
categories: ios
tags: ios ngrok
---

<figure class="figure-image figure-image-fotolife" title="ngrok">[f:id:motom552:20190805174427p:plain:alt=ngrok]<figcaption>ngrok</figcaption></figure>

RailsアプリとiOSアプリを同時開発してると、iOSアプリからRailsアプリにアクセスしたらブレークポイントで止めたり、改修してすぐ動かしたりなど、フットワークの軽さが開発生産性に繋がるかと思います。

しかしLINE Botだったり、iOSのATSだったり何かとHTTPSが必須となってくる場面においてローカルAPIでは難しい話です。

そんな開発中にHTTPSが欲しいときに便利なのがngrokというサービスです。

## ngrok

[ngrok - secure introspectable tunnels to localhost](https://ngrok.com/)

- 認証不要(認証もあるけど)
- ngrokサービスがランダムなHTTPSアクセスできるURLを用意してくれる
- そのランダムURLにアクセスすると`localhost`にフォワーディングしてくれる
- 数時間立つとURLが無効化する

### インストール
```sh
$ brew cask info ngrok
ngrok: latest
https://ngrok.com/
/usr/local/Caskroom/ngrok/latest (24.6MB)
From: https://github.com/Homebrew/homebrew-cask/blob/master/Casks/ngrok.rb
==> Name
ngrok
==> Artifacts
ngrok (Binary)
```

### 使い方

`$ ngrok http 3000` で `localhost:3000`のURLが発行されます。

```sh
$ ngrok http 3000
ngrok by @inconshreveable                             (Ctrl+C to quit)

Session Status                online
Session Expires               7 hours, 59 minutes
Version                       2.3.34
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://27f4620d.ngrok.io -> http://localhost:3000
Forwarding                    https://27f4620d.ngrok.io -> http://localhost:3000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

この場合、`https://27f4620d.ngrok.io` というURLが一時的にHTTPSでアクセスできるようになり、アクセスすると`http://localhost:3000`にフォワーディングしてくれます。
8時間経過するとURLは無効になります。

### 仕組み

本来であれば、ngrokはローカルネットワーク上にあるサーバーを遠隔地からアクセスできるようにする外から内へアクセスを可能にするサービスです。

これをローカルAPIサーバーと同一ローカルネットワーク上にあるiPhoneが、一旦外部のURLにアクセスし、再びローカルネットワーク上のAPIサーバーにアクセスすることで、開発中にローカルAPIにHTTPSでアクセスする仕組みです。

## 注意事項

ngrokに通信を介しているため、セキュアなデータなどもngrok側は見えているかと思われます。
しかし、ngrok側はそれを秘匿性を守秘していたとしても、ngrok側が脆弱性があれば、そこから意図せずデータが漏洩することは可能性はあります。

そのため、認証などテストする場合はどうでもいいテストアカウトでやることを紹介する以上、推奨します。つまり自己責任です。

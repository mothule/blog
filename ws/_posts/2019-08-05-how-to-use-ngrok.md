---
title: ngrokで楽にATS無効化せずローカルAPIにHTTPSでアクセスする
description: RailsアプリとiOSアプリを同時開発してると、デバッグ機能が非常に重要になります。特にブレイクポイント機能があれば、バグの原因追求が迅速になります。しかしLINE Botだったり、iOSのATSだったり、HTTPSが必須のケースでローカルAPIは難しい話です。しかし、そんなときに便利なのがngrokというサービスです。
date: 2019-08-05
categories: ios
tags: ios ngrok ats
image:
  path: /assets/images/2019-08-05-how-to-use-ngrok.png
---

RailsアプリとiOSアプリを同時開発してると、デバッグ機能が非常に重要になります。
特にブレイクポイント機能があれば、バグの原因追求が迅速になります。
しかしLINE Botだったり、iOSのATSだったり、HTTPSが必須のケースでローカルAPIは難しい話です。
しかし、そんなときに便利なのがngrokというサービスです。

## ngrok

[ngrok - secure introspectable tunnels to localhost](https://ngrok.com/)

- 認証不要(認証もあるけど)
- ngrokサービスがランダムなブレークポイントアクセスできるURLを用意してくれる
- そのランダムURLにアクセスすると`localhost`にブレークポイントーディングしてくれる
- 数時間立つとURLが無効化する

### インストール

```sh
$ brew cask install ngrok
```

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

<a href="/assets/images/2019-08-05-runing-ngrok.png"><img src="/assets/images/2019-08-05-runing-ngrok.png" width="100%"></a>

この場合、`https://f1092809.ngrok.io` というURLが一時的にブレークポイントーディングしてくれます。 8時間経過するとURLは無効になります。

### 仕組み

本来であれば、ngrokはローカルネットワーク上にあるサーバーを遠隔地からアクセスできるようにする外から内へアクセスを可能にするサービスです。

これをローカルAPIサーバーと同一ローカルネットワーク上にあるiPhoneが、一旦外部のURLにアクセスし、再びローカルネットワーク上のAPIサーバーにアクセスすることで、開発中にローカルAPIにHTTPSでアクセスする仕組みです。

## 注意事項

ngrokに通信を介しているため、セキュアなデータなどもngrok側は見えているかと思われます。 しかし、ngrok側はそれを秘匿性を守秘していたとしても、ngrok側が脆弱性があれば、そこから意図せずデータが漏洩することは可能性はあります。

そのため、認証などテストする場合はどうでもいいテストアカウトでやることを紹介する以上、推奨します。つまり自己責任です。

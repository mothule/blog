---
title: 【今時必須】Confirm your account recovery settingsについて(GitHub)
categories: tools github
tags: tools github
image:
  path: /assets/images/2020-01-05-tools-github-confirm-your-account-recovery-settings/0.png
---
近年セキュリティを個々が意識し堅牢にすることの重要性が以前より遥かに増しています。  
特にリモートワークなどでは会社情報を含むPCやスマホを使うことが多いので、個人に求められるセキュリティリテラシーはとても高いものとなっています。  
実際に被害に合う確率が天文学な数字であっても、場所と状態さえ満たしてしまえばその確率は宝くじで1等2等に当選することよりも高くなります。

加えて近年のサービスではアクセストークンを第三者へ渡すことで外部からサービスアクセスができる連携機能も重要なエコシステムとなっています。  
しかしリスクとしては個人とサービスだけでなくその第三者がセキュリティ意識が低いことで漏洩リスクが高まります。

今回はGitHubでよく出てくる「Confirm your account recovery settings」画面について1つずつ確認したのでそれを説明します。

## Confirm your account recovery settings 画面とは？

{% page_image 1.png 50% %}

この画面のことです。GitHubにアクセスしたとき一定の期間毎に表示されるようで、  
見かける方はセキュリティ対策が不十分である可能性があります。

## Two-factor methods とは？

Two-factorとは2要素認証のことで通称2FA(Two-factor Authentication)と呼ばれています。  
自身の知っている知識情報だけでなく、自身の所有物を使ったり、自分自身の身体的特徴などを2つの認証要素で認証することを言います。

GitHubではAuthenticator app(認証アプリ)、Security keys(物理キー)、SMS number(スマホのSMSメール)の3種類の手段が用意されています。
注意点としては2FA後にブラウザを許可し2FAをスキップする設定もありますので、許可すると所有認証となる物だけでなくでなくPCをロストするとリスクが拡大します。

### Authenticator app

スマホやPCアプリによる認証コードを出してくれるアプリです。  
メール認証後にこのアプリを使って表示されている認証コードを使って認証します。
認証コードは一定時間毎に入れ替わります。

これにより悪意ある第三者が自分のメール認証のメアドとパスワードを入手しても、私が所有しているスマホを入手しない限りログインできません。  

#### 対応アプリは色々ある

私はAuthyというアプリを使ってます。
MacではAuthy DesktopというPCアプリもあり数年使っていますが今の所そこまで不便に感じずに使ってます。

たまにアプリを立ち上げるとAuthy自体に設定したパスワードを求められるので、少しだけ2段階認証となっております。

- [Authy - App Store](https://apps.apple.com/jp/app/authy/id494168017)
- [Authy - Google Play](https://play.google.com/store/apps/details?id=com.authy.authy&hl=ja)

### Security keys

ハードウェアのセキュリティキーのことで、実在する物理のキーになります。
有名な物だとYubiKeyなどでしょうか。

<a href="https://www.amazon.co.jp/Yubico-Y-072-YubiKey-NEO/dp/B00LX8KZZ8/ref=as_li_ss_il?ie=UTF8&linkCode=li3&tag=mothule05-22&linkId=21079b265ff170d8eb1d0caabfcdd878&language=ja_JP" target="_blank"><img border="0" src="//ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B00LX8KZZ8&Format=_SL250_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=mothule05-22&language=ja_JP" ></a><img src="https://ir-jp.amazon-adsystem.com/e/ir?t=mothule05-22&language=ja_JP&l=li3&o=9&a=B00LX8KZZ8" width="1" height="1" border="0" alt="YubiKey" style="border:none !important; margin:0px !important;" />

[Amazonで開く](https://www.amazon.co.jp/Yubico-Y-072-YubiKey-NEO/dp/B00LX8KZZ8/ref=as_li_ss_tl?ie=UTF8&linkCode=ll1&tag=mothule05-22&linkId=b95d217be6ebdea044d92e29a3d8d2ba&language=ja_JP)

これも前述したAuthenticator app同様に所有認証となり、悪意ある第三者がメール認証のメアドとパスワードを得ても、このセキュリティキーで認証しなければログインできません。

### SMS number

SMS番号とは電話番号へのSMSメッセージを使って認証コードを送ってくれる方法で、得た認証コードを入力することで認証します。  
これも他同様に電話番号が紐付いた端末を保持しているということで所有認証の部類に入ります。

## Recovery options とは？

Recovery options とは万が一上記の認証手段を失ってしまった場合に、回復する手段のことをいいます。

GitHubではRecovery codes(乱数群)、Fallback SMS number(別スマホのSMSメール)、Recovery tokens（回復用乱数羅列）の3種類が用意されています。

セキュリティと直結はしにくいですが、2FAでセキュリティを上げることで認証手段が複数個になるわけですから、同様にその認証手段をロストするリスクも向上します。

セキュリティを堅牢にしても自分がアクセスできなくなっては意味がありません。

### Recovery codes

Recovery codes とは回復用に予め受け取っておいたコード一覧のことです。  
ログイン済みでRecovery codesを取得し、保存しておくことで、何らかの理由でGitHubにアクセスできなくなったときにこのコードのいずれか１つを使ってアクセスします。  
このコードを紙に印刷して完全にデジタルから隔離しておいたり、スマホなど別端末で管理になると思います。  
それぞれ一長一短ありますので、自分で万が一に備えておきましょう。

### Fallback SMS number

2FAで設定したSMS番号とは別のSMS番号に認証コードを送信できるようになります。  
スマホのロストはもっとも確率が高いので、2FAでAuthenticator appsやSMS numberを使っていて、Recovery codesをスマホに保存している場合は、ここを設定しておいたほうが安心です。

### Recovery tokens

Facebookアカウントを使用した回復手段です。  
Facebookアカウントと連携しておくことで万が一アクセス手段をロストしてもFacebookアカウントにログインできれば回復できます。

## 2FAは絶対やろう

2FAは絶対にやりましょう。  

- 様々なサービスを使っている
- 他サービスと同じパスワードを使いまわしている
- フリーWiFiや自分の所有物でない端末でログインする機会がある

いずれ1つでも当てはまる人は、既に射程距離に入っています。  

### 「大手サービスだから大丈夫」
- 所属経験上、大手だからといって安心ではない
- セキュリティ考慮が予算から外れやすい現実
- 大手ほどエンジニアは外注でセキュリティなど完全に予算外

### 漏洩のニュースが流れていなくても情報は外部に漏れている

私自身の経験ですが、過去に使っていたパスワードで、そのパスワードを使ってた対象サービスの漏洩ニュースがなかったにも関わらず、  
メール認証で使ってたメールアドレスに対して、「お前のパスワードこれだろ？悪用されたくなかったらビットコインで金よこせ」といわゆる人質メールが来ました。  
しかも提示されていたパスワードは実際に昔使ってたものでした。

偶然にも私はパスワードは違う形に変えていたことで、有名どころのサービスやクレカを登録してるサービスは異なるパスワードでしたが、もしこれが同じパスワードでしたら  
完全個人情報やクレジットカード情報など、生活におけるほぼ全部の情報が漏洩しているところでした。

つまり GitHubがどんなに堅牢でも、パスワードが同じだと、他サービスがやられたら堂々と不正ログインされます。

自分の人生を他人に信託できるのならどうぞご勝手に。  
私はこれ以降全ての登録サービスを一元管理し、パスワードは長文乱数化、2FAあるなら対応し、不要なサービスはパスワードは複雑化し退会しています。

## 人はミスをする生き物

2FAをしているから万全というわけではありません。会社に迷惑はかからないのでその点は安心なのですが、  
自分の過去の資産にアクセスできないのはそれはそれで手痛いです。  
2FAに必要な認証要素を失ったら自分すらもアクセスできなくなります。

- Authenticator app
- Security keys
- SMS number

これら3つ対応していても、PC担いで通勤中に交通事故に遭ってPCもスマホも物理キーも壊れたら終わりです。  
命助かっても助かった気がしません。

自宅が火事になればもろとも吹き飛びます。

泥棒に盗まれても同じです。

日常に潜む確率の低いリスクにわざわざ巻き込まれやすくする理由はないので、Recovery optionsは確実に残しておきましょう。

これは普段の利便性が下がるものでもなく緊急時に使うものなので、やっておいて何一つ損はないです。


## 本業に集中するための保険だと思うこと
セキュリティは利便性の反比例になるため、堅牢にするほどGitHubの利便性は下がるのは避けられません。

しかし、その利便性を重視しすぎることによって、漏洩やアカウント乗っ取りリスクは影を潜めていても確実にそこにいます。

そのリスクを自分のミスで受けると個人であれば不正利用による信用失墜や巨額の請求が来たり、会社であれば所属会社からの雇用契約書の契約違反による甲側の一方的な解雇と場合によっては損害賠償請求がありえます。

フリーランスや副業の方による業務委託契約であれば、契約書の契約違反となり損害賠償の話になります。

自分が守るべき責務を守らないことで得られるものに対して、確率的に低くとも受けるリスクと比べると**「そこまでして欲しい利便性か？」** と一度己に説いてみるのも重要です。
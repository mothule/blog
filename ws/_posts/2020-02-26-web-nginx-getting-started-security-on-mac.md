---
title: Mac上でnginxのセキュリティ最低限を確認する
categories: web nginx
tags: web nginx mac
image:
  path: /assets/images/2020-02-26-web-nginx-getting-started-security-on-mac/0.png
---
MacでWebサーバnginxを立ち上げるための入門記事シリーズ5回目です。
今回を入門シリーズ最後とします。

最後はMac上にnginxで立てたWebサーバを対象に最低限のセキュリティ項目について確認を行います。
また`nginx.conf`内の設定で分からないディレクティブが出たらそれの確認も行っていきます。

▼前回は設定ファイルをドメイン別に分ける方法について説明しました。  
{% post_link_text 2020-02-26-web-nginx-getting-started-customize-on-mac %}

今回はnginx自体に関するセキュリティ対応であってその上に乗っかるlaravelやRailsアプリサーバに対するセキュリティに関しては記載していません。
また記載されたケース以外にも該当する脅威やシナリオはあることをさきに伝えておきます。

## nginx.confに設定したファイル全容

今回紹介する設定は次になります。
一つずつ調べてみます。

*nginx.conf*  
```
server_tokens off;

add_header X-XSS-Protection "1; mode=block";
add_header Content-Security-Policy "default-src 'self'";
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
add_header X-Download-Options "noopen";
add_header X-Frame-Options sameorigin;
add_header X-Content-Type-Options nosniff;

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
ssl_prefer_server_ciphers on;
ssl_dhparam /usr/local/etc/ssl/certs/dhparam.pem;

server {
  listen 80 default_server;
  server_name _;
  return 403;
}

server {
  listen 443 ssl default_server;
  server_name _;
  ssl_certificate /usr/local/etc/crypt/site.crt;
  ssl_certificate_key /usr/local/etc/crypt/site.key;
}

location = /xmlrpc.php {
  return 403;
}
```


## HTTPヘッダー

### nginxのバージョン情報を隠す

```
server_tokens off;
```

nginxで発見された脆弱性をついたゼロデイ攻撃から少しでも身を守る

例：悪意あるユーザが事前にサイト毎のパッケージのバージョン情報を偵察
  脆弱性が公表されたら、その脆弱性をついた攻撃スクリプトが出回る
  蓄積されたサイト別情報から脆弱性を含むバージョンで動いているサイトを検索
  見つかったサイトに対してスクリプト実行

### クロスサイトスクリプティング(XSS)フィルタリングを有効化する

```
add_header X-XSS-Protection "1; mode=block";
```
`1`は有効化で`0`は無効化です。有効化したときの挙動として`mode=block`を指定します。
有効化することでXSSフィルタリングを有効化します。これはデフォルト値となります。
XSS攻撃を検出したら、ブラウザはページをサニタイズ、安全でない部分を除去します。

`mode=block`がついてるとページ描画を止めます。

### コンテンツセキュリティポリシー(CSP)でセキュリティ層を追加する
CSPはXSS攻撃やデータインジェクション攻撃など一部攻撃を検知、軽減するセキュリティレイヤーです。
CSPを利用すると、サーバから許可されたドメインのスクリプトのみを実行します。
これによりXSSの発生箇所を抑えることができます。
`Content-Security-Policy`ではユーザーエージェントに読み込ませたいリソース情報と範囲を`;`セミコロン分割の列挙で指定します。

```
add_header Content-Security-Policy "default-src 'self'";
```

この場合は全コンテンツをサイト自身のドメインから取得を許可します。ただしサブドメインは許可されません。
デフォルトでは無制限なのでこれを指定することで`-src`で終わるもののデフォルトは全部この値になります。


### Strict-Transport-Security(HSTS)でHTTPS通信を強制する

```
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
```
`max-age`でサイトにHTTPS接続をすることをブラウザに記憶させます。
`includeSubdomains`で他のサブドメインにも適用させます。

### X-Download-Optionsで直接ファイル開くを禁止する
IEがダウロードしたファイル直接開けないようにさせます。
ローカルにファイル化せずブラウザから直接URLを開くと、サイトのコンテキストで実行されるため
悪意あるスクリプトをこの方法で開くとインジェクション攻撃の脅威となります。

```
add_header X-Download-Options "noopen";
```

`noopen`とすることでそもそも「開く」ことができなくなります。

### X-Frame-Optionsで埋め込み表示を同ドメインに絞る

`<iframe>`タグなどの中で表示許可を制限します。
他サイトで埋め込み表示させないことでクリックジャッキング攻撃を防止します。

クリックジャッキングとはタップ可能なUIを隠しておいてユーザに意図せず押させる手法です。

```
add_header X-Frame-Options sameorigin;
```
`sameorigin`は表示許可を同じドメイン内にしぼります。

### X-Content-Type-OptionsでContent-Type見るように強制する

MIMEタイプのスニッフィングの有効無効を指定します。

```
add_header X-Content-Type-Options nosniff;
```
`nosniff`でファイルの種類を内容ではなく`Content-Type`から判断させます。
無許可のファイル・タイプを処理させないようにします。

## SSL

### ssl_protocolsでSSL/TLSプロトコルを指定する

`ssl_protocols`で使う暗号方式を指名できます。

```
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```
デフォルトでは 古くて非推奨なプロトコルも入っているので指定する。

### ssl_ciphersでセキュアな暗号化スイートを指定する

サーバ側でセキュアな暗号化スイートを指定します。
無指定だとクライアント側が指定した方法で暗号化することになります。

```
ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
```
セミコロン(`;`)をデリミタに優先順位順に記載します。

### ssl_prefer_server_ciphersで優先利用させる

```
ssl_prefer_server_ciphers on;
```

`on`とすることでサーバ側で指定した暗号を優先して使うように指示します。

### ssl_dhparamで鍵長を強化する

デフォルトでは512bits, 1024bits以下になっておりDH鍵交換方式の脆弱性をついたLogjam攻撃リスクがあるため。
Logjam攻撃とはTLS接続の暗号強度を低下させ、計算可能な領域に下げ盗聴や改ざんのリスクを高める攻撃です。

```
ssl_dhparam /usr/local/etc/ssl/certs/dhparam.pem;
```

自前で2048や4096のpemを作り設定します。

作成はOpenSSLで簡単につくれます。
```sh
$ openssl dhparam -out dhparam.pem 4096
```

## その他

### IP直打ちアクセスを禁止する

効果のあるセキュリティ対策は悪意あるユーザーにサイトの存在がばれない事です。

しかし、ドメイン名は分からずともIPアドレスは数字なのでデタラメにアクセスするボットでもいつかは有効なアドレスにヒットします。
これで望んでいない悪意あるユーザーにサイトの存在がバレてしまうリスクがあります。

```
server {
  listen 80 default_server;
  server_name _;
  return 403;
}
```
ドメインなしのアクセスがあればデフォルトでここがヒットするようにします。

`https`接続も同じようにします。

```
server {
  listen 443 ssl default_server;
  server_name _;
  ssl_certificate /usr/local/etc/crypt/site.crt;
  ssl_certificate_key /usr/local/etc/crypt/site.key;
}
```

### 一部デフォルトパスを無効化する

```
location = /xmlrpc.php {
  return 403;
}
```
例えばwordpressでは外部からwpを操作する仕組みで`XML-RPC`があり、それを使った脆弱性攻撃があります。
こういった有名フレームワークやライブラリを入れることで導入利便性を高めるためにデフォルトで用意されているページが脆弱性の対象となるので、こういったページは名称を変えるかそもそもアクセスを禁止させます。
今回はアクセスがあったら拒否します。

## 注意
今回調べた項目は調べて必要だなと思った部分を設定として紹介しました。
実際はケースごとにもっと色々と設定が必要だなと思います。
この設定すれば100%安全を保証するものではありませんし、保証できません。
この設定によりインシデントが発生しても責任はおえません。
あくまでも自己責任でお願いします。

## 参考

[参考](https://qiita.com/hi-nakamura/items/fe07afbcfb61185c47f8)
[参考](http://cluex-developers.hateblo.jp/entry/secure-nginx-setting-for-2016)

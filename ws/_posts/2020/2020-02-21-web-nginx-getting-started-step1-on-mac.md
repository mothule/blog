---
title: Macでnginxをインストールして起動する
categories: web nginx
tags: web nginx mac
image:
  path: /assets/images/2020-02-21-web-nginx-getting-started-step1-on-mac/0.png
---
MacでWebサーバnginxを立ち上げるための入門記事シリーズ初回です。
Webサーバとしての基礎知識、Macにnginxのインストール、基本構成や基本動作や設定など初期知識に必要な情報をまとめました。

## nginxはWebサーバ

[nginx - Wikipedia](https://ja.wikipedia.org/wiki/Nginx)
> nginxとはフリーかつオープンソースなWebサーバである。
> 処理性能・高い並行性・メモリ使用量の小ささに焦点を当てて開発
> HTTP, HTTPS, SMTP, POP3, IMAPのリバースプロキシの機能や、ロードバランサ、HTTPキャッシュなどの機能も持つ。

いろんな通信プロトコルや通信機能をカバーした **Webサーバ** です。

nginxは1つのマスタープロセスと複数のワーカープロセスで構成されてます。  
- マスタープロセス：nginx.confを読み取り、ワーカープロセスを維持する。
- ワーカープロセス：リクエスト処理

イベントベースのモデルとOS依存メカニズムを使用して、ワーカプロセス間でのリクエストを効率よく分散します。  
ワーカープロセス数は構成ファイルで定義され、固定値か使用可能なCPUコア数に自動調整します。

### Webサーバとは？
粒度荒く単純に説明するなら  
ブラウザに、静的コンテンツ(HTMLや画像など)を配信するソフトウェア＋ハードです。

nginxを使うことでmacOSにポートを開き、ポートからのHTTPリクエストが来たらドキュメントルート内の一致するパス(ファイル)を返すようになります。  
つまり静的コンテンツなブログのようなサービスを立ち上げることができるということです。

### ポートとは？
噛み砕いて説明すると、コンピュータ通信における窓口です。  
外のコンピュータはこの窓口を通して中のコンピュータに情報を送っています。  
普段このポートは使わない場合は閉じてあります。
またポートには番号が割り振られており、ポートは655356個あります。
一部ポートには用途が予め決められています。
例えばブラウザが通信で使っているプロトコルHTTPは80番ポートです。

### ドキュメントルートとは？
Webサーバが外部に公開するためのディレクトリです。
このディレクトリにファイルを配置することで、パスと名前が一致していればWebサーバはブラウザに一致したファイルを返します。

## なぜMacでnginxなのか？
nginxはWebサーバであり、大抵のサーバOSはLinuxなので、nginxはLinux上で使うことが多いです。  
MacとLinuxではコマンドやパス構成が異なることから、Mac上で得た知識を完全移行はできません。

しかし、**nginxの基礎理解のために慣れたOSを手元で試行錯誤することは全体像の理解を促進します。**  
また、VirtualBoxなど仮想OSでLinuxをMac上で構築することもできますが、ブリッジなど仮想OS自体の知識が必要だったり純粋にnginxの把握には不向きだったりします。

加えて、アプリサーバ開発中にWebサーバをnginxで動作確認したいケースもありえます。

## Macにnginxをhomebrewでインストール
Macのパッケージ管理ソフトウェアHomebrewを使ってnginxをインストールします。

### homebrewでインストール

```sh
$ brew install nginx
```

### nginxが入ってるか確認

```sh
$ nginx -v
nginx version: nginx/1.17.8
```

### nginxを起動する

`launchd`として起動すれば、ログイン時に自動でサービス起動します。
```sh
$ brew services start nginx
```

単純起動は `nginx` を実行するだけです。

どのポートを開いてるかは`lsof`で確認できます。
```sh
$ lsof -c nginx -P | grep LISTEN
nginx   97024 mothule    6u    IPv4 0x9e21b4cd1c187225      0t0        TCP *:8080 (LISTEN)
nginx   97025 mothule    6u    IPv4 0x9e21b4cd1c187225      0t0        TCP *:8080 (LISTEN)
```
この場合は8080が開いてるので、 http://localhost:8080 にアクセスすると表示されます。

▼`lsof`に関しては以下のの記事で説明してます。  
{% post_link_text 2020-02-21-tools-lsof-basic lsofでプロセスが使用中のポートやファイルを確認 %}

設定に問題なければ、デフォルトで用意されているhtmlページが表示されます。

{% page_image 1.png 75% nginx起動初期画面 %}

### nginxを停止する
stopシグナルを送ります。

```
$ nginx -s stop
```

### その他シグナル

|シグナル名|意味|
|---|---|
|nginx -s stop|nginxを停止する。処理中のリクエスト待たずに終了する。|
|nginx -s quit|nginxを停止する。処理を待つ。|
|nginx -s reopen|ログファイルを開き直す|
|nignx -s reload|nginxの設定ファイルを再読み込みする|

## nginxの構成

nginxの内部構成をざっくり分けると次のようになります。

- 設定
  - /usr/local/etc/nginx
- ドキュメントルート(ディレクトリ)
- 追加モジュール
- ログ
- ログローテーション
- キャッシュ


## nginxの設定ファイル
nginxには細かな動作やパラメータを設定するファイル（設定ファイル）があります。  
設定ファイルを変更してnginxをチューニングできます。

### nginxの設定ファイルの場所
Macの場合は`/usr/local/etc/nginx/nginx.conf`になります。
フォルダ上に`nginx.conf`だけでなく`nginx.conf`内部でincludeされている設定ファイル(`mime.types`など)が配置されてあります。


#### 補足: brew info の /usr/local/etc/nginx/servers/
ちなみに `brew info nginx`で
```sh
nginx will load all files in /usr/local/etc/nginx/servers/.
```
とは記述されているのは、 `nginx.conf`内で

```
include servers/*;
```
と記述されてるためです。

`servers`フォルダ内にファイルを置くことで設定ファイルとして読み込んでくれるということです。  
なお、`servers`フォルダは存在しないため自分で作成が必要です。

### ドキュメントルートの確認と変更
ドキュメントルートは`nginx.conf`内に定義されてます。

↓は抜粋したものです。

```
http {
  server {
    location / {
      root  /usr/local/var/www;
      index index.html index.hml;
    }
  }
}
```

### ポートの確認と変更

現在のポート番号は `nginx.conf`内に定義されてます。

↓は抜粋したものです。

```
http {
  server {
    listen  8080;
  }
}
```
この場合は8080ポート番号を開いています。


### nginxの設定ファイルのテスト

設定ファイルの書き方に問題がないかテストする方法があります。
方法は２つあり、

#### `$ nginx -t`でテスト結果を表示
設定ファイルをテストして結果を表示する。  

```sh
$ nginx -t
nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful
```

#### `$ nginx -T`で設定ファイルも表示
設定ファイルをテストして、設定ファイルinclude含め一つの設定ファイルとして表示する。



## nginxのログファイル
ログはアクセスログとエラーログの２酒類です。  
ログの出力先は設定ファイルで変更できます。

*nginx.conf*
```
error_log  logs/error.log;

...

http {
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

  access_log  logs/accss.log main;

  ...

  server {
    access_log logs/host.access.log main;
  }

}
```

httpブロック内のアクセスログでもいいですが、絞りたい場合は serverブロック内のアクセスログもあります。
log_formatを使わず直接access_log にformatを書いても大丈夫です。

上記の構文を次の記事となる{% post_link_text 2020-02-22-web-nginx-getting-started-step2-on-mac %}で説明します。

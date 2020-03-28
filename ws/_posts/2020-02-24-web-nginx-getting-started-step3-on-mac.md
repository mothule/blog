---
title: Mac1台にnginxでWebサーバとPumaでアプリサーバを立てる
categories: web nginx
tags: web nginx mac ruby rails
image:
  path: /assets/images/2020-02-24-web-nginx-getting-started-step3-on-mac/0.png
---
MacでWebサーバnginxを立ち上げるための入門記事シリーズ3回目です。

## ゼロから`nginx.conf`を書いてアプリサーバを構築する

今回はアプリサーバ(APサーバ)をnginxで立てます。  
前回の記事でゼロから作り上げた`nginx.conf`をベースに変更加える形で説明します。

▼もし前回記事を見ていない場合は確認してください。  
{% post_link_text 2020-02-22-web-nginx-getting-started-step2-on-mac %}

**今回も使用ディレクティブを一つ一つ説明します。**  
もし、途中で躓いた場合は最後に`nginx.conf`の全容を載せてます。確認してみてください。

## WebサーバとAPサーバ(アプリサーバ)の違い

まず事前知識としてWebサーバとAPサーバ(アプリサーバ)の違いについて説明します。

### Webサーバとは？
WebサーバはWebブラウザからのリクエストをハンドリングします。

ブログであれば「先週の記事一覧を閲覧したい」というリクエストです。  
Webサーバはリクエストを受け取るとレスポンスをWebブラウザに送信します。先程の「先週の記事一覧」であれば`html`や`css`、`画像`などを送信します。

`nginx`はWebサーバになります。

### APサーバ(アプリサーバ)とは？
厳密にはWebアプリケーションサーバ(Web Application Server)です。APサーバやアプリサーバと略されることが多いです。  
Webサーバが受け取ったリクエストを処理して、結果をWebサーバに返すサーバです。  
APサーバではRubyやPHPなどプログラムを呼ぶことでリクエストを動的に処理して、Webサーバに分かる形で返しています。

## nginx + puma + Railsを1つのMacで構想する

Ruby+Railsをベースに説明します。  
今回のサーバ構成は

- nginx
- [puma](https://github.com/puma/puma)
- Rails

の3層構造となります。

### pumaとは？
> 並行性のために構築されたRuby/Rack Webサーバです。

[github/pumaより引用](https://github.com/puma/puma)

pumaはWebサーバでRackにも対応しているため、puma単体でRailsなどRubyを動かすことができます。  
そのため、開発時はpuma単体を使うことが多いです。

しかしここで疑問が2つあります。

- なぜWebサーバが2つ使うのか？
- Rackとは何か？

この２つを説明します。

### なぜWebサーバが2つ？

nginxはWebサーバですが、pumaもWeb/Rackサーバです。なぜ二つもWebサーバを使うのでしょうか？  
**それはnginxにはRackに直接つなげることができないためです。**  
nginxがクライアントからリクエストを受け取ってもそれをRails/Rubyに渡す手段がありません。

### Rackとは？

ではRackとは一体何でしょうか。  
**RackとはRailsなどWebサーバからRubyプログラムを操作するための統一インターフェイスです。**

▼Rackの詳細はこちらで説明しています。  
{% post_link_text 2019-09-01-rails-rack-middleware-extension %}

### なぜnginxが必要なのか？

ではそもそも何故nginxを使うのでしょうか？役割は何でしょうか？  
rack接続できないnginxを使わずとも、pumaで完結したほうが構成がシンプルになります。  
しかしそれでもnginxを使っている理由は、**パフォーマンスの違いにあります。**

pumaはRubyで書かれてますが、nginxはCで書かれています。速度差は圧倒的にnginxが高速で多機能です。  

> 処理性能・高い並行性・メモリ使用量の小ささに焦点を当てて開発されており、HTTP, HTTPS, SMTP, POP3, IMAPのリバースプロキシの機能や、ロードバランサ、HTTPキャッシュなどの機能も持つ。

[Wikipedia](https://ja.wikipedia.org/wiki/Nginx)より引用

静的ファイルや画像など単純処理の場合にもRailsに渡さずnginxが処理したほうが高速で、CPUリソースも他の動的処理に回せるので全体として効率よく運用できます。

### 今回のリクエストフローを図にする

では今回作り上げるサーバ構成を前述した知識を使うと下図のようになります。

{% page_image 1.png 100% nginxとpumaとRailsを使ったサーバ構成図 %}

一番左側の層はクライアント層で、ブラウザだったりアプリになります。  
左から右にリクエストフローを箇条書きすると次のようになります。

1. クライアントがnginxにHTTPリクエストを渡す
1. nginxはHTTPリクエストを分析してRailsに渡すためpumaに渡す
1. pumaは受け取ったリクエストをRackが分かるデータ形式で渡す
1. Rackはルールに基づいてRailsを呼び出す

ここで補足すると、pumaとrackとRailsは説明都合で過分解してます。  
実際はこれらは同じサーバにのり、呼び出しも通常のRubyによるコールスタックです。

### Rackの役割は疎結合
Rails自体にHTTPサーバ機能はなく、Rackという規約を通してHTTPリクエストを捌ける機能を提供しています。  
pumaはHTTPサーバ機能を持ち、Rackの規約に基づいてRackへHTTPリクエストを渡しているのです。  
つまりRackを通すことでpumaとRailsの疎結合が守られています。

### nginxはリバースプロキシ
nginxの立ち位置はリバースプロキシです。  
これは前述したnginxの存在理由と一致します。  
つまり簡単なHTTPリクエストはnginxが担い、難しいリクエストはPuma+Railsに任せるということです。

そしてnginxからpumaへのデータ伝達テクノロジーとしてUNIXドメインソケットを使います。

### UNIXドメインソケットとはプロセス間通信機能
1つのOS内部でのプロセス間通信でしか使えないですが、高速に通信できます。  
UNIXドメインソケットを使うには、ファイルシステムのパス指定するとファイルが作成されます。  
このファイルはソケットファイルと呼ばれるファイルで、通常ファイルのように実体は存在しません。  
システムを使ったプロセス間の通信手段としてファイルを使います。  
nginxがソケットファイルを作成し、Pumaは作成されたソケットファイルに接続します。

## MacにnginxでWebリバースプロキシサーバを立ち上げる

それでは実際にサーバを構築していきます。まずはメインであるnginxでWebサーバを構築します。  
冒頭でも説明したように前回の記事でゼロから作り上げた`nginx.conf`をベースに変更加える形で説明します。

▼もし前回記事を見ていない場合は確認してください。  
{% post_link_text 2020-02-22-web-nginx-getting-started-step2-on-mac %}

工程は大きく分けて2つです。

1. nginxにリバースプロキシ設定する
2. pumaの設定をRails側で設定する

どちらも共通してUNIXドメインソケットのパス指定です。

### nginxにリバースプロキシ設定する

前回ではlocationに対してどのフォルダを見るのかrootを設定しました。  
静的処理の場合はそれで良かったのですが、動的処理は、処理を委任する必要があります。

次のように`upstream`と`proxy_pass`ディレクティブが重要になってます。

*nginx.conf*
```
http {
  upstream puma {
    server unix:///usr/local/var/work/app-name/tmp/sockets/puma.sock;
  }

  server {
    location / {
      proxy_pass http://puma;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_redirect off;
    }
  }
}
```

このnginx.confの各ディレクティブを一つずつ見ていきます。必要であれば関連ディレクティブも見ていきます。

## upstreamコンテキスト

サーバグループを定義します。異なるポートや通信方式のサーバ群を混在できます。
サーバグループの中のサーバは、リクエストをバランシングして渡されます。  
ここでの`upstream`とはネットワークで下流から上流の通信機器へデータが流れることを指してます。  

構文: `upstream name { ... }`

次の例は4つのサーバを混在させたサーバグループです。

```
upstraem backend {
  server backend1.example.com weight=5; # ①
  server 127.0.0.1:8080 maxfails=3 fail_timeout=30s; # ②
  server unix:/tmp/backend3; # ③

  server backup1.example.com backup; # ④
}
```

サーバ間の分散方式は、デフォルトでは加重ラウンドロビンバランシング方式(weighted round-robin balancing method)で分散されます。
これはサーバに対するリクエストをサーバ負荷に無関係に、ローテーションでウェイトに従い各サーバに振り分ける方式です。
上記サーバグループに7つのリクエストがあったら次のように配信されます。

1. 5つのリクエストが①サーバに送信される
1. 1つのリクエストが②と③サーバにそれぞれ送信される
1. サーバ通信中にエラー発生したら、リクエストは次のサーバに渡される
1. 機能してる全サーバが試行されるまで続く
1. どのサーバからも正常応答を取得できない場合は、最後に通信したサーバの結果を受け取る


### serverディレクティブ

アドレスとサーバパラメータを定義します。

構文: `server address [parameters];`

アドレスはドメインかIPアドレスとポート、または`unix:`プレフィックスの後に指定されたUNIXドメインソケットパスを指定できます。
ポート未指定はポート80が使用されます。

- fuga.example.com
- 127.0.0.1:8080
- unix:/usr/local/var/run/nginx/nginx.sock

|パラメータ名|説明|
|---|---|
|weight|サーバウェイト。デフォルトは1。加重ラウンドロビンバランシングで使います|
|max_conns|プロキシされるサーバへの同時アクティブ接続最大数を制限。デフォルトは０で無制限。サーバグループが共有メモリ※にない場合はこの制限はワーカープロセス毎に機能|
|max_fails|デフォルトは1回。ヘルスモニタで後述|
|max_timeout|デフォルトは10秒。ヘルスモニタで後述|
|backup|サーバをバックアップサーバとして設定。プライマリサーバが利用不可時にリクエストが渡る。`hash`,`ip_hash`,`random`ロードバランシング方式時は利用不可|
|down|サーバを永続的に使用不可として設定|
|resolve|サーバのドメイン名に対応するIPアドレスの変更を監視し、再起動なくupstream構成を自動変更できます。サーバグループは共有メモリに存在する必要がある|
|route|サーバのルート名を設定|
|service|DNS SRVレコードの解決を有効にし、サービス名を設定。これを使うにはサーバの解決パラメタを指定し、ポート番号なしホスト名指定が必要|
|slow_start|サーバ不可から回復後にサーバのウェイトをゼロから公称値に回復する時間を設定。デフォルトは0、つまりスロースタートは無効|
|drain|ドレインモードに設定する。このモードはサーバにバインドされた要求のみがプロキシされる|

※共有メモリに関しては後述する`zone`ディレクティブを確認してください。  
グループにサーバ一つの場合は、 `max_fails`, `max_timeout`, `slow_start`は無視される。

今回はUNIXドメインソケット通信1つしかないため、次のようにします。

```
http {
  upstream puma {
    server unix:///usr/local/var/work/app-name/tmp/sockets/puma.sock;
  }
}
```

ソケットファイルのパスにはアプリ名を入れるのが良いでしょう。
まだアプリ(Railsアプリ)は用意していないので、`app-name`と仮置してます。

#### ヘルスモニタ
max_timeoutパラメータの指定期間内にmax_failsパラメータ指定回数失敗すると、**サーバ利用不可** とみなします。
そしてmax_timeoutパラメータの期間、サーバ利用不可となります。

サーバとの通信試行が指定回数失敗したらサーバ利用不可と判断する時間、もしくはサーバが利用できないとみなされる期間。デフォルトは10秒

#### 注意：max_connsを超えるケース
- アイドル状態のkeepalive接続
- 複数のワーカー
- 共有メモリ

が有効になっている場合、プロキシサーバへのアクティブ状態またはアイドル状態の接続総数が`max_conns`値を超える場合があります。

`keepalive`接続に関しては、後述する`keepalive`ディレクティブを確認してください。

### zoneディレクティブ
「ワーカプロセス間で共有されるグループ構成」と「実行状態」を保持する共有メモリゾーンの名前とサイズを定義します。
この設定は複数グループが同じゾーンを共有するケースがあります。その場合はサイズを1回指定で十分です。

構文: `zone name [size];`

商用サブスクリプションの場合は、nginx再起動せずグループメンバーシップ変更できたり、特定サーバの設定変更できます。

共有メモリを使わない場合は、各ワーカプロセスはサーバグループ設定のそれぞれのコピーを保持し、関連するカウンターのそれぞれのセットを保存します。
カウンターにはグループ内のそれぞれのサーバへの現在の接続数が含まれ、サーバへリクエスト送信の失敗数が含まれます。
サーバグループの設定は変更不可です。
共有メモリが有効な場合、個別でもっているサーバグループ設定全てを共有メモリで扱います。

また共有メモリが有効な場合、あるプロセスがサーバ利用不可と判断したら、別プロセスにも共有されます。
無効な場合は、それぞれがサーバ利用不可と判断されるまでサーバへリクエストを送信し続けます。

今回はワーカープロセスは複数個あるので、設定しておきます。

```
upstream puma {
  zone nginx 64k;
}

```

### keepaliveディレクティブ

Keep-Aliveを有効にします。
`connections`パラメータは、Keep-alive接続の最大数を設定します。
数を超えると使用頻度が低い接続が閉じます。

構文: `keepalive connections;`

**この接続最大数はnginxワーカプロセスが開くことができるサーバの接続数の総数を超えてはいけません。**
超えてしまうと、ワーカプロセスが開ける接続数を超えるリクエストが来てもkeepaliveの期限切れするまで接続できません。

keepalive接続数で処理するリクエストの最大数は `keepalive_requests`ディレクティブで設定できて、
タイムアウトは`keepalive_timeout`ディレクティブで設定できます。

今回はMac上ということで主に開発色が強いので1にします。

```
upstream puma {
  keepalive 1;
}
```

### keepalive_requestsディレクティブ

1つのkeepalive接続を介して処理するリクエスト最大数を設定します。
最大数のリクエストが処理された後、接続が閉じます。

構文: `keepalive_requests number;`  
デフォルト: `keepalive_requests 100;`

今回はデフォルト値でいこうと思います。

#### なぜ接続数が決められてるのか？
無制限ではダメな理由は、接続毎にメモリ割り当てが行われているため、定期的に接続を閉じてメモリ解放を行わないと、要求が高すぎるとメモリ使用量が高くなり推奨されません。

### keepalive_timeoutディレクティブ

プロキシサーバーへのkeepalive接続のタイムアウトを設定します。

構文: `keepalive_timeout timeout;`  
デフォルト: `keepalive_timeout 60s;`

今回はデフォルト値でいこうと思います。

### proxy_passディレクティブ

プロキシするサーバのプロトコルとアドレス、場所となるURIをオプションで設定します。
プロトコルは`http`と`https`を指定できます。アドレスはドメイン名、IPアドレスとオプションでポートを指定できます。
UNIXドメインソケットの場合は`unix:`をつけます。

構文: `proxy_pass URL;`

- 例1： `proxy_pass http://localhost:8080/uri/;`
- 例2： `proxy_pass https://backend.example.com;`
- 例3： `proxy_pass http://unix:/tmp/backend.socket:/uri/;`

ドメイン名が複数アドレスに解決する場合はラウンドロビン方式で使用します。さらにアドレスをサーバグループとして指定できます。

`URL`パラメータには変数が使えます。  

```
location /name/ {
  proxy_pass http://127.0.0.1 $request_uri;
}
```
この場合ディレクティブでURIを指定すると、元のリクエストURIを置き換えてそのままサーバに渡します。

変数を使うと、アドレスがドメイン名なら名前解決はサーバグループ間で検索され、
見つからない場合は`resolver`ディレクティブを使用します。

`resolver`ディレクティブとはネームサーバを設定するディレクティブです。

今回はUNIXドメインソケットなので、 `upstream`で設定した名前を使います。

```
server {
  location / {
    proxy_pass http://puma;
  }
}
```


### proxy_set_headerディレクティブ

プロキシサーバからパス先サーバにheader情報を追加で渡します。

構文: `proxy_set_header field value;`

今回は次のヘッダーをパス先サーバに送ります。

```
location / {
  proxy_set_header    Host    $host;
  proxy_set_header    X-Real-IP    $remote_addr;
  proxy_set_header    X-Forwarded-Host       $host;
  proxy_set_header    X-Forwarded-Server    $host;
  proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
  proxy_set_header    X-Forwarded-Proto $scheme;
}
```

### proxy_hide_headerディレクティブ

クライアントに渡さないヘッダーフィールドを設定する。

構文: `proxy_hide_header field;`

デフォルトでは下記のヘッダーフィールドは渡しません。

- Date
- Server
- X-Pad
- X-Accel-*

ちなみに逆に許可は、`proxy_pass_header`ディレクティブを使用します。

今回は`X-Powered-By`を隠します。
```
location / {
  proxy_hide_header   X-Powered-By;
}
```
`X-Powered-By`フィールドは一部のFWではFW情報やバージョンをこのフィールドに乗せてクライアントに送ります。
使ってるFWバージョンに脆弱性が見つかると攻撃手段を教えているようなもので、通常利用ならクライアント側に教える目的もないため隠します。

### proxy_redirectディレクティブ

プロキシ先の応答の`Location`と`Refresh`ヘッダーフィールドで変更が必要か設定します。

構文:
- `proxy_redirect default;`
- `proxy_redirect off;`
- `proxy_redirect redirect replacement;`

デフォルト: `proxy_redirect default;`

例：
`proxy_redirect http://localhost:8000/two/ http://frontend/one/;`と設定した場合  
プロキシ先から`Location: http://localhost:8000/two/some/uri`が返ってきたら
クライアントには`Location: http://frontend/one/some/uri/`を返す

パラメータ値が`default`では次の２つの設定は同じになります。

```
location /one/ {
  proxy_pass     http://upstream:port/two/;
  proxy_redirect default;
}
location /one/ {
  proxy_pass     http://upstream:port/two/;
  proxy_redirect http://upstream:port/two/ /one/;
}
```

今回はプロキシ先にドメインが正しくを伝えるためにoffにします。

```
server {
  location / {
    proxy_redirect off;
  }
}
```

## 出来上がった設定ファイル(nginx.conf)

この記事を通して出来上がった設定ファイル(`nginx.conf`)になります。

*nginx.conf*
```
worker_processes  4;

error_log /usr/local/var/log/nginx/error.log error;

worker_rlimit_nofile 2048;

events {
  worker_connections 1024;
}

http {
  include mime.types;
  default_type application/octet-stream;

  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

  access_log /usr/local/var/log/nginx/access.log main;

  sendfile on;
  tcp_nopush on;

  keepalive_timeout 60;

  gzip on;
  gzip_min_length 1024;
  gzip_types text/css text/javascript application/json;

  upstream puma {
    server unix:///usr/local/var/work/app-name/tmp/sockets/puma.sock;
    zone nginx 64k;
    keepalive 1;
  }

  server {
    listen 8080;
    server_name localhost;

    charset utf-8;

    access_log /usr/local/var/log/nginx/localhost.access.log  main;

    error_page 404 /404.html;

    location / {
      proxy_pass http://puma;
      proxy_set_header    Host    $host;
      proxy_set_header    X-Real-IP    $remote_addr;
      proxy_set_header    X-Forwarded-Host       $host;
      proxy_set_header    X-Forwarded-Server    $host;
      proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
      proxy_set_header    X-Forwarded-Proto $scheme;
      proxy_hide_header   X-Powered-By;
    }


    location ~* \.(gif|jpg|jpeg|png)$ {
      root /usr/local/var/www/images;
    }
  }
}
```

## pumaの設定をRails側で設定する
puma単体で動かしても動作確認しにくいのでサンプル用のRailsアプリを用意します。

下記環境でRailsアプリを用意します。

- Ruby 2.6.5
- Rails 6.0.2.1

```sh
$ rails new nginx-puma-rails -d mysql --skip-git --skip-javascript --skip-test --skip-spring --skip-bundle
...
$ cd nginx-puma-rails
$ bundle install --path=vendor/bundle -j4
...
$ bin/rake db:create db:migrate db:seed
Created database 'nginx_puma_rails_development'
Created database 'nginx_puma_rails_test'
```

次にpumaの設定ファイルでポートlistenではなくUNIXドメインソケットの変更します。

*nginx-puma-rails/config/puma.rb*  
```ruby
# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
# port        ENV.fetch("PORT") { 3000 }
# ↑ portコマンドはコメントで動かないようにする

bind "unix://var/local/work/nginx-puma-rails/tmp/sockets/puma.sock"
```

*nginx.conf* ではアプリ名を仮(app-name)にしてたいので、ここも合わせます。  
```
http {
  upstream puma {
    server unix:///usr/local/var/work/nginx-puma-rails/tmp/sockets/puma.sock;
  }
}
```

## nginxとRailsアプリを起動して疎通する

UNIXドメインソケットのパスをpumaとnginxそれぞれ合わせたら、Railsアプリを起動します。

```sh
$ bin/rails s
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
=> Run `rails server --help` for more startup options
Puma starting in single mode...
* Version 4.3.3 (ruby 2.6.5-p114), codename: Mysterious Traveller
* Min threads: 5, max threads: 5
* Environment: development
* Listening on unix:///usr/local/var/work/nginx-puma-rails/tmp/sockets/puma.sock
Use Ctrl-C to stop
```

先程指定したパスにあるUNIXドメインソケットファイルをListenするようになります。

ではnginxの開いてるlistenからアクセスして、railsにログが流れるか疎通確認してみます。
nginxが未起動なら起動してください。

ブラウザで`http://localhost:8080`にアクセスします。  
Railsアプリに次のようなアクセスログが流れたら疎通成功です。

```sh
Started GET "/" for 127.0.0.1 at 2020-03-02 00:54:43 +0900
   (0.6ms)  SET NAMES utf8mb4,  @@SESSION.sql_mode = CONCAT(CONCAT(@@sql_mode, ',STRICT_ALL_TABLES'), ',NO_AUTO_VALUE_ON_ZERO'),  @@SESSION.sql_auto_is_null = 0, @@SESSION.wait_timeout = 2147483
Processing by Rails::WelcomeController#index as */*
  Rendering vendor/bundle/ruby/2.6.0/gems/railties-6.0.2.1/lib/rails/templates/rails/welcome/index.html.erb
  Rendered vendor/bundle/ruby/2.6.0/gems/railties-6.0.2.1/lib/rails/templates/rails/welcome/index.html.erb (Duration: 7.3ms | Allocations: 311)
Completed 200 OK in 13ms (Views: 10.0ms | ActiveRecord: 0.0ms | Allocations: 1670)
```

### ファイルディスクリプタの罠
ここで一つ注意点があります。
前回の記事で1プロセスあたりが扱えるファイルディスクリプタ上限について設定しました。
1ワーカープロセス32個のファイルを扱える設定にしてあります。
この32とは1プロセスですが、一つのプロセスにスレッドを複数持つことができるため、スレッドが多すぎるとアプリによっては簡単に32個を超えてしまいます。
pumaのスレッド数は性能だけでなく上限も考慮が必要です。

現在のpuma設定では最小スレッド5,最大スレッド5、つまり常時5スレッド稼働しています。
つまり`32 ÷ 5 ≒ 6` 1スレッドあたり6個以上のファイル操作を行うと上限エラーが発生します。

### nginxのプロセス数とpumaのプロセス数

nginxはリバースプロキシサーバとして立てているため、プロセス数は単純化すれば窓口の数になります。
窓口の数が多すぎて、実際の作業場となるpumaのプロセス数が少ないとpumaサーバがボトルネックになります。
nginxとpumaのプロセス数のバランスが重要になってきます。

{% comment %}
Mac2台使ってnginx/pumaのプロセス数の最適なバランスについてパフォーマンス測定を行う。
{% endcomment %}

## Mac1台にnginxでWebサーバとPumaでアプリサーバを立てた

実際にMac1台にnginxでWebリバースプロキシサーバとPumaアプリサーバ立てることができました。  
Railsアプリを弄っているだけだとWebアプリがどういう仕組みで、そのうちRailsアプリはどこに配置されるのかイメージできなかったりします。
Mac1台でnginxでWebサーバとPumaでアプリサーバを立てることで、nginxからリバースプロキシで送信されたリクエストをpumaWebサーバが受信してRack通じてRailsアプリに処理を渡していることが分かります。

「Mac上でnginx」という本番では無意味な環境でも理解する上ではとても効率の良い環境です。

次回は[nginxのセキュリティ最低限設定](2020-02-26-web-nginx-getting-started-security-on-mac)周りについて説明します。

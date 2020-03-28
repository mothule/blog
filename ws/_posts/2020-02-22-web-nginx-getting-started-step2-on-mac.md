---
title: Macにnginxでゼロから丁寧に簡易なHTTPサーバを立てる
categories: web nginx
tags: web nginx mac
image:
  path: /assets/images/2020-02-22-web-nginx-getting-started-step2-on-mac/0.png
---
MacでWebサーバnginxを立ち上げるための入門記事シリーズ2回目です。

## ゼロから`nginx.conf`を書いてHTTPサーバを構築します

`nginx.conf.default`を一行ずつ読み解いて有無を決めながら簡易な**静的ブログ向け設定ファイルを作り上げていきます。**  
また、`nginx.conf.default`にはないけど関連するものも取り上げます。

上から一つずつ設定しており、それぞれの段階で実行が出来る状態になってありますが、**もし途中で躓いた場合は**
最後に`nginx.conf`の全容を載せてます。確認してみてください。


### インストールや起動方法などが分からない方は過去記事を
前回はWebサーバの簡単な基礎とnginxのインストールから立ち上げるまでを説明しました。  
▼前回の記事はこちらになります。  
{% post_link_text 2020-02-21-web-nginx-getting-started-step1-on-mac %}

## 最小設定でnginxのHTTPサーバを構築する

デフォルトで用意された`nginx.conf`には色々と書かれてて、やる気が萎えるのし分かりにくいです。  
なので、まずはこの雛形を削りながら最少設定でHTTPサーバを構築します。

削りきった最少でHTTPサーバを構築する設定ファイルは下記になります。

*nginx.conf*
```sh
events {
}

http {
  server {
  }
}
```
`events` `http` `server` の３つのブロックディレクティブだけでいけました。  
それ以外はデフォルト値として動いているようです。  
当然何も機能を設定していないので、ほぼ何もできないHTTPサーバです。  
ここまで削れればとっかかりやすいですね。

なおこれらブロックディレクティブのことはコンテキストと呼ぶようです。
**これらブロックディレクティブに1つも囲まれていない部分(インデントなし部分)をmainコンテキストと呼ぶようです。**

次は、デフォルト設定ファイル(`nginx.conf.default`)から一つずつ確認しながら先程の最少設定ファイルを埋めていきます。

## mainコンテキスト

前述したどのブロックディレクティブにも囲まれていない部分から見ていきます。  
`nginx.conf.default`ファイルの冒頭部分です。

```
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;
```

### userディレクティブ
workerプロセスを実行するユーザーとグループを設定します。

構文: `user user [group];`  
デフォルト: `nobody nobody`

デフォルトでもコメントアウトされてるように必須項目ではありません。

### worker_processesディレクティブ
workerのプロセス数を設定します。

構文: `worker_processes *number*|auto;`  
デフォルト: `worker_processes 1;`

最適値はCPUコア数、ストレージ数、負荷パターンなど多岐に渡ります。  
悩ましい場合はCPUコア数を推奨します。  
`auto`はそれを自動検出します。

今回はCPUコア数と同じ値にします。

```
worker_processes 4;
```

手元のMacのコア数はシステムレポートのハードウェア概要で確認できます。　　
システムレポートは `Spotlight検索` > `このMacについて.app` > `システムレポート` でたどり着けます。

### error_logディレクティブ
エラーログ出力先の設定します。

構文: `error_log file [level];`  
デフォルト: `error_log logs/error.log error;`

出力パスとログレベルを設定します。  
ログレベルは`debug, info, notice, warn, error, crit, alert, emerg`の8個です。  
例えばログレベルを`error`にすると`error, crit, alert, emerg`のレベルのログが出力されます。


エラーログは欲しいのでログレベルerrorでログを取ろうと思います。

```
error_log /usr/local/var/log/nginx/error.log error;
```

### pidディレクティブ
メインプロセスのプロセスIDの保存先を設定します。

構文: `pid file;`  
デフォルト: `pid logs/nginx.pid;`

公式のデフォルト値は↑ですが、Macだと `/usr/local/var/run/nginx.pid` にあります。  
デフォルト値でも問題ない場所にあるので特に指定はしないでいきます。

## eventsコンテキスト
```
events {
    worker_connections  10;
}
```
接続処理に影響するブロックディレクティブです。  

### worker_connectionsディレクティブ

ワーカープロセスで開くことができる同時接続の最大数を設定します。

構文: `worker_connections number;`  
デフォルト: `worker_connections 512;`

この接続とは、クライアントだけでなくすべての接続（プロキシサーバとの接続など）も含まれます。  
また、同時接続の実際の数が、`worker_rlimit_nofile` に依存します。  
せっかくなので `worker_rlimit_nofile` についても取り上げます。

### worker_rlimit_nofileディレクティブ
ワーカープロセスが開けるファイルの最大数(`RLIMIT_NOFILE`)の制限を設定します。  
メインプロセスを再起動せずに制限を増やすために使います。

通常1プロセスは`RLIMIT_NOFILE`の数以上のファイルは開けませんが、  
この値を設定することでその上限を超えたファイル数を処理できるようになります。

**なおworker_rlimit_nofileディレクティブはmainコンテキスト**で使えるディレクティブです。**

#### RLIMIT_NOFILEとは？
1プロセスが開けるファイルの上限です。  
確認するには`ulimit -n` で取れます。Macだとデフォルトは`256`しかないようです。


## 同時接続に関するパラメータを整理する

- `worker_rlimit_nofile`はworkerプロセスが扱えるファイル上限数(`RLIMIT_NOFILE`)を設定する
- `RLIMIT_NOFILE`は1プロセスが開けるファイル上限で`ulimit -n`で確認できる。デフォルトでは**256**しかないようです。
- OS全体で扱えるファイル数は`launchctl limit maxfiles`で確認できる。デフォルトでは**256**しかないようです。

`launchctl limit maxfiles`を変更は可能ですが、今回は目的ではないのでデフォルトのままにします。
ちなみに変えたい場合は「launchctl limit maxfiles」で検索するとたくさん出てくるのでそちらを参考にしてください。

### worker_rlimit_nofileの算出式
OS全体ファイル上限、プロセスファイル上限、workerプロセス数の３つからworkerプロセスの同時接続数を算出できそうです。

`workerプロセス数(worker_processes) * プロセスファイル上限(worker_rlimit_nofile) < OS全体ファイル上限(maxfiles)`

この式からプロセスファイル上限(worker_rlimit_nofile)を求めます。

**プロセスファイル上限(`worker_rlimit_nofile`) = OS全体ファイル上限(`maxfiles`) / workerプロセス数(`worker_processes`)**

この式に実際の値を当てはめます。

**256 / 4 = 64**

ただしMacでnginxを使う目的は学習や開発版で、nginx以外にも様々なアプリでファイルを開いていると思うので、その分を考慮します。
今回は半分にします。

**64 * 0.5 = 32**

```
worker_rlimit_nofile 32;
```

ということですね。

次に`worker_connections`ですが、1接続1ファイルオープンではなく少なくとも2つは消耗するようです。[参考](https://qiita.com/mikene_koko/items/85fbe6a342f89bf53e89#%E4%BD%95%E6%95%85-worker_connections-%E3%81%AE2%E5%80%8D%E3%81%AE%E5%80%A4%E3%81%8C-worker_rlimit_nofile-%E4%BB%A5%E4%B8%8B%E3%81%A7%E3%81%82%E3%82%8C%E3%81%B0ok)

上記記事からして `worker_connections` は `worker_rlimit_nofile` の 1/3 にしておけば余裕だと思います。

32 の 1/3 は10.6 きりよく10にします。

```
events {
  worker_connections 10;
}
```

同時接続は4*10で大体40といったところでしょうか。

実際のサーバ(Linux)では上限を結構あげたりすると思いますが、上限が上がったからといってその上限まで同時接続を捌けるとは限りません。あくまでもファイルオープンの限界値が増えただけであって、それ以外のCPU負荷やネットワーク負荷、DB負荷、メモリ負荷の問題は以前変わらずです。

## httpコンテキスト

```
http {
  include       mime.types;
  default_type  application/octet-stream;

  #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  #                  '$status $body_bytes_sent "$http_referer" '
  #                  '"$http_user_agent" "$http_x_forwarded_for"';

  #access_log  logs/access.log  main;

  sendfile        on;
  #tcp_nopush     on;

  #keepalive_timeout  0;
  keepalive_timeout  65;

  #gzip  on;
  server {

  }
}

```
HTTPサーバに関するブロックディレクティブです。

### includeディレクティブ

構文: `include file|mask;`  
デフォルト: `なし`

別ファイルや一致するファイル群を設定として読み込みます。  
取り込むファイルは、構文やディレクティブなども見てくれます。

デフォルトnginx.confの `include mime.types;` は `minem.types` という別ファイルをロードしているようです。

このファイルは`/usr/local/etc/nginx/`ディレクトリにあります。

```sh
$ ls -l | grep mime.types
-rw-r--r--  1 mothule  admin  5170  7  1  2018 mime.types
-rw-r--r--  1 mothule  admin  5231  2 20 03:07 mime.types.default
```

中身は `types` コンテキスト１つにたくさんのファイル・タイプの列挙がされてます。

`nginx.conf.default`の行末付近にも`include`は使われています。
```
include servers/*;
```
これは、サーバー毎の設定ファイルを外部ファイル化し、それをロードする場合に使います。

▼詳しくは同シリーズの記事をご確認ください。  
{% post_link_text 2020-02-26-web-nginx-getting-started-customize-on-mac ドメイン別設定ファイル置き場を用意する %}

### typesコンテキスト

レスポンスのMIMEタイプと拡張子名のマッパーです。  
追加時は小文字で必須です。  

デフォルトでほとんどのMIMEタイプをカバーできているのでこれはロードしたほうが良いです。

```
http {
  include mime.types;
}
```

### default_typesディレクティブ

レスポンスのデフォルトMIMEタイプを設定します。

構文: `default_types mime-type;`  
デフォルト: `default_types text/plain;`

`types`コンテキストで設定したMIMEタイプに当てはまらない場合は `text/plain` になり、レスポンスによってはやばいものもあると思うので、デフォルトenginx.conf同様`application/octet-stream` にしておきます。

```
http {
  default_type  application/octet-stream;
}
```

### access_logディレクティブ
アクセスログ出力先の設定します。

構文: `access_log file [format [buffer=size][gzip[=level]][flush=time][if=condition]]`  
デフォルト: `access_log logs/access.log combined;`

構文内の[]について説明すると、[]内の文字列や値は任意を表します。  
例えば`[buffer=size]` は無指定でも問題ありません。  
`[gzip[=level]]`だと無指定, gzip, gzip=level の3つとなります。

|引数|意味|
|---|---|
|file|出力先パス|
|format|1行ログの形式. 複雑な場合は後述するlog_formatの名前を指定します。|
|buffer=size|ファイルに書き込む前のバッファサイズ|
|gzip[=level]|圧縮して書き込む.levelは1~9で最大は9,デフォルトは1,ログは`zcat`で圧縮解除や読み取り可能です|
|flush=time|バッファをファイルに書き込むインターバル. この時間経過するとバッファをファイルに書き込みます|
|if=condition|条件付きログ. 条件が0または空文字列なら書き込まない|

#### if=condition例
次の例は$statusつまりHTTPコードが200番台,300番台ならログに書き込まない。
```
map $status $loggable {
    ~^[23]  0;
    default 1;
}

access_log /path/to/access.log combined if=$loggable;
```

### log_formatディレクティブ
ログのフォーマットを設定します。

構文: `log_fomat name [escape=deafult|json|none] string ...;`  
デフォルト: `log_format combined "...";`

構文内の|について説明すると、|で区切られた値のみを設定できることを表します。  
例えば`escape=default` `escape=json` `escape=none` の3パターンのみとなります。

string には通常変数とログ書き込み時のみ存在する変数を含めたフォーマットを設定できます。

|変数名|説明|
|---|---|
|$bytes_sent|クライアントへ送信したバイト数|
|$connection|接続シリアルNo|
|$connection_requests|接続を介した現在のリクエスト数|
|$msec|ログ書き込み時間(ミリ秒)|
|$pipe|リクエストがパイプライン化されたら`p`が書き込まれ、それ以外は`.`が書き込まれます。|
|$request_length|リクエスト行、ヘッダー、本文含むリクエストの長さ|
|$request_time|リクエスト処理時間(ミリ秒).リクエストを受けてから返すまでの時間|
|$status|HTTPステータス|
|$time_iso8601|ISO8601フォーマットに沿ったローカル時間|
|$time_local|一般的なログフォーマットに沿ったローカル時間|

ログのデフォルトは `$combined` が指定されており、これは次の形式になっています。

```
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```
実際にnginxサーバにアクセスして`access.log`を覗いてみると下記形式でログが書き込まれます。
```
127.0.0.1 - - [21/Feb/2020:18:43:21 +0900] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
```

{% comment %}
buffer,flush,gzipによるファイル書き込みのパフォーマンス測定について記事を書く
{% endcomment %}

### デフォルト設定はテストすると落ちる
前述したnginx.confだとテストが落ちます。  
理由はログのパスがnginxの場所からの相対パスとなっており、そこにフォルダが存在しないためです。  
また場所もhomebrewの管理下になり、一般的なログ場所とは異なります。  
ログのパスは下記のように絶対パスで指定します。

```
http {
  access_log  /usr/local/var/log/access.log  main;
}
```

### sendfileディレクティブ
`sendfile()` の仕様有無を設定します。

構文: `sendfile on|off;`  
デフォルト: `sendfile off;`

#### sendfileとは？
ファイルディスクリプター間のデータ転送関数。read/write組み合わせより効率が良い。  
ただ、動作不安定や静的ファイルが更新不備など不安定な評判もある。

とりあえず使ってみて動作不安定な気があればここを無効化します。

```
http {
  sendfile on;
}
```

### tcp_nopushディレクティブ
`TCP_NOPUSH`ソケットオプション または `TCP_CORK`オプションの使用有無を設定します。  
FreeBSDでは`TCP_NOPUSH`でLinuxでは`TCP_CORK`を使います。  
このディレクティブは`sendfile`が有効時のみ働きます。

構文: `tcp_nopush on|off;`  
デフォルト: `tcp_nopush off;`

これが有効だと、レスポンスヘッダーとファイルをまとめて送信するため、パケット数を抑え効率よくなります。

今回は`sendfile`を有効化しており、`tcp_nopush`により高速化が見込めるので、ここも有効化します。

```
http {
  tcp_nopush on;
}
```

{% comment %}
sendfile,tcp_nopushによるパフォーマンス測定の記事を書く
{% endcomment %}


### keepalive_timeoutディレクティブ
keep-aliveによる接続時間を設定します。

構文: `keepalive_timeout timeout [header_timeout];`  
デフォルト: `keepalive_timeout 75s;`

`[header_timeout]`は任意オプションです。  
これはMozillaおよびKonquerorによって認識されます。 MSIEは約60秒でキープアライブ接続を自動的に閉じます。

#### keep-aliveとは？

簡易説明すると、HTTPはリクエスト毎にサーバ／クライアント間で接続を確立し、レスポンスを返します。
レスポンスを返したら接続を切るため、リクエストが大量にあれば、たとえ同じクライアントだとしてもそれだけ接続／切断を繰り返すことになります。    
これでは無駄なので、レスポンス送信後すぐに切断せずにしばらく待つことで、次リクエストの接続処理スキップすることで効率よくなります。

詳細は[こちら](https://www.atmarkit.co.jp/ait/articles/1605/11/news030_3.html)を参考にしてください。


keep-aliveはタイムアウト値が適切であれば通信処理を効率良く出来るため、入れておきます。

```
http {
  keepalive_timeout: 60s;
}
```

{% comment %}
keep-aliveによるパフォーマンスの記事を書く
{% endcomment %}



### gzipディレクティブ

`gzip`コマンドで圧縮の使用有無を設定します。

構文: `gzip on|off;`  
デフォルト: `gzip off;`

圧縮することで通信量を減らせます。しかしトレードオフとして圧縮に必要なCPUリソースを消費します。また解凍(=展開)が必要になり解凍はクライアント側が行います。つまりクライアント側にも解凍に必要なCPUリソースを消費します。

今回はonにしてみます。  
ただし、gzipはon/offの二択ではなく、onの場合に細かいパラメータ設定が可能となっています。  
せっかくなのでgzipのパラメータ設定用ディレクティブもまとめます。

```
http {
  gzip on;
}
```

{% comment %}
gzipによるパフォーマンス測定の記事を書く
{% endcomment %}

### gzip_buffersディレクティブ

レスポンス圧縮に使うバッファサイズと数を設定します。

構文: `gzip_buffers number size;`  
デフォルト: `gzip_buffers 32 4k|16 8k;`

デフォルトは1メモリページと同等になってます。そのためプラットフォームに応じて **32個 4kBytes** か **16個 8kBytes** のいずれかです。

ここはバッファサイズがメモリページを横断すると、メモリ操作によるコストがかさむのでデフォルトのままでよいと思います。

### gzip_comp_levelディレクティブ
圧縮レベル(1~9)を設定します。小さいほど圧縮率は下がります。

構文: `gzip_comp_level level;`  
デフォルト: `gzip_comp_level 1;`

圧縮は線形比例ではありません。なので**9が1より9倍圧縮率が高くなることはありません。**  
圧縮レベル別のパフォーマンスは[こちらの記事](https://qiita.com/nmatayoshi/items/9884eea9b0633c1c1f6c)が参考になります。

ここは1か2がコスパよいのでデフォルトと同じ1のままにします。

### gzip_disableディレクティブ

いずれかの正規表現に一致する`User-Agent`には`gzip`圧縮を無効に設定します。

構文: `gzip_disable regex ...;`

今回は特に除外はしないので、未設定にします。

### gzip_http_versionディレクティブ

レスポンス圧縮に必要な最小HTTPバージョンを設定します。

構文: `gzip_http_version 1.0 | 1.1;`
デフォルト: `gzip_http_version 1.1;`

最近は1.1は当たり前なので、これはデフォルトのままにします。

### gzip_min_lengthディレクティブ

レスポンスを圧縮する最小サイズを設定します。この最小サイズは`Content-Length`が使われます。

構文: `gzip_min_length length;`
デフォルト: `gzip_min_length 20;`

これは無圧縮のほうがコスパ良いサイズについて設定します。

ここの値は通信帯域やパケットサイズに関係します。デフォルトは小さすぎるので1k(1024)にします。

```
http {
  gzip_min_length 1024;
}
```

{% comment %}
最小サイズのベストプラクティスを記事にする
{% endcomment %}

### gzip_proxiedディレクティブ

リクエスト／レスポンスに応じてプロキシされたリクエストのレスポンスも圧縮するかを設定します。  
つまり、プロキシから来たリクエストの結果(レスポンス)を圧縮するかどうかを設定します。

パラメータは複数指定が可能です。

構文: `gzip_proxied off|expired|no-cache|no-store|private|no_last_modified|no_etag|auth|any ...;`  
デフォルト: `gzip_proxied off;`

nginxはリバースプロキシ機能を持っており、そこで圧縮したレスポンスを内部ネットワークに応答することもできます。  
その場合は既に圧縮したレスポンスに関しては何もする必要がありません。

プロキシ経由かどうかは`Via`ヘッダーフィールドの存在で確認できます。

パラメータが多いので表にします。

|パラメータ|説明|
|---|---|
|off|プロキシされたリクエストのレスポンスの圧縮を無効|
|expired|期限切れ`Expires`があれば有効|
|no-cache|`Cache-Control`に`no-cache`があれば有効|
|no-store|`Cache-Control`に`no-store`があれば有効|
|private|`Cache-Control`に`private`があれば有効|
|no_last_modified|`Last-Modified`が**なければ**有効|
|no_etag|`ETag`が**なければ**有効|
|auth|`Authorization`があれば有効|
|any|プロキシされたリクエストのレスポンスの圧縮を有効|

複数指定は、スペース区切りで設定します。

今回はリバースプロキシは介さないのでデフォルト(`off`)のままにします。

### gzip_typesディレクティブ

圧縮対象となるMIMEタイプを設定します。  
なお`text/html`は常に圧縮されます。また `*`を指定すると全てのMIMEに一致します。

構文: `gzip_types mime-type ...;`
デフォルト: `gzip_types text/html;`

今回は、CSSやJavascript、JSONも圧縮対象にします。

```
http {
  gzip_types text/css text/javascript application/json;
}
```

### gzip_varyディレクティブ
圧縮ディレクティブ(`gzip`, `gzip_static`, `gunzip`)が有効であれば、
`Vary: Accept-Encoding`ヘッダの挿入の有無を設定します。

構文: `gzip_vary on | off;`
デフォルト: `gzip_vary off;`

これは圧縮可能と不可能の２クライアントから同一リソースにアクセスがあった場合に起きる問題の回避として使います。
詳しくは[こちらの記事](https://qiita.com/cubicdaiya/items/09c8f23891bfc07b14d3)が参考になります。

## serverコンテキスト
バーチャルサーバの設定をします。

少し長いですが`nginx.cnf.default`から`server`を抜粋したものが下記です。

```
server {
  listen       8080;
  server_name  localhost;

  #charset koi8-r;

  #access_log  logs/host.access.log  main;

  location / {
      root   html;
      index  index.html index.htm;
  }

  #error_page  404              /404.html;

  # redirect server error pages to the static page /50x.html
  #
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
      root   html;
  }

  # proxy the PHP scripts to Apache listening on 127.0.0.1:80
  #
  #location ~ \.php$ {
  #    proxy_pass   http://127.0.0.1;
  #}

  # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
  #
  #location ~ \.php$ {
  #    root           html;
  #    fastcgi_pass   127.0.0.1:9000;
  #    fastcgi_index  index.php;
  #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
  #    include        fastcgi_params;
  #}

  # deny access to .htaccess files, if Apache's document root
  # concurs with nginx's one
  #
  #location ~ /\.ht {
  #    deny  all;
  #}
}
```

### listenディレクティブ
サーバがリクエストを受け付けるか設定します。

構文:
1. listen address
```
listen address[:port] [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number]
 [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter]
 [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
```

2. listen port
```
listen port [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number]
 [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind]
 [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
```

3. listen unix:path
```
listen unix:path [default_server] [ssl] [http2 | spdy] [proxy_protocol] [backlog=number]
[rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind]
[so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
```

デフォルト: `listen *:80 | *:8000;`

パターンは大きく3つに分かれており、オプションも膨大です。

|パラメータ|説明|
|---|---|
|address|IPまたはホストネーム|
|:port|ポート番号|
|default_server|どのserverにもマッチしない場合はこのオプションがついたサーバに振り向けます|
|ssl|SSL接続必須指定|
|http2|HTTP/2接続 spdyと同時指定はできません|
|spdy|SPDY接続 http2と同時指定はできません|
|proxy_protocol|PROXY protocol必須指定|
|setfib=number|FIB(SO_SETFIB)を設定,FreeBSD限定|
|fastopen=number|TCP Fast Openを有効にし、3ウェイハンドシェイク未完了の接続キューの最大長|
|backlog=number|保留中接続キューの最大長.接続要求が最大長超えると`ECONNREFUSED`エラーが起きる.FreeBSD,DragonFly BSD, macOSは-1、その他は511.詳細は[こちら](https://kazuhira-r.hatenablog.com/entry/2019/07/10/015733)|
|rcvbuf=size|受信バッファサイズ(`SO_RCVBUF`)|
|sndbuf=size|送信バッファサイズ(`SO_SNDBUF`)|
|accept_filter=filter|受信フィルタ(SO_ACCEPTFILTER)の名前。FreeBSDとNetBSD5.0+のみ|
|deferred|Linuxで遅延accept()`TCP_DEFER_ACCEPT`を使用有無.詳細は[こちら](https://blog.yuuk.io/entry/2013/07/21/022859)|
|bind|指定された`address:port`ペアに個別で`bind()`する。hoge:80,fuga:80,*:80の3つlistenがあったら,*:80にだけ`bind()`する。注意点は接続受付先アドレスの決定に`getsockname()`がが使われる。`setfib`, `backlog`,`rcvbuf`, `sndbuf`, `accept_fileter`, `deferred`, `ipv6only`,`so_keepalive`が使われたら、渡された`address:port`は個々に常に`bind()`する|
|ipv6only=|`IPV6_V6ONLY`を経由してワイルドカードアドレス[::]でlistenしてるIPv6ソケットがIPv6接続だけかIPv4接続の両方を受け付けるかを決める。パラメータは`on`と`off`でデフォルトは`on`|
|reuseport|カーネルが接続をワーカープロセス間に分散して、各ワーカープロセスに`SO_REUSEPORT`を使って個々のlistenソケットを生成指示する。Linux3.9+とDragonFly BSDのみ。|
|so_keepalive=on\|off\|[keepidle]:[keepintvl]:[keepcnt]]|TCP keepaliveの挙動設定する。パラメタ省略するとOS値が設定される。`on`だと`SO_KEEPALIVE`がソケットに対し`on`になる。 `off`だと`SO_KEEPALIVE`に対し`off`となる。Linux2.4+, NetBSD 5+ FreeBSD 9.0-Stableでは、`TCP_KEEPIDLE`,`TCP_KEEPINTVL`,`TCP_KEEPCNT`を使ってkeepaliveをサポートする。省略した場合はOSのデフォルト値が使われる。|

今回はその他のパラメータは今回は使わず、3030ポートを開こうと思います。

```
server {
  listen 3030;
}
```


**もし既にポートが使われている場合**
次のエラーが出力されます。
```sh
nginx: [emerg] bind() to 127.0.0.1:8080 failed (48: Address already in use)
nginx: [emerg] bind() to [::1]:8080 failed (48: Address already in use)
```

### server_nameディレクティブ
バーチャルサーバの名前を設定します。

構文: `server_name name ...;`  
デフォルト: `server_name "";`

#### ワイルドカード
サーバ名には最初と最後の名前にワイルドカード(`*`)が使えます。
```
server_name example.com *.example.com api.example.*;
```
ちなみに`example.com`と`*.example.com`は`.example.com`に結合できます。

#### 正規表現  
名前の前にチルダ(`~`)をつけて
```
servername www.exmaple.com ~^www\d+\.example\.com$;
```
のように正規表現を使えます。

またキャプチャも使えます。
```
server {
  server_name ~^(www\.)?(.+)$;
  location / {
    root /sites/$2;
  }
}
```

名前付きキャプチャは変数として使えます。
```
server {
  server_name ~^(www\.)?(?<domain>.+)$;

  location / {
    root /sites/$domain;
  }
}
```

ちなみに `$hostname`にはマシンのホスト名が入ります。

今回はローカルホストにサーバを立てるのでlocalhostを使います。
```
server {
  server_name localhost;
}
```

### charsetディレクティブ
指定した文字セットを`Content-Type`レスポンスヘッダフィールドに追加します。

構文: `charset charset | off;`
デフォルト: `charset off;`

注意点：`source_charset` と違うと変換が発生する。

今回は無難に`utf-8`で行きます。

```
server {
  charset utf-8;
}
```

### access_logディレクティブ

このディレクティブは前述しているため基本説明は省略します。

追記としては、このサーバに対するアクセスのみログが記録されます。

今回はこのサーバだけのアクセスログを残しておきます。

```
server {
  access_log /usr/local/var/log/nginx/localhost.access.log  main;
}
```

formatは既に定義済みの`main`を使います。

#### open() 2: No such file or directory が出る場合

```
nginx: [emerg] open() "/usr/local/var/log/enginx/localhost.access.log" failed (2: No such file or directory)
```
よく見ると分かりますが、パスが間違ってます。

### error_pageディレクティブ

エラーページとエラーコードのマッピングを設定します。  
`uri`には変数を使えます。

構文: `error_page code ... [=[response]] uri;`

例えば404と500番台でエラーページを用意してるなら

#### GETに変更してリダイレクト
```
server {
  error_page 404 /404.html;
  error_page 500 502 503 504 /50x.html;
}
```

と設定すると、ステータスコードと一致するページにHEAD以外のリクエストを全て`GET`に変更して、内部的にリダイレクトします。

#### 応答コードの変更
例えば404ではなく200にしてEmtpy pageを出したいなら
```
server {
  error_page 404 = 200 /empty.html;
}
```
のように、応答コードを変更できます。

#### 応答ページを別サーバに渡す
例えばPHPなどで404を返すページがある場合
```
server {
  error_page 404 = 404php;
}
```
のように設定できます。

#### 別locationコンテキストにエラー処理を渡す
内部リダイレクトでURIとメソッド変更させない場合は

```
server {
  location / {
    error_page 404 = @fallback;
  }
  location @fallback {
    proxy_pass http://backend;
  }
}
```
のように別locationに移すことができます。

今回は404は専用ページを用意する設定にします。

```
server {
  error_page 404 /404.html;
}
```

## locationコンテキスト

リクエストURIに応じて構成を設定する。

構文:
- `location [ = | ~ | ~* | ^~ ] uri { ... }`
- `location @name {... }`

- "%XX"形式エンコードされてテキストはデコード
- 相対パス`.`と`..`の参照は解決
- ２つ以上続くスラッシュ`/`は1つに差し替え

その後、正規化されたURIに対してマッチングが実施される。

**プリフィック文字**と**正規表現** の２つで定義できる

**正規表現のオプション**

- 先頭文字が`~*`修飾子なら大文字小文字を区別しないマッチング
- 先頭文字が`~`修飾子なら大文字小文字を区別するマッチング

### locationの検索フロー

指定されたリクエストに合致するlocationを見つけるために、

1. nginxはまずプリフィックス文字列を使って定義されるlcoationを調べます
1. それらの中で、一番長くマッチするプリフィックスlocationが選択され記憶されます
   - 記憶したプリフィックスlocationに`^~`修飾子があれば以降の正規表現チェックはしません。
   -  完全一致`=`修飾子で一致したら検索は終了します
1. 設定ファイルの中に現れる順番で正規表現を調べます
   1. 正規表現の検索は一番最初にマッチした時点で終了します
   1. 正規表現にマッチしなかったら、前に記憶されたプリフィックスlocationが使われます

完全一致は指定URIのアクセスが高頻度の場合に適用すると高速化します。

### 検索フロー例

```
location = / {
  # A
}
location / {
  # B
}
location /documents/ {
  # C
}
location ^= /images/ {
  # D
}
location ~* \.(gif|jpeg|jpg|png)$ {
  # E
}
```
というlocationがあった場合、

- `/` はAにマッチ
- `/index.html` はBにマッチ
- `/documents/document.html` はCにマッチ
- `/images/1.gif` はDにマッチ
- `/documents/1.jpg` はEにマッチ

というマッチング結果となります。

### 名前付きlocation
`@`プレフィックスをつけることで名前付きとして定義できます。  
リクエストのリダイレクトに使います。

### パーマネントリダイレクト
locationが末尾が`/`で終わる定義で、設定が `proxy_pass`, `fastcgi_pass`, `uwsgi_pass`, `scgi_pass`, `memcached_pass`, `grpc_pass`の1つで処理された場合は、特別処理がされます。
同じURIだが最後の`/`がないリクエストの応答は、`/`がリクエストのURIに追加されて301として返される。

### rootディレクティブ

ルートディレクトリを設定する。

構文: `root path;`
デフォルト: `root html;`

例えば次の設定の場合
```
location /i/ {
  root /data/wwww;
}
```
`/i/top.png`リクエストは、`/data/www/i/top.png`が応答します。

`path` には `$document_root`と`$realpath_root`を除く変数が使えます。

ルートディレクトリの値にURIを追加するだけでファイルパスが構築されます。
URIを変更する場合は、`alias`ディレクティブを使います。

今回はトップページ、記事ページ、画像の3locationを用意します。

```
location = / {
  root /usr/local/var/www;
}
location /articles/ {
  root /usr/local/var/www;
}
location ~* \.(gif|jpg|jpeg|png)$ {
  root /usr/local/var/www/images;
}
```

### aliasディレクティブ
指定locationの置き換えを設定します。

構文: `alias path;`

例えば次の設定の場合
```
location /i/ {
  alias /data/www/images/;
}
```
`/i/top.png`リクエストは、`/data/www/images/top.png`が応答します。

もしlocationがディレクティブの最後の場所に一致する場合
```
location /images/ {
  alias /data/www/images/;
}
```
この場合は、`root`ディレクティブを使ったほうがいいです。
```
location /images/ {
  root /data/www;
}
```

### indexディレクティブ

indexとして使われるファイル定義を設定します。

`file`には変数を使えます。
ファイルは設定順でチェックします。

構文: `index file ...;`
デフォルト: `index index.html;`

**注意点:**

`index`を使うと内部リダイレクトが発生し、想定外のlocationで処理されることがあります。

```
location = / {
  index index.html;
}
location / {
  # B
}
```

この場合、`/` リクエストは`/index.html`として、2番目のlocation(B)で処理されます。

今回はトップページのみ指定します。

```
location = / {
  root /usr/local/var/www;
  index index.html;
}
```

### denyディレクティブ
指定ネットワークやアドレスのアクエス拒否を設定します。

構文: `deny address | CIDR | unix: | all;`

`unix:`の場合は全てのUNIXドメインソケットのアクセス拒否になります。

特定のファイルに対してアクセス拒否したい場合などに使います。  
今回は特に拒否したいファイルなどはないため設定しません。

## 出来上がった設定ファイル(nginx.conf)

この記事を通して`nginx.conf.default`から必要なディレクティブのみを設定したものになります。

```
worker_processes  4;

error_log /usr/local/var/log/nginx/error.log error;

worker_rlimit_nofile 32;

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


  server {
    listen 8080;
    server_name localhost;

    charset utf-8;

    access_log /usr/local/var/log/nginx/localhost.access.log  main;

    error_page 404 /404.html;

    location = / {
      root /usr/local/var/www;
    }

    location /articles/ {
      root /usr/local/var/www;
    }

    location ~* \.(gif|jpg|jpeg|png)$ {
      root /usr/local/var/www/images;
    }
  }
}
```

### ファイル配置図

*/usr/local/var/www* 配下は次のように配置してます。
```$ tree
.
├── 404.html
├── articles
│   └── 1.html
├── images
│   └── nginx.png
└── index.html
```

- `localhost:8080`にアクセスすると `index.html`が返ってきます。
- `localhost:8080/articles/1.html` にアクセスすると `1.html` が返ってきます。
- `localhost:8080/nginx.png`にアクセスすると `nginx.png`が返ってきます。
- `localhost:8080/hoge`にアクセスすると `404.html`が返ってきます。

## Macにnginxでゼロから丁寧に簡易なHTTPサーバを立てる

今回は、とても単純なブログサーバをnginxで立ち上げました。前回と違い結構なボリュームでした。  
一つずつディレクティブを確認したためこのボリュームになりました。  
しかしこの部分がnginxでもっとも基礎の中でも重要な基礎となります。  
ここを理解することで次の動的なアプリサーバの構築へと繋げられます。

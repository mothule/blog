---
title: CentOS8上にnginxとpumaとRailsを手作業で構築した後に手動でデプロイする
description: LinuxディストリビューションCentOS8上にWebサーバであるnginxとRackサーバであるPuma、そしてWebアプリサーバとなるRailsをAnsibleやCapistranoを使わずに構築して、コードデプロイする流れを説明します。
categories: ruby rails
tags: ruby rails web nginx linux centos
image:
  path: /assets/images/2021-02-19-ruby-rails-build-nginx-puma-rails-on-centos/eyecatch.png
---
Ansibleでインフラ構築したり、Capistranoでデプロイが自動化したり、内部のフローがイメージつかないので、それらを使わずに手動で構築してデプロイを試してみました。


## サーバー構築やアプリのデプロイの内部イメージついてますか？
インフラ構築はAnsible、RailsアプリのデプロイはCapistranoを使うのが定番です。
しかし、内部を知らずにそれら使うと、実際のインフラ構築やデプロイのオペレーションがイメージできず頭がついてこれません。
自身の中でフローをイメージできることは、AnsibleやCapistranoを使うときに最適な処理を構築には必須です。

そのため、この記事ではAnsibleやCapistranoを使わない方法でインフラ構築やデプロイ作業を行いました。
具体的にはそれぞれ次の方法で実現します。

- Ansibleを使わずnginx × Puma × Rails環境を手作業で構築
- Capistranoを使わずgitやSSHを使ってデプロイ

### 対象読者
Mac上でrbenvでRuby環境を構築し、Railsアプリを作ったことがあるが、
Linuxサーバにデプロイをしたことがない、またはデプロイはあるがイマイチ腹落ちできていない。

### この記事のゴール
Macで作ったRailsアプリをCentOS8上に展開、起動できるようにする。
コード更新を手作業で行えるようにする。

### この記事でやらないこと
インフラ構築とデプロイがテーマなので、HTTPS対応とpuma_worker_killerは対応していません。


## Linux(CentOS)サーバの構築は省略
この記事ではVPS上にCentOS8をインストールした後の内容となっています。
CentOS8のセットアップについては「{% post_link_text 2021-02-19-linux-centos-centos8-setup-secure-server %}」にまとめてあります。
またCnetOS上のRuby環境については「{% post_link_text 2021-02-19-linux-centos-build-ruby-env-on-centos %}」にまとめてあります。

なお、今回はMySQLサーバは別サーバ上に立てていますが、記事内容には直接関わらないため、同一サーバにインストールしても問題ないはずです。
ちなみにCentOS上にMySQLサーバ構築については「{% post_link_text 2021-02-19-db-mysql-install-mysql8-on-centos8 %}」にまとめてあります。


## 構築するサーバ構成
今回構築するサーバ構成を簡単に表すとこうなります。

nginx → puma → rails → mysql

- nginxはリバースプロキシとして動かす
- nginx と puma間はUNIXドメインソケットで通信する
- rails と mysql間はTCP/IPで通信する
- railsアプリのデプロイはサーバにSSHで接続して作業する


## 大まかなフロー

1. Railsアプリ用意
2. サーバにGit環境用意
3. サーバにPuma×Railsをデプロイ
4. nginxのリバースプロキシ設定
5. Pumaのデーモン化
6. コードデプロイ

## Railsアプリを用意する
まずはMac上に機能は何でもいいのでRailsアプリを用意します。
あまり凝ったアプリだと躓いたときに原因特定に時間がかかるので、トップページ1つあるだけの簡単なアプリがおすすめです。

用意したらGitHubにプッシュします。
publicレポジトリでも構わないですが、万が一セキュアな情報を誤ってpushするとリスクもありますし、実際の運用を考えるとprivateレポジトリにします。

## サーバにGit環境用意
最初はサーバとGitHub間のssh通信ができるようにSSH用のキーを作成します。
普段MacからGitHub上のprivateレポジトリをクローンしてるように、サーバにも同等の機能をもたせます。

まずサーバにSSH接続したら`ssh-keygen`で公開鍵と秘密鍵を作成します。
作成したら公開鍵をコピーして、[GitHubのSSH keys]([https://github.com/settings/keys](https://github.com/settings/keys))に追加します。

```sh
$ ssh-keygen
$ cat ~/.ssh/id_rsa.pub
```

最近のバージョンであれば鍵長はデフォルト値でも十分だと思いますが、そこは自己責任でお願いします。

GitHubに公開鍵の登録が終わったら疎通確認としてSSH接続をテストします。
正しくできていれば接続成功の表示がされます。

```ruby
$ ssh -T git@github.com
Hi hogehoge! You have successfully authenticated, but GitHub does not provide shell access.
```

## サーバにPuma×Railsをデプロイ
サーバ上にGit環境が整ったら、GitHubからPrivateレポジトリのコードをダウンロードできるようになります。
事前にプッシュしておいたRailsアプリをダウンロードして、サーバー起動していきます。

### GitHubのコードをサーバへClone(クローン)
`git clone`でコードをダウンロードします。なお、コードの展開場所ですがネット記事だと`/var/www/`をよく見かけますが、現場ではユーザのホームディレクトリ上に展開してたりとマチマチです。

今回はホームディレクトリ上に`app`フォルダ作ってそこの中に展開します。
下記コードのGitHubアカウント名やレポジトリ名は適宜差し替えてください。

```sh
$ mkdir ~/app
$ cd ~/app
$ git clone git@github.com:your_github_name/repo_name.git
```

### bundle installでgemをインストール
ダウンロード完了したら、ローカル同様`bundle install`でgemを取得します。

```sh
$ bundle config set --local path "vendor/bundle"
$ bundle install -j4
```

#### mysql2エラーが起きた場合
もしこのときmysql2 gemでエラーが出た場合は、サーバー上にMySQLに関するヘッダーファイルがないのかもしれません。`mysql-devel`をインストールして再実行してみてください。

```sh
$ sudo yum -y mysql-devel
```

### ローカルのRailsアプリからmaster.keyをサーバーへコピー
ローカル環境でproduction環境を実行しても気づきにくいかと思いますが、production環境では`master.key`が必要です。しかし`master.key`はGitHubにプッシュされないようになっています。なのでサーバに`master.key`を渡す必要があります。この情報が渡っていないとRailsは暗号ファイルを復号できずproduction環境を実行できません。

```sh
$ scp master.key user_name@server_address:~/app/myapp/config/
```

### アセットのプリコンパイル実行
production環境では`assets`フォルダ内のリソースは`public/assets`へ事前コンパイルが必要です。

```sh
$ RAILS_ENV=production bundle exec rake assets:precompile
```

### CentOS8 → Puma → Rails間のアクセス疎通確認
PumaはRackサーバ機能も兼ねているため、nginxなしでもアクセス可能です。
なのでnginxを立てる前にPuma×Railsだけでアプリを立ち上げて問題なく疎通できるか確認をとっておきます。

ここをおろそかにしてnginxの構築へ進むと、もし動かない場合どの部分が原因で動かないのか原因特定範囲が広くなります。

なお、単純に`rails s`だと外部からのアクセスできない状態なので、`-b 0.0.0.0`も一緒に渡します。

```sh
$ bundle exec rails s -b 0.0.0.0 -e production
```

Railsアプリが起動したら、ブラウザでルートページにアクセスして正常にページが表示されるか確認します。
URLは`サーバのIPアドレス:Pumaで設定してるポート番号`になります。
`routes.rb`でroot設定していない場合は、存在するエンドポイントにアクセスして疎通確認してください。

#### Pumaで設定してるポート番号
Pumaで設定してるポート番号は、`~/app/myapp/config/puma.rb`に定義されています。
デフォルトのままであれば次のように定義されているはずです。

```ruby
# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port        ENV.fetch("PORT") { 3000 }
```

## nginxのリバースプロキシ設定
Puma × Railsが無事動くことが確認できたら、次はnginxを前段に配置します。
具体的にはPumaのlistenをポートからUNIXドメインソケットに変更して、PumaのlistenをポートからUNIXドメインソケットに変更します。
こうすれば、nginxのリクエストをPumaのソケットに流れるようになります。
まずはPuma側から対応します。

### config/puma.rbのlistenをポートからUNIXドメインソケットに変更
前述したPumaの設定ファイル(`~/app/myapp/config/puma.rb`)では、ポート番号でlistenする設定になっています。

```ruby
port        ENV.fetch("PORT") { 3000 }
```

これをUNIXドメインソケットに変更します。
**このときポート設定は必ずコメントアウトか削除してください。**
ポート設定が残ったままUNIXドメインソケット設定を追記してもポート設定が優先されます。

bindでUNIXドメインソケットのファイル場所を設定します。
Pumaが起動するとこのパス先にソケットファイルが作成されます。

```ruby
# port        ENV.fetch("PORT") { 3000 }
bind "unix://#{Rails.root}/tmp/sockets/puma.sock"
```

この状態でRailsアプリを実行すると、listen先がpuma.sockに変わります。
またソケットファイルも作成されます。

### nginxのリクエストをPumaのUNIXドメインソケットに流す
次はnginx側を変更します。
`/etc/nginx/nginx.conf`の`http`コンテキスト内に次のコードを追記します。

`nginx.conf`に直接アプリ固有の設定を記入せず`include`ディレクティブを使ってアプリ毎に設定ファイルを分離して管理する方法がありますが、今回は省略します。

```ruby
http {
  # ここから
  upstream puma {
    server unix:///home/your_user_name/app/your_app_name/tmp/sockets/puma.sock;
  }
  server {
    listen 3000 default_server;
    server_name puma;
    location / {
      proxy_read_timeout 300;
      proxy_connect_timeout 300;
      proxy_redirect off;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_pass http://puma;
    }
  }
  # ここまでを追加する
}
```
`server`ディレクティブに渡すパスは、Pumaのsocketファイルのパスを指定してください。

nginxが起動中なら変更を反映させます。

```sh
$ systemctl reload nginx
もしくは
$ nginx -s reload
```

nginxの基礎に関しては「{% post_link_text 2020-02-21-web-nginx-getting-started-step1-on-mac %}」にまとめてあります。

### nginx起動
nginxを立ち上げます。
2行目で自動起動を有効化します。

```sh
$ systemctl start nginx
$ systemctl enable nginx
```

### nginx → Puma → Rails間のアクセス疎通確認
ここまで設定すれば、ポート3000にアクセスしたらnginxがPumaにリクエストを上流しRailsアプリへ到達するようになっています。
それを確かめるために疎通確認します。

`http://your-server-ip-address:3000`へアクセスしてRailsアプリのルートページが表示されれば疎通成功です。

もしうまく行かない場合はログを確認することで原因追求に役立ちます。ログは`/var/log/nginx/` にアクセスログとエラーログがあります。

### ログにconnect() to puma.sockでPermission deniedが出る場合

502 Bad Gatewayが出る場合は、nginxからPumaへのつなぎでエラーが出ている可能性があります。

```sh
connect() to unix:///home/mothule/app/rails_sample/tmp/sockets/puma.sock failed (13: Permission denied)
```

nginxからpuma.socketへの権限がない場合このエラーが出ます。
nginxを誰が実行してるか確認します。

```sh
$ ps aux | grep nginx
root       22126  0.0  2.1 120088 10276 ?        Ss   15:49   0:00 nginx: master process nginx
nginx      22131  0.0  1.9 152720  9088 ?        S    15:49   0:00 nginx: worker process
root       22170  0.0  0.2  10284  1056 pts/1    R+   15:53   0:00 grep --color=auto nginx
```

`nginx`ユーザーで動いています。実行ユーザーがRailsアプリを動かしているユーザーと同じでないとファイルの編集権限が足りず権限エラーになります。
なのでnginxの実行ユーザーをRailsアプリを動かしているユーザーに変更します。

nginxの実行ユーザーの変更は`/etc/nginx/nginx.conf`の`user`を変更します。

```
# user nginx
user your_user_name
```

リロードも忘れずに行います。

```sh
$ sudo nginx -s reload
または
$ systemctl reload nginx
```

## Railsアプリのデーモン化
CentOS上にnginx/puma/railsが動くようにはなりました。
しかし、サーバにはSSH接続しており、この状態でRailsを実行してるので、SSHが終了すると、Railsアプリも終了してしまいます。


本番環境でそれだと困るので、SSHが終了しても動くようにPumaをデーモン化する必要があります。
puma.rbをいじってデーモン化します。また本番のみUNIXドメインソケット通信にし、それ以外ではnginxを介さずPuma単体でポートを開いて処理できるようにします。

次のコード`puma.rb`の全容です。
デフォルトコードから余計なコメント等を削除し、本番時のみデーモン化させるコードを追加したものです。

```ruby
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

rails_env = ENV.fetch('RAILS_ENV') { 'development' }
if rails_env == 'production'
  # socket
  bind "unix://#{Rails.root}/tmp/sockets/puma.sock"

  rails_root = Rails.root
  state_path File.join(rails_root, 'tmp', 'pids', 'puma.state')
  stdout_redirect(
    File.join(rails_root, 'log', 'puma.log'),
    File.join(rails_root, 'log', 'puma-error.log'),
    true
  )
  daemonize

else
  # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
  port        ENV.fetch("PORT") { 3000 }
end

# Specifies the `environment` that Puma will run in.
environment rails_env

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
```

- state_path
    - pumaの状態を表したファイルで、pumactlが使います。
- stdout_redirect
    - STDOUTとSTDERRを指定ファイルにリダイレクトします。
    - 最後のBoolean型は出力を追加するかどうかです。デフォルトはfalseです。
- daemonize
    - pumaをデーモン実行するかどうか

## コードデプロイ
最後にコード変更を反映させる方法です。
nginx/puma/railsが既に動いている状態からコードを反映させます。

変更後のコードはGitHubに上がっているので、git pullでとってくることでサーバ上のコードを変更します。
その後の反映ですが、`bundle exec pumactl restart` をすることでpumaが再起動してくれて、コードが反映されます。

### PumaにおけるRailsアプリの起動方法
PumaをRackサーバに使う場合Railsアプリを起動する方法が3つあります。

- `rails server`コマンドを使う
  - `RAILS_ENV`または`-e`で環境と一致するファイルをロード
  - `production`であれば`config/puma/production.rb`をロード試行
  - ファイルなければ`config/puma.rb`をロードします。
- `puma`コマンドを使う
  - `RACK_ENV`で環境と一致するファイルをロード
- `pumactl`コマンドを使う
  - `-F`で指定されたファイルをロード
  - `Rails`をロードしないため設定ファイルに`Rails.root`などが使われていると例外エラーが発生する。

### 起動と再起動はrails s と rails restart
この記事では最初の`rails server`(`rails s`)で起動しています。
そしてリロードは`rails restart`を使っています。
これはpumaのプラグイン`tmp_restart`を入れることで、
`rails_ restart`か`touch tmp/restart.txt`することで`restart`を呼べるようになります。

`puma.rb`に次のコードを入れることで使えるようになり、`rails new`で作成される`puma.rb`にはデフォルトで記入されてあります。

```ruby
# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
```

## 手作業でCentOS8上にnginxとpumaとRailsを構築は良い経験
リンク先も含め記事を順当に進めばCentOS8上にゼロからRailsアプリが動くまでを経験できて、普段コーディングしてるRailsアプリの土台がどのようになっているのかイメージできるようになると思います。

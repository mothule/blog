---
title: docker
categories: docker
tags: docker
---

## Dockerとは？
Dockerとはコンテナ仮想化によるアプリ開発プラットフォームです。

### 環境隔離
プロセスやユーザー情報などアプリ実行環境をコンテナのように閉じこめた仮想環境を作り出すことで、コンテナ外から依存しない隔離された実行環境で運用できます。

### Infrastructure as Code
Dockerfileというテキストファイルでインフラ構成を管理・再現できるため、インフラ情報をGit管理したり変更があってもテストできます。

## Dockerのメリット
- チーム内のローカル開発環境を統一できる
- 新PCや新メンバーの環境構築コストを抑えられる
- CI上でも環境を統一できる
- インフラ変更してもServerSpecでテストできる
- テキストでGit管理可能なのでコードレビューできる

## Dockerの基礎知識を理解する
文章でDockerの動きを説明します。
この文章で、使われる用語や用語間の関連など、概要理解の取っ掛かりを作ります。

### Mac上でDockerを使ったアプリの場合

- MacにインストールされたMacOS(ホスト)のアプリとしてDocker Engineが乗っている。
- Dockerコマンドを使ってDocker Hub上からDockerイメージをダウンロードする
  - もしくはDockerfileからDockerイメージをビルド(作成)する
- ダウンロードまたは作成したDockerイメージからDockerコンテナをデプロイ(起動)する。
- Dockerコンテナ上ではプロセスが動きnginxやMySQLなどソフトウェアが動いている。
- ホストとDocker間の通信はポートフォワーディングでコミュニケーションする
- Docker間の通信はDockerネットワークによりコミュニケーションする

### 構築したDockerイメージを別の人のPC上で再現する場合

- DockerイメージをDockerfileからビルド(作成)する
- 他の人が使えるようにDocker Hubなどにアップロードする
- 他の人がDockerコマンドでアップロードされたDockerイメージをダウンロードする
- ダウンロードしたDockerイメージからDockerコンテナをデプロイ(起動)する

## 一部用語を説明

- Docker Hub
  - GitHubのDocker版
- Dockerイメージ
  - いわゆる型情報
- Dockerコンテナ
  - いわゆる型から作ったインスタンス
- ビルド
  - Dockerイメージを作成すること
- デプロイ
  - Dockerコンテナを起動すること

## MacにDockerをインストール
MacにDocker環境を構築するのは他より非常に簡単です。

```sh
$ brew install docker
$ brew cask install docker
$ open /Applications/Docker.app
```

最後にアプリ(Docker.app)を開いてるのは、アプリの信頼確認をOKするためです。

### インストール確認
Dockerのインストール確認を`docker -v`で確認します。

```sh
$ docker -v
Docker version 20.10.0, build 7287ab3
```

## DockerでHello World
前項で、Dockerの準備が整いました。

最初は、`docker run`コマンドを使って、Dockerコンテナをデプロイ(起動)します。
Dockerコンテナの起動には、Dockerイメージが必要です。
今回は使うDockerイメージは、[hello-world](https://hub.docker.com/_/hello-world)を使います。
`docker run`コマンドは、ローカルにDockerイメージがない場合は、Docker Hubからダウロードします。

`$ docker run hello-world`

このコマンドで、`hello-world`イメージのダウンロードからコンテナ起動までやってくれます。
実行することで下記が出力されて終了します。

```sh
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

`hello-world`イメージは、nginxやRubyなどプロセス常駐はしないイメージです。
コンソールに出力するだけの簡易なイメージです。


## ダウンロード済みDockerイメージ一覧を確認する(docker images)
`docker run`コマンドを実行すると、ローカルになければDockerイメージをダウンロードします。
ダウンロードしたDockerイメージは、`docker images`コマンドで確認できます。

例えば、先程の`docker run hello-world`を一度でも実行していれば、Dockerイメージ一覧にhello-worldイメージが表示されます。

```sh
$ docker images
REPOSITORY               TAG       IMAGE ID       CREATED         SIZE
hello-world              latest    bf756fb1ae65   11 months ago   13.3kB
```

## 稼働中のDockerコンテナを確認する(docker ps)
先程実行した`hello-world`イメージは、コンソールに出力が終わったらプロセスは終了します。
nginxなどプロセスが常駐するイメージの場合は、コンテナ状況を`dockr ps`コマンドで確認できます。

### getting-startedイメージを起動する
コンテナ状況を確認するためにプロセス常駐する`docker/getting-started`イメージをデプロイします。
コマンドは`$ docker run -p 80:80 docker/getting-started`になります。
`-p`はポートフォワーディング指定オプションです。
80:80だと、ホストのポート80とコンテナのポート80をつなぎます。

```sh
$ docker run -p 80:80 docker/getting-started
Unable to find image 'docker/getting-started:latest' locally
latest: Pulling from docker/getting-started
188c0c94c7c5: Already exists
617561f33ec6: Already exists
7d856acdaa9c: Already exists
a0d3c6e28e6d: Already exists
af69a9b963c8: Already exists
0739f3815ad8: Already exists
7c7b75d0baf8: Already exists
Digest: sha256:b821569034e3b5fae03b40e64a866017067f3bf17effe185b782bdbf02179528
Status: Downloaded newer image for docker/getting-started:latest
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up

```

`http://localhost`にアクセスすると、Dockerのチュートリアルページが表示されます。
これはDockerコンテナによって処理されてます。

### 稼働中のコンテナをdocker psで確認する

`getting-started`コンテナによって実行されたプロセスは常駐しています。
`docker ps`コマンドで見てみます。
```sh
$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                NAMES
c90016195071   docker/getting-started   "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes   0.0.0.0:80->80/tcp   thirsty_snyder
```

先程デプロイした`docker/getting-started`が一覧に表示されています。


## 稼働中のDockerコンテナを停止する(docker stop)

起動させたコンテナの停止は、`docker stop`コマンドを使います。
引数には、`docker ps`コマンドで確認できる`CONTAINER ID`の値を使います。

例えば前述で立ち上げたコンテナだと、`CONTAINER ID`は`c90016195071`になります。
コマンドは下記のようになります。

```sh
$ docker stop c90016195071
c90016195071
```

もう一度 `docker ps`コマンドを実行すると、一覧から消えていることが確認できます。


## DockerイメージをDocker Hubからダウンロードして起動する

- docker
  - クラスタ構成
    - Kubernetes
    - オーケストレーションツール(e.g. Kubernetes)
  - Dockerfile(構成管理ファイル)
  - 環境テスト(Severspec)
  - Docker for Mac
  - コンテナ間通信
    - 通信方法
      - Dockerネットワーク作成、コンテナ名で接続
        - 種類
          - bridge
          - host
          - null
        - デフォルトのbridgeというDockerネットワークはDNS設定されていない
          - 名前解決できないため、コンテナ名を使用したコンテナ間通信できない
      - `--link`オプション使用
        - レガシー機能
  - dockerイメージ作成
    - dockerコンテナからdockerイメージ作成
      - 内部構成が見えないので一般的ではない
    - Dockerfileでdockerイメージ作成
  - dockerコンテナ内でソフトウェアインストール
  - ホストとのディレクトリ共有
  - コンテナ操作コマンド
  - イメージ操作コマンド
  - Docker Compose
    - 複数コンテナ構成されたアプリのDockerイメージのビルドや各コンテナ起動・停止を簡単にする
    - ビルドやコンテナ起動のオプション、コンテナ定義をymlにまとめそれを利用してビルドやコンテナ起動する
    - 1コマンドで複数コンテナ操作
    - docker-compose.yml
      - container_name : --name
      - environment : -e
      - ports : -p
      - image
      - volumes : -v
  - Dockerfile
    - レイヤー
      - Dockerfile内の各コマンドの実行毎に作成されるDockerイメージ
      - Dockerfile内コマンドは連続ではなく1行ずつDockerコンテナ起動して、段階的にイメージを作成している。
      - この段階的のDockerイメージはレイヤーと呼ぶ。
      - コマンドは常に`/`から実行される。
      - レイヤー上限128数
      - レイヤー数が多いとdockerイメージサイズが大きくなる
    - キャッシュ
      - 実行済みコマンドはキャッシュが機能する
      - コマンドでキャッシュが使用されなかった場合は、次以降のコマンドはすべてキャッシュが使用されなくなる
      - そのため最初のコマンドはキャッシュが聞きやすい（変更されにくい）コマンドにするとキャッシュ効率が上がる。

  - コマンド
    - `$ docker run --name some-nginx -d -p 8080:80 nginx`
      1. nginxインストール済みdockerイメージをダウンロード
      2. ダウンロードしたdockerイメージでコンテナ起動(デプロイ)
      3. コンテナの中でnginx起動
      4. http://IPアドレス:8080/
      - オプション
        - `-p` ホストとコンテナ間のポートフォワーディング
          - `8080:80`だと8080ポートにアクセスすればdockerコンテナ側80ポートにアクセスします
        - `-d` コンテナのバックグラウンド実行
          - オプション未指定だとコンテナ起動時のコマンドを実行したことと同じで、コンソール出力が出力されます
        - `-name` dockerコンテナ名の指定
    - 例：ワードプレス(mysqlコンテナ + wordpressコンテナ)
      - `$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7`
      - `$ docker run --name some-wordpress -e WORDPRESS_DB_PASSWORD=my-secret-pw --link some-mysql:mysql -d -p 8080:80 wordpress`
    - `$ docker info`
      - システム情報を表示
    - `$ docker images`
      - ローカル環境のDockerイメージ一覧の確認
    - `$ docker ps -a`
      - ローカル環境のDockerコンテナ一覧の確認
    - `$ docker run hello-world`
      - DockerHubに公開されてるhello-worldというDockerイメージをダウンロード、コンテナを起動する。
      - ローカルにイメージがあれば起動し、なければHubから探しダウンロードする。
    - `$ docker pull?hello-world`
      - dockerイメージのダウンロードだけする
    - `$ docker rm?<コンテナ名>`
      - dockerコンテナの削除
    - `$ docker rmi?<docker image名>`
      - dockerイメージの削除
    - `$ docker stop?コンテナ名`
      - dockerコンテナの停止
    - `$ docker pull centos:7`
      - CentOS v7 イメージのダウンロード
    - `$ docker cp <ホスト側のファイル> <コンテナ名>:<コンテナ内のコピー先>`
      - ホスト側からコンテナ内にファイルをコピー
    - `$ docker cp <コンテナ名>:<コンテナ内のファイル> <ホスト側のコピー先>`
      - コンテナ内のファイルをホスト側にコピー
    - `$ docker exec -it tomcat bash`
      - tomcatコンテナにbash実行
    - `$ docker run -it -d -p 18080:8080 -v <ホスト側ディレクトリ>:<コンテナ側ディレクトリ> --name tomcat centos:7`
      - コンテナ名tomcatのcentos7イメージ起動
      - `-v`: ホスト側とコンテナ間のディレクトリ共有
    - `$ docker commit tomcat tomcat-image`
      - tomcatコンテナをtomcat-imageイメージとして作成
    - `$ docker start コンテナ名`
      - 停止したコンテナの起動
    - `$ docker build -t tomcat:1 .`
      - `docker build -t <Dockerイメージ名> <Dockerfileが存在するディレクトリ>`
      - Dockerfileからイメージ作成
    - `$ docker logs -f tomcat-1`
      - tomcat-1コンテナのログ確認
    - `docker build -t tomcat:2 -f Dockerfile_2`
      - `-f`で使用するDockerfile指定
    - `$ docker network create wordpress-network`
      - wordpress-networkという名前のDockerネットワーク作成
    - `$ docker network ls`
      - dockerネットワーク一覧
    - `$ docker network inspect wordpress-network`
      - wordpress-networkネットワークの詳細確認    
    - `$ docker run --name mysql --network wordpress-network -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7`
      - ネットワークを指定してコンテナを起動する
      - `$ docker run --name wordpress --network wordpress-network -e WORDPRESS_DB_PASSWORD=my-secret-pw -p 8080:80 -d wordpress`
  - Dockerfile
    - `FROM centos:7`
      - ベースとするDockerイメージの指定.ローカルにイメージがなくてもダウンロードする
    - `RUN yum install -y java`
      - OSにコマンド実行を命令
    - `ADD files/apache-tomcat-9.0.6.tar.gz /opt/`
      - コンテナへのコピーと `tar`の展開
      - `ADD コピー元 Dockerイメージ内コピー・展開先`
    - `COPY コピー元 Dockerイメージ内コピー`
      - コンテナへのコピー
    - `CMD [ "/opt/apache-tomcat-9.0.6/bin/catalina.sh", "run" ]`
      - コンテナ起動時の実行コマンド
  - docker-composeコマンド
    - `$ docker-compose up -d`
      - コンテナ起動
    - `$ docker-compose ps`
      - 起動状態を確認
    - `$ docker-compose build`
      - dockerイメージの作成
    - `$ docker-compose stop`
      - dockerコンテナ停止
    - `$ docker-compose rm -f`
      - dockerコンテナ削除
      - `-f` は削除確認なし
    - `$ docker-compose down`
      - 停止→削除→ネットワーク削除を実行する
      - `--rmi all`
        - dockerイメージも削除する

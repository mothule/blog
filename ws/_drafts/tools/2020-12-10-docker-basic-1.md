---
title: Dockerの基礎を効率よく理解する
categories: docker
tags: docker
---

Dockerを何もしらない状態から基本を理解し、Dockerを使ってコンテナを立ち上げるとこまでを説明します。
この記事では大まかに次の項目について説明しています。

- Dockerの概要
- Dockerのインストール
- Dockerコンテナのデプロイ
- Dockerイメージ確認
- Dockerコンテナの確認

## Dockerとは？
Dockerとは、コンテナ仮想化によるアプリ開発プラットフォームです。

### 環境を隔離できる
プロセスやユーザー情報などアプリ実行環境をコンテナのように閉じこめて仮想環境を作ります。
コンテナ外から依存しない隔離された実行環境で運用できます。

### Infrastructure as Code
Dockerfile(テキストファイル)でインフラ構成を管理・再現できます。
テキストファイルなのでGit管理できます。
Git管理下になればインフラ変更をCIなどでアプリ動作テストできます。

## Dockerのメリット
- チーム内のローカル開発環境を統一できる
- 新PCや新メンバーの環境構築コストを抑えられる
- CI上でも環境を統一できる
- インフラ変更してもServerSpecでテストできる
- テキストでGit管理可能なのでコードレビューできる

## Dockerの基礎知識を理解する
Dockerの動きを説明します。
使われる用語や用語間の関連など、概要理解の取っ掛かりを作ります。

### 一部用語を確認する
一部ですが基礎となる用語です。
特にDockerイメージとDockerコンテナの関係性は重要です。

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

### DockerイメージはDockerfileで管理される
`hello-world`イメージのDockerfileは単純です。

```sh
FROM scratch
COPY hello /
CMD ["/hello"]
```

このDockerfileでは、helloファイルをルートディレクトリに配置、helloファイルをコマンドとして実行してます。
各行の詳細は TODO: ここにリンク で説明します。

### コンテナ起動時にコマンドが実行される
Dockerコンテナがデプロイされたら、予めDockerイメージに登録されているコマンドが実行されます。
`hello-world`イメージの場合だと、`hello`というコマンドが実行されます。
前述したDockerfileの3行目「`CMD ["/hello"]`」です。
このコマンドが、コンソールに出力してるようです。

### hello-worldイメージの中身を確認する
hello-worldイメージは、GitHubで管理されています。
https://github.com/docker-library/hello-world
一見すると、複数のフォルダやファイルがありどれを見ればいいか分かりにくいです。
しかし、コンソール出力を見ると`amd64`と書いてあるので、[amd64/hello-world](https://github.com/docker-library/hello-world/tree/master/amd64/hello-world)になります。

### 大まかな流れ

hello-worldイメージをデプロイしたときの大まかな流れは下記になります。

1. `docker run hello-world`実行
1. ローカルにhello-worldイメージを探す
1. 見つからないので、Docker Hubでhello-world探す
1. 見つけたのでデータ元となるGitHubからダウンロード
1. DockerイメージからDockerコンテナをデプロイ
1. Dockerfile内からhelloコマンドを実行
1. helloコマンドがコンソールに出力

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
引数には、`docker ps`コマンドで確認できる`CONTAINER ID`か`NAMES`の値を使います。

例えば前述で立ち上げたコンテナだと、`CONTAINER ID`は`c90016195071`になります。
コマンドは下記のようになります。

```sh
$ docker stop c90016195071
c90016195071
```

`NAMES`でも停止できます。

```sh
$ docker stop thirsty_snyder
thirsty_snyder
```

もう一度 `docker ps`コマンドを実行すると、一覧から消えていることが確認できます。

## Dockerコンテナに名前をつける(--name)
`docker run`コマンドなどでデプロイしたコンテナには名前がつきます。
この名前は`docker stop`など様々な場面で利用できます。

名前はデプロイ時に`--name`オプションで指定ができます。
下記コマンドは、`tutorial`と名付けた`docker/getting-started`イメージをデプロイします。
```sh
$ docker run -p 80:80 --name tutorial  docker/getting-started
```

`docker ps`コマンドで見ると、名前が`tutorial`となっていることが確認できます。
```sh
$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS          PORTS                NAMES
fb8ec0635411   docker/getting-started   "/docker-entrypoint.…"   47 seconds ago   Up 46 seconds   0.0.0.0:80->80/tcp   tutorial
```

この名前を使ってコンテナを停止できます。

```sh
$ docker stop tutorial
tutorial
```

## Dockerコンテナをバックグラウンド実行する(-d)
Dockerコンテナをデプロイすると、フォアグラウンドで実行されます。
Dockerコンテナ内のプロセスによって出力されるログが表示されます。

Dockerコンテナのデプロイ時に`-d`オプションをつけることで、デタッチモード（バックグラウンド）でデプロイできます。

```sh
$ docker run -d -p 80:80 docker/getting-started
ac18a62977fbd10f8612660092c205ad496aacb39bccf5546618552dce314cb5
```

`-d`オプションをつけて実行すると、デタッチされるためコンソールにログが表示されません。

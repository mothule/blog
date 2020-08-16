---
title: エンジニアなら知らないとヤバいSSHの基礎
categories: tools ssh
tags: tools ssh
---

## SSHとは？

SSHとは、安全にネットワーク先のコンピュータと通信するためのプロトコルです。  
暗号や認証の技術を利用してセキュリティを強固にしており、このプロトコルによる通信は全て暗号化されます。  
ちなみにSSHはSecure Shellの略名です。

SSHは通信元がなりすまし防止するために認証の仕組みを提供している。

### SSHプロトコルを実装したソフトウェア
SSHはあくまでRFCによって策定されたプロトコル（約束事）であり、実在するソフトウェアではありません。  
このSSHプロトコルを準拠して作成されたソフトウェアの中でデファクトスタンダードとなっているのは、  
OSSとして開発されているOpenSSHになります。  
Macで標準インストールされているSSHもこのOpenSSHで、`$ man ssh`を実行すれば確認できます。

{% page_image 1.png 100% OpenSSH %}


### SSHのない時代
Telnetやrshなどネットワーク先のコンピュータとの通信は平文で行われていたため、  
重要ファイルやパスワードをネットワーク経路上で盗聴されるリスクがありました。

### SSHはクライアントサーバソフトウェア
SSH通信を実現するためには通信元(SSHクライアント)と通信先(SSHサーバ)がSSHプロトコルに準拠したソフトウェアがインストールされている必要があります。  
MacやLinuxであればOpenSSHがSSHクライアントとSSHサーバをサポートしています。

サーバもクライアントもどちらもOpneSSHを使うので勘違いしてしまいそうですが、  
SSHサーバとSSHクライアントは別物です。

SSHクライアントは`ssh`を使い、SSHサーバは`sshd`を使います。  

{% page_image ssh-server-client-networking.png 100% SSHServerClientNetworking %}

### SSHの認証方法

SSHの認証方法は色々と充実しているが、ここでは2つに絞ります。

- パスワード認証方式
- 公開鍵認証方式

#### パスワード認証方式

クライアントからユーザ名とパスワード名を受け取る方式。

- デフォルト値
- ユーザ名とパスワードの一致で認証する
- アカウントは接続先OSのユーザアカウントを使う
- 簡易だがセキュリティは脆弱なので運用時は非推奨

#### 公開鍵認証方式

クライアントが秘密鍵を使い、サーバが公開鍵を使って認証する方式。

- 秘密鍵と公開鍵の2つの鍵を使う
- 予めサーバ側に公開鍵、クライアント側に秘密鍵を登録しておく
- 通信時に秘密鍵と公開鍵で認証を行う

## SSHを使ってみる

実際に別Macにパスワード認証でSSH接続してみます。

### MacでSSHサーバ用意

同一ネットワーク内限定ですが、MacでもSSHサーバを起動できます。

1. システム環境設定.appを開く
1. 共有を開く
1. リモートログインをONにする
1. アクセスを許可をすべてのユーザにする

**※使い終わったら必ずリモートログインをOFFにしてください。**

### SSHサーバに接続

SSHクライアントとしてSSHサーバに接続するには次のコマンドを使います。

`ssh user@host`

今回別Macで用意したSSHサーバでは`mothule@192.168.11.10`と表示されたので、

```sh
$ ssh mothule@192.168.11.10
```

となります。

### 初回アクセスだと警告が表示される
接続先が初めてだと「信頼性を確立できていない」と警告が表示されます。  
それと同時に接続を再開してもよいか確認が表示されます。  
ここで`yes`をタイプすると`known_hosts`にホスト情報が追加された後、パスワード認証に進みます。  
ちなみに`no`の場合は`Host key verification failed.`となり中断します。

```sh
$ ssh mothule@192.168.11.10
The authenticity of host '192.168.11.10 (192.168.11.10)' can not be established.
ECDSA key fingerprint is SHA256:yhxvI/1TAjI0wvlYiRMCJvUsiYAX/L6eiy5bg6+Rv00.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
$ yes
Warning: Permanently added '192.168.11.10' (ECDSA) to the list of known hosts.
Password:
Last login: Thu Aug 13 04:16:45 2020
```

`ECDSA key fingerprint is SHA256:yhxvI/1TAjI0wvlYiRMCJvUsiYAX/L6eiy5bg6+Rv00.`とは、
ECDSA(Elliptic Curve Digital Signature Algorithm)の暗号アルゴリズムを使った鍵のフィンガープリントを表しています。  

腹落ちしてないはずなので、順に説明します。

### フィンガープリントとは
フィンガープリント(指紋)とは、公開鍵を識別するための短いバイト列です。  
指紋は公開鍵を元に暗号学的ハッシュ関数を通すことで作成されます。  
指紋は鍵長より短いので、目的は管理の単純化です。  
`SHA256`とは`暗号学的ハッシュ関数`です。

### 暗号学的ハッシュ関数とは
暗号学的ハッシュ関数とは、暗号数理性質をもったハッシュ関数です。  
ハッシュ関数は、任意データから短い固定長値(ハッシュ値)を得る関数です。

### 暗号化とハッシュ化の違い
暗号化もハッシュ化もどちらも元のデータを別のデータに変換する処理ですが、大きな違いとしては、
ハッシュ化は不可逆変換なので元のデータに復元できません。  
一方暗号化は当然複合できます。

### known_hostsとは
接続経験のあるホストの公開鍵を保存したテキストファイルです。  
ユーザ単位であれば`.ssh/known_hosts`に配置されてます。  
中身はテキストなので`cat`などで見れます。  
1行1ホストで列挙されており、`[host],address 暗号スイート 公開鍵`の並びになってます。  
`[host]`がない行もあります。

#### known_hostsの役割
このファイルに登録されてることで、手元に残してる公開鍵に紐づく秘密鍵があるか検証することで、万が一サーバ側の公開鍵が変更されていても気付ける仕組みとなってます。

SSHクライント側は、既に一度でも接続経験のあるホストなのに、ワーニングが出たら「鍵が変更された」が想定外か判断してください。

## .ssh/configで接続情報を管理する
`config`とは`.ssh`フォルダ内に配置するテキストファイルです。

`ssh`コマンドでSSHサーバに接続するには、少なくとも`ホスト`情報が必要です。

- SSHポートがデフォルト22ではない場合は、`-p`オプション
- ユーザー名を指定する場合はホストの前に`user_name@`
- 公開鍵認証の鍵がデフォルト名ではない場合は、`-i`オプション

これら全部を指定すると、
```sh
$ ssh mothule@192.168.11,10 -p 2200 -i ~/.ssh/my_second_pc.key
```
のように長くなってしまいます。

更に接続先が1つだけでなく複数となってくると、毎回同じ情報を入力するのは無駄な時間です。
`config`はこれらを事前に登録しておくことでsshコマンドのオプション等を省略できます。

例えば先程の全指定したSSH接続の場合だと下記設定を`config`に追記することで、`$ ssh hoge`だけで済みます。

```
Host hoge
HostName 192.168.11.10
User mothule
Port 2200
IdentityFile ~/.ssh/my_second_pc.key
```

### Are you sure you want to continue connecting (yes/no)? をスキップ
~/.ssh/config の接続先ホストに `StrictHostKeyChecking no` を設定することでスキップできる

## GitHubに公開鍵認証方式でSSH接続する

SSH接続するまでの流れです

- キーペア作成
- GitHubに公開鍵登録
- 秘密鍵でssh接続

### キーペア作成
公開鍵と秘密鍵の作成はssh-keygenを使います。

```sh
$ ssh-keygen -f ~/.ssh/github -N pass-phrase-this-key
```

ネットで見かける記事によっては、`-t`や`-b`オプションを使っていますが、キータイプのデフォルトはRSAで、RSAのデフォルトビット数は3072ビットになるので、  
省略しても目的のキータイプや一定の強度を保ったキーが作成されます。  
鍵の名前はデフォルトだと`id_rsa`にしようとしてくるので、そこは別名にすることをおすすめします。  
理由としてはしばらく時間経過後に.sshフォルダを覗いたときに`id_rsa`が何の鍵なのか判断つかなくなるのと、  
キー作成時に誤ってデフォルト名(id_rsa)にしてしまうと上書きされるリスクがあるためです。

`-N`でパスフレーズを決めれます。パスフレーズは空でも作成されますが、セキュリティを上げるためになるべくつけることを推奨します。

ssh-keygenで公開鍵周りについて詳しく知りたい場合は、「{% post_link_text 2020-08-14-tools-ssh-keygen-basic %}」にまとめてあります。


- 秘密鍵と公開鍵
  - id_rsa／id_rsa.pubとは？
    - id_rsa 秘密鍵
    - id_rsa.pub 公開鍵
  - RSA


### Permission denied (publickey).
サーバー側とクライアント側の公開鍵と秘密鍵が一致していないことがよくある原因。


## sshクライアント

- `ServerAliveInterval 60`でSSHセッションにハートビート導入

## ssh-agent
[ssh-agentを利用して、安全にSSH認証を行う - Qiita](https://qiita.com/naoki_mochizuki/items/93ee2643a4c6ab0a20f5)

agent forwarding

- ssh-agent
  - ssh-addコマンド
    - [SSH-ADD (1)](https://euske.github.io/openssh-jman/ssh-add.html)
  - [ssh-agentを利用して、安全にSSH認証を行う - Qiita](https://qiita.com/naoki_mochizuki/items/93ee2643a4c6ab0a20f5)
  - agent forwarding
- /etc/hosts
- ssh-keygen


## SSHサーバ
- SSH認証を公開鍵認証方式に変更する
  - 公開鍵は接続先
  - 秘密鍵は接続元
  - .sshのパーミッションは700
  - .ssh/authorized_keys は 600
  - 公開鍵は cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys で登録
  - rm ~/.ssh/id_rsa.pub で不要になった元の公開鍵を削除
  - パスワード認証を禁止する
    - /etc/ssh/sshd_config を vimで編集する
    - PasswordAuthentication no
    - PubkeyAuthentication yes
  - ssh-copy-idでリモートで公開鍵を登録する
  - rootユーザでのssh禁止は`PermitRootLogin no`


### インターネット上に公開されてる場合のセキュリティ
- デフォルトのポート番号を使わない
  - SSHのポート番号は22番と決まっているため、ポートを変えることで最初の防御を敷くことが出来る。
- パスワード認証は使わない・無効化
  - ブルートフォースアタックでパスワードを破られる

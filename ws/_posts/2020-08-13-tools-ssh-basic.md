---
title: エンジニアなら知らないとヤバいSSHの基礎
description: GitHubなど多様に使われているSSH。known_hostsやフィンガープリント、公開鍵や秘密鍵、パスワード認証や公開鍵認証をイチから理解、実際にGitHubに対して公開鍵認証方式によるSSH接続を体験方法を説明します。
categories: tools ssh
tags: tools ssh
image:
  path: /assets/images/2020-08-13-tools-ssh-basic/eyecatch.png
---
インフラエンジニアでなくともSSH接続や公開鍵認証は基本知識として覚えといたほうがいいです。  
普段めったに触ることのないiOSエンジニアでもknown_hostsや鍵生成などと接する機会は定期的に発生します。  
GitHubにSSHの技術が使われています。基本知識として覚えといて損はないと思います。

この記事ではSSHの基本理解から始まり、実際にGitHubに対して公開鍵認証でSSH接続するまでを説明します。

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
~/.ssh/config の接続先ホストに`StrictHostKeyChecking no`を設定することでスキップできる

### SSH接続のタイムアウトを防ぐ
~/.ssh/config の接続先ホストに`ServerAliveInterval 60`を設定することでSSHセッションにハートビート導入できる。

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

`-N`でパスフレーズを決めれます。パスフレーズは空でも作成されますが、セキュリティを上げるためになるべくつけることを推奨します。


#### キー名を別名にする理由
鍵の名前はデフォルトだと`id_rsa`にしようとしてくるので、そこは別名にすることをおすすめします。  
理由としてはしばらく時間経過後に.sshフォルダを覗いたときに`id_rsa`が何の鍵なのか判断つかなくなるのと、  
**キー作成時に誤ってデフォルト名(id_rsa)にしてしまうと上書きされるリスクがあるためです。**

#### ssh-keygenの詳細について
ssh-keygenで公開鍵周りについて詳しく知りたい場合は、「{% post_link_text 2020-08-14-tools-ssh-keygen-basic %}」にまとめてあります。


### GitHubに公開鍵登録

1. [GitHub > Settings > SSH and GPG keys](https://github.com/settings/keys)の遷移
1. `New SSH key`ボタンを押下
1. `キー名`と`公開鍵`を入力して`Add SSH key`ボタンを押下
1. アカウントのパスワード入力

成功すると一覧画面に戻り新しく公開鍵が登録されていることを確認できます。

{% page_image 2.png 75% GitHubSSHKey %}

※今回は記事用に用意した鍵であり既に削除済みです。くれぐれもむやみに鍵は公開しないことを推奨します。

#### 登録されてる公開鍵のフィンガープリントについて
GitHubで表示されているフィンガープリントは使われてるハッシュ関数はSHA256ではなくMD5になります。  
そのため手元の公開鍵のフィンガープリントを確認する場合は、`-E`で`md5`の指定が必要になります。

```sh
$ ssh-keygen -l -f github -E md5
3072 MD5:59:68:3f:44:4f:ec:79:23:e9:c8:9a:88:10:1e:36:59 GitHub (RSA)
```

`-E`指定なしだとデフォルトとして`sha256`が使われるため、期待する値になりません。
```sh
$ ssh-keygen -l -f github
3072 SHA256:1/1Sdu/MJXQJnPOBDibvs/cvXrmxJKMibFa1kC3NtoI GitHub (RSA)
```

### GitHubに公開鍵認証方式でSSH接続

GitHubにSSH接続するには`git@github.com`で接続します。
認証鍵の指定は、先程登録した鍵を`-i`オプションで指定します。

```sh
$ ssh -i github git@github.com
Enter passphrase for key 'github':
PTY allocation request failed on channel 0
Hi mothule! You have successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

GitHubはシェルアクセスを許可していないのですぐに終了してしまいますが、接続が成功できたことは確認できます。

#### Permission denied (publickey)エラーが出たら
SSH接続で`Permission denied (publickey)`が出たら、公開鍵に限らず、秘密鍵が無効値になっているケースでもこのエラーが表示されます。
公開鍵と秘密鍵のどちらかが正しい値になっていない可能性があります。  
分からない場合はもう一度作成して再登録してください。

#### GitHubを使ったSSH接続はサーバ設定は不要
GitHubに対して公開鍵認証方式によるSSH接続を試しましたが、  
GitHubではSSHサーバとしての設定はGitHub側がよしなになってくれているため、  
公開鍵を渡した後のSSHサーバ側の説明はスキップしてます。

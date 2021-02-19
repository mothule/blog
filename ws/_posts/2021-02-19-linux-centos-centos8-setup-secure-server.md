---
title: CentOS8で不正SSHログイン対策したLinuxサーバ構築する
description: VPSなどでCentOSのLinuxサーバーを立てると、すぐに不正アクセスログがたまります。対策を施してもログには試行ログがたまります。このログが蓄積されなくなるセキュリティセットアップをしつつサーバ構築します。
categories: linux centos
tags: linux centos
image:
  path: /assets/images/2021-02-19-linux-centos-centos8-setup-secure-server/eyecatch.png
---
VPSなどでサーバ立てて無対策だと、ログに結構な量のSSHを狙った不正アクセス試行ログが残ります。  
パスワードが強固であればそう簡単に不正ログインされませんが、ログに残ると心がそわそわ落ち着きません。

今回はこのログに残らない程度、つまり不正SSHログイン試行されない程度にセキュリティ対策したLinuxサーバを構築します。

対策は大きく分けて5つです。

1. rootログイン禁止
2. パスワード認証から公開鍵認証へ変更
3. パスワード認証禁止
4. firewalld起動
5. SSHのポート番号変更

さくらVPSでサーバを立てた状態から基本的なセットアップをしつつセキュリティ対策を施します。  
今回はLinuxのディストリビューションはCentOS8を使います。

## 注意事項
セキュリティは水物で時代とともにその方法や驚異は変わり続けるものです。
また全てを万全にするといった対策はできないものです。（ゼロデイ攻撃、リバースエンジニアリング、ソーシャルエンジニアリングなど）
そのためここに記載するセキュリティに関するセットアップを行ったからといって万全でないことは覚えておいてください。
なお、慣例ですが**何かあっても自己責任です。**

## SSHでrootログインする
CentOSのインストールが完了したら、まず最初にSSHを使ってrootアカウントにログインします。  
ホスト(IPアドレス)はWebのダッシュボード等から確認できると思います。

```sh
$ ssh root@ip_address
```

## CentOS8上に作業用ユーザー作成する
rootアカウントで作業せず、root権限持ったユーザーで操作するために、作業用ユーザーを作成します。    
ユーザー名はなるべく推測されにくい名前が好ましいです。例えばadminとかは避けたほうがいいです。

今回は`main`というユーザーを作ります。`useradd`でユーザーを作成し、`passwd`でパスワードを設定します。

```sh
useradd main
passwd main
```

## 作業用ユーザーをroot権限持ちグループに追加する
ユーザーを新しく作成してもroot権限を持ってなくて不便なので、作成したユーザーを`wheel`グループに追加してroot権限を付与します。

```sh
$ usermod -aG wheel main
```

なお`-a`オプションをつけない記事を見かけますが、`-a`がないとグループへの追加ではなく上書きとなり、既に入ってたグループから抜けてしまうので`-a`オプションは忘れずに。


### root権限をwheelグループに付与する
`wheel`グループにroot権限が付与されていない場合は、`visudo`を開いて次の行を追記して、権限付与します。  
コメントアウトされている場合はコメント解除するだけでいいです。

```
%wheel ALL=(ALL) ALL
```

## SSHからのrootログインを禁止する
作業用ユーザでSSHログインできて、root権限が使えることが確認できたら、SSHでのrootログインを禁止させます。  
rootアカウントは全権限を持っていながら、アカウント名がバレているので不特定多数からアクセスできる状態に晒すことはリスクが高いためです。

`/etc/ssh/sshd_config`を開いて、`PermitRootLogin`を検索すると`yes`になっているので、これを`no`にします。

保存したら、`sshd`を再起動します。
```sh
$ systemctl reload sshd
```

正しく設定できていれば、rootアカウントでSSHログインしようとしても失敗するようになります。

これでまずrootアカウントを狙った不正アクセスから身を守れます。  
ただ、ログには変わらず試行ログが蓄積され続けます。

## SSHログインの認証方式をパスワード認証方式から公開鍵認証方式にする
SSHのログイン認証をパスワードよりもセキュアな公開鍵認証に変更します。  
パスワード認証はユーザー名とパスワードが一致すれば誰でもログインできます。  
よりセキュアにするために公開鍵認証にして秘密鍵保持したPCからのみSSHログインできるようにします。

### ~/.ssh/authorized_keysを用意する
サーバ上に`~/.ssh`フォルダを作成し、パーミッションを`700`に設定します。  
`authorized_keys`は一旦空ファイルとして作成し、パーミッションを`600`に設定します。

```sh
$ mkdir ~/.ssh
$ chmod 700 ~/.ssh
$ touch ~/.ssh/authorized_keys
$ chmod 600 ~/.ssh/authorized_keys
```

### ssh-keygenで公開鍵・秘密鍵を生成する
Mac上で`ssh-keygen`を使って公開鍵・秘密鍵を生成します。

```sh
$ ssh-keygen -f ~/.ssh/main_rsa -N your-pass-phrase
```

ssh-keygenの使い方については、「{% post_link_text 2020-08-14-tools-ssh-keygen-basic %}」にまとめてあります。

### 公開鍵をサーバに配置する
鍵作ったら、公開鍵をサーバに転送します。

```sh
$ scp your-pub-key-path user_name@ip_address:~/.ssh
```

### 公開鍵をauthorized_keysに追加
サーバは公開鍵を受け取ったら、`~/.ssh/authorized_keys`に追記します。
```sh
$ cat ~/.ssh/your-pub-key >> ~/.ssh/authorized_keys
```

### 公開鍵認証を有効にする
`/etc/ssh/sshd_config`の`PubkeyAuthentication`を`yes`にします。
```
PubkeyAuthentication yes
```

有効化したら反映します。
```sh
$ systemctl reload sshd
```

### 公開鍵認証の設定に問題ないか接続確認する
公開鍵認証方式を有効にしたら、問題ないか接続確認します。  
接続確認は重要な工程です。公開鍵やフォルダのパーミッションの設定が間違っていたり、間違えて秘密鍵を配置してたりして接続失敗するポイントがいくつかあるためです。  
ここで接続確認せずにパスワード認証方式を無効化すると、もし公開鍵認証で接続できなかった場合に二度とそのサーバにssh接続できなくなります。  
なので、公開鍵認証の設定が完了したらパスワードログインはそのままで、公開鍵認証方式でログインできるか確認しましょう。

公開鍵認証の秘密鍵が`~/.ssh/vps/rsa.key`だとしたら、ssh接続では`-i`オプションでファイルを指定することで、認証方式が公開鍵認証となり接続試行します。

```sh
$ ssh user_name@ip_address -i ~/.ssh/vps/rsa.key.pub
```

## SSHログインでパスワード認証を禁止する
公開鍵認証方式でのログインが成功したら、パスワード認証を無効化します。
`/etc/ssh/sshd_config`の`PasswordAuthentication`を`no`にします。

```
PasswordAuthentication no
```

保存したら、`sshd`をリロードします。

```bash
systemctl reload sshd
```

## 最低限必要なパッケージをインストールする
ここでサーバ作業において必要なパッケージをインストールします。

```sh
# Bash completion
yum -y install bash-completion

# Vim
yum -y install vim-enhanced

# mlocate(ファイル一覧DB)
yum -y install mlocate
updatedb

# 日本語環境
yum -y install langpacks-ja
localedef -f UTF-8 -i ja_JP ja_JP
localectl set-locale LANG=ja_JP.utf8
source /etc/locale.conf

timedatectl set-timezone Asia/Tokyo

yum clean all
yum -y upgrade
```

## firewalldを起動する
今度はファイアウォールとなるfirewalldを起動させて、許可したサービスやポートのみを使えるようにします。  
既に起動中の場合もあるかもしれませんが、さくらVPSだとfirewalldは未起動で自動起動は無効になっています。

### 注意：SSHポート番号を変更してる場合
もし先にSSHのポート番号をデフォルト22から別の値に変更している場合は、一度ポートをデフォルトに戻してください。  
firewalldはデフォルトでSSHサービスは許可されていますが、ポートはデフォルト22となっており、それ以外のポート番号は許可されてません。  
そのため、firewalldを有効にした途端SSH接続が途絶えて、サーバへの接続手段がロストします。

### firewalldの状態確認

```sh
systemctl status firewalld
```

`Active: active(running)`となっていれば稼働中です。

### firewalldを起動する

```sh
$ sudo systemctl start firewalld
```
firewalldを起動することで許可したポートやサービス以外のアクセスは拒否されます。
しかしsshのデフォルトポートは22番で、これは不正アクセスする側も知っている情報なのでこのポートに対してsshログインが試行され続けます。

## SSHのポート番号を変更する
SSHのポート番号は22番と決まっているため、そのポートに対してSSH接続攻撃を仕掛けられます。
SSHからのrootログインは無効化し、SSHの認証方式は公開鍵認証にしているため、だいぶ不正ログインされるリスクは減っていると思います。
しかし、ポート番号はバレているため、もともと解決したいSSHログイン失敗ログはたまり続けます。

これをポート番号を変更することで攻撃者に分からないようにします。

### firewalldが未稼働の場合
firewalldを起動しないとポート許可ができないため先に起動させます。
```sh
$ systemctl start firewalld
```

### firewalldに変更先ポートを許可させる
既にfirewalldが稼働中の場合、デフォルトでSSHサービス(TCP/22)が許可されています。
しかし、先にポート番号を変更してしまうと、firewalldからアクセス拒否されて接続できなくなってしまいます。
そのため、SSH利用ポートを変更する前にfirewalldで変更先ポートを許可します。
次の例はポート番号22444番のTCPを許可しています。

```bash
$ sudo firewall-cmd --permanent --add-port=22444/tcp
success
$ sudo firewall-cmd --reload
success
```

サービスとして登録・管理する方法もあります。そちらに関しては「{% post_link_text 2021-02-19-linux-centos-firewalld-create-new-service %}」にまとめてあります。

### sshd_configのPortを変更
SSHのポート番号は`/etc/ssh/sshd_config`の`Port`の数字で定義されています。
この数字を22ではない別の番号にすることでSSHで使うポート番号を変更できます。

ただし、0~1023番は`WELL KNOWN PORT NUMBERS`と呼ばれる予め決められた範囲なため、それ以外の番号を選びます。
またポート番号を65535以上にすると接続できなくなるので、それ未満にします。

最後にsshdを再起動します。

```sh
$ systemctl reload sshd
```

### SSH接続でポート番号を指定する
ポート番号は`-p`オプションで指定します。認証方式がパスワードではなく公開鍵の場合は`-i`オプションの指定も忘れずに。

```sh
$ ssh main@ip_address -p new_port_number
```

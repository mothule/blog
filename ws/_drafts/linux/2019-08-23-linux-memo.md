---
title: ActiveRecordでpluckとselectしてpluckに変化はあるか？
categories: ruby rails active-record
tags: ruby rails active-record
---

Linux 基礎コマンド

```bash
useradd <user name>
```

```bash
passwd [user name]
```
ユーザ名未指定だと自分のパスワード変更する。

```bash
cat /etc/passwd
```
ユーザー情報が1行1ユーザーで格納される。

```bash
id <user name>
```

```bash
userdel [-r] <user name>
```
-r: ホームディレクトリごと削除する


```bash
groupadd <group name>
```

```bash
usermod -G <group name> <user_name>
```

```bash
groupdel <group name>
```

```bash
cat /etc/group
```
グループ情報が1グループ1行で格納される。


```bash
chown <user name> <file or directory>
```

```bash
chgrp <group name> <file or directory>
```

変数をエクスポートすることで定義したシェルから起動したシェルや実行したコマンドから変数を参照できるようになる。
これを環境変数と呼ぶ。
```bash
export var2=cdn
```

```bash
locate <file pattern>
```

```bash
ps
```
|オプション|説明|
|---|---|
|a|全ユーザーのプロセス表示|
|u|ユーザー名表示|
|x|全端末のプロセス表示|

```bash
$ ps aux | head -n 5
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  19232  1500 ?        Ss   12:54   0:00 /sbin/init
root         2  0.0  0.0      0     0 ?        S    12:54   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S    12:54   0:00 [migration/0]
root         4  0.0  0.0      0     0 ?        S    12:54   0:00 [ksoftirqd/0]
```

プロセスの親子関係を表示
```bash
mothule@centos ~]$ pstree
init─┬─auditd───{auditd}
     ├─crond
     ├─dhclient
     ├─login───bash
     ├─master─┬─pickup
     │        └─qmgr
     ├─5*[mingetty]
     ├─rsyslogd───3*[{rsyslogd}]
     ├─sshd───sshd───sshd───bash─┬─less
     │                           └─pstree
     └─udevd───2*[udevd]
```

プロセスに送るシグナル表

|ID|名|動作|
|---|---|---|
|9|KILL|強制終了|
|15|TERM|終了(デフォルト)|
|18|COUNT|再開|
|19|STOP|一時停止|

シグナル送信は kill コマンドを使う
```bash
$ kill 28000
```

IDではなくシグナル名を指定する場合は
```bash
$ kill -s TERM 28000
```

プロセスIDではなくプロセス名でシグナル送信したい場合は
```bash
$ killall -15 xclock
```
のようにする -15 は シグナルID


ユーザー側の処理単位をジョブ
1ジョブで複数プロセスが走るので 1ジョブ=1プロセスではない
実行中のジョブ一覧
```bash
$ jobs
```

コマンドの末尾に & をつけるとバックグラウンドで実行する
```bash
$ less hoge.txt &
```

Ctrl+Z でジョブは一時停止状態になる
一時停止状態のジョブを再開するには
fg [%ジョブID]

バックグラウンドで再開するには
bg [%ジョブID]


/etc/hosts にはIPアドレスとホスト名の対応が記述する
/etc/resolv.conf には利用するDNSサーバやドメイン名を指定する
/etc/sysconfig/network にはネットワークの基本情報を設定する


公開鍵認証方式でsshログイン
公開鍵は接続先
秘密鍵は接続元
.sshのパーミッションは700
.ssh/authorized_keys は 600
公開鍵は
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
で登録
rm ~/.ssh/id_rsa.pub で不要になった元の公開鍵を削除


パスワード認証を禁止する
/etc/ssh/sshd_config を vimで編集する
PasswordAuthentication no
PubkeyAuthentication yes
にする

scp でクライアントからサーバーへ転送する方法
scp <コピー元> <コピー先>
リモート先は [サーバーのユーザーID][サーバーアドレス]:<パス> で表す

# VirtualBox

## ホストOSからゲストOSにssh接続する
ブリッジアダプタを使用する.
設定>ネットワーク>アダプター
割当をブリッジアダプターにする
名前をメモしとく

ゲストOS上で ifconfig でメモした名前のIPアドレスを確認
ホストOS上からIPアドレスにssh接続する
```
ssh ユーザー名@ゲストOSのIPアドレス
```

# 圧縮／解凍

## gzip
ファイル圧縮
gzipのgはGNU Zipのg
拡張子は.gzとなる
```
gzip <ファイル名>
```
圧縮はファイルのみでフォルダはできない
圧縮コマンドを実行すると元のファイルは削除される

## gunzip
圧縮ファイルの展開
```
gunzip <圧縮ファイル名>
```
解凍コマンドを実行すると元の圧縮ファイルは削除される.
もし残したいなら
```
gunzip <圧縮ファイル名> > <解凍後ファイル名>
```

## bzip2
圧縮率の高い新しい圧縮コマンド
bzip2コマンドとbunzip2コマンドを使う
利用方法はgzip/gunzip同様
拡張子.bz2となる

## tar
アーカイブを作成・展開
ディレクトリを1つのファイルにアーカイブする
拡張子は .tar となる
### アーカイブ作成
アーカイブ作成は cvf オプションを指定する
```
tar cvf <アーカイブファイル名> <ディレクトリ名>
```

c:アーカイブ作成
v:verbose
f:アーカイブファイル名の指定

### アーカイブの展開
```
tar xvf <アーカイブファイル名>
```

## フォルダを圧縮
1. tar でフォルダをアーカイブ後
1. gzip でアーカイブされたファイルを圧縮

圧縮されたフォルダは フォルダ名.tar.gz となる

### もっと簡単な方法
zオプション指定する
tar czvf <アーカイブファイル名> <ディレクトリ名>
tar xzvf アーカイブファイル名

圧縮をgzipではなくbzip2を使う場合
zオプションの代わりにjオプションを指定する

```bash
locate <file pattern>
```

```bash
ps
```
|オプション|説明|
|---|---|
|a|全ユーザーのプロセス表示|
|u|ユーザー名表示|
|x|全端末のプロセス表示|

```bash
$ ps aux | head -n 5
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  19232  1500 ?        Ss   12:54   0:00 /sbin/init
root         2  0.0  0.0      0     0 ?        S    12:54   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S    12:54   0:00 [migration/0]
root         4  0.0  0.0      0     0 ?        S    12:54   0:00 [ksoftirqd/0]
```

プロセスの親子関係を表示
```bash
mothule@centos ~]$ pstree
init─┬─auditd───{auditd}
     ├─crond
     ├─dhclient
     ├─login───bash
     ├─master─┬─pickup
     │        └─qmgr
     ├─5*[mingetty]
     ├─rsyslogd───3*[{rsyslogd}]
     ├─sshd───sshd───sshd───bash─┬─less
     │                           └─pstree
     └─udevd───2*[udevd]
```

プロセスに送るシグナル表

|ID|名|動作|
|---|---|---|
|9|KILL|強制終了|
|15|TERM|終了(デフォルト)|
|18|COUNT|再開|
|19|STOP|一時停止|

シグナル送信は kill コマンドを使う
```bash
$ kill 28000
```

IDではなくシグナル名を指定する場合は
```bash
$ kill -s TERM 28000
```

プロセスIDではなくプロセス名でシグナル送信したい場合は
```bash
$ killall -15 xclock
```
のようにする -15 は シグナルID


ユーザー側の処理単位をジョブ
1ジョブで複数プロセスが走るので 1ジョブ=1プロセスではない
実行中のジョブ一覧
```bash
$ jobs
```

コマンドの末尾に & をつけるとバックグラウンドで実行する
```bash
$ less hoge.txt &
```

Ctrl+Z でジョブは一時停止状態になる
一時停止状態のジョブを再開するには
fg [%ジョブID]

バックグラウンドで再開するには
bg [%ジョブID]


/etc/hosts にはIPアドレスとホスト名の対応が記述する
/etc/resolv.conf には利用するDNSサーバやドメイン名を指定する
/etc/sysconfig/network にはネットワークの基本情報を設定する




# CentOS

## ネットワークアダプタの設定

NetworkManagerを使う

nmtuiコマンドで [Edit a connection]
[Automatically connect]にチェックを入れて終了



## yum update upgrade

yum update -y
yum upgrade -y


https://www.rem-system.com/linux-first-setting/#14

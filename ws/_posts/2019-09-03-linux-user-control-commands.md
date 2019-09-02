---
title: LinuxのCentOSでユーザー操作
categories: linux centos
tags: linux centos
---

ユーザーの追加や削除、グループ追加やsudo付与などユーザー操作に関するコマンドを忘れては調べ忘れては調べるを繰り返しているので、いい加減自分用に用意しました。

## ユーザー情報を確認する

idコマンドで確認できます。

`id [user name]`

rootを調べた場合はこうなります。

```sh
id root
uid=0(root) gid=0(root) groups=0(root)
```

ユーザーを指定しない場合は、カレントユーザーになります。
例えばユーザー`hoge`でログインしてる場合は次のようになります。

```sh
$ id
uid=1000(hoge) gid=1000(hoge) groups=1000(hoge) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```


## ユーザーを作成する

`useradd [user name]` でユーザーを作成し、
`passwd [user name]` で指定ユーザーのパスワード設定ができます。
`usermod -G wheel [user name]`で指定ユーザーにsudo権限を付与します。

`wheel`という予め用意されているグループには、sudoが使えるグループになっており、
このグループにユーザー追加することで,ユーザーがsudoが使えるようになります。

### ユーザー情報はファイルになっている

作成したユーザーはどこで管理されているのかと言うと、ファイルとして一覧管理されています。

先程作ったユーザー`hoge`を確認します。

```sh
$ cat /etc/passwd | tail -n 1
hoge:x:1000:1000::/home/hoge:/bin/bash
```
passwdというファイルにユーザー情報が保存されています。
passwdという名前ですが、パスワードは別ファイルになります。

```sh
$ sudo cat /etc/shadow | tail -n 1
hoge:$6$q0cLZgb4$dqS356Q4qNWcvDGxqqUhEOW32cXpma8uErO9ioiAZly3V3iQ.x1F3.zqzE.96yWFTl3klPNWJ61.9ahXvVPkj0:18141:0:99999:7:::
```
`shadow`ファイルになります。こちらは`sudo`権限がないと見れないので、先の `wheel`グループにユーザーを追加する必要があります。

また加入したグループもファイルになっています。

```sh
$ cat /etc/group | grep wheel
wheel:x:10:hoge
```

## ユーザーを削除する

`userdel -r [user name]`でユーザーとユーザーディレクトリを削除します。
`-r` が未指定だとユーザーのみが削除され、ユーザーディレクトリは残ります。

## グループを削除する

`groupdel [group name]`で指定グループを削除することができますが、
グループをプライマリとするユーザーがいる場合は削除できません。

Linuxではユーザーを作成時に同時にグループも作成し、作成されたユーザーの最初のグループとなります。
ユーザー`hoge`であればグループ`hoge`が作成されます。

```sh
$ cat /etc/group | tail -n 1
hoge:x:1000:
```

## 所有者を変更する

`chown [user name] [file or directory]`で変更ができます。

## グループを変更する
`chgrp [group name] [file or directory]`で変更ができます。

---
title: Linuxのグループ操作をすぐ忘れる
categories: linux
tags: linux
image:
  path: /assets/images/2021-02-19-linux-edit-group/eyecatch.png
---
CentOSやUbuntuなどLinxuのグループ編集作業時に忘れてしまっているので、備忘録としてまとめます。

## Linuxユーザーの所属グループ確認
user_nameにユーザー名を指定すればそのユーザー名のグループを確認します。
複数ユーザーの場合はスペース区切りで指名します。
無指定だとログイン中のユーザーを確認します。
```sh
$ groups [user_name][user_name]...
```

## Linuxユーザーに新たなグループを追加
**`-a`**をつけ忘れると追加ではなく上書きになります。  
`-a`の指定がなく「追加」と書いてるネット記事多いので注意。

```sh
$ usermod -aG group_name user_name
```

## Linuxユーザーをグループから削除

```sh
$ gpasswd -d user_name group_name
```

## Linuxに新しくグループ作成

```sh
$ groupadd group_name
```

## Linuxのグループの削除

```sh
$ groupdel group_name
```

## Linuxのグループ一覧の確認

```sh
$ less /etc/group
```

### `/etc/group`の見方
グループ一覧が確認できたとしても、グループ名が列挙されてるだけでなく変わった書き方がされていて意味が気になります。

```sh
$ tail /etc/group
stapsys:x:157:
stapdev:x:158:
sshd:x:74:
pesign:x:992:
chrony:x:991:
mothule:x:1000:mothule
slocate:x:21:
rngd:x:990:
wheel:x:1002:root,mothule
nginx:x:989:
```

例えば`sshd:x:74:`は左から順番にグループ名、パスワード、グループIDになります。
コロン「:」区切りになります。
パスワードは暗号化されたパスワードもしくは、「x」はシャドウパスワードを使用してることを表します。

次に`wheel:x:1002:root,main`の最後`root,main`はこのグループをサブグループとして登録しているユーザー一覧です。
サブグループとは`usermod -aG`とかでユーザー作成後追加したグループです。

これは`groups`コマンドと一致しています。
```sh
$ groups root
root : root wheel
```

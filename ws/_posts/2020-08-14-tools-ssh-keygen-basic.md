---
title: SSH公開鍵認証で必要なssh-keygenの使い方を理解する
description: SSHで公開鍵認証方式に必要な公開鍵の作成に使うssh-keygenツールの基本的な作成方法からパスフレーズの変更方法、コメントの変更方法など作成だけではない使い方について説明する。
categories: tools ssh
tags: tools ssh ssh-keygen
image:
  path: /assets/images/2020-08-14-tools-ssh-keygen-basic/eyecatch.png
---
ネット記事に書いてる通りに従ってSSH用公開鍵を作成してばかりで、ssh-keygen自体の理解が進んでいない人に向けて、ssh-keygenの公開鍵認証周りに絞って説明します。

## ssh-keygenとは？

SSHの認証キーの生成と管理と変更を行うコマンドです。
SSHを公開鍵認証方式で認証したい場合にそのキーペアを生成できます。

## 公開鍵の作成

**公開鍵の作成は、`ssh-keygen`コマンドのみで作成できます。**  
パラメータ用オプションが指定されていないと対話形式でパラメータを決めていきます。  
この場合、最低限のパラメータしかイジることができません。

コメントやファイル形式、暗号タイプやビット長などはデフォルト値となります。

下記は指定なしで実行して作成されるまでの流れです。

```sh
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/mothule/.ssh/id_rsa): hoge_rsa
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in hoge_rsa.
Your public key has been saved in hoge_rsa.pub.
The key fingerprint is:
SHA256:usyuy2k2WRbKlAmx4qJSVjG3m3EkhJvKSOvmvbwRb5Y mothule@mothule.local
The key\'s randomart image is:
+---[RSA 3072]----+
|  ..oo+ .        |
|  ...+ +         |
|. ...=o .        |
|.o .* .=         |
|o++= .o.S        |
|++o = +.         |
|+  . E.          |
|.oo.O+ .         |
|o. BB==          |
+----[SHA256]-----+
```

この場合だと、鍵は次の情報で作成されます。

|||
|---|---|
|ファイル名|hoge_rsa and hoge_rsa.pub|
|パスフレーズ|asdf|
|暗号タイプ|RSA|
|ビット長|3072|
|ファイル形式|RFC4716|
|コメント|ホスト情報|

### オプションを渡して公開鍵を作成する
`ssh-keygen`コマンドにオプションを一緒に渡すことで対話形式をなくしたり、デフォルト値を変えたりできます。

```sh
$ ssh-keygen -b 3072 -C コメント -f ~/.ssh/hoge_rsa -m RFC4716 -N asdf -t rsa
```

## 公開鍵のフィンガープリントを表示

`-l`オプションを使うことで公開鍵のフィンガープリントを表示します。  
`-v`オプションをつけるとアスキーアートも表示されます。  
`-f`でキーを指定できます。無指定だと対話形式でファイル名を訪ねてきます。  
`-E`オプションで表示するフィンガープリントのハッシュ関数を変更できます。  
`md5`と`sha256`が使えます。デフォルトはsha256です。

```sh
$ ssh-keygen -l -v -E sha256 -f ~/.ssh/github_id_rsa
```


## パスフレーズの変更

既存キーのパスフレーズを変更する場合は、`-p`と`-N`、`-P`を使います。  
`-f`で対象キーを指定しますが、未指定時は`id_rsa`になります。

`-p`オプションでパスフレーズの変更を要求します。  
`-N`で新しいパスフレーズを渡し、`-P`で今のパスフレーズを渡します。

```sh
$ ssh-keygen -p -f ~/.ssh/hoge_rsa -N qwer -P asdf
```

今のパスフレーズが間違っていたらエラーになります。  
`Failed to load key hoge_rsa: incorrect passphrase supplied to decrypt private key`

### パスワードとパスフレーズの違い
パスフレーズはパスワードに似てますが、一連の単語、句読点、数字、空白、文字列を含むフレーズで構成できます。

適切なパスフレーズ長さは10~30文字ぐらいです。ここの詳細は省きます。  
気になる方は別記事でセキュリティ関連の記事を参考にしてください。

パスフレーズは忘れないようにしてください。  
消失しても復元する方法はなく、新しく鍵を作る必要があります。

## コメントの変更

既存キーのコメントを変更する場合は、`-c`と`-C`を使います。  
`-f`で対象キーを指定しますが、未指定時は`id_rsa`になります。  
`-P`でパスフレーズ事前入力ができます。未指定でパスフレーズがあると対話形式で入力になります。

`-c`オプションでコメント変更を要求します。
`-C`で新しいコメントを渡します。

```sh
$ ssh-keygen -c -C 新しいコメント -f ~/.ssh/hoge_rsa -P asdf
```

## known_hostsをハッシュ化
`known_hosts`のホスト部をハッシュ化します。  
`-H`オプションを渡すことでハッシュ化されます。  
`-f`オプションでは、対象となる**known_hosts**の指定ができます。  
他のオプションでは`-f`はキーパスが多いので、ここはキーパスではないことに注意してください。

```sh
$ ssh-keygen -H -f ~/.ssh/known_hosts
```

変更前のファイルは`.old`サフィックスがついて別名保存されます。

### known_hostsをハッシュ化する目的

セキュリティの向上です。  
ホスト情報を分からなくすることで紐付けされにくくさせます。

## known_hostsから検索
ハッシュ化されたknown_hostsだと、調べたいホストがknown_hostsに登録済みか調べられません。  
`-F`オプションでknown_hostsからホスト名やホスト名:ポートに一致する行を検索します。

```sh
$ ssh-keygen -F github -lv -f ~/.ssh/known_hosts
```

`-l`オプションで出力をフィンガープリントに変更します。  
`-lv`オプションだとアスキーアートも表示されます。

## known_hostsから削除

`-R`オプションを指定することでknown_hostsからキーを削除します。  
`-f`オプションでは、対象となるknown_hostsの指定ができます。

```sh
$ ssh-keygen -R github -f ~/.ssh/known_hosts
```

テキスト形式であれば直接エディタ開いて削除できますが、ハッシュ形式だとどれか分からないため、こちらを使うことになります。


## OpenSSH形式の秘密鍵に紐づく公開鍵を標準出力に表示

`-y`オプションで秘密鍵に紐づく公開鍵を表示します。  
`-f`オプションでキー指定ができます。

```sh
$ ssh-keygen -y -f ~/.ssh/github_id_rsa
```

## 鍵のインポートとエクスポート

`-i`と`-e`オプションで鍵のインポートとエクスポートができます。  
`-f`でファイル指定をして、`-m`でファイル形式の指定ができます。

```sh
$ ssh-keygen -i -f ~/.ssh/github_id_rsa -m RFC4716
$ ssh-keygen -e -f ~/.ssh/github_id_rsa -m RFC4716
```

## ssh-keygenのオプションについて

ssh-keygenでは、一部パラメータ用オプションを使い回す傾向があります。  
ここでは使いまわしされてるパラメータ用オプションについてまとめます。

|オプション名|用途|
|---|---|
|-f|ファイルパスの指定|
|-P|パスフレーズの指定|
|-m|ファイル形式の指定|
|-q|サイレントモードの指定|
|-v|詳細モードの指定|

## ssh-keygenのオプションのデフォルト値について

ssh-keygenでは、オプション未指定だとデフォルト値を使ったり、対話形式で入力をしたりします。

ここではオプションのデフォルト値についてまとめます。

|オプション名|デフォルト値|
|-t|RSA|
|-f|id_rsaやknown_hosts|
|-C|user@host形式|
|-m|RFC4716|

## 一部パラメータ系オプションの挙動について

一部パラメータ系オプションは値に制限があったり、複数指定すると挙動が変わったりします。  
ここではそれらについてまとめます。

- `-m`
  - RFC4716(default)
  - PKCS8
  - PEM
- `-t`
  - rsa(default)
  - dsa
  - ecdsa
  - ed25519
- `-E`
  - md5
  - sha256(default)
- `-v`
  - 複数オプションを指定すると詳細度が最大で3上がります
- `-b`
  - キータイプが`RSA`の場合は1024以上、デフォルト3072ビット
  - ECDSAキーの場合は256, 384, 521ビット

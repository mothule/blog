---
title: Linuxサーバのホスト名をhostnamectlで変更する
description: CentOSやUbuntuなどLinuxサーバーをVPS等で立ち上げたとき、初期ホスト名は適当な名前になっており、管理しにくい。これをhostnamectlを使って変更や確認する方法を説明します。
categories: linux
tags: linux
image:
  path: /assets/images/2021-02-19-linux-hostnamectl/eyecatch.png
---
CentOSやUbuntuなどLinuxサーバーのホスト名を変更するには、`hostnamectl`を使います。
なおこの動作確認はCentOS8で検証しましたが、Ubuntuでも同様のようです。

bashやzshなどのシェルを使ってターミナルでサーバにSSH接続すると、
プロンプトは`[user_name@hoge-123-12345.vs.sakura.ne.jp ~]$`みたいになっており、
今どのサーバに接続してるのか分かりにくいです。
これを例えば、`[user_name@backend-api ~]$`みたいに分かりやすくします。

## 初期ホスト名は覚えにくい
VPSなどサーバ立てると、ホスト名は適当な名前が設定されます。

例えばさくらVPSだと、`hoge-123-12345.vs.sakura.ne.jp`みたいなURLだとしたら、ホスト名は`hoge-123-12345`という名前になっています。

このままでも作業に支障はありませんが、ホスト名を自分が分かりやすい名前にしておくと、複数サーバに接続しててもどのサーバに接続してるターミナルなのかすぐに見分けられるようになります。

## ホスト名を変更する
`hostnamectl set-hostname`を使うことで簡単にホスト名を変更できます。
変更後に再接続すると名前が反映されています。

```sh
$ sudo hostnamectl set-hostname <HOSTNAME>
```

## 現在のホスト名を確認する
なお、現在設定されているホスト名を確認する方法は`hostnamectl`を使うことで確認できます。

```sh
$ hostnamectl | grep hostname
   Static hostname: your_cool_host_name
 ```

 直接ファイルを変更する方法もありますが、まずは`hostnamectl`が使えるならこれを使ったほうが楽です。

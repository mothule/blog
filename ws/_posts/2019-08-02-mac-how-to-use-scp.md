---
title: MacからMacへscpを使う方法
categories: mac
tags: mac
---
MacからLinuxに対してscpを使うことをよくあるのですが、Macに対してscpを使おうとしたときに躓いたのでまとめました。
ちなみに送信元はMacでなくとも何でもいいです。

## 躓いた原因はSSH設定がGUIだったから

scpはsshを利用して暗号化通信上でファイルコピーをするコマンドなので、ssh/sshdが必要になります。
なので当初は「sshdなどをサービスをコマンドラインから立ち上げて、ポート解放の資料探せばいけるだろ〜」って考えていたのですが、実際はMacの共有GUIを使ってやる想定外の方法だったので、躓きました。


## システム環境設定の共有でSSHログインを許可する

1. システム環境設定を開く
1. 共有を開く
1. リモートログインをONにする

{% page_image -1.png 50% %}


リモートログインをONにすると、右側に接続方法が表示されるので、それを他PCからssh接続すること成功します。

{% page_image -2.png %}

これで無事scpを使うことができる。

```sh
$ scp -C /tmp/hoge.txt mothule@192.168.11.6:/tmp
hoge.txt                                  100%  227    17.8KB/s   00:00
```

## ちなみにssh許可していないとエラーになる

```sh
$ scp -C /tmp/hoge.txt mothule@192.168.11.6:/tmp
ssh: connect to host 192.168.11.6 port 22: Connection refused
lost connection
```

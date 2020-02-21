---
title: lsofでプロセスが開いてるポートやファイルを確認する方法
categories: tools lsof
tags: tools lsof
image:
  path: /assets/images/2020-02-21-tools-lsof-basic.png
---

lsofを使ってプロセスが使っているポートを確認したり、指定したファイルをどのプロセスが開いているかを確認したり、指定プロセスが開いてるファイルを確認する方法をまとめました。

## lsofとは？
lsof(for **L**i**S**t **O**pen **F** ile)  
UNIXプロセスに対して開かれているファイルに関する情報を表示します。

ファイルは様々なタイプをサポートしてます。
↓ `man lsof` より引用
> An open file may be a regular file, a directory, a block special file, a character special file, an executing text reference, a library, a stream or a net-
work file (Internet socket, NFS file or UNIX domain socket.)  A specific file or all the files in a file system may be selected by path.

今回はこの中の `a stream or a net-work file (Internet socket, NFS file or UNIX domain socket.)`


## 指定ポートを開いてるプロセスを確認

`lsof -i:[ポート番号]`で確認できます。

```sh
$ lsof -i:4000,3000,8080 -P | grep LISTEN
nginx     97024 mothule    6u  IPv4 0x9e21b4cd1c187225      0t0  TCP *:8080 (LISTEN)
nginx     97025 mothule    6u  IPv4 0x9e21b4cd1c187225      0t0  TCP *:8080 (LISTEN)
ruby      98474 mothule    9u  IPv4 0x9e21b4cd1e91bba5      0t0  TCP localhost:4000 (LISTEN)
```

- `-i:`の後にカンマ区切りでポート番号を指定します。
- `-P`でwell-known portを自動置換を無効化します。

grepで LISTENしてる理由は、CLOSEDが混じらせないため。

## 指定ファイルを開いているプロセスを確認

`lsof [path]` で確認できます。

例えばnginxのアクセスログを開いているプロセスを知りたい場合は

```sh
$ lsof /usr/local/var/log/nginx/access.log
COMMAND   PID    USER   FD   TYPE DEVICE SIZE/OFF       NODE NAME
nginx   97024 mothule    4w   REG    1,4    37496 8599850676 /usr/local/var/log/nginx/access.log
nginx   97025 mothule    4w   REG    1,4    37496 8599850676 /usr/local/var/log/nginx/access.log
```

## 指定プロセスID(PID)が開いてるファイルを確認

`lsof -p [PID]`で確認できます。

```sh
$ lsof -p 97024
COMMAND   PID    USER   FD   TYPE             DEVICE SIZE/OFF       NODE NAME
nginx   97024 mothule  cwd    DIR                1,4      512 8639303448 /Users/mothule/workspace/blog
nginx   97024 mothule  txt    REG                1,4  1180300 8665868994 /usr/local/Cellar/nginx/1.17.8/bin/nginx
nginx   97024 mothule  txt    REG                1,4   448496 8665868586 /usr/local/Cellar/pcre/8.44/lib/libpcre.1.dylib
...
```

## 指定プロセスが開いてるファイルを確認

`lsof -c [COMMAND]`で確認できます。

```sh
$ lsof -c nginx
COMMAND   PID    USER   FD     TYPE             DEVICE SIZE/OFF       NODE NAME
nginx   97024 mothule  cwd      DIR                1,4      512 8639303448 /Users/mothule/workspace/blog
nginx   97024 mothule  txt      REG                1,4  1180300 8665868994 /usr/local/Cellar/nginx/1.17.8/bin/nginx
nginx   97024 mothule  txt      REG                1,4   448496 8665868586 /usr/local/Cellar/pcre/8.44/lib/libpcre.1.dylib
nginx   97024 mothule  txt      REG                1,4   485860 8665963276 /usr/local/Cellar/openssl@1.1/1.1.1d/lib/libssl.1.1.dylib
nginx   97024 mothule  txt      REG                1,4  2265596 8665963282 /usr/local/Cellar/openssl@1.1/1.1.1d/lib/libcrypto.1.1.dylib
nginx   97024 mothule  txt      REG                1,4   973824 8628277556 /usr/lib/dyld
...
```

## まとめ

|コマンド|用途|
|---|---|
|`lsof -i:[ポート番号]`|指定ポートを開いてるプロセスを確認|
|`lsof [path]`|指定ファイルを開いているプロセスを確認|
|`lsof -p [PID]`|指定プロセスID(PID)が開いてるファイルを確認|
|`lsof -c [COMMAND]`|指定プロセスが開いてるファイルを確認|

他にも細かい指定はできるのですが、そこまで覚えなくとも上記だけでも便利です。

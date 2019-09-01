---
title: Railsとmysql@5.6で発生するmysql2インストールエラーの対処法が変わってた
categories: ruby rails
tags: ruby rails mysql
---
MySQLを最新ではなく5.6で環境構築する機会がありました。
その時にOpenSSL要因で発生するmysql2がインストールできないエラーの対処法が従来より知ってる方法ではうまく行かず別の方法に変わっていました。

## 従来は --with-ldflagsと --with-cppflags指定だった

自分が知っている方法はldflagsとcppflagsでOpenSSLのヘッダーファイル群のパスとライブラリファイル群のパスを指定する方法でした。

しかし、この方法だとエラーが発生するようになっていました。
エラーはそのコマンドは存在しないと怒られます。

```sh
$ bundle config --local build.mysql2 --with-mysql-config=/usr/local/opt/mysql@5.6/bin/mysql_config --with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include
```

## 今回は --with-opt-dir指定

上記オプション指定でエラーが発生すると候補が出て、もしやと思い試したところうまく動きました。
次の`--with-opt-dir`でOpenSSLのパスを指定する方法で試すと動きます。

```sh
$ bundle config --local build.mysql2 --with-opt-dir=/usr/local/opt/openssl
```

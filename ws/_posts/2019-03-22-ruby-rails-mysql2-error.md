---
title: rails new -d mysqlでmysql2失敗はOpenSSLを疑え(Mac)
categories: ruby rails
tags: ruby rails mysql
---
## 前提環境

- MacOS Mojave 10.14.2
- Ruby 2.3.7
  - rbenvでインストール
- MySQL 5.6.37
  - homebrewでインストール
- rails 5.0.7.2



上記構成でrailsアプリを作るときに初めからdatabaseをMySQLにしたら、いくつか失敗したのでその解消法についてまとめます。

## rails new のときに mysql を指定
デフォルトだとsqliteになってdatabase.ymlを書き直さないといけないので初めからdatabaseをmysqlに指定したい場合

```sh
$ rails new <app name> -d mysql
```
または
```sh
$ rails new <app name> -database=mysql
```


## rails newでmysql2のインストールが失敗する

```sh
$ rails new <app name> -d mysql
...
Fetching mysql2 0.5.2
Installing mysql2 0.5.2 with native extensions
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
...
checking for rb_absint_size()... yes
checking for rb_absint_singlebit_p()... yes
checking for rb_wait_for_single_fd()... yes
-----
Using mysql_config at /usr/local/opt/mysql@5.6/bin/mysql_config
-----
checking for mysql.h... yes
checking for errmsg.h... yes
checking for SSL_MODE_DISABLED in mysql.h... no
checking for MYSQL_OPT_SSL_ENFORCE in mysql.h... no
checking for MYSQL.net.vio in mysql.h... yes
checking for MYSQL.net.pvio in mysql.h... no
checking for MYSQL_ENABLE_CLEARTEXT_PLUGIN in mysql.h... yes
checking for SERVER_QUERY_NO_GOOD_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_NO_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_WAS_SLOW in mysql.h... yes
checking for MYSQL_OPTION_MULTI_STATEMENTS_ON in mysql.h... yes
checking for MYSQL_OPTION_MULTI_STATEMENTS_OFF in mysql.h... yes
checking for my_bool in mysql.h... yes
-----
Do not know how to set rpath on your system, if MySQL libraries are not in path mysql2 may not load
-----
-----
Setting libpath to /usr/local/opt/mysql@5.6/lib
-----
creating Makefile

To see why this extension failed to compile, please check the mkmf.log which can be found here:

  /Users/mothule/.rbenv/versions/2.3.7/lib/ruby/gems/2.3.0/extensions/x86_64-darwin-18/2.3.0-static/mysql2-0.5.2/mkmf.log

current directory: /Users/mothule/.rbenv/versions/2.3.7/lib/ruby/gems/2.3.0/gems/mysql2-0.5.2/ext/mysql2
make "DESTDIR=" clean

current directory: /Users/mothule/.rbenv/versions/2.3.7/lib/ruby/gems/2.3.0/gems/mysql2-0.5.2/ext/mysql2
make "DESTDIR="
compiling client.c
compiling infile.c
compiling mysql2_ext.c
compiling result.c
compiling statement.c
linking shared-object mysql2/mysql2.bundle
ld: library not found for -lssl
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [mysql2.bundle] Error 1

make failed, exit code 2

Gem files will remain installed in /Users/mothule/.rbenv/versions/2.3.7/lib/ruby/gems/2.3.0/gems/mysql2-0.5.2 for inspection.
Results logged to /Users/mothule/.rbenv/versions/2.3.7/lib/ruby/gems/2.3.0/extensions/x86_64-darwin-18/2.3.0-static/mysql2-0.5.2/gem_make.out

An error occurred while installing mysql2 (0.5.2), and Bundler cannot continue.
Make sure that `gem install mysql2 -v '0.5.2' --source 'https://rubygems.org/'` succeeds before bundling.

In Gemfile:
  mysql2
         run  bundle exec spring binstub --all
Could not find gem 'mysql2 (< 0.6.0, >= 0.3.18)' in any of the gem sources listed in your Gemfile.
```

↑よく見ると、どうやら失敗してそうなのはOpenSSL周りが怪しそう↓
```
checking for SSL_MODE_DISABLED in mysql.h... no
checking for MYSQL_OPT_SSL_ENFORCE in mysql.h... no
...
ld: library not found for -lssl
```

## brewでopensslがインストールされてなければ、opensslをインストールする
```sh
$ brew install openssl
```

## bundle configでmysql2のビルドオプションを変更する
bundleに対してmysql2インストール時に先程インストールしたopnesslのlibとheaderのパスを指定すれば良いらしい
**しかしbundleはおろかrails newも未実行なのでbundle configはできない。**
```sh
$ bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include"
```


## rails newでのbundle installをしないようにする
mysql2へのビルドコンフィグを設定できるためにbundle installはスキップさせたい。
これは簡単に出来る。

```sh
rails new <app name> --skip-bundle
```
これだけでbundle installが実行されなくなる。

## 改めてbundle configでmysql2のビルドコンフィグを設定

```sh
$ bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include"
```

## bundle installを実行
```sh
$ bundle install -j4 --path=vendor/bundle
```

これで初期状態からmysqlをdatabaseにしたrailsアプリが出来上がると思います。

うまくいかない場合は別の要因かもしれません。

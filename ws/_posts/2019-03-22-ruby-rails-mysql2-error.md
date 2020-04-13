---
title: Ruby on Railsのmysql2エラーはOpenSSLを疑え(Mac)
description: Mac上でRuby on Railsのrails newでDatabaseはMySQL使ったらmysql2でインストールエラー起きたので調査してOpenSSLの問題特定とbundle configを使ったビルドにOpenSSLパスを渡して解決する手順などをまとめました。
categories: ruby rails
tags: ruby rails mysql
image:
  path: /assets/images/2019-03-22-ruby-rails-mysql2-error.png
---
この記事はMac上でRuby on Railsで新しくアプリケーションを作る時にデータベースをMySQLを指定したらmysql2 gemが失敗したので調査したらOpenSSLに問題があったのでその時に調べたことをまとめた記事です。

## rails newのmysql2インストールが失敗する

ことの始まりは、Ruby on Railsでアプリを調査する必要があったため、MySQLの古いバージョンでRailsアプリケーションを作成しました。
しかし、MySQLアダプタであるmysql2 gemのインストールでエラーが発生しました。

構築しようとしたときの環境は次の通りです。

### 前提環境

- MacOS Mojave 10.14.2
- Ruby 2.3.7
  - rbenvでインストール
- MySQL 5.6.37
  - homebrewでインストール
- rails 5.0.7.2

MySQLのバージョンが5.6系と非常に古いバージョンになります。

### rails newのときにMySQLを指定
データベースはデフォルトだとSQLiteになってdatabase.ymlを書き直さないといけないので初めからdatabaseをmysqlに指定したい場合は、`-d` または `--database` オプションで`mysql`を指定します。

```sh
$ rails new <app name> -d mysql
```

`<app name>`は適当にアプリ名を入れてください。
このコマンドを実行します。

### mysql2 gemのインストールに失敗する

コマンドを実行すると次のようなエラーログが出力されます。

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

このログを見ると、どうやら失敗してそうなのはOpenSSL周りが怪しそうです。以下は怪しそうな箇所をログ抜粋したもの

```
checking for SSL_MODE_DISABLED in mysql.h... no
checking for MYSQL_OPT_SSL_ENFORCE in mysql.h... no
...
ld: library not found for -lssl
```

{% comment %}
`
{% endcomment %}


`no`と言われてますし、 なにより`ld`コマンドでライブラリがないと言ってます。  
ちなみにldコマンドの`-l`オプションでは`ssh`が指定された場合は`libssl.a`というファイルを検索します。  
そのためここでは`libssl.a`ファイルが見つからないということになります。


## mysql2のsslエラー原因を調査する

仮にSSLが原因だと仮定して調査します。  
ではなぜsslエラーが起きているのでしょうか？

### OpenSSLがインストールされているか確認する

Macで使われるSSLライブラリはOpenSSLとなります。  
このライブラリがインストールされているかを確認します。  
確認方法は`openssl version`でバージョン返せばインストールされてることを確認できます。  
私の環境では次のバージョンです。

```sh
$ openssl version
LibreSSL 2.6.5
```

#### OpenSSLとはツールキットである
OpenSSLとは、TLS/SSLツールキットであり汎用暗号ライブラリです。  
様々ながプラットフォームで利用可能なため一般的に広く認知されています。

`LibreSSL`とは過去のハートブリード問題をうけてOpenSSLからフォークされたライブラリです。

### brewでOpenSSLをインストールする

もしOpenSSLが未インストールであるならHomebrewを使って、次のコマンドで簡単にインストールできます。

```sh
$ brew install openssl
```

インストールが終わったらきちんと動くか`openssl version`で確認してみてください。

### mysql2インストールのリンクで見つけられるようにする
OpenSSLをインストールしただけではmysql2のインストール時にどこにあるのか分からないままなので失敗してしまいます。  
そのためインストールの工程の一つであるビルド時にOpenSSLのライブラリとヘッダーのパス情報を渡してあげる必要があります。

通常でgemでのインストール時にパス情報を渡しますが、今回はbundler配下なのでbundleを通してパス情報を渡します。

## mysql2のビルド設定にOpenSSLパスを渡す

仮定ではありますが、mysql2のビルド時にSSLライブラリのパスが通っていないと見越して、ビルド設定にOpenSSLのパスを渡すことをトライしてみましょう。

### bundle configでOpenSSLパス情報を渡す

bundleを通してパス情報を渡すには、`bundle config`を使い次のように渡します。

```sh
$ bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include"
```

`build.mysql2` とすることでmysql2のビルド時に後ろの文字列を引数として渡すことができます。
`--local`とすることでこのディレクトリだけの設定となります。

**▼もしこの引数の渡し方でダメな場合は、新しい方法で試してみてください。mysql2が新しくなったことで渡すオプションも変わっています。**  
{% post_link 2019-07-30-ruby-rails-mysql56-mysql2-error-fix %}

### rails newでのbundle installをしないようにする

既に`rails new`を実行済みであれば前述した`bundle config`は使えます。  
**しかしbundleはおろかrails newも未実行なのでbundle configはできないです。**

`rails new`すると`mysql2`が失敗する。しかし`mysql2`にビルドコンフィグを渡すには`rails new`が必要…というデッドロック状態です。  
**これを回避するには、`rails new`のときに`bundle install`をスキップさせます。**  
これはオプションで`--skip-bundle`を追加するだけで`bundle install`がスキップされます。

```sh
$ rails new <app name> --skip-bundle
```

これで`rails new`実行完了後に改めて`bundle config`でパス情報を渡します。

## mysql2にSSLパスを通してbundle installを実行
OpenSSLをインストール済みの状態で、`rails new`を`--skip-bundle`で実行、`bundle config`でOpenSSLライブラリのパス情報を渡す設定をした状態で、もう一度`bundle install`で`mysql2`のインストールをトライとなります。

```sh
$ bundle install -j4 --path=vendor/bundle
```

これで初期状態からMySQLをDatabaseにしたRailsアプリが出来上がると思います。

## rails newでmysql2エラーの対処法まとめ

エラー要因でOpenSSLが怪しい場合は次の対処を試してみてください。

1. OpenSSLをインストール
1. `rails new`を`--skip-bundle`で実行
1. `bundle config`で`mysql2`のビルド設定にOpenSSLライブラリのパスを渡す
1. `bundle install`実行

うまくいかない場合は別の要因かもしれません。

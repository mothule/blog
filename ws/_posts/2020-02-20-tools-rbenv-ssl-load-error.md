---
title: OpenSSL Library not loadedが出たら疑う場所
categories: tools rbenv
tags: tools rbenv ruby
image:
  path: /assets/images/2020-02-20-tools-rbenv-ssl-load-error.png
---
今回あることをしてRails実行したらOpenSSLがロードされないエラーが発生しました。
この記事は何をしたらこのエラーが起きたのか？何をしたらこのエラーを対処できたのかをまとめました。

```
LoadError:
  dlopen(/Users/mothule/workspace/piglet/vendor/bundle/ruby/2.5.0/gems/mysql2-0.5.2/lib/mysql2/mysql2.bundle, 9): Library not loaded: /usr/local/opt/openssl/lib/libssl.1.0.0.dylib
```

## 何をしたのか？
homebrew管理下のnginxを更新(`$ brew upgrade nginx`)しました。


### homebrewでnginxの依存関係を調べる

homebrewには管理してるformulaがどのformulaを使っているのか依存関係を調べることができます。

下記はその機能を使って、nginxがどのformulaに依存してるのかを調べた結果です。

{% comment %}
homebrewの機能を記事にする
{% endcomment %}

```sh
$ brew deps nginx
openssl@1.1
pcre
```

どうやらnginxをバージョン更新した際に依存関係であるopensslに何らかの更新が入り、Ruby/Railsで使われているopensslに影響が起きたようです。

## 原因調査
自分が調べて対処した順番に書いていきます。
解決した項目だけを実施しても解決しないかも知れません。
なぜなら問題が複数ケースだったり、順番に実施した内容のなかで必要手順が含まれていたのかもしれないからです。

### Ruby再インストール(解決せず)
ネットで調べたところ、 Rubyに紐づくopensslが外れた事で読み込めなくなっているのではないか？と仮説にたどり着きました。
Rubyはrbenvで管理しているため、rbenvで対象バージョンを再インストールすることで再紐付けされないか？と試してみることにしました。

{% comment %}
rbenvの機能を記事にする
{% endcomment %}

```sh
$ rbenv install <ruby version>
```

しかし解決はしませんでした。

### シンボリックリンクを用意(解決せず)

OpenSSLのライブラリ置き場を確認したら次のように`1.0.0`版なくなってました。

```sh
$ ls -lkh /usr/local/opt/openssl/lib/
total 7236
drwxr-xr-x  4 mothule  staff   128B  9 10 22:13 engines-1.1
-r--r--r--  1 mothule  staff   2.2M  2 20 21:43 libcrypto.1.1.dylib
-r--r--r--  1 mothule  staff   3.7M  9 10 22:13 libcrypto.a
lrwxr-xr-x  1 mothule  staff    19B  9 10 22:13 libcrypto.dylib -> libcrypto.1.1.dylib
-r--r--r--  1 mothule  staff   474K  2 20 21:43 libssl.1.1.dylib
-r--r--r--  1 mothule  staff   704K  9 10 22:13 libssl.a
lrwxr-xr-x  1 mothule  staff    16B  9 10 22:13 libssl.dylib -> libssl.1.1.dylib
drwxr-xr-x  5 mothule  staff   160B  2 20 21:43 pkgconfig
```

どうやら存在しないバージョンファイルに対してアクセスをしているため失敗しているようです。

強引ですが、試しにシンボリックリンクで1.1版に向けてみたら動かないか試してみました。  
**と思ったのも、セマンティック バージョニングなら1.0.0から1.1はマイナーバージョンアップになるので、運が良ければ破壊変更はないからです。（それでも将来的に考えたらこの方法はNGです）**

```sh
$ ln -s libssl.1.1.dylib libssl.1.0.0.dylib
$ ln -s libcrypto.1.1.dylib libcrypto.1.0.0.dylib
```

こちらで試しましたが、MySQLの起動が失敗するようになりました。

### MySQLが起動しないことが発覚
ガサツな方法だと解決できない根深さなようなので本腰入れて調べることにしました。

エラーログを確認すると、opensslはmysql2 gemがopensslを使おうとしてエラーを起こしています。

```
LoadError:
  dlopen(/Users/mothule/workspace/piglet/vendor/bundle/ruby/2.5.0/gems/mysql2-0.5.2/lib/mysql2/mysql2.bundle, 9): Library not loaded: /usr/local/opt/openssl/lib/libssl.1.0.0.dylib
```

まず問題を特定するために、そもそもMySQLが起動するかを確認しましたが、MySQLが起動(`$ mysql.server start`)しなくなっていました。

MySQLは都合上最新ではなく MySQL5.6を使っており、homebrewで管理しています。
なので再インストールをしてみることにしました。

```sh
$ brew reinstall mysql@5.6
```

**MySQLは立ち上がるようになりました。** しかしRailsは以前変わらず起動しません。

### mysql2 gem を再インストール

前述したようにエラーはmysql2で起きてます。 MySQLが動くようになったので、今度はRubyとMySQLのアダプターとなる`mysql2`を再インストールしました。

gem直接ではなくbunlder管理なのでbundlerから経由で指示します。

```sh
$ bundle exec gem uninstall mysql2
$ bundle install
```

結果は変わらず起動していませんが、エラー内容が少し変わりました。

### ついに動いた

エラー内容がマイグレーション関係のエラーだったので、マイグレーションを走らせました。

```sh
$ bin/rake db:migrate:reset db:seed
```

これで起動したらついに動きました。

## それぞれのopensslのパスがズレていた？
振り返ってみると、nginxを更新したことでopensslが更新され、MySQL,ruby,mysql2とそれぞれでopensslのパスがズレたことが原因じゃないかと見ています。

なので、どれか一つではなく、複数の対処で解決したんじゃないかと思ってます。

## OpenSSL Library not loadedが出たときの対処法

今回自分が行った対処一覧となります。

1. `$ brew reinstall mysql@5.6`
2. `$ rbenv install 2.5.7 && gem install bundler -v "2.0.2"`
3. `$ bundle`
4. `$ bundle exec gem uninstall mysql2`
5. `$ bundle`
6. `$ bin/rake db:migrate:reset db:seed RAILS_ENV=test`

全ての環境で解決はしないと思いますが、その場合は自分のように原因領域の特定と仮説、試行の繰り返しが重要です。

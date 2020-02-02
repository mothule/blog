---
title: MySQL5.6でActiveRecordのencodingがutf8mb4だとKey長すぎ問題の対応
categories: ruby rails active-record
tags: ruby rails active-record mysql
image:
  path: /assets/images/2019-08-02-ruby-rails-activerecord-fix-mysql56-encode-utf8mb4-key-too-length.png
---
charsetをutf8からutf8mb4に変更したことでindexのキーが長過ぎると言われるようになりました。

ちなみに環境はRails5系 + MySQL5.6系環境で、`databases.yml`の`encoding`を`utf8mb4`にすると `db:migrate`でエラーが出ます。
```
Mysql2::Error: Index column size too large. The maximum column size is 767 bytes.
```

新しいアプリを用意するたびに忘れ対応方法だけを調べて対応するといった、行きあたりばったりの対応ばかりしてたので、今回メモ兼調査をしてみることにしました。

## そもそもなぜ767バイトなのか？

そもそもなんで767バイトなのか気になりますよね。

まずencodingがutf8の場合1文字は3バイトです。
しかし、これがutf8mb4だと1文字4バイトになるため、 255 * 4 = 1020バイトとなり、767バイトをオーバーしてしまいます。

では、255という数字はどこから来てるかというと、
ActiveRecordのテーブル定義で使う `t.string` は MySQLだと `VARCHAR(255)` に変換されます。ここの最大数から来てます。

じゃぁなぜ255なのか？というと
MySQL(InnoDB)では最大値が767バイト制限がそもそも敷かれています。
[公式サイト](https://dev.mysql.com/doc/refman/5.6/ja/innodb-restrictions.html)ではこう書いてあります。

> デフォルトでは、単一カラムインデックスのインデックスキーを最大で 767 バイトにすることができます。

続けてこう書いてあります。

> たとえば、UTF-8 文字セットと文字ごとに最大 3 バイトを使用すると仮定すれば、TEXT または VARCHAR カラム上で 255 文字よりも長いカラムプリフィクスインデックスを使用すると、この制限に達する可能性があります。

つまり ActiveRecordが `VARCHAR(255)` にしているのは、この制限を超えないためですね。
しかし`databases.yml` の `encoding` が `t.string` に反映されないのは少し不便かと思いますね。
MySQL(InnoDB) + utf8mb4 で `db:migrate` が呼ばれたら、 `VARCHCAR(191)`にするかもしくは、警告してくれると便利なのになぁと思いました。

### 原因から見えてくる対処法2つ

原因が分かったところで、解決方法は次の２つが候補として挙げられます。

- 対象カラムの文字最大数を制限する
- カラムのcharsetをutf8に戻す
- MySQLのキー最大長を伸ばす

## 対象カラムの文字最大数を制限する
1つは目は対象となるカラムに対して文字数を制限することで1020バイトを超えないようにする方法です。
指定しなければ `VARCHAR(255)` なら指定すればいいって考えですね。

この場合の最大文字数は767 / 4 = 191.75なので、 191文字にすることでエラーを回避できます。
例えばテーブル`users`の`name`カラムに対して制限かけたい場合は、コードにするとこんな感じですね。

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 191
      t.timestamps
    end

    add_index :users, :name
  end
end
```

## カラムのcharsetをutf8に戻す

`encoding` で `utf8mb4` にすると全部のテーブル対象になるので、一部カラムだけを `utf8` にしようって話です。

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, charset: :utf8
      t.timestamps
    end

    add_index :users, :name
  end
end
```


## MySQLのキー最大長を伸ばす

MySQLにはキーの最大長を拡張する機能があります。その機能を使うことでキー最大長を**3072**バイトまで伸ばすことができます。(つまりutf8mb4だと3072 / 4 = 768文字ですね)

### `innodb_large_prefix` で `3072`バイトに伸ばす


`innodb_large_prefix`オプションを指定することで、長さの制限が3072バイトに伸ばせます。
以下[公式](https://dev.mysql.com/doc/refman/5.6/ja/innodb-restrictions.html)より
> innodb_large_prefix 構成オプションを有効にすると、DYNAMIC および COMPRESSED 行フォーマットを使用する InnoDB テーブルで、この長さ制限が 3072 バイトに上昇します。

しかし、いくつか制限があります。

* ストレージエンジンが InnoDB であること
* 行フォーマットが `DYNAMIC` か `COMPRESSED` であること

まずストレージエンジンについてですが、MySQLのデフォルトストレージエンジンは、

* `MySQL5.5`以前は`MyISAM`
* `MySQL5.5`以上は`InnoDB`

になります。[公式](https://dev.mysql.com/doc/refman/5.6/ja/innodb-default-se.html)
ストレージエンジンの変更方法は今回は省略します。(自分が使うのは5.6だったので)

### `innodb_file_format`を`Barracuda`にする

行フォーマットはMySQL5.0.3以降(InnoDB)のデフォルトは `COMPACT`になっているので、これを`DYNAMIC`か`COMPRESSED`へ変える必要があります。
そして`DYNAMIC`か`COMPRESSED` に変更するには、ファイルフォーマット(`innodb_file_format`)が`Barracuda`である必要があります。
なぜなら`Antelope`では対応しておらず`Barracuda`が対応しているフォーマットだからです。

これは[公式](https://dev.mysql.com/doc/refman/5.6/ja/innodb-file-format-enabling.html)に書いてあります。

> innodb_file_format パラメータは現在、Antelope および Barracuda ファイル形式をサポートしています。テーブル圧縮や新しい DYNAMIC 行フォーマットなどの、Barracuda ファイル形式によってサポートされる機能を利用する新しいテーブルを作成するには、innodb_file_format を BARRACUDA に設定します。

またデフォルトが `Antelope`だということも続けて記載されてあります。
> 可能な場合、新しいテーブルには Barracuda 形式を使用することをお勧めしますが、MySQL 5.5 では、異なる MySQL リリースを含むレプリケーション構成との最大限の互換性のために、デフォルトのファイル形式は引き続き Antelope です。

ちなみに `MySQL5.7`以降は `innodb_file_format`のデフォルトは`Barracuda` になるのでこの変更は不要になります。

### `innodb_file_per_table`を有効にする

また `innodb_file_per_table`オプションがOFFだと `Baraccuda`が適用されず `Antelope`になるので、このオプションもONにします。
`MySQL5.6.6`以上ならデフォルトONなのでこの記述は不要ですが、パッチバージョンによる変更で気づいてる方は少ないかと思うので、明示的に記述しておいてもいいかと思います。

### つまりまとめると

* MySQL 5.6
  * `innodb_file_per_table` を有効化して `Barracuda`が使える準備
  * `innodb_file_format` を `Barracuda` に変更して `innodb_large_prefix`が使える準備
  * `innodb_large_prefix` を有効化
* MySQL 5.7
  * `innodb_large_prefix` を有効化

となります。

## オプションをmy.cnf で指定する

コマンドラインでMySQL起動時にオプション指定でも可能ですが、`my.cnf`の方が楽なのでそっちで指定します。

**my.cnf**  
```
innodb_file_per_table = 1
innodb_file_format = Barracuda
innodb_large_prefix
```

`my.cnf`の場所が分からない場合は `$ mysql --help | grep my.cnf` でパスが並ぶので好きな場所の `my.cnf` に追記してください。

保存したら MySQLを再起動します。

## Rails側も弄る必要がある

これで終わりではありません。MySQL側の準備が整っただけであり、テーブル作成する側つまりRails側の設定が必要になります。

と言ってもテーブルが1つ2つであれば単純です。

`create_table`メソッドに `options`で指定するだけです。

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, options: 'ROW_FORMAT=DYNAMIC' do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :users, :name
  end
end

```

ここまで来てテーブルを作成すると、無事エラーは出なくなりutf8mb4として動きます。

```
mysql> show create table users;
+-------+-----------------------------------------------------------+
| Table | Create Table                                                                                                                                                                                                                                                                                    |
+-------+-----------------------------------------------------------+
| users | CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC |
+-------+-----------------------------------------------------------+
1 row in set (0.00 sec)
```

ちなみに既存テーブルの場合はALTER TABLEで変更する必要があります。

キー長を伸ばす方法は長々と面倒に思えますが、

* my.cnfに3行追加
* migrationの各create_tableにoptions追加

で解決するのでやってみると思ってたより楽です。

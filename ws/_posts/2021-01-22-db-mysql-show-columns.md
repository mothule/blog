---
title: MySQLでテーブルのカラムを表示して確認する
description: MySQLでテーブル(TABLE)のカラム(COLUMNS)を一覧で表示して確認できるステートメントSHOW COLUMNSやDESCRIBEについて簡単な使い方や詳細な使い方、注意事項についてまとめてます。
image:
  path: /assets/images/2021-01-22-db-mysql-show-columns/eyecatch.png
categories: db mysql
tags: db mysql
---
MySQLでテーブルのカラム一覧を表示するには、`SHOW COLUMNS`ステートメントを使います。  
`SHOW COLUMNS`構文は指定したテーブル内のカラム情報を表示します。  
これはビューのカラムも表示します。

## MySQLのSHOW COLUMNSステートメントの構文
`SHOW [FULL] COLUMNS {FROM | IN} tbl_name [{FROM | IN} db_name] [LIKE 'pattern | WHERE expr]`

`[]`は任意で、`{|}`はどちらかを選択になります。

## MySQLのSHOW COLUMNSの実行例
次の例は、USEステートメントでDB`hoge_development`を選択したのちに`SHOW COLUMNS`を実行してます。

```sh
mysql> show columns from users;
+-----------------+--------------+------+-----+---------+----------------+
| Field           | Type         | Null | Key | Default | Extra          |
+-----------------+--------------+------+-----+---------+----------------+
| id              | bigint(20)   | NO   | PRI | NULL    | auto_increment |
| email           | varchar(255) | YES  |     | NULL    |                |
| password_digest | varchar(255) | YES  |     | NULL    |                |
| created_at      | datetime(6)  | NO   |     | NULL    |                |
| updated_at      | datetime(6)  | NO   |     | NULL    |                |
+-----------------+--------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)
```

### DB名とテーブル名のFROM句を結合する
`db_name`と`tbl_name`を`.`で繋ぐことができます。次の2つは同等です。

```sh
mysql> show full columns from users from hoge_development;
mysql> show full columns from hoge_development.users;
```

## SHOW COLUMNSのLIKE句で表示カラムを絞る
構文内にある`LIKE`句を使うことで表示カラムを選択できます。  
`LIKE`句はカラム名と照合します。

```sh
mysql> show columns from users like '%_at';
+------------+-------------+------+-----+---------+-------+
| Field      | Type        | Null | Key | Default | Extra |
+------------+-------------+------+-----+---------+-------+
| created_at | datetime(6) | NO   |     | NULL    |       |
| updated_at | datetime(6) | NO   |     | NULL    |       |
+------------+-------------+------+-----+---------+-------+
2 rows in set (0.01 sec)
```

## SHOW COLUMNSのFULL修飾子でCollation(照合順序)とPrivileges(権限)とComment(コメント)を追加表示する
構文内にあるFULL装飾子がついた`SHOW FULL COLUMNS`を使うことで出力カラムにCollation(照合順序)とPrivileges(権限)とComment(コメント)を表示します。

```sh
mysql> show full columns from users;
+-----------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
| Field           | Type         | Collation          | Null | Key | Default | Extra          | Privileges                      | Comment |
+-----------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
| id              | bigint(20)   | NULL               | NO   | PRI | NULL    | auto_increment | select,insert,update,references |         |
| email           | varchar(255) | utf8mb4_general_ci | YES  |     | NULL    |                | select,insert,update,references |         |
| password_digest | varchar(255) | utf8mb4_general_ci | YES  |     | NULL    |                | select,insert,update,references |         |
| created_at      | datetime(6)  | NULL               | NO   |     | NULL    |                | select,insert,update,references |         |
| updated_at      | datetime(6)  | NULL               | NO   |     | NULL    |                | select,insert,update,references |         |
+-----------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
5 rows in set (0.00 sec)
```

## SHOW COLUMNSが表示する値の説明
`SHOW COLUMNS`や`SHOW FULL COLUMNS`が表示する値について説明します。

### Field(フィールド)
`Field`フィールドはテーブルのカラム名です。

### Type(カラムデータ型)
`Type`フィールドはカラムデータの型です。

### Collation(照合順序)
`Collation`フィールドは文字列カラムの照合順序です。文字列でもバイナリは除きます。  
その他の型の場合はNULLになります。

この値は`FULL`装飾子を使ったときだけ表示されます。

### Null
`Null`フィールドはNULLを格納できるかどうかを示します。  
NULLを設定できる場合は`YES`、できない場合は`NO`が表示されます。

### Key
`Key`フィールドはこのカラムのインデックス設定を`(空)/PRI/UNI/MUL`のいずれかで示します。

#### Keyが空の場合
インデックス未設定か、
#### KeyがPRIの場合
`PRIMARY KEY`か、`マルチカラムPRIMARY KEY`の一つです。

#### KeyがUNIの場合
`UNIQUE`インデックスです。  

`NULL`は複数の存在を許してしまいます。  
もし困る場合は、`Null`が`NO`にして`NULL`自体を拒否してください。
#### KeyがMULの場合
特定の値が複数存在することを許可した一意(ユニーク)ではないインデックスの最初のカラムです。

### Default
`Default`フィールドはカラムのデフォルト値です。  
デフォルト値がNULLだったり、カラム定義に`DEFAULT`句がない場合は`NULL`が表示されます。

### Extra
`Extra`フィールドは追加情報が含まれます。  
この値が空以外になるのは、次のケースです。

- `AUTO_INCREMENT`属性を持つカラムだと`auto_increment`が表示されます。
- `ON UPDATE CURRENT_TIMESTAMP`属性を持つ`TIMESTAMP`または`DATETIME`カラムだと`on update CURRENT_TIMESTAMP`が表示されます。

### Privileges(権限)
`Privileges`フィールドはユーザーがカラムに持っている権限を示します。  
この値は`FULL`装飾子を使ったときだけ表示されます。

### Comment(コメント)
`Comment`フィールドは任意のコメントを示します。  
この値は`FULL`装飾子を使ったときだけ表示されます。

## SHOW COLUMNSをWHERE句で表示カラムを絞る
構文内にある`WHERE`句を使うことで表示カラムを選択できます。  
テーブル`users`から`Type`カラムに対して照合すると次のようになります。

```sh
mysql> show columns from users where Type like '%char%';
+-----------------+--------------+------+-----+---------+-------+
| Field           | Type         | Null | Key | Default | Extra |
+-----------------+--------------+------+-----+---------+-------+
| email           | varchar(255) | YES  |     | NULL    |       |
| password_digest | varchar(255) | YES  |     | NULL    |       |
+-----------------+--------------+------+-----+---------+-------+
2 rows in set (0.00 sec)
```

## 注意: SHOW COLUMNSは権限がないカラムは表示されない
カラムに対する権限を持っていない場合は、`SHOW COLUMNS`の結果に表示されません。

## その他同様のステートメント
構文にもあるように`SHOW COLUMNS`と`SHOW FIELDS`は同じ処理を行います。

また`DESCRIBE`ステートメントも`SHOW COLUMNS`と同じ情報を提供できます。  
さらに、`DESCRIBE`と`EXPLAIN`と`DESC`はシノニム(代替名)です。  
つまり、次の行は全て同じ結果を返します。

```sh
mysql> show columns from users;
mysql> show fields from users;
mysql> describe users;
mysql> explain users;
mysql> desc users;
```

ただし、`SHOW FULL COLUMNS`で追加表示されるカラムは、`DESCRIBE`ステートメントには表示されません。


## MySQLのmysqlshowコマンドでも取得可能
ターミナル上で`mysqlshow`コマンドを実行することで、同様にMySQLのカラム一覧を表示できます。

```sh
$ mysqlshow -uroot hoge_development users
Database: hoge_development  Table: users
+-----------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
| Field           | Type         | Collation          | Null | Key | Default | Extra          | Privileges                      | Comment |
+-----------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
| id              | bigint(20)   |                    | NO   | PRI |         | auto_increment | select,insert,update,references |         |
| email           | varchar(255) | utf8mb4_general_ci | YES  |     |         |                | select,insert,update,references |         |
| password_digest | varchar(255) | utf8mb4_general_ci | YES  |     |         |                | select,insert,update,references |         |
| created_at      | datetime(6)  |                    | NO   |     |         |                | select,insert,update,references |         |
| updated_at      | datetime(6)  |                    | NO   |     |         |                | select,insert,update,references |         |
+-----------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
```

ただし、`SHOW COLUMNS` のように`LIKE`や`WHERE`句は使えません。


## 最も手軽にテーブル構造を確認するのはDESCステートメント
前述された情報から考えて、最もタイプ数が少なくて、手軽にテーブル構造を確認する方法は`DESC`ステートメントを使うことです。

```sh
mysql> desc users;
```

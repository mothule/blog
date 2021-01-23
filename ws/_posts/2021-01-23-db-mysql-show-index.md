---
title: MySQLでテーブルのインデックスを表示して確認する
description: MySQLのテーブル(TABLE)のインデックス(INDEX)を表示して確認できるステートメントSHOW INDEXについて簡単な使い方や詳細な使い方、注意事項についてまとめてます。
image:
  path: /assets/images/2021-01-23-db-mysql-show-index/eyecatch.png
categories: db mysql
tags: db mysql
---
MySQLでテーブルのインデックスを表示するには、`SHOW INDEX`ステートメントを使います。  
`SHOW INDEX`構文は指定したテーブル内のインデックス情報を表示します。

## MySQLのSHOW INDEXステートメントの構文

`SHOW {INDEX | INDEXES | KEYS} {FROM | IN} tbl_name [{FROM | IN} db_name] [WHERE expr]`

`[]`は任意で、`{|}`はどちらかを選択になります。  
`{FROM | IN}`であれば`FROM`か`IN`どちらかを使えます。

`INDEX`と`INDEXES`、そして`KEYS`はどれを選んでも結果は同じです。  
`INDEXES`と`KEYS`は`INDEX`のシノニム(代替名)です。

## SHOW INDEXの実行例
USEステートメントでDB`hoge_development`を選択したのちに`SHOW INDEX`を実行してます。

```sh
mysql> show index from tokens;
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table  | Non_unique | Key_name                | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| tokens |          0 | PRIMARY                 |            1 | id          | A         |           1 |     NULL | NULL   |      | BTREE      |         |               |
| tokens |          0 | index_tokens_on_value   |            1 | value       | A         |           1 |     NULL | NULL   | YES  | BTREE      |         |               |
| tokens |          1 | index_tokens_on_user_id |            1 | user_id     | A         |           1 |     NULL | NULL   | YES  | BTREE      |         |               |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)
```

### DB名とテーブル名のFROM句を結合する
`db_name`と`tbl_name`を`.`で繋ぐことができます。次の2つは同等です。

```sh
mysql> show index from users from hoge_development;
mysql> show index from hoge_development.users;
```

## MySQLのSHOW INDEXで表示される項目

|項目名|説明|
|---|---|
|Table|テーブル名です。|
|Non_unique|重複許可を表します。重複可能:1, 重複不可:0|
|Key_name|インデックスの名前。このインデックスが主キーなら、常に PRIMARY です。|
|Seq_in_index|インデックス内のカラムシーケンス番号であり、1から始まります。|
|Column_name|カラム名です。|
|Collation|インデックス内カラムのソート方法。`A`なら`昇順`, `NULL`なら`ソートされない`のどちらかです。|
|Cardinality|インデックス内のユニーク数の推定値。統計値なため必ずしも正確ではない。この値が高いほど結合時にこのインデックス利用可能性が高くなります。|
|Sub_part|カラムが部分的インデックス設定されてるときの文字の数。カラム全体がインデックス設定されている場合は NULLが入ります。|
|Packed|キーがパックされる方法を示します。パックされない場合は NULL。|
|Null|このカラムに`NULL`を含められるなら`YES`、含められないなら空白が入ります。|
|Index_type|使用されるインデックス方法 (BTREE、FULLTEXT、HASH、RTREEのいずれかです)。|
|Comment|各カラムで説明されていないこのインデックスに関する情報|
|Index_comment|このインデックスが作成されたときに COMMENT 属性で設定された任意のコメント。|

この中でよく確認したりチューニング時に見る項目は次の項目が多いかと思います。  
`Table`、`Non_unique`、`Key_name`、`Column_name`、`Cardinality`、`Sub_part`、`Null`

インデックスの条件等を確認するなら、次の項目あたりになります。
- Table
- Non_unique
- Key_name
- Column_name
- Null

チューニングでインデックスの状態を確認するなら、次の項目あたりになります。
- Cardinality
- Sub_part

## SHOW INDEXをWHERE句で表示テーブルを絞る

構文内にある`WHERE`句を使うことで表示インデックスを選択できます。  
テーブル`tokens`から`Key_name`カラムに対して照合すると次のようになります。

```sh
mysql> show index from tokens where Key_name like 'index_%';
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table  | Non_unique | Key_name                | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| tokens |          0 | index_tokens_on_value   |            1 | value       | A         |           1 |     NULL | NULL   | YES  | BTREE      |         |               |
| tokens |          1 | index_tokens_on_user_id |            1 | user_id     | A         |           1 |     NULL | NULL   | YES  | BTREE      |         |               |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)
```

## 注意: SHOW INDEXは権限がない場合は表示されない
カラムに対する権限を持っていない場合は、`SHOW INDEX`の結果に表示されません。

## MySQLのmysqlshowコマンドでも取得可能
ターミナル上で`mysqlshow -k db_name tbl_name`コマンドを実行することで、テーブルのインデックスを一覧表示できます。

```sh
$ mysqlshow -uroot -k hoge_test tokens
Database: hoge_test  Table: tokens
+------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
| Field      | Type         | Collation          | Null | Key | Default | Extra          | Privileges                      | Comment |
+------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
| id         | bigint(20)   |                    | NO   | PRI |         | auto_increment | select,insert,update,references |         |
| value      | varchar(256) | utf8mb4_general_ci | YES  | UNI |         |                | select,insert,update,references |         |
| user_id    | bigint(20)   |                    | YES  | MUL |         |                | select,insert,update,references |         |
| created_at | datetime(6)  |                    | NO   |     |         |                | select,insert,update,references |         |
| updated_at | datetime(6)  |                    | NO   |     |         |                | select,insert,update,references |         |
+------------+--------------+--------------------+------+-----+---------+----------------+---------------------------------+---------+
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table  | Non_unique | Key_name                | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| tokens | 0          | PRIMARY                 | 1            | id          | A         | 1           |          |        |      | BTREE      |         |               |
| tokens | 0          | index_tokens_on_value   | 1            | value       | A         | 1           |          |        | YES  | BTREE      |         |               |
| tokens | 1          | index_tokens_on_user_id | 1            | user_id     | A         | 1           |          |        | YES  | BTREE      |         |               |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
```

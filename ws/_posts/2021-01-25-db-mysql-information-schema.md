---
title: MySQLのINFORMATION_SCHEMA STATISTICSでインデックスを表示して確認する
description: MySQLのINFORMATION_SCHEMAデータベース内にあるSTATISTICSテーブルを表示して、インデックス情報を確認する方法についてまとめてあります。
image:
  path: /assets/images/2021-01-25-db-mysql-information-schema/eyecatch.png
categories: db mysql
tags: db mysql
---
MySQLのインデックスを確認する方法として、`SHOW INDEX`ステートメントがありますが、  
他にもMySQLのINFORMATION_SCHEMAデータベース内にあるSTATISTICSテーブルを表示して、インデックス情報を確認する方法があります。

## MySQLのINFORMATION_SCHEMAは情報データベース

INFORMATION_SCHEMAは、「MySQLサーバが保持する全てのデータベース」に関する情報を格納するデータベースです。
次のMySQLサーバに関する情報を提供します。

- データベースの名前
- テーブルの名前
- カラムのデータ型
- アクセス権限

## INFORMATION_SCHEMAのSTATISTICSはテーブルインデックスの情報を持つ
`STATISTICS`テーブルの構造を見てみます。

```sh
mysql> desc statistics;
+---------------+---------------+------+-----+---------+-------+
| Field         | Type          | Null | Key | Default | Extra |
+---------------+---------------+------+-----+---------+-------+
| TABLE_CATALOG | varchar(512)  | NO   |     |         |       |
| TABLE_SCHEMA  | varchar(64)   | NO   |     |         |       |
| TABLE_NAME    | varchar(64)   | NO   |     |         |       |
| NON_UNIQUE    | bigint(1)     | NO   |     | 0       |       |
| INDEX_SCHEMA  | varchar(64)   | NO   |     |         |       |
| INDEX_NAME    | varchar(64)   | NO   |     |         |       |
| SEQ_IN_INDEX  | bigint(2)     | NO   |     | 0       |       |
| COLUMN_NAME   | varchar(64)   | NO   |     |         |       |
| COLLATION     | varchar(1)    | YES  |     | NULL    |       |
| CARDINALITY   | bigint(21)    | YES  |     | NULL    |       |
| SUB_PART      | bigint(3)     | YES  |     | NULL    |       |
| PACKED        | varchar(10)   | YES  |     | NULL    |       |
| NULLABLE      | varchar(3)    | NO   |     |         |       |
| INDEX_TYPE    | varchar(16)   | NO   |     |         |       |
| COMMENT       | varchar(16)   | YES  |     | NULL    |       |
| INDEX_COMMENT | varchar(1024) | NO   |     |         |       |
+---------------+---------------+------+-----+---------+-------+
16 rows in set (0.00 sec)
```

## SHOW INDEXとほぼ結果は同じ
下記は`hoge_development`データベースの`tokens`テーブルのインデックス情報を表示した結果です。

```sh
mysql> select * from statistics where table_schema = 'hoge_development' and table_name = 'tokens';
+---------------+-----------------------+------------+------------+-----------------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+----------+------------+---------+---------------+
| TABLE_CATALOG | TABLE_SCHEMA          | TABLE_NAME | NON_UNIQUE | INDEX_SCHEMA          | INDEX_NAME              | SEQ_IN_INDEX | COLUMN_NAME | COLLATION | CARDINALITY | SUB_PART | PACKED | NULLABLE | INDEX_TYPE | COMMENT | INDEX_COMMENT |
+---------------+-----------------------+------------+------------+-----------------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+----------+------------+---------+---------------+
| def           | hoge_development | tokens     |          0 | hoge_development | PRIMARY                 |            1 | id          | A         |           3 |     NULL | NULL   |          | BTREE      |         |               |
| def           | hoge_development | tokens     |          1 | hoge_development | index_tokens_on_user_id |            1 | user_id     | A         |           3 |     NULL | NULL   | YES      | BTREE      |         |               |
+---------------+-----------------------+------------+------------+-----------------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+----------+------------+---------+---------------+
2 rows in set (0.00 sec)
```

出力されるカラム名は異なりますが、`SHOW INDEX`ステートメントと値は同じものになります。

```sh
mysql> show index from tokens from hoge_development;
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table  | Non_unique | Key_name                | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| tokens |          0 | PRIMARY                 |            1 | id          | A         |           3 |     NULL | NULL   |      | BTREE      |         |               |
| tokens |          1 | index_tokens_on_user_id |            1 | user_id     | A         |           3 |     NULL | NULL   | YES  | BTREE      |         |               |
+--------+------------+-------------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)
```

## 複数テーブルのインデックスを表示して確認できる
`SHOW INDEX`は一つのテーブルに対するインデックス情報を表示しますが、`INFORMATION_SCHEMA STATISTICS`を使うとデータベースを横断してアクセスするため、  
`Where`で絞り込むことで複数テーブルのインデックス情報を表示して確認できます。


## インデックス情報の確認は大抵はSHOW INDEXで事足りる
`INFORMATION_SCHEMA STATISTICS`テーブルを使えば多くの情報を得られますが、インデックスを調べるだけであれば、大抵は`SHOW INDEX`ステートメントで事足ります。

`SHOW INDEX`ステートメントの詳細は、「{% post_link_text 2021-01-23-db-mysql-show-index %}」にまとめてあります。

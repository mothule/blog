---
title: MySQLのテーブル一覧を表示して確認する
description: MySQLのテーブル(TABLE)を一覧で表示して確認できるステートメントSHOW TABLESについて簡単な使い方や詳細な使い方、注意事項についてまとめてます。
image:
  path: /assets/images/2021-01-22-db-mysql-show-tables/eyecatch.png
categories: db mysql
tags: db mysql
---
MySQLのテーブル一覧を表示するには、`SHOW TABLES`構文を使います。  
`SHOW TABLES`構文は、特定データベース内の*TEMPORARY*以外のテーブルを一覧表示します。  
また、ビューも一覧表示します。

## MySQLのSHOW TABLES構文
`SHOW [FULL] TABLES [{FROM | IN} db_name] [LIKE 'pattern' | WHERE expr]`

`[]`は任意で、`{|}`はどちらかを選択になります。

## SHOW TABLESの実行例
USE構文でDB`hoge_development`を選択したのちに`SHOW TABLES`を実行してます。

```sh
mysql> show tables;
+---------------------------------+
| Tables_in_hoge_development      |
+---------------------------------+
| active_admin_comments           |
| active_storage_attachments      |
| active_storage_blobs            |
| ar_internal_metadata            |
| schema_migrations               |
| hoges                           |
| tokens                          |
| users                           |
+---------------------------------+
8 rows in set (0.00 sec)
```

## SHOW TABLESのLIKE句で表示テーブルを絞る

構文内にある`LIKE`句を使うことで表示テーブルを選択できます。  
先程のテーブル名から先頭に`active` と入るテーブル名を選択する場合は次のようになります。

```sh
mysql> show tables like 'active_%';
+--------------------------------------------+
| Tables_in_hoge_development (active_%)      |
+--------------------------------------------+
| active_admin_comments                      |
| active_storage_attachments                 |
| active_storage_blobs                       |
+--------------------------------------------+
3 rows in set (0.00 sec)
```

## SHOW TABLESのFULL修飾子でテーブルタイプを追加表示する

構文内にあるFULL装飾子がついた`SHOW FULL TABLES`を使うことで出力カラムにテーブルタイプを表示します。

```sh
mysql> show full tables;
+---------------------------------+------------+
| Tables_in_hoge_development      | Table_type |
+---------------------------------+------------+
| active_admin_comments           | BASE TABLE |
| active_storage_attachments      | BASE TABLE |
| active_storage_blobs            | BASE TABLE |
| ar_internal_metadata            | BASE TABLE |
| schema_migrations               | BASE TABLE |
| hoges                           | BASE TABLE |
| tokens                          | BASE TABLE |
| users                           | BASE TABLE |
+---------------------------------+------------+
8 rows in set (0.00 sec)
```

テーブルタイプ(Table_type)の値は、テーブルかビューで変わります。
- テーブルは`BASE TABLE`
- ビューは`VIEW`

## SHOW TABLESをWHERE句で表示テーブルを絞る

構文内にある`WHERE`句を使うことで表示テーブルを選択できます。  
先程のテーブル名から`users`テーブルを選択する場合は次のようになります。

```sh
mysql> show tables where Tables_in_hoge_development = 'users';
+---------------------------------+
| Tables_in_hoge_development      |
+---------------------------------+
| users                           |
+---------------------------------+
1 row in set (0.00 sec)
```
また、FULL装飾子をつけてテーブルタイプ(Table_type)を追加すれば、同様に条件として使えます。

## 注意: SHOW TABLESは権限がない場合は表示されない
テーブルやビューに対する権限を持っていない場合は、`SHOW TABLES`の結果に表示されません。

## MySQLのmysqlshowコマンドでも取得可能
ターミナル上で`mysqlshow`コマンドを実行することで、同様にMySQLのテーブル一覧を表示できます。

```sh
$ mysqlshow -uroot hoge_development
Database: hoge_development
+----------------------------+
|           Tables           |
+----------------------------+
| active_admin_comments      |
| active_storage_attachments |
| active_storage_blobs       |
| ar_internal_metadata       |
| schema_migrations          |
| hoges                      |
| tokens                     |
| users                      |
+----------------------------+
```

ただし、`SHOW TABLES` のように`LIKE`や`WHERE`句は使えません。

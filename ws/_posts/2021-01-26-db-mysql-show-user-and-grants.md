---
title: MySQLユーザーの一覧や権限を表示して確認する
description: MySQLユーザーの情報を一覧で表示したり、ユーザーの持つ権限を表示して確認する方法についてまとめた記事です。
image:
  path: /assets/images/2021-01-26-db-mysql-show-user-and-grants/eyecatch.png
categories: db mysql
tags: db mysql
---
MySQLユーザーの一覧表示や、ユーザーが持つ権限を表示する方法について整理します。

## MySQLユーザー情報を一覧表示する
MySQLのユーザー情報を表示するには、`mysql`データベースの`user`テーブルを表示します。  
次のステートメントは、ユーザー名`main`の`Host`と`User`カラムを表示してます。

```
mysql> select host, user from mysql.user;
+-----------+------+
| host      | user |
+-----------+------+
| localhost | main |
+-----------+------+
1 row in set (0.00 sec)
```

`Host`と`User`にもカラムはありますが、量が多いので省略します。


## MySQLユーザーの権限を表示して確認する
MySQLのユーザー権限を表示するには、`SHOW GRANTS`ステートメントを使います。  
次のステートメントは`main@localhost`の権限を表示してます。

```sh
mysql> show grants for main@localhost;
+------------------------------------------+
| Grants for main@localhost                |
+------------------------------------------+
| GRANT USAGE ON *.* TO 'main'@'localhost' |
+------------------------------------------+
1 row in set (0.00 sec)
```

`GRANT USAGE ON *.* TO 'main'@'localhost'`とは権限がないことを表します。

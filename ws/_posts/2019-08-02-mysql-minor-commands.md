---
title: 忘れるのに定期的に必要になるMySQLコマンド
categories: db mysql
tags: db mysql
---

普段はRailsでMySQLを操作してるため、使わないし覚えてなくても開発に支障が出ることは少ないのに、開発環境スイッチしたことでマイグレーションが失敗とか、explainでindex漏れがないかとか、**定期的に必要になるコマンド** ってありますよね。
毎度忘れては検索して調べてるので、いい加減メモっておこうと思います。

## インデックス

### 指定テーブルのインデックスを確認

```sql
SHOW INDEX FROM table_name
```

例： `users`テーブルを見た場合 (nameにindexがある)

<a href="/assets/images/2019-08-02-mysql-minor-commands-1.png"><img src="/assets/images/2019-08-02-mysql-minor-commands-1.png" alt="SHOW INDEX FROM users;" width="100%"></a>

### 指定テーブルのインデックス削除

```
mysql> ALTER TABLE table_name DROP INDEX index_name
```

例： `users`テーブルの`name`インデックスを消す場合
```
mysql> ALTER TABLE users DROP INDEX index_users_on_name;
```

## テーブル定義


### 指定テーブルのカラム情報を確認する(簡易)

```
mysql> DESC table_name
```
実は DESC と EXPLAIN は同義であり、 explain に差し替えても動きます。

例： `users`テーブルを見た場合
```
mysql> desc users;
+------------+--------------+------+-----+---------+----------------+
| Field      | Type         | Null | Key | Default | Extra          |
+------------+--------------+------+-----+---------+----------------+
| id         | bigint(20)   | NO   | PRI | NULL    | auto_increment |
| name       | varchar(255) | YES  |     | NULL    |                |
| created_at | datetime     | NO   |     | NULL    |                |
| updated_at | datetime     | NO   |     | NULL    |                |
+------------+--------------+------+-----+---------+----------------+
4 rows in set (0.01 sec)
```

### 指定テーブルのカラム情報を確認する(詳細)
```
mysql> SHOW FULL COLUMNS FROM table_name
```


例： `users`テーブルを見た場合

<a href="/assets/images/2019-08-02-mysql-minor-commands-2.png"><img src="/assets/images/2019-08-02-mysql-minor-commands-2.png" alt="SHOW FULL COLUMNS FROM users;" width="100%"></a>

### 指定テーブルの作成時のクエリー表示

```
mysql> SHOW CREATE TABLE table_name
```


例： `users`テーブルを見た場合

```
mysql> show create table users;
+-------+-------------------------------------------------------+
| Table | Create Table                                          |
+-------+-------------------------------------------------------+
| users | CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |
+-------+-------------------------------------------------------+
1 row in set (0.00 sec)
```



## テーブル操作

### データを削除する

```
mysql> DELETE FROM table_name [WHERE where_condition]
```


## 設定系

[MySQLのmy.cnfの場所を見つける]({% post_url 2019-08-02-mysql-find-mycnf %})
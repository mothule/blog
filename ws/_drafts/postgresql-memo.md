---
title: PostgreSQLメモ
categories: postgresql
tags: postgresql
---

# PostgreSQLのInformation表示
```bash
$ heroku pg:info --app kawakatei-heroku
```

テーブル一覧表示
```bash
$ \dt;
```

### PostgreSQLの消費容量を確認する方法
テーブルのブロックサイズを確認
```bash
# show block_size;
```

テーブルのページ数を表示
```bash
# SELECT relname, relfilenode, relpages from pg_class;
```
relpagesの値 * ブロックサイズ

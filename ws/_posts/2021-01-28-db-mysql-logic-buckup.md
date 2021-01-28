---
title: MySQLサーバからmysqldumpで論理バックアップを作成する
description: MySQLデータベースサーバ上のテーブル構造やデータをmysqldumpコマンドを使って論理バックアップする方法について説明します。
image:
  path: /assets/images/2021-01-28-db-mysql-logic-buckup/eyecatch.png
categories: db mysql
tags: db mysql
---
MySQLデータベースサーバからデータベースを論理バックアップするには、`mysqldump`コマンドを使います。ただ呼ぶだけでなく、いくつかオプションをつけることでより効果良くします。

## 論理バックアップとは？

物理バックアップのようにデータファイルをコピーせず、テーブル構造とデータを再生成できるCREATE TABLE や INSERT などのステートメントが含まれたバックアップです。

### 物理バックアップと比べたデメリット

データサイズが大きくなってくると、リストアに時間がかなりかかる。

## mysqldumpコマンドで論理バックアップファイルを作成

バックアップファイルといってもDDLとDMLが書かれたSQLファイルです。

フォーマットは次のようにします。

```sh
mysqldump -u <ユーザ名> --databases <DB名> -p --host <DBサーバIP> -P <ポート番号> --quick --single-transaction --quote-names --ignore-table=<無視テーブル名1> --ignore-table=<無視テーブル2> > 出力ファイル名.sql
```

少しオプションが多いですが、いくつかオプションをが入っていることで、安全面や速度の効果を期待できます。

いくつかのオプションをデフォルトで動くケースではオプション数を減らせます。
例えばlocalhostのMySQLにrootで全テーブルをバックアップする場合は次のようになります。

```sh
mysqldump -uroot hoge_database --quote-names --single-transaction > hoge.sql
```

## 使用するオプション

`mysql`コマンドで既に使ったことのあるオプションは省略します。

### `--quick`オプション

テーブルのレコードをバッファせず1行ずつダンプする。デフォルトで有効なので、明示的にする目的以外では指定しなくても問題ありません。

なお`--skip-quick`を使用すれば、ダンプ前にテーブル内容をメモリにバッファリングしますが、サイズの大きいテーブルがあるとメモリ不足を起こします。

### `--single-transaction`オプション

一貫した状態でダンプする。ただし、InnoDBテーブルのみ有効。

MyISAMテーブルを含むDBでは効果がないですが、MySQL5.6からはデフォルトストレージエンジンはInnoDBとなってるので気にするケースは少ないかと思います。

なお、MyISAMテーブルを含むDBでは、--lock-tablesか--lock-all-tablesを使います。

### `--ignore-table`オプション

指定されたテーブルはダンプの対象から外れます。
複数テーブル指定は複数個オプションを渡します。

### `--quote-names`オプション

識別子を逆引用符文字(バックティック)で囲みます。識別に予約ワードが含まれても問題を起こさないようにします。

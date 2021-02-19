---
title: CentOS8にMySQL8をインストールして構築する
description: Linuxディストリビューションの1つであるCentOSのバージョン8にMySQLバージョン8をインストールしたときの手順を説明します。
categories: db mysql
tags: db mysql linux centos
image:
  path: /assets/images/2021-02-19-db-mysql-install-mysql8-on-centos8/eyecatch.png
---
CentOS8にMySQLをインストールします。なお当時のバージョンは8です。
公式からインストールする方法もありますが、ここではyumにあるバージョンを使います。

## Linux自体の初期セットアップは済ませておく
ローカルPCであれば問題はないですが、VPSなど外部にLinuxサーバを立てた場合は、MySQL環境の前にLinux自体のセキュリティセットアップを実施することをおすすめします。

セットアップに関しては、「{% post_link_text 2021-02-19-linux-centos-centos8-setup-secure-server %}」にまとめてあります。

## MySQL Serverをインストールする
yumパッケージを更新したのちにMySQLをインストールします。

```sh
$ sudo yum -y upgrade
$ sudo yum -y install mysql mysql.server
$ mysql --version
mysql  Ver 8.0.21 for Linux on x86_64 (Source distribution)
$ systemctl status mysqld.service
● mysqld.service - MySQL 8.0 database server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
```

カーネル更新は避けたい人は`upgrade`の代わりに`yum -y update --exclude=kernel*`を実行します。

OSパッケージによってはMariaDBがインストール済みの可能性があります。
その場合は事前にアンインストールしてからMySQLをインストールしてください。

## MySQLの起動と自動起動を有効化する

インストール完了したら起動します。
起動が確認できたら自動起動を有効化します。

```sh
$ systemctl start mysqld.service
$ systemctl enable mysqld
```

なお起動の確認方法は、`$ mysql -uroot -p`でlocalhostからrootに接続できれば起動しています。

## mysql_secure_installationでセキュリティ改善する

`mysql_secure_installation`とはMySQLのセキュリティを改善させるスクリプトです。
MySQLのインストール後に実行します。

英語でのウィザードになりますが、このスクリプトで実施するのは次の項目です。

- `root` のパスワード設定
- localhost以外からの`root`ログインを禁止
- 匿名ユーザーアカウントの削除
- `test` DBの削除と`test_`プリフィックスのDBへのアクセス権削除

セキュリティ強度の方向性が分からない場合は、本番運用想定し英数字記号大文字小文字混じりの超長いパスワードを設定して、localhost外からの`root`ログイン禁止、匿名ユーザー削除、テストDBの削除にしておいたほうが無難です。

実際の実行結果を質問別＆コメント付きで掲載します。

### 要約: パスワード強化しますか？

```sh
$ mysql_secure_installation

Securing the MySQL server deployment.

Connecting to MySQL using a blank password.

VALIDATE PASSWORD COMPONENT can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD component?

Press y|Y for Yes, any other key for No: y
```

### 要約: パスワード強度のポリシーを選んでください

パスワードを設定する前にどのぐらいの強度にしたいのか強さをLOW, MEDIUM, STRONGから設定します。
設定したらそのまま希望するパスワードを入力します。

```sh
There are three levels of password validation policy:

LOW    Length >= 8
MEDIUM Length >= 8, numeric, mixed case, and special characters
STRONG Length >= 8, numeric, mixed case, special characters and dictionary                  file

Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 2
Please set the password for root here.

New password:

Re-enter new password:

Estimated strength of the password: 100
Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) : y

```

### もしパスワードがポリシーの定める強さより脆弱な場合

入力したパスワードが前に設定したパスワードポリシーが定める強さより脆弱な場合は、エラーとなり再入力となります。

```sh
Estimated strength of the password: 50
Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) : y
 ... Failed! Error: Your password does not satisfy the current policy requirements

New password:

Re-enter new password:

```

### 要約: 匿名ユーザーを削除しますか？

MySQLではテストやインストールを円滑にすすめるために簡易にMySQLにアクセスできる匿名ユーザーが作成されてあります。

このユーザーは本番では当然不要なので削除します。

```sh
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Success.
```

### 要約：localhost外からのログインを禁止しますか？

デフォルトでは、外部環境からrootアカウントにログインできます。しかしこれは危険なため禁止します。

```sh
Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
Success.
```

### 要約：テストDBを削除しますか？

匿名ユーザー同様にテスト用途としてテストDBがあります。これも本番環境では不要なので削除します。

```sh
By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.

Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
 - Dropping test database...
Success.

 - Removing privileges on test database...
Success.
```

### 要約: この結果を確定しますか？

最後にこのスクリプトでの変更を反映させるかの確認です。
特に問題なければ確定し反映させます。

```sh
Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.

All done!
```

なお、`mysql_secure_installation`に関しては公式リファに説明があります。
[MySQL 5.6 リファレンスマニュアル - MySQL インストールのセキュリティー改善]([https://dev.mysql.com/doc/refman/5.6/ja/mysql-secure-installation.html](https://dev.mysql.com/doc/refman/5.6/ja/mysql-secure-installation.html))

## MySQLユーザーを作成する
Linuxユーザー同様にMySQLでの操作にrootアカウントは使いません。
権限やアクセス領域を絞ったユーザーを作成します。

なおIPアドレスは接続元のホスト情報です。
未指定だと`%`となりどのホストからもアクセスできるユーザーとなります。

```sql
mysql> create user 'user'@'123.456.789.012' identified by 'strong_password';
Query OK, 0 rows affected (0.01 sec)
mysql> select user, host from mysql.user;
+------------------+-----------------+
| user             | host            |
+------------------+-----------------+
| user             | 123.456.789.012 |
| mysql.infoschema | localhost       |
| mysql.session    | localhost       |
| mysql.sys        | localhost       |
| root             | localhost       |
+------------------+-----------------+
5 rows in set (0.00 sec)
```

### ユーザーパスワードが脆弱な場合

作成するユーザーのパスワードは、`mysql_secure_installation`で定めたパスワードポリシーにジュンクする必要があります。そのため脆弱だとエラーとなります。

```sh
mysql> create user 'user'@'host' identified by 'hogehoge';
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
```

## MySQLユーザーに権限付与する

作成したMySQLユーザーに権限を付与します。
ユーザーを作成しただけでは権限を持っていないため、何もできません。

構文：`grant 権限 on DB.テーブル to ユーザー`

次の例は`your_db_name` DBの全テーブルに対する全権限を`'user'@'123.456.789.012'`に付与してます。ちなみに存在しないDB名でも権限付与できます。

```sh
mysql> grant all on your_db_name.* to 'user'@'123.456.789.012';
Query OK, 0 rows affected (0.00 sec)
```

なお構文を間違えてたり指定が無効だったりするとエラーが起きます。
ちなみに次のエラーは付与先のユーザー指定がミスってます。

```sh
mysql> grant all on your_db_name.* to 'user@123.456.789.012';
ERROR 1410 (42000): You are not allowed to create a user with GRANT
```

`show grants`を使えば権限を確認できます。
先程付与した権限とは別に`USAGE`という権限があります。
これは「権限なし」という意味です。

```sql
mysql> show grants for user@123.456.789.012;
+---------------------------------------------------------------------------------+
| Grants for user@123.456.789.012                                                 |
+---------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `user@123.456.789.012`                                    |
| GRANT ALL PRIVILEGES ON `your_db_name`.* TO `user@123.456.789.012`              |
+---------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
```

を使えば権限を剥奪できます。
allを剥奪します。

```sql
mysql> revoke all on your_db_name.* from 'user'@'123.456.789.012';
Query OK, 0 rows affected (0.00 sec)

mysql> show grants for user@123.456.789.012;
+---------------------------------------------------+
| Grants for user@123.456.789.012;                  |
+---------------------------------------------------+
| GRANT USAGE ON *.* TO `user`@`123.456.789.012`    |
+---------------------------------------------------+
1 row in set (0.00 sec)
```

### 権限設計をどうするか？

権限が細かすぎてALLにしたくなる気持ちがありますが、Railsからアクセスなどシステムによるアクセスの場合は、Railsでよく使う権限を付与しておきシステム特性に合わせて随時追加する形が楽だと思います。

またマーケティング部署など非エンジニアやDBスキルの低い人がSQLを叩く場合は、SELECTなど読み取り系の権限で構成になると思います。

権限はたくさんあります。詳しくは[公式のGRANT および REVOKE に対して許容可能な権限]([https://dev.mysql.com/doc/refman/5.6/ja/grant.html#grant-privileges](https://dev.mysql.com/doc/refman/5.6/ja/grant.html#grant-privileges))を確認してください。

### FLUSH PRIVILEGESの有無

ネット記事によっては、grantの後に`FLUSH PRIVILEGES;` を実行してるのをよく見かけます。
ただ、[公式]([https://dev.mysql.com/doc/refman/5.6/ja/privilege-changes.html](https://dev.mysql.com/doc/refman/5.6/ja/privilege-changes.html))の説明を見ると分かりますが、`GRANT、REVOKE、SET PASSWORD、RENAME USER`などのアカウント管理ステートメントの場合は、自動でリロードするので不要です。

必要なタイミングは、`INSERT、UPDATE、DELETE`ステートメントで直接権限テーブルを更新したときです。

## 作成したMySQLユーザーで接続確認する

MySQLユーザーを作成したら実際にアクセスして疎通確認します。
例えばMySQLサーバを立てたサーバのIPが`123.123.123.123`だとします。

```sql
$ mysql -u user -h 123.123.123.123 -p
```

### 接続エラーは要因が多い

MySQLの接続エラーは特定が困難です。何らかの原因で接続エラーが起きると接続失敗の旨のみ表示されます。

```
ERROR 2003 (HY000): Can't connect to MySQL server on '123.123.123.123' (113)
```

ここではすべてのパターンは掲載しませんが、一部掲載します。

- ユーザーが異なる
    - 接続しようとしてるMySQLユーザーが間違っていないか？
    - ユーザー名は合っててもホストがあっているか？
- ホスト(IPアドレス)が異なる
    - 接続先DBサーバのホスト(IP)があっているか？
- firewalldで許可されてない
    - MySQLサービスまたは使用ポートが許可されてるか？
    - firewalldの許可サービスに`mysql`またはポート(3306/tcp)が含まれているか？
- ポート番号が異なる
    - デフォルト3306から変更してるなら`-P`オプションで指定してるか？
    - 指定したポートが間違っていないか？

## DBはインフラの中で比較的よく触る
これでCentOS上にMySQLをインストール、稼働させることが出来たと思います。
ただし、構築して終わりではなくWeb開発の現場では、MySQLなどのデータベースは他のインフラと比べて、比較的触る頻度が多いです。
理由としては、RailsなどWebアプリケーションの実装の影響を受けやすく、Webパフォーマンスに影響するため、スロークエリを調べたりEXPLAINでインデックスが効いているか確認したりと、チューニング作業が発生するためです。

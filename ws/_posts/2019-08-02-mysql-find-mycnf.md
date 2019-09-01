---
title: MySQLのmy.cnfの場所を見つける
date: 2019-08-02
categories: mysql
tags: mysql
---
初期環境構築時など必ずと言っていいほど弄る多いmy.cnfですが、パスがなんだったか毎回忘れてしまっています。
しかし、この方法ならどこにパスが書いてあるかを覚えていれば環境毎にパスが変わっても同様に見つけ出すことができます。

## 結論

```sh
$ mysql --help | grep my.cnf
```

## ヘルプに書いてる

実はヘルプを見ると長文の中にひっそり書かれています。


```sh
$ mysql --help
...省略...

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
The following groups are read: mysql client

...省略...
```

なので後は検索して抽出すれば欲しい情報をちょっとブサイクですが表示することができます。
↓だと3行目ですね。左から順に読み込まれます。

```sh
$ mysql --help | grep my.cnf
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
```

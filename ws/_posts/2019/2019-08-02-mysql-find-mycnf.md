---
title: MySQLの複数あるmy.cnfの場所全部を覚えず調べる方法
categories: db mysql
tags: db mysql
image:
  path: /assets/images/2019-08-02-mysql-find-mycnf/0.png
---
環境構築などでほぼ必ず弄るmy.cnfですが、my.cnfのパスを毎回忘れてしまいます。しょっちゅう触るファイルでもないので忘れてしまうのは仕方ないですね。
しかもmy.cnfは複数配置をサポートしているため、毎回覚えるのは大変です。

この記事では、複数あるmy.cnfの場所を確認する方法について説明します。
この方法ならどこにパスが書いてあるかを覚えていれば環境毎にパスが変わっても同様に見つけ出すことができます。

## my.cnfは複数配置をサポートしてる
MySQLのmy.cnfは1箇所だけでなく決められた複数パスに対してファイルアクセスを試みて存在してたらロードを行います。  
この順番と場所を把握しておかないと、**自分の知っているmy.cnfの変更しても反映されない** などの穴にハマります。

初めて環境構築する場合は基本的に複数のmy.cnfが配置されることはないのでこの穴にハマることはないですが、
途中からチームに参加した人だとハマる可能性があります。

**「設定ファイルを変更するだけの作業で反映されないで何時間も時間掛かってしまう」はあるあるです**

## my.cnfの場所と読み込む順番は記載されてる
実はMySQLがmy.cnfファイルにアクセスを試みるパス場所は、MySQLコマンドのヘルプを見ると長文の中にひっそり書かれています。  
下記はヘルプの実行結果を抜粋したものです。

```sh
$ mysql --help
...省略...

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
The following groups are read: mysql client

...省略...
```

MySQLは決められた順番でmy.cnfを読み込みます。場所はOSによって変わります。
次の順番はMacでの読み込み順番とmy.cnfの場所になります。

1. `/etc/my.cnf`
1. `/etc/mysql/my.cnf`
1. `/usr/local/etc/my.cnf`
1. `~/.my.cnf`

この順番でmy.cnf読み込みます。

## シェルだけでmy.cnfの場所と順番を確認する方法
MySQLのヘルプに記載されてることが分かれば、後は検索して抽出すれば欲しい情報をちょっとブサイクですが表示することができます。  
下記はgrepでmy.cnfを検索した結果です。grep結果2行目が場所と順番になります。

```sh
$ mysql --help | grep my.cnf
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
```

シェルについて分からない方は「{% post_link_text 2020-02-05-shellscript-basic-for-mobile-enginner %}」を読んでみてください。

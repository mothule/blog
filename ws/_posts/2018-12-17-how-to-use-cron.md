---
title: cronの書き方
categories: tools
tags: tools cron
image:
  path: /assets/images/2018-12-17-how-to-use-cron.png
---
crond だけでなく何かと色んな所で出てくる cron 記法
毎回検索しても欲しい記法見つけるのに時間かかるのでほぼ自分用に書いた。

## フォーマット

```sh
分 時 日 月 曜日 コマンド
```

## 日時の範囲

|時間|値範囲|
|---|---|
|分|0~59|
|時|0~23|
|日|1~31|
|月|1~12 or jan~dec|
|曜日|0~7 or sun ~ sat|

###  `*` はどの値にも当てはまる
```sh
* * * * * <command>
```

### `,` で区切ると複数時間を指定できる

**月曜と水曜のみ実行**
```sh
* * * * 1,3 <command>
```

### `*` を `/` で割ると一定時間おきに実行する
**3時間置きに実行**
```sh
* */3 * * * <command>
```
※ この記法は Linux だと動かないかも

## 登録されてるcron一覧

カレントユーザーのcron一覧は `crontab` に `-l` オプションをつけるだけです。
```sh
$ crontab -l
```

### 指定ユーザーのcron一覧
ユーザー指定する場合は `-u` で指定します。
権限ないとエラーになるのでsudoつけます。

```sh
$ sudo crontab -u <user name> -l
```


#### 権限なし
```sh
$ crontab -u <user name> -l
crontab: must be privileged to use -u
```

---
title: 古いPCにLinux(CentOS 7)をUSBメモリでインストールしてプリンターサーバーとして再生させる
categories: linux centos
tags: linux centos printer
image:
  path: /assets/images/2018-12-10-replace_oldpc_to_printer_server.png
---

こないだ断捨離してたら独身の頃買ったネットブックを発見。
長らく使っておらず今後も予定なかったので、破棄も考えたのですが比較的使っているプリントサーバとして勉強がてら復活させました。

色々ネットで調べながら構築したのですが、ネットでは見つからなかったり、躓いたり、情報が散らばって進めにくかったのでまとめました。

## 環境

|機器|名称|
|---|---|
|PC|acer の Aspire 1410|
|プリンター|iP2700|
|OS|Windows 7 64bits版|
|作業PC|Mac|
|USBメモリ|4GB|

## 構築したプリントサーバ

Windows 7 がインストールされてる 内部HDD を CentOS 7 64bits Minimal で上書き。
GUIはなしです。
プリンターはPCにUSBケーブルで接続します。
system-config-printer は GUI なのでそれ以外の方法で構築します

## 注意
PC内のデータやOSは全て削除されます。

## イメージファイルをダウンロード
特別記載することはないですね。 CentOS のページからダウンロードするだけです。
[Download CentOS](https://www.centos.org/download/)
ちなみに Minimal にした理由は２つあって

1. 手持ちのUSBフラッシュメモリの容量不足
1. 足りないパッケージや環境などを自分で構築するため

のためなので、特にそういった目的不要であれば フルパッケージ版を入れてもいいと思います。

## イメージファイルをUSBフラッシュメモリに書き込む

### USBメモリの初期化

ディスク一覧を確認
```bash
$ diskutil list
```

MS_DOS(FAT)形式で初期化
ディスク一覧で確認したパーティションが `/dev/disk2` だとしたら
```bash
$ diskutil eraseDisk MS-DOS UNTITLED /dev/disk2
```

マウント解除
```bash
$ diskuntil unmountDisk /dev/disk2
```

ISOイメージをUSBメモリに書き込む
ここで Finder 上でisoイメージファイルをコピペしても認識されません。
ddコマンド使って書き込む。

以下は isoイメージファイルが ~/Downloads/centos.iso とした場合
```bash
$ sudo dd if=~/Downloads/centos.iso of=/dev/disk2 bs=4028
```

ディスク取り出し
```bash
$ diskutil eject /dev/disk2
```

## BIOSのブート順序を変える
1. PCの電源を入れてF2を押しておき、F12が押せるように設定を変更
2. 再起動してF12を押しておき、ブートディスクをUSBメモリを1番上に移動

## yum を使う準備
```bash
$ yum update
$ yum install epel-release
$ yum install wget
```
権限エラーの場合はsudo つけてください

## CUPSをインストール
```bash
$ yum install cups cups-devel
```
権限エラーの場合はsudo つけてください

### 次のような必要ファイルが見つからない場合は
```実行コマンド = rpm -Uvh ./packages/cnijfilter-common-3.30-1.i386.rpm
エラー: 依存性の欠如:
	libcups.so.2 は cnijfilter-common-3.30-1.i386 に必要とされています
	libpopt.so.0 は cnijfilter-common-3.30-1.i386 に必要とされています
```

```bash
$ yum provides libcups.so.2
```
のようにすることで内包してるパッケージ名を確認できます。

### PCからプリンタのUSBケーブルを抜くとCUPSの設定が無効になる
CUPSウェブ管理上では変化ないが印刷しても反応しない
再設定すると印刷される

### Macのプリンタ設定で見つからない場合
プリンターサーバーに avahi をインストールしてみてください。


## CUPSを設定

`vi /etc/cups/cupsd.conf`

```
Listen localhost:631
```
を
```
# Listen localhost:631
Listen 631
```
にする

```
<Location /></Location>
```
の間に `Allow From All` 末尾を追加
```
<Location /admin></Location>
```
の間に `Allow From All` 末尾を追加
```
<Location /admin/conf></Location>
```
の間に `Allow From All` 末尾を追加

## CUPS起動
プリンタ電源を入れておこう

USBにプリンタが接続されているか確認
```bash
lsusb
```


```bash
$ systemctl start cups
```

## Firewalld で IPP のポートを開ける

### サービス確認

```bash
$ firewall-cmd --get-services
```

### IPP が定義されてれば追加
```bash
$ firewall-cmd --add-service=ipp --permanent
$ firewall-cmd --reload
```

## Linux用プリンタードライバーをインストール
[https://cweb.canon.jp/drv-upd/ij-sfp/bjlinux330-ip2700.html:title] から rpm をダウンロードします
```bash
$ wget http://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDEwMDAwMjcxNjAx&cmp=ACM&lang=JA
```
ダウンロードしたファイルはホームフォルダにあります。
適宜名前を変更してください。

```bash
$ rpm -vhU --nodeps --force <rpm name>
```

CentOSの再起動が必要です。


## CUPS設定
ブラウザで `http://サーバーアドレス:631` にアクセス
サーバーアドレスは
```bash
$ ip a
```
で確認できる

1. 管理者向けの「プリンターとクラスの追加」
1. プリンターの「プリンターの追加」
1. 権限エラーページが出るので表示されたURLにアクセス
1. 再度「プリンターの追加」
1. rootアカウント情報を入力
1. プリンターに接続しているローカルプリンターを選択
1. 「このプリンターを共有する」をONにする



## PCのスリープをOFF
`vi /etc/systemd/logind.conf` を編集する

```
#HandleLidSwitch=suspend
#HandlePowerKey=poweroff
#HandleSuspendKey=suspend
#HandleHibernateKey=hibernate

# PCを閉じた
HandleLidSwitch=ignore
# パワーキーを押した
HandlePowerKey=ignore
# サスペンドキーを押した
HandleSuspendKey=ignore
# ハイバネートキーを押した
HandleHibernateKey=ignore
```

再起動する
```bash
$ systemctl restart systemd-logind.service
```

## プリンタの自動電源OFF機能を無効化
iP2700だと自動電源がデフォルトでONになってる
調べた感じCUI上からだと変更はできなさそう。

## 少しセキュリティを強固にする

### yum-cron で定期 yum update 実行
```bash
$ yum install yum-cron
```

除外設定
vi /etc/yum.conf

[main] より下に除外したい項目を追加

```
[main]
exclude=kernel*
```

自動更新を設定
/etc/yum/yum-cron.conf

```
apply_updates = no
```
を yes にする

セキュリティ関連に限定するために
```
update_cmd = default
```
を security にする

自動起動にする
```bash
$ systemctl start yum-cron
$ systemctl enable yum-cron
```

### 不要サービスを止める

起動中サービスを確認
```bash
$systemctl list-unit-files -t service
```

サービスを止める
```bash
$ systemctl disable <service name>
```

### root ユーザーのログイン無効化
`/etc/ssh/sshd_config` 内の

```
#PermitRootLogin yes
```
を
```
PermitRootLogin no
```
に変更する

再起動する
```bash
$ systemctl reload sshd.service
```

## 何かインストールしても変わらない場合
OSの再起動を試してみてください。

## 参考URL

- [Mac OSX上でISOイメージからBootable USBを作成する - 1日ひとつだけ強くなる](http://hal0taso.hateblo.jp/entry/2016/09/08/190140)
- [SambaとCUPSと各種プリンター（CUPS・プリンタ編） - Qiita](https://qiita.com/yyano/items/e0c27eda5d8e70de66e0)
- [【丁寧解説】Linuxのファイアウォール firewalld の使い方](https://eng-entrance.com/linux-centos-firewall)
- [CUPS 設定 - CentOS プリンタ 管理](http://centos86config.web.fc2.com/cups-setting.html)

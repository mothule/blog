---
title: MacでLinuxのISOファイルをUSBフラッシュメモリに書き込む
description: Macでターミナル上のシェルコマンドdiskutilとddコマンドを使ってLinuxのISOイメージファイルをUSBフラッシュメモリドライブに焼いてインストールメディアデバイスを作成する方法を説明します。
categories: linux
tags: linux mint mac
image:
  path: /assets/images/2020-04-29-linux-write-iso-to-usb-flash-drive/0.png
---

**Linux触るならシェルで焼こう**

使わなくなったPCにLinuxをインストールして触れる機会を増やし、慣れて知識を増やそう作戦の最初の壁。  
それがLinuxのインストール…ではなく**インストール用ドライブの作成です。**  
単純にUSBメディアにISOファイルを入れるだけと思って、Finderで外部デバイスにコピーしたけどちゃんとできない人がいるのでは？  

インストールメディア用として認識させるには、ちゃんとした段取りで正しい方法で用意する必要があります。  
この記事は、Macを使ってLinuxのISOイメージファイルをターミナルを使って作成する手順について説明しています。

## MacでISOイメージファイルをUSBに焼く流れ

1. イメージファイルをサイトから**ダウンロード**
1. **USBフラッシュメモリドライブ** をMacにセット
1. diskutilコマンドで**USBフラッシュメモリを初期化**
1. ddコマンドで**isoイメージファイルをUSBフラッシュメモリにコピー**


## ISOイメージファイルをサイトからダウンロード
OSのISOイメージファイルを公式サイトからダウンロードします。

今回OSは[Linux Mint](https://www.linuxmint.com/)にします。

{% page_image 4.png 50% LinuxMintLogo %}

Linux MintのISOイメージファイルを[Linux Mintのダウンロードページ](https://www.linuxmint.com/download.php)から落とします。

## USBフラッシュメモリドライブをMacにセット

使うUSBフラッシュメモリなら何でもいいです、今回は手元にあるものから用意しました。

{% page_image 1.jpg 50% USBフラッシュメモリ %}

用意したUSBフラッシュメモリドライブをMacに挿します。  
もし下記アラートが出たら「無視」を選んでください。

{% page_image 2.png 50% MacUSB認識不可ディスクアラート %}

## diskutilコマンドでUSBフラッシュメモリを初期化

ターミナルでdiskutilコマンドを使ってドライブ初期化を実行します。

### diskutilとは？
diskutilとはディスクユーティリティツールです。  
**ローカルのディスクとボリュームを管理** するユーティリティです。  
ほとんどのコマンドにはsudoが必要です。


### 初期化の手順
diskutilコマンドを使ってドライブを初期化するには、次の手順になります。

1. diskutil listコマンドで**対象ドライブのパス確認**
1. diskutil eraseDiskコマンドで**パス指定で削除**
1. diskutil unmountDiskコマンドでドライブのマウント解除


### diskutil listコマンドで対象ドライブのパス確認
`diskutil list`コマンドで現在マウントしてるUSBフラッシュメモリドライブを探します。

例えば下記は自分の環境で`diskutil list`を実行した結果です。  
この場合だと最後`external`と`physical`と表示されてる`/dev/disk2`ですね。  
容量(SIZE)も用意したUSBフラッシュメモリと同じなので間違いないです。

```
$ diskutil list
/dev/disk0 (internal):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                         251.0 GB   disk0
   1:                        EFI EFI                     314.6 MB   disk0s1
   2:                 Apple_APFS Container disk1         250.7 GB   disk0s2

/dev/disk1 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +250.7 GB   disk1
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            206.4 GB   disk1s1
   2:                APFS Volume Preboot                 47.8 MB    disk1s2
   3:                APFS Volume Recovery                522.7 MB   disk1s3
   4:                APFS Volume VM                      3.2 GB     disk1s4

/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *4.0 GB     disk2
   1:                       0xEF                         9.2 MB     disk2s2
```

### diskutil eraseDiskコマンドでパス指定で削除
`diskutil eraseDisk`コマンドで対象ディスクのパスを指定してディスクを初期化します。  
使い方を簡単にすると下記です。

```sh
$ diskutil eraseDisk format name ドライブのパス
```

ドライブのパスは、先程調べたパス(`/dev/disk2`)になるので結果的に実行するコマンドは下記になります。

```
$ diskutil eraseDisk MS-DOS UNTITLED /dev/disk2
```

`MS-DOS`はファイルフォーマット`FAT`となります。`FAT32`は古いので大抵のOSではサポートしてるため。
今回はUSBフラッシュメモリの容量は4GBなので`FAT`でちょうど良かったりする。
(FATの最大ファイルサイズは4GiB)  
`UNTITLED`は何でもいいです。

下記は先程のコマンドを実行した結果です。  
`Finished erase on disk2`と出て無事初期化成功しています。

```sh
$ diskutil eraseDisk MS-DOS UNTITLED /dev/disk2
Started erase on disk2
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk2s2 as MS-DOS (FAT) with name UNTITLED
512 bytes per physical sector
/dev/rdisk2s2: 7478992 sectors in 934874 FAT32 clusters (4096 bytes/cluster)
bps=512 spc=8 res=32 nft=2 mid=0xf8 spt=32 hds=255 hid=411648 drv=0x80 bsec=7493632 bspf=7304 rdcl=2 infs=1 bkbs=6
Mounting disk
Finished erase on disk2
```

### diskutil unmountDiskコマンドでドライブのマウント解除
削除工程の最後は、マウント解除です。  
これをせず次工程のISOイメージファイルをコピーしようとすると下記エラーとなります。

```
dd: /dev/disk2: Resource busy
```

下記は`diskutil unmountDisk`コマンドでマウント解除した結果です。

```sh
$ diskutil unmountDisk /dev/disk2
Unmount of all volumes on disk2 was successful
```

## ddコマンドでisoイメージファイルをUSBフラッシュメモリにコピー

`diskutil eraseDisk`でUSBフラッシュメモリをキレイにできました。  
今度はisoイメージファイルをUSBフラッシュメモリにコピーします。  
コピーには`dd`コマンドを使います。

### ddコマンドとは？
ファイルの変換とコピーするコマンドです。
標準入力を標準出力にコピーします。
入力データは512バイトのブロック毎に入力・出力します。

### ddコマンドでISOファイルをUSBメモリにコピーする
`dd`コマンドを次のように指定します。

```sh
$ sudo dd if=~/Downloads/linuxmint-19.3-xfce-32bit.iso of=/dev/disk2 bs=4028
489925+1 records in
489925+1 records out
1973420032 bytes transferred in 1604.956170 secs (1229579 bytes/sec)
```

`dd`コマンドのオプションに`if`と`of`と`bs`オプションを使います。

- `if=`オプションで入力ファイルとなるISOイメージファイルのパスを指定します。
- `of=`オプションで出力ファイルとなるドライブのパスを指定します。
- `bs=`オプションでブロックサイズを指定します。未指定時は512バイトです。

このコマンドは完了に時間がかかります。  
動いてるかどうかは、USBフラッシュメモリドライブによっては、入出力の点灯で確認できます。

### USBフラッシュメモリドライブを抜く

ISOイメージファイルをUSBフラッシュメモリへコピーが完了したらマウント解除して安全にUSBドライブが抜けるようにします。

```bash
$ diskutil eject /dev/disk2
Disk /dev/disk2 ejected
```

下記は`diskutil list`を実行した結果です。消えてることが分かります。

```
$ diskutil list
/dev/disk0 (internal):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                         251.0 GB   disk0
   1:                        EFI EFI                     314.6 MB   disk0s1
   2:                 Apple_APFS Container disk1         250.7 GB   disk0s2

/dev/disk1 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +250.7 GB   disk1
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            206.4 GB   disk1s1
   2:                APFS Volume Preboot                 47.8 MB    disk1s2
   3:                APFS Volume Recovery                522.7 MB   disk1s3
   4:                APFS Volume VM                      3.2 GB     disk1s4
```

## インストールメディアは単純だけど慣れるほど使わない
一回でも手を動かしてインストールメディアを作成してしまえば、思いの外単純だと思います。
でもそう何回もインストールメディアを作ることはなく、必要となったときには忘れてしまいます。

こういうのは、慣れるより探せです。

---
title: CentOS8のfirewalldが未起動のままポート許可やサービス登録する
categories: linux centos
tags: linux centos firewalld
image:
  path: /assets/images/2021-02-19-linux-centos-firewalld-edit-firewalld-in-inactive/eyecatch.png
---
**SSHの使用ポートをデフォルトの22番から別番号に変更**はセキュリティを改善できます。
しかし、そのあと**何の対応もせずfirewalldを起動するとアクセスが遮断**されます。
そしてそれ以降SSHでのアクセス手段が詰みます。
しかも、**firewalldのポート登録は起動していないと登録できません。**

この記事は**firewalldが未起動のままポート登録する方法**を説明します。

## 注意: 自己責任です
今回説明する方法は自己責任でお願いします。この方法がどの環境やバージョンでも適用できるとは限らないためです。

もし試す場合は、必ず回復が可能な状態にしてください。もしfirewalldに追い出されてsshでログインできなくなっても責任は持てません。

## firewalldとは
Linux用ファイアウォール管理ツールです。指定したポートをサービス単位で指定できたり直接ポート番号指定し、ポートへのアクセス制限を管理できます。以前のバージョンでは`iptables`がその役割でしたが、最近のバージョンではこちらに変わりました。

## SSHを先にセットアップしたい
CentOSでLinuxサーバーをセットアップすると、まず最初はrootアクセス制限や公開鍵認証など、firewalldよりもSSH周りのセキュリティ強化を進めるかと思います。その流れでSSHのポート番号を変更もしてしまいたいです。
でもポート番号が変わってしまうと、firewalldでは許可していないポート番号となるため、起動した瞬間にアクセス遮断されます。

「起動する前にポート許可をすれば？」と思うかもしれませんが、firewalldは起動していないとポート許可ができません。  
未起動のまま登録を試しても次のようにエラーとなってしまいます。

```bash
$ firewall-cmd --permanent --add-port=22444/tcp
FirewallD is not running
```

そのため通常であれば、一度SSHのポート番号を元の22に戻した後firewalldを起動し、ポート番号を登録するといった手間が発生します。


## firewalldの設定情報を直接変更する
通常大抵のサービスは永続性のある情報は何らかの形で再起動しても残ります。firewalldも永続性のある情報をファイルとしてサーバー内に保存しています。

### firewalldの設定情報ファイルを確認する
CentOS8だと`/etc/firewalld/zones`にzone毎に**xmlファイル**で保存されてます。
例えばpublic zoneのxmlファイルだと次のように構造です。

```sh
$ sudo su -
$ cat /etc/firewalld/zones/public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
</zone>

```

### xmlファイルに直接許可ポートを追加する
このxmlを直接編集すればfirewalldを起動せずポートやサービスを追加できます。例えば22444/TCPを許可する場合は、次の1行を追加します。

```xml
<port port="22444" protocol="tcp"/>
```

追加はzoneタグ内であれば問題ありません。

```xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <port port="22444" protocol="tcp"/>
</zone>
```

これでfirewalldを起動するとポート22444/tcpが追加された状態で起動します。

```sh
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens3
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22444/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

もちろんポートだけでなくサービスも事前に登録は可能です。
ポート番号がデフォルト22ではないSSHサービスを用意して、xmlに追加するとポートのときと同じように追加したサービスを許可します。

なお、ポート番号の異なるSSHサービスを用意する方法は「 {% post_link_text 2021-02-19-linux-centos-firewalld-create-new-service %} 」にまとめてあります。

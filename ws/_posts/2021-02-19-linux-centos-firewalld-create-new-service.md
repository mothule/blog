---
title: CentOSのfirewalldにポート番号変更したSSHのサービスを自作して登録する
description: CentOSのfirewalldにポート番号を変更したSSHを対応する方法やポートではなくサービスとして管理するメリットについて説明します。
categories: linux centos
tags: linux centos firewalld
image:
  path: /assets/images/2021-02-19-linux-centos-firewalld-create-new-service/eyecatch.png

---
CentOSのインストールセットアップでセキュリティ対策のためSSHのポート番号を変えたいけど、firewalldのsshサービスは22番になってる。これを新しいポート番号に対応したい。

この記事は、CentOSのfirewalldのサービスを自作する方法と、ポート番号を変更したSSHサービスを登録する方法を説明します。

## ポートではくサービスとして登録するメリット
firewalldが稼働中にSSHサービスのポート番号をデフォルトの22番以外の番号に変更する場合は、`firewall-cmd —permanent —add-port=22444/tcp`と直接ポート番号指定する方法が簡単です。

例えば、ポート番号22444番のTCPを許可します。

```bash
$ sudo firewall-cmd —permanent —add-port=22444/tcp
success
$ sudo firewall-cmd --reload
success
```

これで許可状態を確認すると、次のように表示されます。

```bash
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens3
  sources:
  services: cockpit dhcpv6-client http https
  ports: 22444/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

`ports`のところに先程許可したポートが並びます。
追加したばかりなので、この番号はSSHのポート番号だと判断できます。

しかし、これが次のケースだとどうでしょうか？

- 許可ポートが大量にある
- 次firewalldを見るのが半年後〜数年後になる
- 次firewalldを見るのが自分ではない

firewalldのポート開放は、数字と意味がセットにならないと情報が欠落します。
この問題をサービスとして登録することで解決します。

## firewalldのサービスの実態はxmlファイル
firewalldで扱っているサービス一覧は`firewall-cmd --get-services`コマンドで確認できます。

```sh
$ firewall-cmd --get-services
RH-Satellite-6 amanda-client amanda-k5-client amqp amqps apcupsd audit bacula bacula-client bb bgp bitcoin bitcoin-rpc bitcoin-testnet bitcoin-testnet-rpc bittorrent-lsd ceph ceph-mon cfengine cockpit condor-collector ctdb dhcp dhcpv6 dhcpv6-client distcc dns dns-over-tls docker-registry docker-swarm dropbox-lansync elasticsearch etcd-client etcd-server finger freeipa-4 freeipa-ldap freeipa-ldaps freeipa-replication freeipa-trust ftp ganglia-client ganglia-master git grafana gre high-availability http https imap imaps ipp ipp-client ipsec irc ircs iscsi-target isns jenkins kadmin kdeconnect kerberos kibana klogin kpasswd kprop kshell kube-apiserver ldap ldaps libvirt libvirt-tls lightning-network llmnr managesieve matrix mdns memcache minidlna mongodb mosh mountd mqtt mqtt-tls ms-wbt mssql murmur mysql nfs nfs3 nmea-0183 nrpe ntp nut openvpn ovirt-imageio ovirt-storageconsole ovirt-vmconsole plex pmcd pmproxy pmwebapi pmwebapis pop3 pop3s postgresql privoxy prometheus proxy-dhcp ptp pulseaudio puppetmaster quassel radius rdp redis redis-sentinel rpc-bind rsh rsyncd rtsp salt-master samba samba-client samba-dc sane sip sips slp smtp smtp-submission smtps snmp snmptrap spideroak-lansync spotify-sync squid ssdp ssh ssh-22444 steam-streaming svdrp svn syncthing syncthing-gui synergy syslog syslog-tls telnet tentacle tftp tftp-client tile38 tinc tor-socks transmission-client upnp-client vdsm vnc-server wbem-http wbem-https wsman wsmans xdmcp xmpp-bosh xmpp-client xmpp-local xmpp-server zabbix-agent zabbix-server
```

これらはxmlファイルとして定義されており、`/usr/lib/firewalld/services`に配置されてます。

```sh
$ ls /usr/lib/firewalld/services/
RH-Satellite-6.xml       cockpit.xml           freeipa-replication.xml  isns.xml               mdns.xml       ovirt-imageio.xml         rdp.xml              snmptrap.xml           tinc.xml
amanda-client.xml        condor-collector.xml  freeipa-trust.xml        jenkins.xml            memcache.xml   ovirt-storageconsole.xml  redis-sentinel.xml   spideroak-lansync.xml  tor-socks.xml
amanda-k5-client.xml     ctdb.xml              ftp.xml                  kadmin.xml             minidlna.xml   ovirt-vmconsole.xml       redis.xml            spotify-sync.xml       transmission-client.xml
amqp.xml                 dhcp.xml              ganglia-client.xml       kdeconnect.xml         mongodb.xml    plex.xml                  rpc-bind.xml         squid.xml              upnp-client.xml
amqps.xml                dhcpv6-client.xml     ganglia-master.xml       kerberos.xml           mosh.xml       pmcd.xml                  rsh.xml              ssdp.xml               vdsm.xml
apcupsd.xml              dhcpv6.xml            git.xml                  kibana.xml             mountd.xml     pmproxy.xml               rsyncd.xml           ssh.xml                vnc-server.xml
audit.xml                distcc.xml            grafana.xml              klogin.xml             mqtt-tls.xml   pmwebapi.xml              rtsp.xml             steam-streaming.xml    wbem-http.xml
bacula-client.xml        dns-over-tls.xml      gre.xml                  kpasswd.xml            mqtt.xml       pmwebapis.xml             salt-master.xml      svdrp.xml              wbem-https.xml
bacula.xml               dns.xml               high-availability.xml    kprop.xml              ms-wbt.xml     pop3.xml                  samba-client.xml     svn.xml                wsman.xml
bb.xml                   docker-registry.xml   http.xml                 kshell.xml             mssql.xml      pop3s.xml                 samba-dc.xml         syncthing-gui.xml      wsmans.xml
bgp.xml                  docker-swarm.xml      https.xml                kube-apiserver.xml     murmur.xml     postgresql.xml            samba.xml            syncthing.xml          xdmcp.xml
bitcoin-rpc.xml          dropbox-lansync.xml   imap.xml                 ldap.xml               mysql.xml      privoxy.xml               sane.xml             synergy.xml            xmpp-bosh.xml
bitcoin-testnet-rpc.xml  elasticsearch.xml     imaps.xml                ldaps.xml              nfs.xml        prometheus.xml            sip.xml              syslog-tls.xml         xmpp-client.xml
bitcoin-testnet.xml      etcd-client.xml       ipp-client.xml           libvirt-tls.xml        nfs3.xml       proxy-dhcp.xml            sips.xml             syslog.xml             xmpp-local.xml
bitcoin.xml              etcd-server.xml       ipp.xml                  libvirt.xml            nmea-0183.xml  ptp.xml                   slp.xml              telnet.xml             xmpp-server.xml
bittorrent-lsd.xml       finger.xml            ipsec.xml                lightning-network.xml  nrpe.xml       pulseaudio.xml            smtp-submission.xml  tentacle.xml           zabbix-agent.xml
ceph-mon.xml             freeipa-4.xml         irc.xml                  llmnr.xml              ntp.xml        puppetmaster.xml          smtp.xml             tftp-client.xml        zabbix-server.xml
ceph.xml                 freeipa-ldap.xml      ircs.xml                 managesieve.xml        nut.xml        quassel.xml               smtps.xml            tftp.xml
cfengine.xml             freeipa-ldaps.xml     iscsi-target.xml         matrix.xml             openvpn.xml    radius.xml                snmp.xml             tile38.xml
```

内部では使用するポート番号などが定義されてます。
例えばsshでは次のように定義されてます。

```sh
$ cat /usr/lib/firewalld/services/ssh.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>SSH</short>
  <description>Secure Shell (SSH) is a protocol for logging into and executing commands on remote machines. It provides secure encrypted communications. If you plan on accessing your machine remotely via SSH over a firewalled interface, enable this option. You need the openssh-server package installed for this option to be useful.</description>
  <port protocol="tcp" port="22"/>
</service>
```

## ssh.xmlのコピーでポート番号変更版sshサービスを作る
サービスの実態が分かれば後は単純な話です。

例えばポート番号を22から22444に変更したsshサービスを用意したい場合は、
既存サービスをコピーしてxml(`ssh-22444.xml`)内に記載された`<port protocol="tcp" port="22"/>`の22を22444に変更します。

```sh
$ cp /usr/lib/firewalld/services/ssh.xml /usr/lib/firewalld/services/ssh-22444.xml
$ sudo vim /usr/lib/firewalld/services/ssh-22444.xml
```

これだけでfirewalldに新しいサービス(`ssh-22444`)が追加されました。
詳細を見るとポートが22444になっていることが確認できます。

```sh
$ firewall-cmd --get-services | xargs -n1 echo | grep ssh
ssh
ssh-22444

$ firewall-cmd --info-service=ssh-22444
ssh-22444
  ports: 22444/tcp
  protocols:
  source-ports:
  modules:
  destination:
  includes:
  helpers:
```

## ssh-22444サービスをfirewalldに追加登録する
作成したポート22444版SSHサービス(`ssh-22444)`をfirewalldに登録します。

登録前は次の状態です。

```sh
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens3
  sources:
  services: cockpit dhcpv6-client http https ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

firewalldに作成したサービスを登録します。`—-permanent`オプションを忘れずに。
これでfirewalldにssh-22444というサービスが登録されます。
登録すると`services`に追加されます。`--reload`しないと反映されません。

```sh
$ sudo firewall-cmd --permanent --add-service=ssh-22444
success
$ sudo firewall-cmd --reload
success
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens3
  sources:
  services: cockpit dhcpv6-client http https ssh ssh-22444
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

これでSSHのポート番号を22444に変更してもfirewalldに拒否されず接続できるようになります。

## 不要になった通常のsshサービスを外す

`sshd_config`でPortの番号を22444に変更したら、ポート22番は使わなくなります。不要にポートは空けたままにしないため通ポート22番のsshサービスをfirewalldから外します。

```sh
$ sudo firewall-cmd --permanent --remove-service=ssh
success
$ sudo firewall-cmd --reload
success
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens3
  sources:
  services: cockpit dhcpv6-client http https ssh-22444
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

なお、くれぐれも変更したポートで接続できたのを確認してから外してください。確認を怠りSSHログインができないまま外してしまうと締め出されてしまいます。

## firewalldが未起動でポートやサービスを登録する
通常はfirewalldに許可するポートやサービスを登録したり削除したり編集するにはfirewalldが起動していることが必須となります。
しかしファイルを直接編集することで、firewalldが未起動でも登録や削除が可能です。詳しくは「{% post_link_text 2021-02-19-linux-centos-firewalld-edit-firewalld-in-inactive %}」にまとめてあります。

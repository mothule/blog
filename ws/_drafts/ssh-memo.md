---
title: SSHメモ
categories: tools ssh
tags: tools ssh
---

公開鍵認証方式でsshログイン
公開鍵は接続先
秘密鍵は接続元
.sshのパーミッションは700
.ssh/authorized_keys は 600
公開鍵は
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
で登録
rm ~/.ssh/id_rsa.pub で不要になった元の公開鍵を削除


パスワード認証を禁止する
/etc/ssh/sshd_config を vimで編集する
PasswordAuthentication no
PubkeyAuthentication yes
にする




# ssh メモ

## ~/.ssh フォルダ内の説明

- config
- id_rsa
- id_rsa.pub
- know_hosts

## config
sshクライアントの設定ファイル。
接続先情報が一覧化されている。
ここで定義しておくことで ssh コマンドのオプション省略することも可能

## id_rsa / id_rsa.pub
`ssh-keygen` で生成した秘密鍵と公開鍵

## known_hosts
接続経験のあるサーバのSSHサーバ証明書が格納される。

## Are you sure you want to continue connecting (yes/no)? をスキップ
~/.ssh/config の接続先ホストに `StrictHostKeyChecking no` を設定することでスキップできる

## Permission denied (publickey).
サーバー側とクライアント側の公開鍵と秘密鍵が一致していないことがよくある原因。

# SSHについて調べてみた

ssh
ssh-add
[SSH-ADD (1)](https://euske.github.io/openssh-jman/ssh-add.html)


[ssh-agentを利用して、安全にSSH認証を行う - Qiita](https://qiita.com/naoki_mochizuki/items/93ee2643a4c6ab0a20f5)

agent forwarding


known_hosts

/etc/hosts にはIPアドレスとホスト名の対応が記述する

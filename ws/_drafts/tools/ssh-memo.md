---
title: エンジニアなら知らないとヤバいSSHの基礎
categories: tools ssh
tags: tools ssh
---

- SSHとは？
  - 仕組み
    - sshd
      - ポート番号22
    - sshクライアント
  - SSHのない時代
  - デフォルトのポート番号を使わない
- 2つのSSH認証方式
  - パスワード認証方式
    - デフォルト
    - ユーザー名とパスワードでログインする方式
    - アカウントは接続先OSのユーザーアカウントを使う
  - 公開鍵認証方式
    - 公開鍵
    - 秘密鍵
    - 2つの鍵(キーペア)
  - 公開鍵認証方式の推奨理由
- 秘密鍵と公開鍵
  - id_rsa／id_rsa.pubとは？
    - id_rsa 秘密鍵
    - id_rsa.pub 公開鍵
  - RSA
- 既知ホスト(know_hosts)
  - 接続経験のあるサーバのSSHサーバ証明書が格納される。
- ssh-agent
  - ssh-addコマンド
  - agent forwarding
- /etc/hosts
- ssh-keygen

- SSH認証を公開鍵認証方式に変更する
  - 公開鍵は接続先
  - 秘密鍵は接続元
  - .sshのパーミッションは700
  - .ssh/authorized_keys は 600
  - 公開鍵は cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys で登録
  - rm ~/.ssh/id_rsa.pub で不要になった元の公開鍵を削除
  - パスワード認証を禁止する
    - /etc/ssh/sshd_config を vimで編集する
    - PasswordAuthentication no
    - PubkeyAuthentication yes

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

## Are you sure you want to continue connecting (yes/no)? をスキップ
~/.ssh/config の接続先ホストに `StrictHostKeyChecking no` を設定することでスキップできる

## Permission denied (publickey).
サーバー側とクライアント側の公開鍵と秘密鍵が一致していないことがよくある原因。

[ssh-agentを利用して、安全にSSH認証を行う - Qiita](https://qiita.com/naoki_mochizuki/items/93ee2643a4c6ab0a20f5)

agent forwarding


known_hosts

/etc/hosts にはIPアドレスとホスト名の対応が記述する

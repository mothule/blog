---
title: 公開鍵認証によるSSHで使う鍵管理をssh-agentで楽する
description: SSH公開鍵認証で必要な公開鍵と秘密鍵はセキュリティ対策が必要ですが、多重SSHなどSSH接続したサーバーから続けて別サーバに接続するにはサーバ上に秘密鍵が必要になるが、ssh-agentを使うことでこれを解決する。
categories: tools ssh
tags: tools ssh ssh-agent
image:
  path: /assets/images/2020-08-18-tools-ssh-ssh-agent-usage/eyecatch.png
---

ssh接続で使う公開鍵のパスフレーズ入力は面倒ですが、ssh-agentでパスフレーズ入力を代理してくれます。  
また、複数サーバを横断する場合に鍵の管理に困りますが、ssh-agentで秘密鍵をサーバに配置せずに済みます。

## ssh-agentとは？
ssh-agentは認証代理プログラムです。  
RSAやDSA、ECDSAなど公開鍵認証に使う秘密鍵をメモリ上に保持します。  
エージェントプロセスが生きている間は、sshログイン時のパスフレーズ入力を代理します。

## ssh-agentの最大のメリット
ssh-agentはパスフレーズを代理してくれることですが、最もその効果を発揮するのは、  
複数サーバーを跨いだ認証で、サーバ毎に秘密鍵の配置が不要になります。  
インターネット上に秘密鍵を配置するリスクを負わずに、ローカル上で秘密鍵を保持しててもエージェントが認証を代理してくれます。  
ssh-agentを使わない場合は、踏み台サーバにサーバBへの秘密鍵を置くなどリスクまたは手間が生じます。

{% page_image ssh-agent-multi-server.png 100% 複数サーバでのssh-agent %}

ssh-agentを使うことで、認証データを他PCに保存不要で、パスフレーズがネットワークに乗りません。  
秘密鍵を必要とする操作をエージェントによって実行されるため、  
秘密鍵はエージェントを使うクライアントに公開されません。

## ssh-agentの起動

ssh-agentを起動するには`ssh-agent`コマンドを使います。  
実行するとシェルスクリプトが表示されます。

```sh
$ ssh-agent
SSH_AUTH_SOCK=/var/folders/45/7f_wlrcs3xv6rmstcz2l5_000000gn/T//ssh-2tCfpXRm9s6R/agent.12199; export SSH_AUTH_SOCK;
SSH_AGENT_PID=12200; export SSH_AGENT_PID;
echo Agent pid 12200;
```

このスクリプトを実行して環境変数を登録する必要があります。

- SSH_AUTH_SOCK環境変数: unixドメインソケットの名前が入る
- SSH_AGENT_PID環境変数: エージェントのプロセスIDが入る

なので、通常は起動には、`eval`コマンドを使い、出力をそのまま実行します。

```sh
$ eval `ssh-agent`
Agent pid 12200
```

### ssh-agentの起動オプション一覧

エージェントの起動には様々なオプションを渡せます。

`ssh-agent [-c | -s] [-Dd] [-a bind_address] [-E fingerprint_hash] [-P pkcs11_whitelist] [-t life] [command [arg ...]]`

`ssh-agent`コマンドで使えるオプションを説明します。

#### -a bind_address: UNIXドメインソケットのパス指定
ssh-agentを指定したUNIXドメインソケットにバインドします。  
デフォルトは`$TMPDIR/ssh-XXXXXXXXXX/agent.<ppid>`です。

#### -c: Cシェルでログイン
起動時に表示するシェルをCシェルコマンドで出力します。
SHELL環境変数の値がcsh互換性の場合は、この出力がデフォルトです。

#### -s: Bourneシェルでログイン
起動時に表示するシェルをBourneシェル(所謂sh)コマンドで出力します。
SHELL環境変数の値がsh互換性の場合は、この出力がデフォルトです。

#### -D: フォアグラウンドで起動
フォアグラウンドモードで起動します。  
このオプションを使うとssh-agentはforkを使わなくなります。

#### -d: デバッグモードで起動
デバッグモードで起動します。  
このオプションを使うとssh-agentはforkを使わず、デバッグ情報を標準エラーに出力します。

#### -E fingerprint_hash: フィンガープリントのハッシュ関数を指定
キーのフィンガープリントを使うハッシュ関数を指定します。  
オプションは、`md5`、`sha256`で、デフォルトは`sha256`です。

#### -P pkcs11_whitelist: PKCS#11共有ライブラリのパス指定
`ss-add`に`-s`オプションを使って追加できるPKCS#11共有ライブラリの受け入れ可能なパスパターンリストを指定する。  
デフォルトは`/usr/lib/*`、`/usr/local/lib/*`からPKCS#11ライブラリをロードします。

渡されたホワイトリストに一致しないPKCS#11ライブラリは拒否します。

#### -t life: 追加した鍵の保持寿命設定
エージェントに追加されるIDの最大存続時間のデフォルト値を設定します。  
存続時間は秒単位やsshd_configで指定された時間形式で指定します。

`ssh-add`でIDに指定された有効期限は、この値を上書きします。  
このオプションがない場合の最大存続時間は無制限です。

保持寿命を設定することで、プロセスが起動し続けてても寿命過ぎるとエージェントから削除されるので、セキュリティ制御ができるようになります。

## ssh-agentの終了

エージェントを終了するには、`ssh-agent`に`-k`オプションを渡します。  
現在のエージェントを強制終了します。  
終了する対象エージェントは環境変数`SSH_AGENT_PID`のPIDを終了します。

`ssh-agent [-c | -s] -k`

`-c`と`-s`は起動時に渡したのであれば同じように渡します。  

```sh
$ ssh-agent -k
unset SSH_AUTH_SOCK;
unset SSH_AGENT_PID;
echo Agent pid 12200 killed;
```

終了処理も起動と同じでシェルスクリプトが表示されるので、終了時は`eval`コマンドで囲います。

### 指定のエージェントを終了
起動時に環境変数`SSH_AGENT_PID`がセットされてるので、  
通常は問題になりませんが、起動時に環境変数が未登録だと、`SSH_AGENT_PID not set, cannot kill agent`が表示されます。  
つまり、`SSH_AGENT_PID`に終了したいエージェントのPIDをセットすることで、指定エージェントを終了できます。

```sh
$ ps aux | grep ssh-agent
mothule          28671   0.0  0.0  4334652    612 s002  U+    4:33AM   0:00.00 grep ssh-agent
mothule          27257   0.0  0.0  4300640    428   ??  Ss    4:33AM   0:00.00 ssh-agent
mothule          26972   0.0  0.0  4289376    428   ??  Ss    4:33AM   0:00.00 ssh-agent

$ SSH_AGENT_PID=27257 ssh-agent -k
unset SSH_AUTH_SOCK;
unset SSH_AGENT_PID;
echo Agent pid 27257 killed;

$ ps aux | grep ssh-agent
mothule          28703   0.0  0.0  4268300    704 s002  S+    4:35AM   0:00.00 grep ssh-agent
mothule          26972   0.0  0.0  4289376    428   ??  Ss    4:33AM   0:00.00 ssh-agent
```

## ssh-agentに鍵追加
当然ながらssh-agentの起動直後は秘密鍵がありません。  
鍵の追加は、`.ssh/config`の`AddKeysToAgent`か`ssh-add`で追加していきます。
ややこしいですが、削除や確認にも`ssh-add`を使います。

### AddKeysToAgentで登録する
`AddKeysToAgent`は`.ssh/config`で使うオプションです。  
ホスト毎に指定できて、指定されてることで`ssh-agent`に秘密鍵の追加有無を設定できます。

#### AddKeysToAgent未指定
`AddKeysToAgent`未指定の*~/.ssh/config*です。
```
Host github
  HostName github.com
  IdentityFile ~/.ssh/github
  User git
```

`AddKeysToAgent`がないと、パスフレーズを求められます。

```sh
$ ssh github
Enter passphrase for key '/Users/mothule/.ssh/github':
PTY allocation request failed on channel 0
Hi mothule! You have successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

#### AddKeysToAgent指定
`ssh-agent`への鍵登録を許可するには、`AddKeysToAgent`で`yes`が指定します。

`AddKeysToAgent`が指定された*~/.ssh/config*です。
```
Host github
  HostName github.com
  IdentityFile ~/.ssh/github
  User git
  AddKeysToAgent yes
```

`AddKeysToAgent`があると、パスフレーズは求められません。

```sh
$ ssh github
PTY allocation request failed on channel 0
Hi mothule! You have successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

もし指定鍵がssh-agentから見つからない場合は、パスフレーズをユーザーから求めた後に自動でssh-agentに登録します。

### ssh-addでキー追加する
ssh-addは認証エージェント(ssh-agent)に秘密鍵IDを追加するプログラムです。  
そのため、ssh-addを使うには、ssh-agentが実行されていて、`SSH_AUTH_SOCK`環境変数にエージェントへのソケット名が含まれてる必要があります。

`ssh-add 秘密鍵パス`で秘密鍵を追加します。  
引数なしで実行すると、`~/.ssh/id_rsa` `~/.ssh/id_dsa` `~/.ssh/id_ecdsa` `~/.ssh/id_ed25519`の秘密鍵を追加します。

```sh
$ ssh-add .ssh/github
Enter passphrase for .ssh/github:
Identity added: .ssh/github (mothule@mothule.local)
$ ssh-add -l
3072 SHA256:Ik22naSN6JXh0HGRjifWkBDERYUy8Td2dvDYUt3wGpE mothule@mothule.local (RSA)
$ ssh github
PTY allocation request failed on channel 0
Hi mothule! You have successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

## ssh-agentの登録済み鍵の確認

- `ssh-add -l`で登録済み鍵をフィンガープリントで一覧表示します。
- `ssh-add -L`で登録済み鍵の公開鍵を一覧表示します。

## ssh-agentの登録済み鍵の削除

- `ssh-add -d`で指定鍵の削除
- `ssh-add -D`で登録済み鍵の全削除

## 鍵の保持寿命を設定
`ssh-add -t life`で追加する鍵をエージェントが保持する期間を設定できます。  
未指定の場合は、エージェントのデフォルト値が期間として使われます。  
エージェントのデフォルト値も未指定だと期間は無制限になります。

無制限はセキュリティの観点からしてリスクがあるので、一定の期間を設けておくことを推奨します。

## ssh-agentを接続先ホストでも使う(SSH Agent forwarding)
Agent forwardingで接続することで、接続先ホストでローカルのssh-agentを使うことができます。  
つまり、接続先ホストに秘密鍵をおかずに、秘密鍵を使うことができるようになります。

### Agent forwardingの事前条件

- SSHサーバが`AllowAgentForwarding`の許可が必要
- SSHクライアント接続時に何れかの方法で指定する
  - sshコマンドに`-A`オプションを渡す(セッション毎)
  - `.ssh/config`に全体またはホスト毎に`ForwardAgent yes`を記載する(ユーザー・ホスト毎)
  - `/etc/ssh/ssh_config`に`ForwardAgent yes`を記載する(システム全体)

## ssh-agentのリスク

便利なssh-agentですが、運用にはリスクが伴います。

`man ssh`の`-A`でも記載されてますが、Agent forwardingには一定のセキュリティリスクが潜在します。  
またssh-agentはパスフレーズを一度登録すればなしにしてしまうので、キーの保持寿命を設定するなど使用には注意が必要です。

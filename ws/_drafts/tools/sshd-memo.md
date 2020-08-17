## SSHサーバ
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
  - ssh-copy-idでリモートで公開鍵を登録する
  - rootユーザでのssh禁止は`PermitRootLogin no`


### インターネット上に公開されてる場合のセキュリティ
- デフォルトのポート番号を使わない
  - SSHのポート番号は22番と決まっているため、ポートを変えることで最初の防御を敷くことが出来る。
- パスワード認証は使わない・無効化
  - ブルートフォースアタックでパスワードを破られる

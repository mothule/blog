---
title: RubyMineでUNIXドメインソケット通信なRailsアプリをデバッグする方法
categories: tools rubymine
tags: mac rubymine nginx tools ruby rails
image:
  path: /assets/images/2020-03-29-tools-rubymine-debugging-unix-socket-server/0.png
---
RubyMine使ってますか？周りで使ってる人は少なく、ネットでも一部の人しか使われていない印象です。
しかしIDE上がりの人間からするとやはりIDEの恩恵は授かりたいものですよね。
私達は開発環境を整えるためにRubyを弄ってるのではなくアプリやツールなど体験を提供するサービスを作りたいのが本質のはずですし。

今回はRubyMineを使ってUNIXドメインソケット通信で起動してるRailsアプリにブレイクポイントを仕込んだり、ブレイクポイントで止めたコンテキストからRubyを実行したり、変数をウォッチしたりするいわゆるデバッグする方法についてまとめます。

## 環境

- RubyMine
- PumaにてUNIXドメインソケット通信中のRailsアプリ
- Mac

## RubyMineから実行はUNIXドメインソケット通信による起動がない

通常ならRubyMineからRailsアプリを実行するには、メニューバーの `Run > Run... > Development: app_name` の順で実行できます。
もし設定を変更したい場合は、`Run > Edit Configurations...`を選ぶことで登録された設定情報を変更できる画面が表示されます。

*▼RubyMineのEdit Configurations...を開いた画面*  
{% page_image 2.png, 100%, RubyMineのEdit Configurations...を開いた画面 %}

ここでIP addressとPortを指定して実行すればサーバが立ち上がります。
しかしこの方法はTCP/IPによるポートが開かれるタイプとなり、UNIXドメインソケットによる立ち上げとは異なります。

`Server`項目を見てもそれらしき項目は見当たりません。

*▼サーバーパラメータ一覧*  
{% page_image 1.png, 100%, RubyMineのEdit Configurations...を開いた画面のServer一覧 %}

私が調べた限りでは直接UNIXドメインソケット通信として起動する方法はありませんでした。
これでは起動もデバッグもできずで、RubyMineが使い物にならなくなります。
しかし、実は少し手間ですがちゃんと手段はあります。

## UNIXドメインソケット通信はRubyMineでRailsアプリをアタッチする

それはメニューバーの`Run > Attach to Process...`による**既存プロセスにアタッチ**する方法です。

*▼メニューバーのRunにAttach to Process...はあります。*  
{% page_image 3.png 100% RubyMineのメニューバーのRunを開いた画面 %}

これを使うことで起動中のRailsアプリに対してアタッチを試み、成功したらRubyMineが介入できる環境を構築してくれます。

フローは次のようになります。

1. デバッグしたいRailsアプリをシェルで起動
1. RubyMineからAttach to Processを実行
1. Attachが成功するのを待つ


### デバッグしたいRailsアプリをシェルで起動
ターミナルからRailsのServerコマンドを実行してRailsアプリを起動します。

> Listening on unix:///usr/local/var/work/nginx-puma-rails/tmp/sockets/puma.sock

となっているのでUNIXドメインソケット通信として起動しています。

```sh
$ bin/rails s
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
=> Run `rails server --help` for more startup options
Puma starting in single mode...
* Version 4.3.3 (ruby 2.6.5-p114), codename: Mysterious Traveller
* Min threads: 5, max threads: 5
* Environment: development
* Listening on unix:///usr/local/var/work/nginx-puma-rails/tmp/sockets/puma.sock
Use Ctrl-C to stop
```

### RubyMineからAttach to Process...を実行

`Attach to Process...`を選ぶとRubyMineがRubyで起動してるプロセスを見つけて一覧として出してくれます。

*▼Rubyプロセス一覧*  
{% page_image 4.png, 100%, Attach to Process...で出る一覧画面 %}

先程立ち上げたRailsアプリを見つけてくれます。賢いですね。

### Attachが成功するのを待つ

次はこれを選ぶことでRubyMineがRailsアプリにアタッチをトライしてくれます。

{% page_image 5.png 100% 接続中プログレス %}

RubyMineのDebug Toolbarにも次のようなログが流れます。

```sh
/bin/bash -c "env RBENV_VERSION=2.6.5 /usr/local/Cellar/rbenv/1.1.2/libexec/rbenv exec ruby /Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/ruby-debug-ide-0.8.0.beta21/bin/gdb_wrapper --pid 15009 --ruby-path /Users/mothule/.rbenv/versions/2.6.5/bin/ruby --include-gem /Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/ruby-debug-ide-0.8.0.beta21/lib --include-gem /Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/debase-0.3.0.beta23/lib -- --key-value --step-over-in-blocks --disable-int-handler --evaluation-timeout 20 --evaluation-control --time-limit 100 --memory-limit 0 --rubymine-protocol-extensions --port 61951 --host 0.0.0.0 --dispatcher-port 61952 --attach-mode"
Fast Debugger (ruby-debug-ide 0.8.0.beta21, debase 0.3.0.beta23, file filtering is supported, block breakpoints supported, smart steps supported, obtaining return values supported, partial obtaining of instance variables supported)
executed 'lldb /Users/mothule/.rbenv/versions/2.6.5/bin/ruby --no-lldbinit'
executed `attach 15009` command inside lldb.
executed `thread list` command inside lldb.
executed `thread list` command inside lldb.
executed `thread select 1` command inside lldb.
executed `bt` command inside lldb.
executed `thread select 2` command inside lldb.
executed `bt` command inside lldb.
...
executed `thread select 23` command inside lldb.
executed `bt` command inside lldb.
executed `thread select 1` command inside lldb.
executed `expr (void *) dlopen("/Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/debase-0.3.0.beta23/lib/attach.bundle", 2)` command inside lldb.
executed `expr (int) debase_start_attach()` command inside lldb.
executed `breakpoint set --shlib /Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/debase-0.3.0.beta23/lib/attach.bundle --name __func_to_set_breakpoint_at` command inside lldb.
continuing
executed `expr (void) debase_rb_eval("require '/Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/ruby-debug-ide-0.8.0.beta21/bin/../lib/ruby-debug-ide/attach/debugger_loader'; load_debugger(['/Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/ruby-debug-ide-0.8.0.beta21/lib', '/Users/mothule/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/debase-0.3.0.beta23/lib'], ['--key-value', '--step-over-in-blocks', '--disable-int-handler', '--evaluation-timeout', '20', '--evaluation-control', '--time-limit', '100', '--memory-limit', '0', '--rubymine-protocol-extensions', '--port', '61951', '--host', '0.0.0.0', '--dispatcher-port', '61952', '--attach-mode'])")` command inside lldb.
```

成功するとRailsアプリのログにも次のようなログが出力されます。

```sh
Fast Debugger (ruby-debug-ide 0.8.0.beta21, debase 0.3.0.beta23, file filtering is supported, block breakpoints supported, smart steps supported, obtaining return values supported, partial obtaining of instance variables supported) listens on 0.0.0.0:61951
```

### 失敗するときの3つの確認

Attach to Processはアタッチ処理は安定とはいえないです。何回か試して成功するという状態です。
私がアタッチが失敗した場合にいつも試してることを教えます。
もし失敗する場合は次の4つを試してみてください。

1. タイムアウトを伸ばす
1. Railsアプリを立ち上げ直す
1. アタッチトライ中にRailsアプリを動かしてみる
1. ブレイクポイントをつけてAttachを実行する

「タイムアウトを伸ばす」はRubyMineのPreferencesから出来ます。

*▼Preferences > Build, Execution, Deployment > Debugger > Ruby > Debug connection timeout*  
{% page_image 6.png, 100%, RubyMineのSettingsからDebug connection timeを延長する %}

## RubyMineでUNIXドメインソケット通信でもデバッグできるようになる
通常ではRubyMineから起動したアプリしかデバッグができなかったり、ターミナル上でしかUNIXドメインソケット通信のRailsアプリを起動できなかったりしますが、この方法であれば既に立ち上がっているRubyプロセスでもアタッチすることでデバッグができるようになり便利ですね。

---
title: RackとRack Middlewareを知ることでRailsの一部仕組みを理解する
description: Railsの挙動を拡張するには3つの方法があり、今回はその中で `Rack Middleware` で拡張する基本や拡張先となるRackに関する仕組みについて調べました。この記事でRailsとRackサーバーの関係やRackそのものについてやRackに沿った拡張`Rack Middleware`について理解が深まると思います。
date: 2019-08-25
categories: ruby rails rack
tags: ruby rails rack rack-middleware
draft: true
---

Railsの挙動を拡張するには3つの方法があり、今回はその中で `Rack Middleware` で拡張する基本や拡張先となるRackに関する仕組みについて調べました。
この記事でRailsとRackサーバーの関係やRackそのものについてやRackに沿った拡張`Rack Middleware`について理解が深まると思います。

1. Rack Middleware
1. Railtie
1. その他

## Rackとは規約

Rakeとは、Web server と Ruby framework 間をつなぐ規約、取り決めです。
PythonのPSGIの規約を参考に登場し、
Rubyで実装されたサーバーとアプリの差異を埋める緩衝材みたいな存在です。

### 規約について
`.ru`を拡張子のRubyファイルを用意し、決まったシグネチャとレスポンスを返すメソッドを用意することでRackとして機能します。

- シグネチャはHashを引数にした`call`メソッド
- レスポンスは次の3つを含む配列を返す
  - HTTPステータスコード
  - ヘッダー情報が格納されたHash
  - eachに反応するオブジェクト 

つまり最小コードで表すと次のコードになります。

**config.ru**  
```ruby
app = lambda do |env|
  [200, {'Content-Type' => 'text/html'}, ['Hello, world']]
end
```
- 引数Hashは慣習として`env`がネーミングされます。
- 次のコード例では、 `Proc#call` によりシグネチャの制約を満たしています。

## Rack Middlewareはいわばパイプ

Rack MiddlewareとはRackの規約に準拠し、
Rackアプリに機能を追加するミドルウェアです。


## Rackアプリケーションを作ってみる

文章だけではイメージはしにくいので、実際に動く簡単なRackアプリを作ってみます。

ますRackアプリを作る上で便利クラスなどが集まったgemを用意する
```sh
$ gem install rack
```

`rack`をインストールすることで`rackup`というコマンドが使えるようになります。
先程の `config.ru` を `rakeup` で呼ぶことでサーバーが起動します。

```sh
$ rackup config.ru
```
※ `config.ru` であればそもそも指定が不要で `rakeup` だけでいい。


## Rack Middlewareを作ってみる

Rake Middlewareとは先程のRackアプリに対して、処理を追加するプログラムです。
次のような `ReplaceWords` クラスを `use ReplaceWords` と呼ぶことで
処理を追加することができます。

```ruby
class ReplaceWords
  def initialize(app)
    @app = app
  end

  def call(env)
    http_status_code, headers, body = @app.call(env)
    body.gsub!(/rake/i, 'rack')
    return [http_status_code, headers, body]
  end
end

App = lambda do |env|
  [200, {'Content-Type' => 'text/html}, ['Hello, Rake world!']]
end

use ReplaceWords
run App
```

### Rack Middlewareには制約がある

Rack同様にミドルウェアにもシグネチャとレスポンスを守る必要があります。

- Rackアプリを引数とした`initialize`メソッドがある
- Rackアプリ同様に、 Hashを引数とした`call`メソッドがある

この制約を守っていれば、パイプのように連結することも可能になります。
下記は2つのRack Middlewareを連結したことになります。

```ruby
use ReplaceWords
use UpperWords
run App
```

このようにパイプライン、ストリームのように連結して受け取った値を次に渡すことができるのは、制約を守っているためです。

## envの中身
env、`call`の第一引数には、リクエスト情報が格納されている。

- アクセスパス
- IPアドレス
- Acceptなどのヘッダー

### Rack Middlewareにおけるenvの活用

Rack Middlewareを連結することでenvはContext情報のように取り回され続きます。
そのため env に値を追加すれば、次のRack Middlewareでその値を使うことができます。

## RailsのRack Middlewareを確認

```sh
$ bin/rake middleware
```

のrakeコマンドで `use` 部分一覧を表示します。
RailsのRackがどのようなMiddlewareを経てRailsに渡ってきてるのか興味がある方は調べてみると面白いかもしれません。

## RailsでRack Middlewareを追加する
`config.ru`を編集ではなく、 `config/application.rb` や `config/envrionments/*.rb` ファイルの中で `use` で登録します。

```ruby
module Hoge
  class Application < Rails::Application
    config.middleware.use LogMiddleware
  end
end
```

## まとめ

RackやRack Middlewareを知ることで、Railsの拡張性の高さや実際にどうやって拡張されているのかを知ることができたと思います。
このように普段ほとんど関わることのない機能であっても知ることで色んな所の仕組みが理解できるようになるのはおもしろいですね。


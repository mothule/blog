---
title: Railsのアセットパイプラインの使い方を最短理解する
description: Railsのアセットパイプラインの使い方、全体像、用語を知り効率よくアセットパイプラインを使えるようにまとめました。
image:
  path: /assets/images/2021-01-06-ruby-rails-assets-pipeline-use/eyecatch.png
categories: ruby rails
tags: ruby rails asset-pipeline
---
Railsのアセットパイプラインの理解に時間を費やしたくないけど、理解しないといけないケースが多いです。  
アセットパイプラインの使い方をなるべく端的にまとめました。

## アセットパイプライン(Asset Pipeline)の概要
アセットパイプラインの概要は「{% post_link_text 2021-01-05-ruby-rails-assets-pipeline-brief %}」にまとめてあります。

## アセットパイプライン(Asset Pipeline)とは
アセットパイプラインを後述する用語を使って説明します。

アセットパイプラインとは、マニフェスト毎に集めたアセット群から1つのマスターファイルを作成するフレームワークです。  
マニフェストファイルにはアセットの一覧となるマニフェストが書かれており、マニフェストの表現にディレクティブ（命令）を使います。  
マニフェストファイルが2個あれば、マスターファイルは2つ作成されます。

### アセットとは
アセットとはスタイルシートやJavaScriptなどのリソースの指します。

### パイプラインとは
アセットを次々に一連の処理が施される仕組みです。

### マニフェストファイルとは
マニフェストとはロードするアセットの集まりであり、  
マニフェストファイルとはそのマニフェストが書かれたファイルです。

### ディレクティブとは
マニフェストを実現するためのファイルロードに関する命令です。  
ディレクティブを駆使してマニフェスト（アセットのリスト）を表現します。

## アセットパイプラインの全体フローを知る
例えば、アセットパイプラインを使って複数のスタイルシートから1つのスタイルシートがロードされるまでの流れです。

1. `application.scss`内のディレクティブに沿ってファイルをロード
  - ロード対象の検索先は`app/assets/stylesheets`です。
1. ロードしたファイルをコンパイル
1. マスターファイルとなる`application.css`にコンパイル済みファイルを結合
1. マスターファイルを`application.html.haml`からロードする

本番環境の場合はコンパイル処理は事前に実施(プリコンパイル)され、`public/assets`フォルダに配置されます。

### アセットパイプライン処理の対象フォルダ
前述したロード対象の検索先の他にもいくつか検索候補があります。

1. `app/assets`
1. `lib/assets`
1. `vendor/assets`

このなかの`app/assets`は、Railsアプリを作成時に自動で作成されます。

## アセットパイプライン(Asset Pipeline)を使う

では実際にアセットパイプラインを使ってみます。  
なお、説明に使うコードはerbではなくhamlを使います。

### 仕組みはデフォルトで用意されている
実はRailsアプリを作成すれば、既にアセットパイプラインを利用できる環境は整っています。  
そのため、各Controllerのスタイルシートを編集してるだけで、それらのスタイルシートはパイプラインの処理を施されマスターファイルが作成されます。

なぜなら、デフォルトファイル`application.scss`は自身の位置するフォルダ配下のアセットを対象としたマニフェストが書かれてるからです。

そのため、Controllerを作成すればスタイルシートは`app/assets/stylesheets`フォルダ配下に作成されますが、マニフェストの対象となっているため、自動でマスターファイル(`application.css`)に結合されます。

### マスターファイルをロードする
作成されたマスターファイルのロードは、`stylesheet_link_tag`を使用します。

なお、マスターファイル`application.css`は、デフォルトのレイアウトファイル`application.html.haml`でロードされています。
次のコードは`application.html.haml`を一部抜粋したものです。
```
!!!
%html
  %head
    %meta{:content => "text/html; charset=UTF-8", "http-equiv" => "Content-Type"}/
    %meta{name: 'viewport', content: 'width=device-width,initial-scale=1'}
    %title AnyTitle
    = csrf_meta_tags
    = csp_meta_tag
    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload'
    = javascript_pack_tag 'application', 'data-turbolinks-track': 'reload'
    = stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload'
```


`'data-turbolinks-track': 'reload'`はページ遷移時にリソースを必要に応じてリロードします。

## ディレクティブについて
マニフェストファイル(`application.scss`)にはマニフェスト表現のためにディレクティブが書かれてます。
具体的には、次のようなコメント上で特殊な構文が使われます。

```scss
*= require_tree .
*= require_self
```

### require_tree
`require_tree`ディレクティブは指定した相対パスのディレクトリ以下全てのアセットを対象にします。
子ディレクトリにも再帰的に動きます。

特定のディレクトリだけ指定したい場合は、`require_directory`ディレクティブを使います。

### require_self
`require_self`は自身のCSSを使います。

### ディレクティブ順番が結合順
ディレクティブの順番によってマスターファイルに結合される順番が変わります。
順番によってはcssの設定が上書きされたりするので、注意が必要です。

## アセットのコンパイルは環境依存
アセットパイプラインの処理には、ミニファイや結合などのファイル操作があります。  
このファイル操作は開発環境では、ファイルのロード時に動的でコンパイルされます。  
これは開発中にアセットが変更されても、自動でコンパイルするので開発しやすいです。

### 本番では自動コンパイル無効
しかし、本番環境ではアセットは頻繁に変わることはないので、サーバーが動的にコンパイルするのは無駄です。  
そのため、本番環境ではコンパイルはOFFにされており、事前にアセットのコンパイル(プリコンパイル)が必要です。  


### 自動コンパイルの設定確認
なお、アセットの動的コンパイルは次のコードで設定します。

```ruby
config.assets.compile = true
```

本番環境ではこの値がfalseになっています。

## 本番用にプリコンパイルする
本番環境用にマスターファイルを作成するには、`rails assets:precompile`タスクを使います。

```sh
$ RAILS_ENV=production bin/rails assets:precompile
```

プリコンパイルされたファイルは`public/assets`に展開され、`public`ディレクトリ同様に静的ファイルとして扱われます。

### ファイルが見つからないとエラーが起きる
本番環境でプリコンパイル済みファイルが見つからないと、`Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError`が発生します。

### フィンガープリントでキャッシュ制御
キャッシュが有効な場合、マスターファイルにはフィンガープリントでキャッシュ制御が必要です。  
なぜなら、キャッシュはパスで管理されます。  
アセットに変更が加わってもマスターファイルのパスは変わらないので、キャッシュ有効と判断されます。

そのため、プリコンパイルするたびにファイル名にフィンガープリントが付与されます。

## マニフェストを増やす
デフォルトではマニフェストファイルは`application.scss`や`application.js`です。

例えばRailsアプリに管理画面を追加したく、管理画面用Bootstrapフレームワークを使いたいなど、レイアウトが大きく変えたい場合などはマニフェストを分けたほうが使いもしないコードの混在を回避できます。

別のマニフェストを追加したい場合は、`config/initializers/assets.rb`内で`Rails.application.config.assets.precompile`を使用します。  
管理画面用のマニフェストを`admin`にしたい場合は、コードは次のようになります。

```ruby
Rails.application.config.assets.precompile += %w( admin.js admin.css )
```

## アセットパイプラインは未だに健在する
アセットパイプラインはモダンな環境では使われないかもしれません。  
しかし、世の中で動いているサービスの比率で言うとまだまだアセットパイプラインは負債扱い・現役問わず、まだまだ使用されています。  
アセットパイプラインを使った環境で開発したり、使わない環境へリニューアルするにしてもアセットパイプラインの知識がまだまだ必要なはずです。

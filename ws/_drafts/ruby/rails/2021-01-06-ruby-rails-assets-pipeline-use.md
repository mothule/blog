---
title: RailsのAsset Pipeline(アセットパイプライン)の使い方
categories: ruby rails
tags: ruby rails asset-pipeline
---

## アセットパイプライン(Asset Pipeline)とは
アセットパイプラインの概要を手っ取り早く理解するには、「{% post_link_text 2021-01-05-ruby-rails-assets-pipeline-brief %}」にまとめてあります。

TODO: 記事完成したら、 2021-01-05-ruby-rails-assets-pipeline-brief 側のリンクとつなぐ

## アセットパイプライン(Asset Pipeline)の使い方

アセットパイプラインを使う流れ

- controller作成作るだけ
- アセットの配置場所
  - `app/assets`
  - `lib/assets`
  - `vendor/assets`
- 対象ファイルを使う
  - アセットのパス検索
- 範囲外のファイルを使えるようにする
- プリコンパイルする

説明に使うRailsアプリはerbではなくhamlを使います。

### デフォルトはapplication
Railsアプリのデフォルトレイアウト`application.html.haml`では、

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

### Controllerを作るだけ

仮にController(`admin/users_controller`)を作るとします。
作成時に専用のScss(`admin/users.scss`)が作成されます。

```sh
$ bin/rails g controller admin/users_controller index
      create  app/controllers/admin/users_controller.rb
       route  namespace :admin do
  get 'users/index'
end
      invoke  haml
      create    app/views/admin/users
      create    app/views/admin/users/index.html.haml
      invoke  helper
      create    app/helpers/admin/users_helper.rb
      invoke  assets
      invoke    scss
      create      app/assets/stylesheets/admin/users.scss
```


- ファイルを`app/assets`ディレクトリ以下に配置する
  - ファイルタイプ毎にサブフォルダに分ける
    - 画像なら`images`
    - JavaScriptなら`javascripts`
    - Stylesheetなら`stylesheets`
- `production`モードではプリコンパイルしたファイルを`public/assets`に展開する
  - `public`ディレクトリ同様に静的ファイルとして扱われる。
- コントローラ(`HogeController`)を生成するとjs/cssもコントローラー用に生成されます。
  - `app/assets/javascripts/hoge.js`
  - `app/assets/stylesheets/hoge.css`
  - `coffee-rails`や`sass-rails`gemが有効な場合だとcoffee/scssが生成されます。
    - `app/assets/javascripts/hoge.coffee`
    - `app/assets/stylesheets/hoge.scss`
- プリコンパイルすると`app/assets`フォルダ以下の`application.js`, `application.css`, 非js/cssがインクルードされる。
- 他のマニフェストや他のスタイルシートやJavaScriptをインクルードする場合は`config/initializers/assets.rb`で
`precompile`という配列に追加する。
- `production`モードでプリコンパイル済みファイルが見つからないと、`Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError`が発生する
- 動的コンパイル
  - `config.assets.compile = true`



## フィンガープリントでキャッシュ制御
アセットパイプラインは、作成したファイルをフィンガープリントでキャッシュ制御します。  
なぜなら複数ファイルを結合したファイルは、そのままでは正しく反映されません。

### キャッシュの基礎理解

キャッシュを噛み砕いて表現するなら、KeyValue形式です。

```ruby
cache = {
  'https://www.google.co.jp': '<!doctype html><html itemscope="" itemtype="http:/...'
}
```
のようにKeyにはURL, ValueにはURL先のレスポンス結果が入ってます。  
通信先にリクエスト出す前にURLをキャッシュ先にあるか調べます。  
見つかれば通信せずにキャッシュ先のValueを使るイメージです。  
**（あくまでイメージです。厳密には異なります）**

### 結合されたファイルのURLは1つ
キャッシュは、パフォーマンスのためにあらゆる通信機構の中で使われます。  
例えば、同じURLであればリクエストせずにキャッシュ先のファイルを使います。

アセットパイプラインで作成されたファイルは、複数のファイルが1ファイルに結合されています。  
URLも1つです。

つまり、結合前のファイルに変更を加えても、URLは変わらないためキャッシュが有効と判断されたらキャッシュ先のファイルが使われます。

### キャッシュ回避のためファイル名を変える
このキャッシュを確実になくす方法があります。
URLが別名であればキャッシュは存在しないため必ず通信先から取得します。

この仕組みを利用したのが、ファイル名にフィンガープリントをつけることです。
例えば、`hoge.css`であれば`hoge-1234asdferty.css`など、ファイル名の末尾にハッシュ値がつきます。  
フィンガープリントは、ハッシュ値です。MD5で生成します。

ハッシュはファイルの中身から生成します。
なので結合元のファイルに変更があれば、結合ファイルの中身も変わります。
中身が変わればハッシュ値も変わります。
ハッシュ値が変わればファイル名も変わります。
つまり、**結合元のファイルが変われば、URLが変わります。**

懸念として、URLが変わるとリンク切れの心配もあります。  
そこは自動で対応されます。


---

*application.css*
```css
/*
 *= require_self
 *= require_tree .
 */
```

- アセットパイプライン(Asset Pipeline)
  - アセットパイプライン(Asset Pipeline)とは
    - Sprockets(sprockets-rails)が実体
    - デフォルト有効
  - プリコンパイル
    - 複数ファイルを1ファイルに結合するには、事前に実行しておく必要がある
    - `config.assets.precompile`
  - cssの圧縮
    - yui gem
  - jsの圧縮
    - uglifier gem
  - Sprockets
    - マニフェストファイル
      - ディレクティブ
        - require
          - 必要ファイルの指定
        - require_self
          - 自身のファイルを指定
        - require_tree
          - 指定ディレクトリ以下を再帰的に指定

## require

## require_self
ファイル自体をロードapplication.css自体


## require_tree

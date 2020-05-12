---
title: rablの使い方を丁寧に説明
description: Railsのビューテンプレートエンジンにも使われるrablの導入やDSLの書き方であるnode,object,collection,attributes,attribute,child,glue,extends,cacheについて説明します。
categories: ruby rails
tags: ruby rails
image:
  path: /assets/images/2020-05-05-ruby-rails-rabl-basic/rabl-eyecatch.png
---
この記事ではrablの書き方を毎回忘れてしまう人や初めて耳にしてrablの使い方を知りたい人向けにrablの導入からrablの書き方まで詳しく説明します。

流れは大きく次の順番で説明していきます。

- rablとは？
- rabl環境構築
- rabl DSLの書き方

## rablとは？

- RABL(Ruby API Builder Language)
- Rails向けRuby用テンプレートシステム
- json, bson, xml, plist, msgpackサポート
- 表示データとその表現を分離させている
- GitHubは[nesquena/rabl](https://github.com/nesquena/rabl)
- RubyGemsは[rabl](https://rubygems.org/gems/rabl/versions/0.11.6)

## rabl環境の構築

1. gem用意
1. 設定ファイル登録
1. rablファイル用意

### gem用意
Gemfileにgemを追加します。

```ruby
gem 'rabl'
```

`bundle install`を忘れずに。

### 設定ファイル登録
`config/initializers`に**rabl_init.rb**を追加します。

内容は最低限下記を記載します。

```ruby
require 'rabl'

Rabl.configure do |config|

end
```

まずは設定は特になしで問題ありません。後ほど一部設定項目について説明します。

### rablファイル用意
viewsフォルダに例えば`index.rabl`を用意します。  
レスポンスがJSONのControllerであれば直接`.rabl`でも動きます。

## rablに慣れる
まずは簡単なrablの書き方から入ってrablに触れて少し慣れましょう。

### 最初のrabl
まずはrablで最も単純なrabl記法です。

```ruby
node(:key) { "value" }
```

結果はこれになります。

```json
{"key":"value"}
```

### Rubyオブジェクトの値を表示する
次は先程の`node`を使ってRubyオブジェクトを表示します。  
手元で動かす場合は、ControllerやModelは適宜用意してください。

Model側:  
```ruby
create_table :users do |t|
  t.string :name
  t.date :birth_date
  t.integer :score
  t.timestamps
end
```

Controller側：  
```ruby
class UsersController < ApplicationController
  def show
    @user = User.first
  end
end
```

View側:  
```ruby
node(:name) { @user.name }
node(:birth_date) { @user.birth_date }
node(:score) { @user.score }
```

`$ http get "http://localhost:3000/users/1"`のレスポンスです。※  
```json
{
  "name": "A",
  "birth_date": "2020-05-05",
  "score": 1
}
```

※`$ http get`はHTTPieといってcurlよりも書き方が直感的なCLIツールです。気になる方は、「{% post_link_text 2019-02-24-recommend-httpie %}」にまとめてあります。

### rabl上でRubyコードを書く
rablファイル上ではRubyコードを書くことが可能です。  
次のコードはユーザー数が2つなら複数モデルを表示します。

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
  end
end
```

rablコード  
```ruby
if @users.count == 2
  node(:users) do
    @users.map do |user|
      {
        name: user.name,
        birth_date: user.birth_date,
        score: user.score
      }
    end
  end
end
```

レスポンス  
```json
{
  "users": [
    {
      "name": "A",
      "birth_date": "2020-05-05",
      "score": 1
    },
    {
      "name": "B",
      "birth_date": "2020-05-04",
      "score": 3
    }
  ]
}
```

`node`のブロック内がRubyコードを評価されます。  
このブロック内ではrabl記法は評価されません。

### nodeだけでは本領発揮
`node`ではrablの本領を発揮していません。
rablは通常は表示データはモデルであり、レスポンスはRuby DSLを使ってrablファイルに記述します。

## rablのobjectを使う
ActiveRecordのUserを表示する場合は次のrablコードになります。

```ruby
object @user
attributes :name, :score
attribute :birth_date => 'birth_day'
node(:down_case_name) { |user| user.name.downcase }
```

これのレスポンスです。

```json
{
  "user": {
    "name": "A",
    "score": 1,
    "birth_day": "2020-05-05",
    "upper_name": "a"
  }
}
```

`object`にモデルを渡すことで表示のためのDSLがそのモデルを情報として使うようになります。

- `attributes`の渡してる文字列はJSONとモデルで使われます
  - JSONのメンバー名になる
  - モデルのカラム名として呼ばれる
  - Hash構造を渡せばJSONのメンバー名とモデルのメソッド名を分けれます。
- `node`も使えます。
  - `node`にモデルが引数として渡されます。

### rablはモデルのメソッドを呼んでいる
rablの`attributes`はカラム値を取得してるのではなく、  
ARモデルのメソッドを呼んで結果を取得しています。  
なので先程の`node(:down_case_name)`はメソッド名としてARモデル側に用意すれば`attributes`として指定できます。

ARモデル:  
```ruby
class User < ApplicationRecord
  def down_case_name
    name.downcase
  end
end
```

rabl:  
```ruby
object @user
attributes :name, :score
attribute :birth_date => 'birth_day'
attribute :down_case_name
```

### ルートノードを外すまたは変える
objectを使ったレスポンスではルートノードに`user`という括りがされています。  
これを違う名前にしたかったり、外したい場合は`object`にオプションを渡します。

無指定だと
```ruby
object @user # user:
```
`user`が入ります
```json
{"user":{"name":"A","score":1,"birth_day":"2020-05-05"}}
```

Hash形式でシンボル値を渡すと
```ruby
object @user => :gamer
```
渡したシンボル名になります。
```json
{"gamer":{"name":"A","score":1,"birth_day":"2020-05-05"}}
```
※シンボル指定です。文字列だと`string`になります。

`false`を渡すと
```ruby
object @user => false
```
ルートノードはなしになります。
```json
{"name":"A","score":1,"birth_day":"2020-05-05"}
```
になります。


## rablのcollectionを使う
`object`がモデル1つだとしたら、`collection`は複数形です。

最初に載せたNodeを使った複数Userを表示するrablを`collection`を使うとこうなります。

```ruby
collection @users
attributes :id, :birth_date, :name
```

結果はこうなります。

```json
[
  {
    "user": {
      "id": 1,
      "birth_date": "2020-05-05",
      "name": "A"
    }
  },
  {
    "user": {
      "id": 2,
      "birth_date": "2020-05-04",
      "name": "B"
    }
  }
]
```


### オブジェクトルートを変更または消す
モデル毎に`user`というオブジェクトルートが入っているのでこれを消すには`collection`にオプションを渡します。

```ruby
collection @users, :object_root => false
```

`object`と同じで`false`ではなくシンボルを渡せば`user`ではなく別名に変更できます。

### ルートノードをつける
ルートノードをつけたい場合は`root`オプションを渡します。

```ruby
collection @users, :root => 'gamers', :object_root => false
```

結果はこうなります。

```json
{
  "gamers": [
    {
      "id": 1,
      "birth_date": "2020-05-05",
      "name": "A"
    },
    {
      "id": 2,
      "birth_date": "2020-05-04",
      "name": "B"
    }
  ]
}
```

## rablのchildを使う
objectとcollectionはルートレベルにモデルがマッピングされている場合に使えます。  
しかし次のルートレベルにモデル以外のレスポンスが必要なケースがあります。

```json
{
  "count": 2,
  "users": [
    {
      "id": 1,
      "birth_date": "2020-05-05",
      "name": "A"    
    },
    {
      "id": 2,
      "birth_date": "2020-05-04",
      "name": "B"
    }
  ]
}
```

この場合は、`object`を`false`にして`node`形式と`child`を使います。

```ruby
object false

node(:count) { @users.count }
child(@users, object_root: false) do
  attributes :id, :birth_date, :name
end
```

`object_root`を`false`にしておかないとモデル毎に`user`というキーが入ります。


## 親子関係はchildを使う

Userモデルと住所モデルがあり、Userが住所を複数個持っている関係とした場合

```ruby
class User < ApplicationRecord
  has_many :addresses, inverse_of: :user
end

class Address < ApplicationRecord
  belongs_to :user, inverse_of: :addresses
end
```

rablでは`child`を使います。


```ruby
collection @users, :object_root => false
attributes :id, :name, :birth_date

child(:addresses, object_root: false) do
  attributes :post_code
end
```

ルートレベルにオブジェクトが紐付いているため、シンボルを渡すことでそのオブジェクトのメソッドとして評価されます。　　
次のコードと同じ意味になります。
```ruby
child(@user.addresses, object_root: false)
```

## rablのglueを使う
glueとはモデルとはリレーションシップのないモデルを繋ぎます。  
glueの和訳は「接着剤」または「接着する」するです。  
つまりあるデータとあるデータをくっつける場合に使います。

Controller側で異なるUserのアドレスを1件取っておきます。  
```ruby
def show
  @user = User.first
  @other_address = User.second.address.first
end
```

rabl側では`glue`を使って`@other_address`の情報を`@user`の情報と合わせて一つのレスポンスとして返します。

```ruby
object @user
attributes :name, :score, :birth_date

child(:addresses, object_root: false) do
  attributes :post_code
end

glue @other_addresses do
  attributes :post_code => :other_post_code
end
```

レスポンスでは無関係なモデルが1つのレスポンスとしてかえってきます。

```json
{
  "user": {
    "name": "A",
    "score": 10,
    "birth_date": "2020-05-05",
    "addresses": [
      {
        "post_code": "1680064"
      }
    ],
    "other_post_code": "5680068"
  }
}
```

## rablのextendsを使う
rablで部分テンプレート(partial)を使うには`extends`を使います。


次のコードはUser単体を表示するrablです。  
rablの場所を`users/show`とします。

```ruby
object @user
attributes :name, :score, :birth_date

child(:addresses, object_root: false) do
  attributes :post_code
end
```

次のコードはUser一覧表示を上のrablを`extends`を使って表示するrablです。
```ruby
collection @users, :object_root => false
extends 'users/show'
```

### extends先のobjectやcollectionは上書きされる
extends先のrablのobjectやcollectionは呼び出し元に渡されたオブジェクトになります。  
上記の場合は単体のUserモデルが渡されることになります。

child内のextendsでも同じです。

下記rablファイル(`addresses/index`)があった場合に
```ruby
collection @addresses
attributes :post_code
```

Userモデルからextendsで呼ばれたら、collectionにはUserモデルのaddressesが入ります。
```ruby
child(:addresses, object_root: false) do
  extends 'addresses/index'
end
```

呼び出し元でオブジェクトを指定することもできます。
```ruby
extends "addresses/index", object: @other_addresses
```

## rablでcacheを使う
rablでフラグメントキャッシュを使うには`cache`を使います。  
デフォルトでは、Railsのキャッシュシステムを使います。  
利用にはキャッシュ用のキーが必要になります。  

### キャッシュキー
キーは文字列になります。

文字列以外を渡す場合は、文字列へ変換されます。例えば

- モデルを渡す場合は`cache_key`メソッドが定義されて文字列を返す必要があります。  
- 配列の場合は先頭から各要素を文字列変換後にスラッシュ(`/`)で結合します。

```ruby
cache 'lists' # lists
cache @user # @user.cache_key
cache ['hoge', @user] # "hoge/#{@user.cache_key}"
```

### キャッシュ期限
オプションで`expires_in`を渡すことでキャッシュの期限を設定できます。

```ruby
cache @user, expires_in: 1.hour
```

### extends先のキャッシュ
cacheコマンドはextends先のrablでも使えます。

自身の呼び出し元のオブジェクトを参照したい場合は`root_object`を使います。

```ruby
cache ["list", root_object]
attributes :id, :name
```

## ルートノードの表示のデフォルト値を設定する
ルートノードはオブジェクトルートの表示をrabl毎に設定せずに一律デフォルト値を設定する場合は  
`/config/initializers/rabl_init.rb`に次の2つを指定することでデフォルト値の変更ができます。

```ruby
Rabl.configure do ||config|
  config.include_json_root = false
  config.include_child_root = false
end
```

他にもrablの設定では

- 存在しない属性にRuntimeErrorを発生させる(productionはtrue非推奨)
- nilは空の文字列に変換する
- nilの場合はレスポンスから除外

などの変更ができます。

```ruby
# 存在しない属性にRuntimeErrorを発生させる(productionはtrue非推奨)
config.raise_onmissing_attribute = true

# nilは空の文字列に変換する
config.replace_nil_values_with_empty_strings = true

# nilの場合はレスポンスから除外
config.exclude_nil_values = true
```

詳しくは[GitHubのConfiguration](https://github.com/nesquena/rabl#configuration)にて説明されています。

## rablは使いにくい
個人的にはRuby on Railsでrablは採用しないほうがいいです。

- DSLの書き方が独自なため流動性が低い
- repositoryが活発的とは言えない
- ARモデル表示に特化しすぎていてページネーションとかARモデル外の柔軟性が低い
- 日本語記事が少ない

この記事を書いたのも仕事柄どうしてもrablで書かないといけないケースがあって、そのたびに忘れてしまい生産性が下がるのでまとめた次第です。

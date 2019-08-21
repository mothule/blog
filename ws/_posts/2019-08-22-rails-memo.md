---
title: ActiveRecordでpluckとselectしてpluckに変化はあるか？
description: ActiveRecordでpluckとselectしてpluckに変化はあるか？
date: 2019-08-05
categories: ruby rails active-record
tags: ruby rails active-record
---

# rabl

## ルートノードを外す

デフォルトではルートノードにモデル名が表示される。
このモデル名を外したい場合は `/config/initializers/rabl_config.rb`を次のようにする。

```ruby
Rabl.configure do ||config|
  config.include_json_root = false
end
```


## Basic

### テーブルカラムをViewに出す
object, collection, attributesを使う。

#### モデル単体をViewに出す

```ruby
@user = User.first
```

```show.json.rabl
object @user
attributes :id, :name
```

```JSON
{
  "id": 5,
  "name": "hoge"
}
```

#### モデル複数をViewに出す

```ruby
@users = User.all
```

```index.json.rabl
collection @users
attributes :id, :name
```

```JSON
{
  "users": [
    {
      "id": 5,
      "name": "hoge"
    },
    {
      "id": 6,
      "name": "fuga"
    }
  ]
}
```


### テーブルカラムでない属性をViewに出す
nodeやchildを使う。

- node: ブロックを使って自由な属性を出せる
- child: 親子関係があるときに使う
- glue: has_oneな子供を親につける

#### node
先程のUser単体を表示するコードもnodeで書き直すこともできる。

```rabl
object @user
node(:id) {|u| u.id }
node(:name) {|u| u.name }
```

userキーではなく別のキーとして使うこともできる。

```rabl
object false
node(:data) do
  {
    id: @user.id
    name: @user.name
  }
end
```

```json
{
  "data": {
    "id": 5,
    "name": "hoge"
  }
}
```

条件分岐もかける
```rabl
object @user
attributes :id, :name
if current_user.admin?
  node(:full_name) { |u| u.full_name }
end
```

#### child
UserにAddressが次のような関連を持っているとしたら
```ruby
class User < ActiveRecord::Base
  has_many :addresses
end
```

```ruby
object @user
attributes :id, :name
child :addresses do
  attributes :country, :state, :city
end
```

UserにFamilyが次のような関連を持っているとしたら

```ruby
class User < ActiveRecord::Base
  belongs_to :family
end
```

```ruby
object @user
attributes :id, :name
child :family do
  attributes :name
end
```

### ビューのテンプレート化

先程表示したUser単体表示を複数でしたい場合は次のようにします。

```ruby
collection @users
extends "users/show"
```

child内でextendsを呼んでも呼び込み先ではobjectはchildで渡されたオブジェクトになる。

index.rabl
```ruby
child @sales => :sale do
  extends 'show'
end
```

**show.rabl**

```ruby
attributes :id, :name
```

↑ object @sale といったオブジェクト指定は不要。

extends 先にオブジェクトを指定する
```ruby
extends "spree/v2/products/large", object: @product
```


## Cache

Railsのキャッシュシステムを使う。
キャッシュ用キー（cache_keyメソッド, 配列, 文字列応答できるオブジェクト）が必要。

cacheコマンドはRailsのフラグメントキャッシュと同じパラメータを受け取る。

```ruby
cache @user # @user.cache_key
cache ['hoge', @user] # "hoge/#{@user.cache_key}"
cache 'lists' # lists
cache @user, expires_in: 1.hour
```

cacheコマンドはテンプレート先でも元でも使える。

テンプレート先で呼び出し元のオブジェクトを参照したい場合は
root_objectを使う
```ruby
object @task
extends 'users/base'
```

```users/base.ruby
cache ["base", root_object]
attributes :id, :name
```

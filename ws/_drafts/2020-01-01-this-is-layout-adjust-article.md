---
title: レイアウト調整記事
categories: ios ruby
tags: TODO debug
image:
  path: /assets/images/2020-01-01-this-is-layout-adjust-article/0.png
---
リード文リード文リード文リード文リード文リード文リード文リード文リード文リード文リード文リード文リード文リード文　　
リード文リード文リード文リード文リード文リード文リード文リード文

リード文リード文リード文リード文
## H2タイトル
あいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをんあいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをん  
改行後abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ

段落後abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
### H3タイトル
あいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをんあいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをん  
#### H4タイトル
あいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをんあいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをん  
##### H5タイトル
あいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをんあいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをん  
###### H6タイトル
あいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをんあいうえおかきくけこさしすせそたちつてとなにぬねのまみむめもらりるれろわいうえをん  

**太字** **ABCEabcde** *イタリック* *ABCDEabcde* ~~取り消し~~ ~~ABCDEabcde~~

表直前あいうえお

|名前|意味|中央寄せ|右寄せ|
|---|---|:--:|--:|
|表表表|table|TABLETABLE|ひょう|
|表|tabletable|TABLE|ひょうひょう|

表直後あいうえお

コード前あいうえお

あいうえお`コード`aiueo`code`あいうえお

コード後あいうえお

引用前

> 引用  
> あいうえお

引用後

プレコード前あいうえお
```
プレコード
pre
```
プレコード後あいうえお

ハイライト言語前あいうえお
```sh
$ cat ~/test.txt
test
$ echo "test2" > ~/test.txt
$ cat ~/test.txt
test2
```
```ruby
require 'yaml'
echo 'ruby language syntax highlight'
class YamlPerser
  attr_accesser :name
end

# Classクラスaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 191
      t.timestamps
    end

    add_index :users, :name
  end
end
```
ハイライト言語後あいうえお


箇条書き前あいうえお
- あいうえお1
  - あいうえお2
    - あいうえお3
- あいうえおA
  - あいうえおB

箇条書き後あいうえお

番号付き箇条書き前あいうえお
1. あいうえお1
    1. あいうえお2
        1. あいうえお3
1. あいうえおA
    1. あいうえおB

番号付き箇条書き後あいうえお

区切り線前

---

区切り線後

画像前あいうえお

{% page_image 1.jpg 50% alt-text %}

画像後あいうえお

## H2タグ直下に引用

> 引用
> 引用

### H3タグ直下に引用

> 引用
> 引用

## H2タグ直下にコード
```swift
print("Aiue", #function)
```

### H3タグ直下にコード
```swift
print("Aiue", #function)
```

## H2タグ直下にテーブル

|A|B|C|
|---|---|---|
|asdf|asdf|asdf|
|asdf|asdf|asdf|
|asdf|asdf|asdf|

### H3タグ直下にテーブル

|A|B|C|
|---|---|---|
|asdf|asdf|asdf|
|asdf|asdf|asdf|
|asdf|asdf|asdf|

## H2タグ直下に箇条書き

- 箇条書き1
  - 箇条書き2
- 箇条書き1
  - 箇条書き2
- 箇条書き1
  - 箇条書き2
- 箇条書き1
  - 箇条書き2

### H3タグ直下に箇条書き

- 箇条書き1
  - 箇条書き2
- 箇条書き1
  - 箇条書き2
- 箇条書き1
  - 箇条書き2
- 箇条書き1
  - 箇条書き2

## H2タグ直下に段落
あいうえお

### H3タグ直下に段落
あいうえお

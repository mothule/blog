---
title: Rubyのバックスラッシュ記法(\t \n \sなど)一覧を確認
categories: ruby
tags: ruby
image:
  path: /assets/images/2020-02-28-ruby-backslash.png
---

## バックスラッシュ記法とは？
文字列中でバックスラッシュ(\\)の後に記述する文字によって特別な意味を持つ記法です。制御文字とも呼ばれます。

## バックスラッシュ記法の一覧

|バックスラッシュ記法|意味|
|---|---|
|\\t|タブ(0x09)|
|\\v|垂直タブ(0x0b)|
|\\n|改行(0x0a)|
|\\r|キャリッジリターン(0x0d)|
|\\f|改ページ(0x0c)|
|\\b|バックスペース (0x08)|
|\\a|ベル (0x07)|
|\\e|エスケープ (0x1b)|
|\\s|空白 (0x20)|
|\\nnn|8 進数表記 (n は 0-7)|
|\\xnn|16 進数表記 (n は 0-9,a-f)|
|\\cx or \\C-x|コントロール文字 (x は ASCII 文字)|
|\\M-x|メタ x (c \| 0x80)|
|\\M-\\C-x|メタ コントロール x|
|\\x|文字 x そのもの|
|\\unnnn|Unicode 文字(n は 0-9,a-f,A-F、16進数4桁で指定)|
|\\u{nnnn}|Unicode 文字列(n は 0-9,a-f,A-F)。nnnnは16進数で1桁から6桁まで指定可能。スペースかタブ区切りで複数の Unicode 文字を指定できる。例: "\\u{30eb 30d3 30fc a}" # => "ルビー\\n"|
|\\改行|文字列中に改行を含めずに改行|

[Rubyリファレンスマニュアルより抜粋引用](https://docs.ruby-lang.org/ja/latest/doc/spec=2fliteral.html#backslash)

### タブ(\\t)

分かりにくいですが、fooとbarの間にスペースではなく、タブが入ります。

```ruby
puts "foo\tbar"
foo	bar
```

### 垂直タブ(\\v)
真下に移動します。

```ruby
puts "foo\vbar"
foo
   bar
```

### バックスペース(\\b)

キーボードのバックスペース同様、手前1文字を消します。

```ruby
puts "foo\bbar"
fobar
```

### ベル(\\a)

実行すると音がなります。

```ruby
puts "foo\abar"
foobar
```

### 空白(\\s)

スペース1文字入ります。

```ruby
puts "foo\sbar"
foo bar
```

### 8進数表記, 16進数表記, コントロール文字

これらは直接制御文字を指定する方法です。
制御文字のコードと命令については[Wikipedia](https://ja.wikipedia.org/wiki/%E5%88%B6%E5%BE%A1%E6%96%87%E5%AD%97)が分かりやすいです。

例えば前述したタブの場合は コントロール文字であれば`^I`16進数なら`09`なので、
Rubyではこう書きます。

```ruby
puts "foo\cIbar"
foo	bar

puts "foo\x09bar"
foo	bar
```

### Unicode文字, Unicode文字列

Unicodeを直接指定します。
例えば`A`の場合は`0x0041`なので

```ruby
puts "\u0041"
A
```

文字列`ABC`の場合は`0x0041 0x0042 0x0043`なので

```ruby
puts "\u{0041 0042 0043}"
ABC
```

### 文字列中に改行を含めずに改行(\\改行)

文字列を作成中に改行しても文字列作成中を継続する場合に使います。
これ意味わかりにくいですが、コード見ると何のことかすぐ分かります。

```ruby
hoge = "foo\
bar\
baz"
puts hoge # foobarbaz
```

## Rubyのバックスラッシュ記法一覧確認したけど
用途や効果の分からない記法もありました。長年実務でも見かけたことのないものなので特別なシステム開発でしか使われないかと思います。

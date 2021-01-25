---
title: Swiftの高階関数で遅延評価(lazy)を使い処理を効率化する
description: Swiftで提供されてる高階関数に遅延評価を取り入れることでそのままでは非効率な処理フローを効率よくする方法について説明する。
categories: ios swift
tags: ios swift
image:
  path: /assets/images/2020-08-07-ios-swift-lazy-sequence-and-collection/0.png
---
例えばlazyを使うと10万件のフルアクセス処理が1件で済みます。

## Swiftの高階関数はその場でクロージャを評価する
SwiftのCollectionなどで使える高階関数(filter, map, reduceなど)は、  
関数が呼ばれたら、その場でクロージャが評価されます。

```swift
func toString(from val: Int) -> String {
    print(#function)
    return String(val)
}

let sequence = stride(from: 0, to: 10, by: 1)
    .filter({ $0 % 2 == 0 })
    .map({ $0 * 2 })
    .filter({ $0 > 0 && $0 < 5 })
    .map(toString)
print("Will call count")
print(sequence.count)
```

例えば上記コードを実行すると、コンソールには下記が出力されます。

```
toString(from:)
Will call count
1
```

## ケースによっては無駄な処理が生まれる

例えば10万件に対しあるfilter処理した結果に対し**isEmpty**を呼びたいケースはコードだとこうなります。

```swift
let sequence = Array(stride(from: 0, to: 100000, by: 1))
    .filter({ $0 % 2 == 0 })
print(sequence.isEmpty)
```

これを高階関数を使わず書くとこうなります。

```swift
var isEmpty: Bool = true
let sequence = Array(stride(from: 0, to: 100000, by: 1))
for val in sequence {
    if val % 2 == 0 { isEmpty = false } // ①
}
print(isEmpty)
```

isEmptyは1回でも条件満たせばいいので、それ以降のループ処理を走らせる必要がありません。  
①の部分でisEmpty = falseの後にbreakでループを抜けるべきです。

### 高負荷だと無駄が顕著に現れる

例えば高階関数のクロージャが少し重かったとします。(0.001秒かかる)  

```swift
let sequence = Array(stride(from: 0, to: 100000, by: 1))
    .filter({
        Thread.sleep(forTimeInterval: 0.001)
        return $0 % 2 == 0
    })
print(sequence.isEmpty)
```

この場合、最終的な結果を得るには、少なくとも100秒(0.001秒 × 10万件)かかります。

## lazy(遅延評価)を使う
SwiftのSequenceやCollectionにはlazy機能があります。  
これは実際の値が必要になるまで高階関数内クロージャを実行しません。  
実際の値とは`isEmpty`や`count`、`first`などです。

### 遅延を確認する

lazyを使うには、高階関数を呼ぶ前に`lazy`メソッドを呼びます。  
冒頭に説明したコードを使ってlazy化します。

```swift
func toString(from val: Int) -> String {
    print(#function)
    return String(val)
}

let sequence = stride(from: 0, to: 10, by: 1)
    .lazy
    .filter({ $0 % 2 == 0 })
    .map({ $0 * 2 })
    .filter({ $0 > 0 && $0 < 5 })
    .map(toString)
print("Will call count")
print(Array(sequence).count)
```

これを実行するとコンソールには下記が出力されます。

```
Will call count
toString(from:)
1
```

高階関数内で呼ばれている`toString(from:)`が`Will call count`より後に来ています。

### 効率化を確認する

Swiftのlazyにはもう一つ特徴があります。  
それは実際の値を必要としてるメソッドによって、高階関数のクロージャを中断することです。  
例えば先程使った100秒かかるコードをlazy化してみます。

```swift
let sequence = Array(stride(from: 0, to: 100000, by: 1))
    .lazy
    .filter({
        print("in filter")
        Thread.sleep(forTimeInterval: 0.001)
        return $0 % 2 == 0
    })
print(sequence.isEmpty)
```

これを実行するとコンソールは下記を出力します。

```
in filter
false
```

`in filter`が1回しか呼ばれていないです。
これは1回目のループで`true`になったことで`isEmpty`の判断ができるようになったので処理を中断してます。  

ちなみに`isEmpty`を`count`にすると、lazyしてないコード同様に全てのループを実行します。  
これは`count`の結果を判断するには全部の処理を通さないと結果が分からないためです。

つまり`lazy`を使うことで途中で結果が得られたら中断し得られない場合は継続します。

## 全部lazyというわけではない
とりあえず全部lazyにしとけば良いというものではありません。  
lazyにすることで通常と比べ遅延用の仕組みが必要となるため内部処理が複雑となるため速度やメモリ負荷がその分かかります。  

またlazyは評価を遅らせます。遅延評価のデメリットが発生することを知る必要があります。  

- LazyCollectionやLazySequenceには用意されてない高階関数がある
- 呼出元と処理実行タイミングが異なるため、どこで実際の処理が走るのか読みにくくなる

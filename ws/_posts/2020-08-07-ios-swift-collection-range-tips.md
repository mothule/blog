---
title: SwiftのCollectionとRangeを組み合わせて使いこなし術
description: SwiftのCollectionを使いこなすことでSetやArray、DictionaryをよりSwiftyに使えるようになる。今回はRangeを使った使いこなし術を説明する。
categories: ios swift
tags: ios swift
image:
  path: /assets/images/2020-08-07-ios-swift-collection-range-tips/0.png
---
SwiftのCollectionはSetやArray、Dictionaryの土台となる重要なポジションです。  
今回は[Supporting Types - Apple Developer Documentation](https://developer.apple.com/documentation/swift/swift_standard_library/collections/supporting_types)にあるサポート機能について使えそうなものがないかを調べてまとめました。


## CollectionとRangeの組み合わせ

Collectionには範囲取得する機能があります。  
範囲を表す型は、Rangeを使います。  
例えば、下のコードを見かけた人は多いと思います。

```swift
let values = [1, 2, 3, 4]
let partial = values[1...2]
print(partial) // [2, 3]
```

実はこれ以外の範囲指定方法がCollectionには用意されています。

- PartialRangeUpTo: 上限のみ(上限未満)
- PartialRangeThrough: 上限のみ(上限以下)
- PartialRangeFrom: 下限のみ
- UnboundedRange_: 上限下限なし

### PartialRangeUpTo: 上限のみ(上限未満)

上限値のみが指定された範囲型です。  
下限は無制限となります。  
そのため`contains`メソッドで範囲内判定を確認するとマイナスでも`true`を返します。

```swift
let upToFive = ..<5.0
print(type(of: upToFive)) // PartialRangeUpTo<Double>
print(upToFive.contains(3.14)) // true
print(upToFive.contains(5.0)) // false
print(upToFive.contains(5.1)) // false
print(upToFive.contains(-0.1)) // true
```

これをCollectionの範囲指定として使えます。

```swift
let numbers = [4, 2, 3, 4, 5]
print(numbers[..<3]) // [4, 2, 3]
```

ちなみにパターンマッチング演算子(`~=`)が用意されているので下記2つは同じ意味です。
```swift
print(..<3 ~= 2) // true
print((..<3).contains(2)) // true
```

### PartialRangeThrough: 上限のみ(上限以下)

PartialRangeUpToと同じですが、こちらは上限値も範囲に含めます。

```swift
let throughFive = ...5.0
print(throughFive.contains(3.14)) // true
print(throughFive.contains(5.0)) // true
print(throughFive.contains(5.1)) // false
print(throughFive.contains(-0.1)) // true
```

これをCollectionの範囲指定として使えます。

```swift
let numbers = [4, 2, 3, 4, 5]
print(numbers[...3]) // [4, 2, 3, 4]
```
### PartialRangeFrom: 下限のみ

下限値のみが指定された範囲型です。  
上限は無制限となります。  
`contains`メソッドで確認すると下記のようになります。

```swift
let atLeastFive = 5...
print(atLeastFive.contains(4)) // false
print(atLeastFive.contains(5)) // true
print(atLeastFive.contains(Int.max)) // true
```

これをCollectionの範囲指定として使えます。

```swift
let numbers = [4, 2, 3, 4, 5]
print(numbers[3...]) // [4, 5]
```

### UnboundedRange_: 上限下限なし

これはレアケースな気がしますが、上限も下限も無制限の指定方法があります。

```swift
let numbers = [4, 2, 3, 4, 5]
print(numbers[...]) // [4, 2, 3, 4, 5]
```

## Collection+Rangeまとめ

出てきた書き方を下記にまとめます。

```swift
let numbers = [4, 2, 3, 4, 5]
print(numbers[..<3])
print(numbers[...3])
print(numbers[3...])
print(numbers[...])
zip(numbers, 999...).forEach { (v1, v2) in
    print(v1, v2)
}
print(..<3 ~= 2)
```

Collectionの範囲取得で 0..<3 のような書き方をショートハンドのように省略できるようになります。  
使い所は広くはありませんが、知っておくとライブラリコードで突然出てきても落ち着いて読み進めることができます。

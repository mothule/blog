---
title: SwiftのCollectionのサポート機能に触れてみる
categories: ios swift
tags: ios swift
---
[Supporting Types - Apple Developer Documentation](https://developer.apple.com/documentation/swift/swift_standard_library/collections/supporting_types)


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

## LazySequenceやLazyCollectionによる遅延評価で効率化

Collectionの高階関数(filter, map, reduceなど)は関数が呼ばれたその場で渡したクロージャが評価されます。

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

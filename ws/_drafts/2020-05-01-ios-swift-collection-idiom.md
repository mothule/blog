---
title: SwiftのArrayとDictionaryのイディオム
categories: TODO
tags: TODO
---
TODO: リード文

- 追加
- 参照
- 検索
- 削除



### isEmptyの反対

ArrayやDictionary、StringにはisEmptyプロパティがあります。  
これは要素が空であればtrueを返すプロパティです。

しかし、状態の否定メソッドはあっても反対の肯定メソッドがないのは何かと不便です。  
「要素があれば処理をする」を書くとき下記コードのように読みにくいです。  
こののように条件に否定形を避けられません。

```swift
let string = ""
if string.isEmpty == false {
  // process something
}
```

あまり読みにくく感じないですか？  
ではこういったコードはどうですか  
否定形が増えれば増えるほど認知負荷が高くなり、リーディングに時間と頭を消耗し疲れます。

```swift
let params = ["1", "2", ""]
params.filter { !$0.isEmpty }.isEmpty == false
```

isEmptyの反対としてisAnyを用意することで眠くなるコードともおさらばです。  
下記コードはisAnyをArray,Dictionary,StringにisEmptyの反対の結果を返すプロパティisAnyを定義してます。

```swift
extension Collection {
    var isAny: Bool { !isEmpty }
}
extension String {
    var isAny: Bool { !isEmpty }
}
```

これによりさっきのコードがこう書けます。

```swift
let string = ""
if string.isAny {
  // process something
}
```

もう一つのコードもこうなります。

```swift
let params = ["1", "2", ""]
params.filter { $0.isAny }.isAny
```

### 単体検索ならfilterよりfirst
**filterは全要素アクセスするが、firstは条件満たしたら中断する**

これはイディオムとは言えないレベルですが、`filter`は要素のフィルタリングが目的なので、各要素に対して条件判定を通す必要があるので、検索としては不適切です。  

一方で`first`は最初の条件満たす要素を見つけることが目的なので、全ての要素を探す可能性が減ります。  
これは実際に動かしてみると分かります。

`filter`を使って探す場合

```swift
let array: [String] = ["A", "B", "exit", "C"]
if let exit = array.filter({
  print($0)
  return $0 == "exit"
}).first {
  print("found \(exit)")
}
```

```
A
B
exit
C
found exit
```

`first`を使って探す場合

```swift
let array: [String] = ["A", "B", "exit", "C"]
if let exit = array.first(where: {
  print($0)
  return $0 == "exit"
}) {
  print("found \(exit)")
}
```

```
A
B
exit
found exit
```

### 存在確認ならfirstよりcontains
firstとcontainsはともに条件ヒットしたら終了します。
要素の有無を調べるだけであれば、containsを使いましょう。
containsの戻り値はboolで、探してた要素を使わない場合はこちらのほうがシンプルになります。

```swift
if array.contains("exit") {
    print("found exit")
}
```

一方firstを使うと戻り値が助長になります。

```swift
if array.first(where: { $0 == "exit" }) != nil {
    print("found exit")
}
```

### ArrayからDictionary
`reduce`を使います。  
複数要素を1Dictionaryに集約します。

配列からDictionaryの変換では、**配列の1要素をKeyとValueに分解が必須です。**  
「1要素を分解しようにも…」って中々思いつかない方もいると思いますが、  
そんな難しく考えなくても実務では分解可能なモデルが多いです。

下記はある商品配列を[商品ID:商品]の型に変換するコードです。

```swift
struct Item {
    let id: Int
    let name: String
    let price: Int
}

let array: [Item] = [
    .init(id: 0, name: "梅干し", price: 230),
    .init(id: 1, name: "砂糖", price: 512),
    .init(id: 2, name: "唐辛子", price: 223)
]
let dict: [Int: Item] = array.reduce(into: [:], { result, value in
    result[value.id] = value
})
print(dict)
```

```
[1: Item(id: 1, name: "砂糖", price: 512), 2: Item(id: 2, name: "唐辛子", price: 223), 0: Item(id: 0, name: "梅干し", price: 230)]
```

KeyはItem.id以外にもnameでも使えそうです。実はこれを使った高速化テクニックがあります。
詳細については「」を見てください。

### 構造体配列からメンバー

これは人によると思いますが、次のItem構造体の配列があるとします。

```swift
struct Item {
    let id: Int
    let name: String
    let price: Int
    let regularPrice: Int

    var isSale: Bool { price < regularPrice }
}
let array: [Item] = [
  .init(id: 0, name: "梅干し", price: 230, regularPrice: 300),
  .init(id: 1, name: "砂糖", price: 512, regularPrice: 700),
  .init(id: 2, name: "唐辛子", price: 223, regularPrice: 223)
]
```

で、「Item配列から値引き合計額を求める」処理を適当にやると次みたいなコードになります。

```swift
let price = array.reduce(0, { total, item in
    total + item.isSale ? (item.regularPrice - item.price) : 0
})
print(totalPrice)
```

これを段階を経てデータ加工していくと後の処理がシンプルになって、一つの処理の塊を順序よく読みやすくなります。

```swift
let price = array.filter { $0.isSale }
                 .map { $0.regularPrice - $0.price }
                 .reduce(0, +)
print(totalPrice)
```

### 指定範囲の数字を繰り返す

```swift
(10..<15).forEach({ val in
    print(val)
})
```

```
10
11
12
13
14
```

### 指定数だけ繰り返す

```swift
extension Int {
    var times: CountableRange<Int> {
        return (0..<self)
    }
}

10.times.forEach {
  print($0)   
}

let strings = 10.times.map { String($0) }
print(strings)
```

### 安全な添字アクセス
array[safe: index]

```swift
extension Collection {
  subscript (safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

let array: [Int] = [1,2,3]
print(array[safe: 0])
print(array[safe: 3])
```

```
Optional(1)
nil
```

### 要素数を気にせず範囲取得


```swift
let array: [Int] = [1, 2, 3]
print([array.prefix(5)]) // [1, 2, 3]
```

```swift
[array.prefix[3]] // [ArraySlice([1, 2, 3])]
```


### 順序保証Dictionary
KeyValuePairs

RubyのHashは順番が保証されています。
例えばAZ順で名前を返すAPIがあって、アプリでもそのままAZ順に表示したい場合
Dictionary.mapは順序保証されないため想定した並びになりません。
（数が少ないと順番通りになりますが、それは偶然です)
```json
{
  "A": ["Ariel", "Albelt"],
  "B": ["Bob", "Bash"],
  "C": ["Chris", "Carse"]
}
```

## ArrayとDictionary

配列を辞書化してメモリ倍を対価に検索速度を向上

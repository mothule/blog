---
title: iOS開発で便利なSwiftのArrayとDictionaryのイディオム
categories: ios swift
tags: ios swift
image:
  path: /assets/images/2020-05-01-ios-swift-collection-idiom/0.png
---
Swiftではデータ構造の代表格としてArrayとDictionaryがあります。
この2つを使いこなすことは、iOSエンジニアとして重要なことです。

Swift特有の使い方、つまりイディオムを理解することでSwiftyなコーディングができるようにもなります。

この記事で紹介するものが全てを網羅していませんが、  
iOSエンジニアなら知っておくべきSwiftのArrayとDictionaryに関するイディオムについて説明します。

## isEmptyの反対を追加する

ArrayやDictionary、StringにはあるisEmptyプロパティは状態の否定形なので使い勝手が悪いです。

```swift
let params = ["1", "2", ""]
params.filter { !$0.isEmpty }.isEmpty == false
```

### isAnyを用意する
isEmptyの反対としてisAnyを用意します。
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
let params = ["1", "2", ""]
params.filter { $0.isAny }.isAny
```

## ArrayからDictionaryに変換する
`reduce`で配列要素をDictionaryのKeyとValueに変換します。  
変換には、**配列の要素をKeyとValueへの分解が必須条件です。**

下記はある`[商品]`を`[商品ID: 商品]`の型に変換するコードです。

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

コンソール結果
```
[1: Item(id: 1, name: "砂糖", price: 512), 2: Item(id: 2, name: "唐辛子", price: 223), 0: Item(id: 0, name: "梅干し", price: 230)]
```

{% comment %}
KeyはItem.id以外にもnameでも使えそうです。実はこれを使った高速化テクニックがあります。
詳細については「」を見てください。
{% endcomment %}


## データ加工を段階的に分解する

次のItem構造体とその配列があるとします。

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

このarrayから「Item配列から値引き合計額を求める」処理を`reduce`だけで書くとこうなります。

```swift
let price = array.reduce(0, { total, item in
    total + item.isSale ? (item.regularPrice - item.price) : 0
})
print(totalPrice)
```

これをデータ加工を段階に分けるコードが下記になります。  
一つ一つの処理内容がシンプルになり、一連の処理として見た時に読みやすくなります。

```swift
let price = array.filter { $0.isSale }
                 .map { $0.regularPrice - $0.price }
                 .reduce(0, +)
print(totalPrice)
```

### トレードオフ
しかしトレードオフとしてパフォーマンスが低下します。  
次の表は30万個の配列からそれぞれを実施した結果です。

|パターン|最速|最遅|平均(秒)|
|---|---|---|---|
|reduceのみ|0.095|0.11|0.099|
|組み合わせ|0.124|0.129|0.126|

30万個を多いかどうかは作ってる物依存なので各自判断となります。


## Arrayで単体検索ならfilterよりfirst
**filterは全要素アクセスするが、firstは条件満たしたら中断する**

`filter`は要素の絞り込みが目的です。各要素すべてに対して条件評価するので単体検索には不向きです。  
一方で`first`は最初の条件クリアする要素を見つけた時点で終了するので平均して速いです。



### 実際に動きを見る

下記コードは`filter`を使って`exit`を探す処理です。  
3回目で`exit`を見つけてますが、最後の要素まで繰り返します。

```swift
let array: [String] = ["A", "B", "exit", "C"]
if let exit = array.filter({
  print($0)
  return $0 == "exit"
}).first {
  print("found \(exit)")
}
```

コンソール結果
```
A
B
exit
C
found exit
```

下記コードは`first`を使って`exit`を探す処理です。  
`exit`が見つかった時点で以降の要素にはアクセスしていません。

```swift
let array: [String] = ["A", "B", "exit", "C"]
if let exit = array.first(where: {
  print($0)
  return $0 == "exit"
}) {
  print("found \(exit)")
}
```

コンソール結果
```
A
B
exit
found exit
```

このように単体検索なら`first`の方が効率的です。

## Arrayで存在確認ならfirstよりcontains
firstとcontainsはともに条件ヒットしたら終了します。  
もし要素の有無を調べるだけであれば、containsを使いましょう。  
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


## Rangeで指定範囲の数字を繰り返す

指定範囲でfor文を回したい時に便利です。

```swift
(10..<15).forEach({ val in
    print(val)
})
```

コンソール結果
```
10
11
12
13
14
```

## Rangeで指定数だけ繰り返す

範囲に寄る繰り返しで開始値を0に固定にして、Intのextensionに次のメソッド用意するだけで、RubyのActiveSupportにあるような書き方ができるようになります。

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

## Collectionの安全な添字アクセス

Dictionaryのsubscriptのように無効であればnilを返すようにする拡張メソッドです。
通常であれば例外になるArrayの添字アクセスもこのメソッドを通すことで安全にアクセスできるようになります。

これは割と有名かと思われます。

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

コンソール
```
Optional(1)
nil
```

## Arrayで要素数を気にせず範囲取得

配列の要素数を気にせず範囲取得したい場合に「先頭からN」または「後方からN」のパターンであれば  
`prefix`と`suffix`を使うことで、要素数を上回るとり方をしてもクラッシュせず範囲取得ができます。


```swift
let array: [Int] = [1, 2, 3]
print(Array(array.prefix(5))) // [1, 2, 3]
```

prefixの戻り値は`ArraySlice`型であって`Array`ではありません。  
Arrayのinitにわたすことで`Array`に変換できます。

**ここをシンタックスシュガー表現にすると、違う結果になるので注意です。**

```swift
[array.prefix[3]] // [ArraySlice([1, 2, 3])]
```

## イディオムは寿命と活用範囲が狭く短い
イディオムとは特定の領域でしか活用できないノウハウのことです。  
一般的にアーキテクチャ→デザインパターン→イディオムの並びで表されます。

SwiftにおけるSwiftの特性を活かした使い方、それがSwiftのイディオムです。
別の見方をすえば、Swiftでしか使えない知識です。

他言語ではまた違った書き方になるため知識の再利用がしにくいです。  
しかしながら、実際にSwiftに触れている間でもっとも使われるのがイディオムです。

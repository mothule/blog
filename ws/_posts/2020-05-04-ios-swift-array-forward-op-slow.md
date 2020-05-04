---
title: SwiftのArrayの前方挿入は遅い
categories: ios swift
tags: ios swift
image:
  path: /assets/images/2020-05-04-ios-swift-array-forward-op-slow/0.png
---
Swiftでは非常に使用頻度の高いArrayですが、挙動を把握しておかないと誤った使い方で処理の重いコードを書いてしまいます。

**この記事では、Arrayの内部特性を理解し特性が含むリスクに対して、速度パフォーマンスを測定して何が重い実験した結果をまとめたレポートです。**

## きっかけ

- Arrayを再作成するかappend/removeをするか考えてた
- 考えてみればArrayは本当に配列（メモリは直列）なのか？
- 内部データ構造はListだったりしないか？
- 内部データ構造が配列ならstd::vector同様に前方削除や追加が重いのでは？

## メモリが直列とは？

直列とは物理的なメモリ上に横並びにデータが展開されていることを指します。

### 直列を維持するリスク

例えば添字の0はメモリだと先頭でなければいけません。逆も然りです。
では先頭に新しくデータ追加した場合は、どうするのか？

メモリは一度アロケートすると先頭アドレスとサイズをブロックとして確保します。
追加でメモリが必要な場合は、改めて必要なサイズのメモリを確保しなければいけません。
その後、既存データと新規データ両方をセットする必要があります。

このとき最後尾に追加する場合は最後の領域にセットして完了ですが、
最後尾以外に追加する場合は、新規データのサイズ分ズラす必要があります。
しかもメモリ操作領域が大きければ大きいほど負荷が高くなります。

## Swiftソースコードで直列か確認

Swiftのソースコードは[GitHub](https://github.com/apple/swift)にあります。  
Arrayのビルドインされた実装はその中の[/stdlib/public/runtime/Array.cpp](https://github.com/apple/swift/blob/master/stdlib/public/runtime/Array.cpp)になります。  
Arrayのインターフェイスは、[/stdlib/public/core/Array.swift](https://github.com/apple/swift/blob/55782b2f73cd887ffd8d136d29d5cd3fa612e41a/stdlib/public/core/Array.swift)で実装されています。

### 処理をトレースする

Array.remove(at:)からArray.cppに実装されているコピー操作までの処理をトレースします。

今回swift側検証コードは下記になります。
```swift
let array: [Int] = [1,2,3,4,5]
array.remove(at: 0)
```

この`array.remove(at: 0)`の処理をトレースするとざっくり下記になります。

```
- remove(at:)
  - _makeMutableAndUnique()
    - _createNewBuffer(bufferIsUnique:minimumCapacity:growForAppend)
      - ContiguousArrayBuffer._copyContents(subRange:,initializing:)
        - ...
          - swift_arrayInitWithCopy(OpaqueValue*,OpaqueValue*,size_t,const Metadata*)
  - moveInitialize(from:count:)
    - ...
      - swift_arrayInitWithTakeFrontToBack(OpaqueValue*,OpaqueValue*,size_t,const Metadata*)
```

`remove(at:) -> Element`は[/stdlib/public/core/Array.swift#L1292-L1306](https://github.com/apple/swift/blob/55782b2f73cd887ffd8d136d29d5cd3fa612e41a/stdlib/public/core/Array.swift#L1292-L1306)で実装されています。

```swift
public mutating func remove(at index: Int) -> Element {
  _makeMutableAndUnique() // ①
  let currentCount = _getCount()
  let newCount = currentCount - 1
  let pointer = (_buffer.firstElementAddress + index)
  let result = pointer.move()
  pointer.moveInitialize(from: pointer + 1, count: newCount - index) // ②
  _buffer.count = newCount
  return result
}
```

#### \_makeMutableAndUnique ①

`_makeMutableAndUnique`は[/stdlib/public/core/Array.swift#L345-L352](https://github.com/apple/swift/blob/55782b2f73cd887ffd8d136d29d5cd3fa612e41a/stdlib/public/core/Array.swift#L345-L352)で実装されており、
内部では`_createNewBuffer`が呼ばれています。

この`_createNewBuffer`は[/stdlib/public/core/Array.swift#L1051-L1080](https://github.com/apple/swift/blob/55782b2f73cd887ffd8d136d29d5cd3fa612e41a/stdlib/public/core/Array.swift#L1051-L1080)で実装されており、
内部では新しいキャパシティサイズの`_ContiguousArrayBuffer`をしたのちに`_buffer._copyContents`を呼んでいます。

これは内部でArray.cppの[swift_arrayInitWithCopy](https://github.com/apple/swift/blob/31af116df62d40779b0f43ffc61c2806469a53cc/stdlib/public/runtime/Array.cpp#L137-L142)を呼んでいます。

#### pointer.moveInitialize ②

`pointer.moveInitialize`とは[/stdlib/public/core/UnsafePointer.swift#L786-L812](https://github.com/apple/swift/blob/d7b5de95f3fdfe281dee9dfec66b220e27675ca3/stdlib/public/core/UnsafePointer.swift#L786-L812)で実装されています。

この関数内でArray.cppの[swift_arrayInitWithTakeFrontToBack](/stdlib/public/runtime/Array.cpp#L151-L156)か[swift_arrayInitWithTakeBackToFront](https://github.com/apple/swift/blob/55782b2f73cd887ffd8d136d29d5cd3fa612e41a/stdlib/public/runtime/Array.cpp#L158-L163)が呼ばれていると思われます。

`remove(at:)`で引数indexに0を渡すと、`pointer.moveInitialize`を介してデータサイズ*データ数のメモリ移動が発生します。

## 仮説

メモリが直列であれば、前方削除や前方挿入が後方より重いはずです。

## 検証

下記環境下で検証します。

- iOS環境
- Simulator
- 配列数9900〜99000を10回に分ける
- 検証回数10回
- これらのサイズを8バイトと32バイトでする
- 検証メソッドまたはシナリオ
  - removeFirst()
  - removeLast()
  - insert(:at:0)
  - insert(:at:count-1)
  - append()
  - reserveCapacity()後にinsert(:at:0)

### 検証コード

```swift
struct Item {
    let id: Int
    let name: String
    let price: Int
}

func main() {
    var results: [Perf.Result] = []

    let numberOfCaptures = 10
    var samplingCount = (0..<1000)
  typealias ElemType = Item
    let genElem: (Int) -> ElemType = { no in Item(id: no, name: "A\(no)", price: no * 10) }
//    typealias ElemType = Int
//    let genElem: (Int) -> ElemType = { no in no }

    (0..<10).forEach({ index in
        let maxValue = ((100000 - 1000) / 10) * (index + 1)
        samplingCount = (0..<maxValue)
        print(maxValue)

        results.append(
            Perf(numberOfCaptures: numberOfCaptures).capture(label: "insert(:at:last)") {
                var array: [ElemType] = []
                samplingCount.forEach({ no in
                    let lastIndex = max(0, array.count - 1)
                    array.insert(genElem(no), at: lastIndex)
                })
            }
        )
    })

    (0..<10).forEach({ index in
        let maxValue = ((100000 - 1000) / 10) * (index + 1)
        samplingCount = (0..<maxValue)
        results.append(
            Perf(numberOfCaptures: numberOfCaptures).capture(label: "append()") {
                var array: [ElemType] = []
                samplingCount.forEach({ no in array.append(genElem(no)) })
            }
        )
    })

    (0..<10).forEach({ index in
        let maxValue = ((100000 - 1000) / 10) * (index + 1)
        samplingCount = (0..<maxValue)
        results.append(
            Perf(numberOfCaptures: numberOfCaptures).capture(label: "Use reserveCapacity") {
                var array: [ElemType] = []
                array.reserveCapacity(numberOfCaptures)
                samplingCount.forEach({ no in array.insert(genElem(no), at: 0) })
            }
        )
    })

    (0..<10).forEach({ index in
        let maxValue = ((100000 - 1000) / 10) * (index + 1)
        samplingCount = (0..<maxValue)
        results.append(
            Perf(numberOfCaptures: numberOfCaptures).capture(label: "removeLast()") {
                var array: [ElemType] = samplingCount.map { genElem($0) }
                array.count.times.forEach({ _ in array.removeLast() })
            }
        )
    })

    (0..<10).forEach({ index in
        let maxValue = ((100000 - 1000) / 10) * (index + 1)
        samplingCount = (0..<maxValue)
        results.append(
            Perf(numberOfCaptures: numberOfCaptures).capture(label: "insert(:at:0)") {
                var array: [ElemType] = []
                samplingCount.forEach({ no in array.insert(genElem(no), at:0) })
            }
        )
    })

    (0..<10).forEach({ index in
        let maxValue = ((100000 - 1000) / 10) * (index + 1)
        samplingCount = (0..<maxValue)

        results.append(
            Perf(numberOfCaptures: numberOfCaptures).capture(label: "removeFirst()") {
                var array: [ElemType] = samplingCount.map { genElem($0) }
                array.count.times.forEach({ _ in array.removeLast() })
            }
        )
    })

    print(Perf.toCSV(from: results))
}
```

## 結果

下図は検証コードから得た結果を整理してものです。  
X軸が配列数で、Y軸が処理時間(秒)になります。

要素サイズの32バイトの`insert(:at:)`が群を抜いて負荷がかかっています。

{% page_image 1.png 100% SwiftArrayパフォーマンス全体図 %}

2枚目は上図で下層で束なってる部分のみの図となります。

{% page_image 2.png 100% SwiftArrayパフォーマンス縮図 %}

- **前方挿入は重い**
- **配列の要素サイズが大きいと 前方挿入は非常に重い**
- reserveCapacityはほぼ効果ない
- insert(:at:last)よりappendのほうが少し速い
- removeFirstは重いがそこまで気にしなくていい程度

### おまけ:更に要素サイズを上げる

```swift
struct Item {
    let id: Int
    let name: String
    let price: Int
    let regularPrice: Int
    let brand: Brand
    let publishDate: Date
}
struct Brand {
    let id: Int
    let name: String
    let startDate: Date
}
```

上記のような80バイトで最も重い`insert(:at:0)`で試してみます。
先程郡を抜いていた32バイトより更に重くなっています。

{% page_image 3.png 100% SwiftArrayパフォーマンスサイズ大 %}


## 考察
32バイトはInt2つでString1つしかありません。

80バイト程度で1~2万件のデータを扱う時に前方挿入をする処理が多いとスパイクが起きるレベルです。  
これがECなどで1つの商品情報を扱う場合は更にでかいサイズかと思います。  
そうなると1万件以下でも重くなるでしょう。  
追加するタイミングによっては無視できない重さになると思います。

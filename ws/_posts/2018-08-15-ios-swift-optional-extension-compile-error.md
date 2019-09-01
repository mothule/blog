---
title: Optional<String>をExtension化したのにエラーになって役に立たなかった話
categories: ios swift
tags: ios swift
---

nil結合演算子はコンパイルが重くなる要因だし、見た目としてもよくないから解決したいと考えてた。

そこで Optional を拡張してそのコードを次のようにカプセル化した。
これなら nil結合演算子も使わずにコード量も抑えられる。

```swift
extension Optional where Wrapped == String {
    var orEmpty: String {
        guard let value = self else { return "" }
        return value
    }
}
```

## だけど実際のコードではエラーになる

```swift
let url: URL? = URL(string: "https://hogehogex.jp")
url?.absoluteString.orEmpty // Value of type 'String' has no member 'orEmpty'
```

エラー説明見ると String に orEmpty がないと言われてるので試しに用意してもダメ。
```swift
extension String {
    var orEmpty: String {
        return self
    }
}

let url: URL? = URL(string: "https://hogehogex.jp")
url?.absoluteString.orEmpty // Value of optional type 'String?' not unwrapped; did you mean to use '!' or '?'?
```

こっちみたいに一度格納すると認識する。
```swift
let value: String? = url?.absoluteString
value.orEmpty // OK
```

結局これだとほとんどのケースで無駄にコード量が増えるので役に立たなかった。

## 言語不具合
Swiftコードを見たことないけど、これバグだよな。
バグじゃなくとも不便。
nilの伝搬とメソッドの評価順が逆なんじゃないかと思う。

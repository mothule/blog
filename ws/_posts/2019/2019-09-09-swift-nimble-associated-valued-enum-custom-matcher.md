---
title: Nimbleでenum(Associated Value)の自作matcher作って可読性を上げる
categories: ios nimble
tags: swift test nimble
image:
  path: /assets/images/2019-09-09-swift-nimble-associated-valued-enum-custom-matcher.png
---

テストフレームワークでQuickとマッチャーにNimbleを使って開発する人は多いのではないかと思います。

通常のenumであればテストは別に困ることはないのですが、それがAssociated Valueとなると話が180度変わります。
そのまま対策せずゴリ押しでテストコードを書くと、後で気持ち悪いテストコードを目にすることになるので、
少しでも健全で見やすいテストコードを書く方法について書いています。

## テストターゲットは次のモデル
次のようなAssociated Valueなenumがあったとします。

```swift
enum VariableType {
    case string(String)
    case integer(Int)
    case float(Float)
    case boolean(Bool)
}
```

## 特に何もしないでテストを書いた場合

この状態のままテストをする場合、次のようなコードになると思います。

*VariableTypeSpec.swift*  
```swift
class VariableTypeSpec: QuickSpec {
    override func spec() {
        describe("VariableTypeSpec") {
            it("") {              
                let value = VariableType.string("Hoge")
                if case let VariableType.string(string) = value {
                    expect(string) == "Hoge"
                } else {
                    fail()
                }
            }
        }
    }
}
```

## Equatable protocolを採用する

これを解決するには, Equatable protocol を VariableType に採用することでよりシンプルな書き方が可能になります。

*VariableType.swift*
```swift
extension VariableType: Equatable {
    static func == (lhs: VariableType, rhs: VariableType) -> Bool {
        switch (lhs, rhs) {
        case let (.string(left), .string(right)): return left == right
        case let (.integer(left), .integer(right)): return left == right
        case let (.float(left), .float(right)): return left == right
        case let (.boolean(left), .boolean(right)): return left == right
        default: return false
        }
    }
}
```

*VariableTypeSpec.swift*
```swift
class VariableTypeSpec: QuickSpec {
    override func spec() {
        describe("VariableTypeSpec") {
            it("") {
                expect(VariableType.string("Hoge")) == .string("Hoge")
            }
        }
    }
}
```

## Custom Matcher を用意する

今のままで十分可読性は良いのですが、もし `Equatable` だけでは厳しい場合やエラー時のメッセージの情報を増やしたい場合は
Custom Matcherを用意するといいでしょう。

```swift
func message(expected: VariableType) -> Predicate<VariableType> {
    return Predicate { (expression: Expression<VariableType>) throws -> PredicateResult in
        let message = ExpectationMessage.expectedActualValueTo("message \(expected)")
        if let actual = try expression.evaluate() {
            return PredicateResult(bool: actual == expected, message: message)
        } else {
            return PredicateResult(status: .fail, message: message)
        }
    }
}
```

このようにルールに準拠したメソッドを用意することで次のようにNimbleでMatcherとして使えるようになります。

```swift
expect(VariableType.string("Hoge")).to(message(expected: .string("Hoge")))
```

まぁこれは `equal()` とほぼ同じMatcherになりますね。

## テストコードをプロダクションに含む是非について

私は追加することは構わないと思います。

なぜならSwiftのMockingはマニュアルモッキングを推奨していますが、  
マニュアルモッキング用にprotocolを用意してMockを作ることが、既にテストコードが設計レベルで組み込まれているからです。

本来ならprotocolを挟まずともよい部分にも関わらずprotocol化したり、DIで依存性注入したりと、
「なんのためにその実装を書いているのか？」と考えればテスタビリティを上げるためです。

であれば、今更テストコードがプロダクションに入ることになんの違和感を持ちましょうか。

違和感を感じる暇があれば、テストコードの暴発と本番時のみ動くコードを減らす労力に回したほうがマシです。

これは仕方がないことです。Swiftという言語仕様がテスタビリティを下げているので従うしかなく、  
私達が求めるテスタビリティまで向上させるには必要せざる得ない対応策だと思います。

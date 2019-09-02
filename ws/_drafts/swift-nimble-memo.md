# Nimbleでenum(Associated Value)の自作matcher作って可読性を上げる

```swift
    // Custom matcher
    func message(expected: CouponTimelimitMessage.Message) -> Predicate<CouponTimelimitMessage.Message> {
        return Predicate { (expression: Expression<CouponTimelimitMessage.Message>) throws -> PredicateResult in
            let message = ExpectationMessage.expectedActualValueTo("message \(expected)")
            if let actual = try expression.evaluate() {
                return PredicateResult(
                    bool: actual == expected,
                    message: message
                )
            } else {
                return PredicateResult(status: .fail, message: message)
            }

        }
    }
}

// for Custom matcher
extension CouponTimelimitMessage.Message: Equatable {
    public static func == (left: CouponTimelimitMessage.Message, right: CouponTimelimitMessage.Message) -> Bool {
        switch (left, right) {
        case let (.until(lhs), .until(rhs)): return lhs == rhs
        case (.untilToday, .untilToday): return true
        case let (.lastSomeDay(lhs), .lastSomeDay(rhs)): return lhs == rhs
        case (.onlyToday, .onlyToday): return true
        case (.unknown, .unknown): return true
        default: return false
        }
    }
}
```

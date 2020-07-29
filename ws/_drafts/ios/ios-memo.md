# ios memo


## iOSネタ

- Universal Links
- Remote Notification Push
- Error設計
- Errorハンドリング設計
- メッセージフロー設計
- plistにアクセス
- 入力フィールドの多い画面
- UIFont, UIColor, Font size
- IBDesignable/IBInspectable
- UICollectionViewFlowLayout
- 正規表現
- UserDefaults
- XCTest
- print debugPrint CustomDebugStringConvertible CustomStringConvertible


## image media
- Kingfisher
- AlamofireImage
- SDWebImage
- Nuke
- PINRemoteImage


## array x array contains
```swift
let fruitsArray = ["apple", "mango", "blueberry", "orange"]
let vegArray = ["tomato", "potato", "mango", "blueberry"]
let output = fruitsArray.filter(vegArray.contains)
```

## dynamicMemberLookup

プロパティをダックタイピングできるようにする。

```swift
@dynamicMemberLookup struct Profile {
    let firstName: String
    let lastName: String
    var fullName: String { firstName + " " + lastName }

    subscript(dynamicMember key: String) -> Any {
        switch key {
        case "first": return firstName
        case "last": return lastName
        case "full": return fullName
        default: return ""
        }
    }
}

let profile = Profile(firstName: "Taro", lastName: "Yamada")
print(profile.first)
print(profile.last)
print(profile.full)
```

## Key path member lookup
dynamic member lookupをKeyPathで活用しより協力にしたもの
```swift
@dynamicMemberLookup struct Lens<T> {
    var value: T
    subscript<U>(dynamicMember keyPath: WritableKeyPath<T, U>) -> U {
        value[keyPath: keyPath]
    }
}

struct Point { var x, y: Double }
struct Rectangle { var topLeft, bottomRight: Point }

let lensRectangle = Lens(value: Rectangle(topLeft: .init(x: 10, y: 10), bottomRight: .init(x: 20, y: 20)))
print(lensRectangle.bottomRight)
print(lensRectangle.topLeft)
```

## propertyWrapper
「プロパティに関するの制御をテンプレ化できる仕組み」

```swift
@propertyWrapper
struct Score {
    private var value: Int
    private var limit: CountableClosedRange<Int>
    init(limit: CountableClosedRange<Int> = 0...100) {
        self.value = 0
        self.limit = limit
    }

    var wrappedValue: Int {
        get { value }
        set { value = min(limit.upperBound, max(0, limit.lowerBound)) }
    }
}
struct TestResult {
    @Score
    var japanese: Int

    @Score(limit: 0...150)
    var math: Int
}
```

## XCTest

### Quick

```swift
class CustomQuickConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {        
        // テスト全体に事前処理させたい場合はここに記述してください
        configuration.beforeEach {_ in
            MemoryCache.shared.clearAll()
        }
    }
}
```

### Nimble
- 例外(exception)の想定

### wait
waitForExpectationsで同期処理


## exception
↓ expect()をit で挟んでない
```
2020-07-12 21:02:34.119100+0900 nice-rearing[91513:2795555] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'An exception occurred when building Quick's example groups.
Some possible reasons this might happen include:

- An 'expect(...).to' expectation was evaluated outside of an 'it', 'context', or 'describe' block
- 'sharedExamples' was called twice with the same name
- 'itBehavesLike' was called with a name that is not registered as a shared example

Here's the original exception: 'NSInternalInconsistencyException', reason: 'API violation - call made to wait without any expectations having been set.', userInfo: '(null)''
```


## UserDefaults

```swift
protocol UserDefaultsProtocol {
    func object(forKey defaultName: String) -> Any?
    func bool(forKey key: String) -> Bool
    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Bool, forKey key: String)
    func remove(forKey key: String)
    func synchronize() -> Bool
}

extension UserDefaultsProtocol {
    func object(forKey defaultName: String) -> Any? {
        return UserDefaults.standard.object(forKey: defaultName)
    }
    func bool(forKey key: String) -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }
    func set(_ value: Any?, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)

    }
    func set(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func synchronize() -> Bool {
        return UserDefaults.standard.synchronize()
    }

    func isExist(forKey key: String) -> Bool { object(forKey: key) != nil }
}

class UserDefaultsProtocolImpl: UserDefaultsProtocol {}
```

## Validation

```swift
protocol ValidationResult {
    var isOk: Bool { get }
}
extension ValidationResult {
    var isNg: Bool { return !isOk }
}

extension Array where Element == ValidationResult {
    var isValidAll: Bool {
        if contains(where: { $0.isNg }) { return false }
        return true
    }
    var isInvalidAny: Bool {
        return !isValidAll
    }
}

struct EmailAddress {
    let address: String

    func isValid() -> Bool {
        return validate().isOk
    }

    func validate() -> EmailAddressValidateResult {
        // 厳密にやってもAPI側と完全同期しないといけなくて、面倒なので最低限のみにする。
        if address.isEmpty {
            return .required("メールアドレスが入力されていません")
        }

        if let last = address.last {
            if last == " " {
                return .invalidFormat("末尾に空白が含まれてます")
            }
        }

        return .none
    }
}

enum EmailAddressValidateResult: ValidationResult {
    case none
    case required(String)
    case invalidFormat(String)

    var isOk: Bool { if case .none = self { return true } else { return false } }
    var errorMessage: String? {
        switch self {
        case .none: return nil
        case let .required(msg): return msg
        case let .invalidFormat(msg): return msg
        }
    }
}

struct EmailAuthPassword {
    static let PasswordLengthMin = 8
    static let PasswordLengthMax = 20

    let password: String

    func isValid() -> Bool {
        return validate().isOk
    }

    func validate() -> EmailAuthPasswordValidateResult {
        if password.isEmpty {
            return .required("パスワードが入力されていません")
        }
        if password.count < EmailAuthPassword.PasswordLengthMin {
            let value = EmailAuthPassword.PasswordLengthMin
            return .minLength(value, "\(value)文字以上にしてください")
        }
        if password.count > EmailAuthPassword.PasswordLengthMax {
            let value = EmailAuthPassword.PasswordLengthMax
            return .maxLength(value, "\(value)文字以内にしてください")
        }
        return .none
    }


    init(password: String) {
        self.password = password
    }

    init(password: String?) {
        if let password = password {
            self.password = password
        } else {
            self.password = ""
        }
    }
}

enum EmailAuthPasswordValidateResult: ValidationResult {
    case none
    case required(String)
    case minLength(Int, String)
    case maxLength(Int, String)

    var isOk: Bool { if case .none = self { return true } else { return false } }
    var errorMessage: String? {
        switch self {
        case .none: return nil
        case let .required(msg): return msg
        case let .minLength(_, msg): return msg
        case let .maxLength(_, msg): return msg
        }
    }
}

```

## user defaults
```swift
@objc(State)
class State: NSObject, NSCoding {
    static let userDefaultKey = "ApplicationState"
    // MARK: - Serialize/Deserialize
internal required init?(coder aDecoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
    haveSigned = aDecoder.decodeObject(forKey: "haveSigned") as! Bool
//        isExecutedWhenFirstLaunch = aDecoder.decodeObject(forKey: "isExecutedWhenFirstLaunch") as! Bool
    if let haveBrowseTutorialView = aDecoder.decodeObject(forKey: "haveBrowseTutorialView") {
        haveBrowsedTutorial = haveBrowseTutorialView as! Bool
    } else {
        haveBrowsedTutorial = State.hasValidUserId
    }
    super.init()
}


internal func encode(with aCoder: NSCoder) {
    aCoder.encode(NSNumber(value: haveSigned), forKey: "haveSigned")
//        aCoder.encode(NSNumber(value: isExecutedWhenFirstLaunch), forKey: "isExecutedWhenFirstLaunch")
    aCoder.encode(NSNumber(value: haveBrowsedTutorial), forKey: "haveBrowseTutorialView")
}

}
```

## application environment
```swift
var isDebug: Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
}

var isUnitTesting: Bool {
    return AppEnvironment.shared.isUnitTesting
}

/// iOS13.0ならtrue
/// TODO: 13.0のシェアが低くなったらこの処理と関連処理を消す
func isOS130() -> Bool {
    if #available(iOS 13.1, *) {
        return false
    } else if #available(iOS 13.0, *) {
        return true
    } else {
        return false
    }
}

/// iOS12以前ならtrue
/// TODO: 最低サポートがiOS13になったらこの処理と関連処理を消す
func isiOS12orEarlier() -> Bool {
     if #available(iOS 13.0, *) {
        return false
     } else {
        return true
    }
}

class AppEnvironment {
    static var shared: AppEnvironment = AppEnvironment()

    /// 環境変数一覧
    private var environments: [String: String]
    private var stateValue: String? { return environments[ AppEnvArgument.State.key ] }
    private var accessTokenValue: String? { return environments[ AppEnvArgument.AccessToken.key ] }
    private var apiEnvValue: String? { return environments[ AppEnvArgument.ApiEnv.key ] }
    private var state: AppEnvArgument.State? { return AppEnvArgument.State(value: stateValue) }

    var isUnitTesting: Bool {
        guard isDebug else { return false }
        return environments["XCTestConfigurationFilePath"] != nil
    }
    var isUITesting: Bool {
        guard isDebug else { return false }
        return environments[AppEnvArgument.LaunchMode.key] != nil
    }
    var useProductionFacebookApp: Bool {
        guard let value = environments["UseProductionFacebookApp"] else { return false }
        return value.caseInsensitiveCompare("true") == .orderedSame
    }

    var apiEnv: AppEnvArgument.ApiEnv {
        guard let env = AppEnvArgument.ApiEnv(value: apiEnvValue) else { return .stg }
        return env
    }

    var appEnv: CrashCustomKey.Env {
        if isUITesting { return .ci }
        if isDebug { return .dev }
        return .prod
    }

    init(environments: [String: String]? = nil) {
        self.environments = ProcessInfo.processInfo.environment
        if let env = environments {
            self.environments = env
        }

        // 以下のコメントはfastlaneのsmarby_envアクションから操作する
        //<fastlne injection code> self.environments[AppEnvArgument.ApiEnv.key] = AppEnvArgument.ApiEnv.<env>.rawValue
    }

    func setup() {
        guard let state = state else { return }

        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)

        State.shared.reset()
        switch state {
        case .doNothing:
            break

        case .finishTutorial:
            State.shared.browseTutorial()

        case .finishSignIn:
            if let accessToken = accessTokenValue {
                State.shared.browseTutorial()
                State.shared.signInUser()
                User.shared.accessToken = accessToken
            }
        }
    }
}



protocol AppEnvArgumentKeyable {
    static var key: String { get }
}

public struct AppEnvArgument {
    struct LaunchMode: AppEnvArgumentKeyable {
        static var key: String = "AppLaunchMode"
    }
    enum State: String, AppEnvArgumentKeyable {
        static var key: String = "XCState"

        case doNothing
        case finishTutorial
        case finishSignIn

        init?(value: String?) {
            guard let value = value else { return nil }
            self.init(rawValue: value)
        }
    }
    enum ApiEnv: String, AppEnvArgumentKeyable {
        static var key: String = "ApiEnv"

        case stg
        case intg

        init?(value: String?) {
            guard let value = value else { return nil }
            self.init(rawValue: value)
        }

        var isStaging: Bool { if case .stg = self { return true } else { return false } }
    }
    struct AccessToken: AppEnvArgumentKeyable {
        static var key: String = "XCAccessToken"
        let token: String
    }

    var accessToken: AccessToken
    var launchMode: LaunchMode
    var state: State
    var apiEnv: ApiEnv

    static func makeForUiTest(state: State, accessToken: String = "", apiEnv: ApiEnv = .stg) -> AppEnvArgument {
        return AppEnvArgument(accessToken: AccessToken(token: accessToken),
                                     launchMode: LaunchMode(),
                                     state: state,
                                     apiEnv: apiEnv)
    }

    func toDictionary() -> [String: String] {
        return [
            LaunchMode.key: "uiTests",
            AccessToken.key: accessToken.token,
            State.key: state.rawValue,
            ApiEnv.key: apiEnv.rawValue
        ]
    }
}
```

## NSError makeable
```swift
/// NSError作成可能protocol
protocol ErrorMakeable {
    /// Crashlytics は domain と code で識別している.
    var domain: String { get }

    /// Crashlytics は domain と code で識別している.
    var code: Int { get }

    /// errorDescription で最初に目にするエラー情報として表示される.
    var errorDescription: String { get }

    /// extraUserInfo でエラー詳細表示ページのKeysに表示される.
    var extraUserInfo: [String: Any]? { get }
}

extension ErrorMakeable {
    func make() -> Error {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorDescription]
        if let extraUserInfo = extraUserInfo {
            userInfo += extraUserInfo
        }
        let prefix = AppEnvironment.shared.appEnv.isProduction ? "" : "debug."
        return NSError(domain: prefix + domain, code: code, userInfo: userInfo)
    }
}
```

## Assertion with disabled when UT
```swift
func assertionFailure(_ string: String) {
    guard !AppEnvironment.shared.isUnitTesting else { return }
    Swift.assertionFailure(string)
}
func assertionFailure() {
    guard !AppEnvironment.shared.isUnitTesting else { return }
    Swift.assertionFailure()
}
func assertion(_ condition: Bool) {
    guard !AppEnvironment.shared.isUnitTesting else { return }
    Swift.assert(condition)
}
func assertion(_ condition: Bool, string: String) {
    guard !AppEnvironment.shared.isUnitTesting else { return }
    Swift.assert(condition, string)
}
```

## NavigationBar Appearance

```swift
// Make the navigation bar's title with red text.
let appearance = UINavigationBarAppearance()
appearance.configureWithOpaqueBackground()
appearance.backgroundColor = UIColor.systemRed
appearance.titleTextAttributes = [.foregroundColor: UIColor.lightText] // With a red background, make the title more readable.
navigationItem.standardAppearance = appearance
navigationItem.scrollEdgeAppearance = appearance
navigationItem.compactAppearance = appearance // For iPhone small navigation bar in landscape.

// Make all buttons with green text.
let buttonAppearance = UIBarButtonItemAppearance()
buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
navigationItem.compactAppearance?.buttonAppearance = buttonAppearance // For iPhone small navigation bar in landscape.

// Make the done style button with yellow text.
let doneButtonAppearance = UIBarButtonItemAppearance()
doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemYellow]
navigationItem.standardAppearance?.doneButtonAppearance = doneButtonAppearance
navigationItem.compactAppearance?.doneButtonAppearance = doneButtonAppearance // For iPhone small navigation bar in landscape.
```

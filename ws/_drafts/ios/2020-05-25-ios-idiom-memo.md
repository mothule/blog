---
title: TODO
categories: TODO
tags: TODO
---

### UIAppearance

```swift
UISegmentedControl.appearance().tintColor = UIColor.red
UIProgressView.appearance().tintColor = UIColor.red
UISlider.appearance().tintColor = UIColor.red
UISwitch.appearance().tintColor = UIColor.red
UISegmentedControl.appearance().tintColor = UIColor.red
UINavigationBar.appearance().tintColor = UIColor.red
UINavigationBar.appearance().barTintColor = UIColor.red

UITabBar.appearance().barTintColor = UIColor.red
UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -9999, vertical: 0), for: .default)
UINavigationBar.appearance().backIndicatorImage = UIImage
UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage
let attr = [NSAttributedString.Key.foregroundColor: UIColor.red
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12.0) ]
UINavigationBar.appearance().titleTextAttributes = attr


let barButtonItemTitleAttr = [NSAttributedString.Key.foregroundColor: UIColor.red]
UIBarButtonItem.appearance().setTitleTextAttributes(barButtonItemTitleAttr, for: .normal)
```


### SDWebImage
```swift
guard let cache = SDWebImageManager.shared().imageCache else { return }
let config = cache.config
config.maxCacheAge = 60 // 1 min
config.maxCacheSize = 100 * 1024 * 1024 // 100 MB
cache.maxMemoryCost = (600 * 500) * 300 // 商品画像300枚程度
```

```swift
extension UIImageView {
    /**
     # SDWebImage のラッパーメソッド

     ## 次の条件を一つでも満たす場合は .image には nil が入る.
     - URL文字列が無効
     - URLが無効
     - エラー発生

     - parameter url: URL文字列
     */
    func sd_setImageWithFadeIn(url: String?) {
        guard let urlString = url else {
            image = nil
            return
        }
        guard let url = URL(string: urlString) else {
            image = nil
            return
        }


        let options: SDWebImageOptions = [.retryFailed, .lowPriority]
        sd_setImage(with: url, placeholderImage: nil, options: options) { [weak self] (_, error, cacheType, _) in
            guard let myself = self else { return }

            if error != nil {
                myself.image = nil
            }

            if cacheType != .memory {
                let options: UIView.AnimationOptions = [
                    .transitionCrossDissolve,
                    .curveLinear,
                    .allowUserInteraction
                ]
                UIView.transition(with: myself, duration: 0.28, options: options, animations: nil, completion: nil)
            }
        }
    }
}
```

### Assertion
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

### Crashlytics Non fatal error
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


### App version
```swift
struct AppVersion {
    let shortVersion: String

    init() {
        shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
```

### App environment variables
```swift
let environments: [String: String] = ProcessInfo.processInfo.environment
```

### Force version update
```swift
struct ForceUpdate {
    let remoteVersion: Int

    var localVersion: Int? {
        guard let bundleInfoDictionary = bundleInfoDictionary,
            let versionString = bundleInfoDictionary["CFBundleVersion"] as? String,
            let version = Int(versionString) else {
                assertionFailure("ローカルのビルド番号が取得できません")
                return nil
        }
        return version
    }

    private var bundleInfoDictionary: [String: Any]?

    init(remoteVersion: Int, bundleInfoDictionary: [String: Any]? = Bundle.main.infoDictionary) {
        self.remoteVersion = remoteVersion
        self.bundleInfoDictionary = bundleInfoDictionary
    }

    var needsUpdate: Bool {
        guard let localVersion = self.localVersion else { return false }
        return localVersion < remoteVersion
    }
}
```

### Codable Preferneces
```swift
@objc(Hoge)
class Hoge: NSObject, NSCoding {

  required init?(coder aDecoder: NSCoder) {
    haveSigned = aDecoder.decodeObject(forKey: "haveSigned") as! Bool
    if let haveBrowseTutorialView = aDecoder.decodeObject(forKey: "haveBrowseTutorialView") {
        haveBrowsedTutorial = haveBrowseTutorialView as! Bool
    } else {
        haveBrowsedTutorial = State.hasValidUserId
    }
    super.init()
  }

  internal func encode(with aCoder: NSCoder) {
      aCoder.encode(NSNumber(value: haveSigned), forKey: "haveSigned")
      aCoder.encode(NSNumber(value: haveBrowsedTutorial), forKey: "haveBrowseTutorialView")
  }

  func save() {
    let data: Data = NSKeyedArchiver.archivedData(withRootObject: self)
    userDefaults.set(data, forKey: userDefaultKey)
    _ = userDefaults.synchronize()
  }
}
```

### Validation
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
```

### User Preferences

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


### EzTask
```swift
class EzTask<Response, E> {
    typealias MyType = EzTask<Response, E>
    typealias Process = ((fulfill: SuccessClosure, reject: FailureClosure)) -> Void
    typealias SuccessClosure = (Response) -> Void
    typealias FailureClosure = (E) -> Void
    typealias FinishClosure = (Response?, E?) -> Void

    enum TaskState {
        case running
        case paused
        case success(Response)
        case failure(E)
        case finished

        var canHandle: Bool {
            if case .success = self { return true }
            if case .failure = self { return true }
            return false
        }

        var isFinished: Bool { if case .finished = self { return true }; return false }
        var isPaused: Bool { if case .paused = self { return true }; return false }
    }

    private(set) var process: Process
    private(set) var success: SuccessClosure?
    private(set) var failure: FailureClosure?
    private(set) var finish: FinishClosure?
    private(set) var state: TaskState
    private(set) var afterTask: MyType?

    var canSuccessClosureExecutable: Bool { return success != nil || finish != nil }
    var canFailureClosureExecutable: Bool { return failure != nil || finish != nil }

    init(_ process: @escaping Process) {
        self.process = process
        state = .running
        doProcess()
    }
    init(paused: Bool, process: @escaping Process) {
        self.process = process
        state = paused ? .paused : .running
        doProcess()
    }
    init(fulfill response: Response) {
        self.process = { (arg) in let (fulfill, _) = arg; fulfill(response) }
        state = .running
        doProcess()
    }
    init(reject error: E) {
        self.process = { (arg) in let (_, reject) = arg; reject(error) }
        state = .running
        doProcess()
    }

    func resume() {
        state = .running
        doProcess()
    }

    @discardableResult func onSuccess(_ closure: @escaping SuccessClosure) -> MyType {
        self.success = closure
        handleByState()
        return self
    }

    @discardableResult func onFailure(_ closure: @escaping FailureClosure) -> MyType {
        self.failure = closure
        handleByState()
        return self
    }

    @discardableResult func onFinish(_ closure: @escaping FinishClosure) -> MyType {
        self.finish = closure
        handleByState()
        return self
    }

    @discardableResult func onThen(_ closure: @escaping Process) -> MyType {
        afterTask = MyType(paused: true, process: closure)
        return afterTask!
    }

    private func doProcess() {
        guard state.isPaused == false else { return }

        let fulfillHandler: SuccessClosure = { res in
            self.state = .success(res)
            self.handleByState()
        }
        let rejectHandler: FailureClosure = { err in
            self.state = .failure(err)
            self.handleByState()
        }
        self.process((fulfillHandler, rejectHandler))
    }

    private func handleByState() {
        guard state.canHandle else { return }

        switch state {
        case .success(let res):
            if canSuccessClosureExecutable {
                success?(res)
                finish?(res, nil)
                state = .finished

                afterTask?.resume()
            }

        case .failure(let err):
            if canFailureClosureExecutable {
                failure?(err)
                finish?(nil, err)
                state = .finished
            }

        default:
            assertionFailure("Call fulfill or reject in init process closure.")
        }
    }
}
```

### Extensions
```swift
extension Date {
    func toString(_ dateFormat: String = "yyyy年M月d日") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}

extension Int {
    var second: TimeInterval {
        return TimeInterval(self)
    }
    var minute: TimeInterval {
        return TimeInterval(self * 60)
    }
    var hour: TimeInterval {
        return TimeInterval(self * 60 * 60)
    }
}

// see https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Array {
    func lastIndexIs(_ index: Index) -> Bool {
        guard !isEmpty else { return false }
        return count - 1 == index
    }

    var isAny: Bool {
        return !isEmpty
    }
}


extension String: URLConvertible {

    enum FormatType: String {
        case fullAndUTC = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZ" // このフォーマットはdeprecated
        case yyyyMMdd = "yyyy'-'MM'-'dd'"
        case yyyyMMddHHmm = "yyyy'-'MM'-'dd'T'HH':'mm"
        case yyyyMMddHHmmssZZZZZ = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
    }

    func toDate(fromFormatType type: FormatType) -> Date? {
        return toDate(fromFormat: type.rawValue)
    }

    func toDate(fromFormat dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }

    func isContainMultiByteStrings() -> Bool {
        return !self.canBeConverted(to: .ascii)
    }

    func toURL() -> URL? {
        return URL(string: self)
    }

    var isAny: Bool {
        return isEmpty == false
    }
}

extension CustomDebugStringConvertible {
    public var debugDescription: String {
        let mirror = Mirror(reflecting: self)
        var result = String(describing: mirror.subjectType) + "{"
        for case let(label?, value) in mirror.children {
            result += " ,\(label):\(value)"
        }
        return result.replacingOccurrences(of: "{ ,", with: "{") + "}"
    }
}

extension CGRect {

    // swiftlint:disable identifier_name
    /**
     # 矩形の中心を重心として拡縮した結果を返す

     - parameter scaleX: X軸拡縮値(0.0~)
     - parameter scaleY: Y軸拡縮値(0.0~)
     - returns: スケーリングされた矩形
    */
    func scaling(scaleX: CGFloat, scaleY: CGFloat) -> CGRect {
        let center = CGPoint(x: origin.x + width.half, y: origin.y + height.half)
        let sx = center.x - (center.x - origin.x) * scaleX
        let sy = center.y - (center.y - origin.y) * scaleY
        let gx = center.x + (center.x - origin.x) * scaleX
        let gy = center.y + (center.y - origin.y) * scaleY
        return CGRect(x: sx, y: sy, width: gx - sx, height: gy - sy)
    }
    // swiftlint:enable identifier_name

    func scaling(scale: CGFloat) -> CGRect {
        return scaling(scaleX: scale, scaleY: scale)
    }
}
```

```swift
extension UIDevice {

    var platform: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let mirror = Mirror(reflecting: systemInfo.machine)
        var identifier = ""

        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier += String(UnicodeScalar(UInt8(value)))
            }
        }
        return identifier
    }

    var modelName: String {
        return platform
    }
}
```

```swift
typealias AlertActionHandle = (UIAlertAction) -> Void


extension UIAlertController {
    // MARK: - Common
    static func make(title: String?, message: String?, style: UIAlertController.Style, buttons: [UIAlertAction]) -> UIAlertController {
        let ret = UIAlertController(title: title, message: message, preferredStyle: style)
        buttons.forEach({ ret.addAction($0) })
        return ret
    }

    // MARK: - Alert
    static func alert(title: String?, message: String?, buttons: [UIAlertAction]) -> UIAlertController {
        return make(title: title, message: message, style: .alert, buttons: buttons)
    }

    static func alert(title: String, message: String, buttonTitle: String, buttonHandler: AlertActionHandle?) -> UIAlertController {
        let button = UIAlertAction.default(title: buttonTitle, handler: buttonHandler)
        let ret = alert(title: title, message: message, buttons: [button])
        return ret
    }
    static func alert(title: String, message: String, justCloseButtonTitle buttonTitle: String) -> UIAlertController {
        return alert(title: title, message: message, buttonTitle: buttonTitle, buttonHandler: nil)
    }

    // MARK: - ActionSheet
    static func actionSheet(title: String, buttons: [UIAlertAction]) -> UIAlertController {
        return actionSheet(title: title, message: nil, buttons: buttons)
    }
    static func actionSheet(title: String?, message: String?, buttons: [UIAlertAction]) -> UIAlertController {
        return make(title: title, message: message, style: .actionSheet, buttons: buttons)
    }
}

extension UIAlertAction {

    static func button(title: String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: nil)
    }
    static func `default`(title: String, handler: AlertActionHandle?) -> UIAlertAction {
        return UIAlertAction(title: title, style: UIAlertAction.Style.default, handler: handler)
    }
    static func cancel(title: String = "キャンセル", handler: AlertActionHandle? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: UIAlertAction.Style.cancel, handler: handler)
    }
    static func destructive(title: String, handler: AlertActionHandle?) -> UIAlertAction {
        return UIAlertAction(title: title, style: UIAlertAction.Style.destructive, handler: handler)
    }
}
```

```swift
extension UIView {

    var isShow: Bool {
        set {
            isHidden = !newValue
        }
        get {
            return !isHidden
        }
    }
}
```

```swift
// MARK: - NSObjectProtocol
extension NSObjectProtocol {
    static var className: String {
        return String(describing: self)
    }
    static var identifier: String {
        return className
    }
}

// MARK: - Storyboardable
protocol Storyboardable: NSObjectProtocol {
    static var storyboardName: String { get }
}

extension Storyboardable where Self: UIViewController {
    static var storyboardName: String {
        return className
    }

    static func instance() -> Self {
        let vc: Self = UIStoryboard.instantiate()
        return vc
    }
}

extension Storyboardable where Self: UITableViewController {
    static var storyboardName: String {
        return className
    }

    static func instance() -> Self {
        let vc: Self = UIStoryboard.instantiate()
        return vc
    }
}

extension UIStoryboard {
    static func instantiate<T: Storyboardable>() -> T {
        let storyBoardName: String = T.storyboardName
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)

        if let viewController = storyBoard.instantiateInitialViewController() as? T {
            return viewController
        }

        let identifier: String = T.className
        return storyBoard.instantiateViewController(withIdentifier: identifier) as! T
    }
}


// MARK: - UINib
protocol Nibable: NSObjectProtocol {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension Nibable {
    static var nibName: String {
        return className
    }
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }

    func register<T: UICollectionReusableView>(_ viewType: T.Type) where T: Nibable {
        register(T.nib, forCellWithReuseIdentifier: T.identifier)
    }

    func register<T: UICollectionReusableView>(_ viewType: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.identifier)
    }

    func registerSupplementaryView<T: UICollectionReusableView>(_ viewType: T.Type, kindOf kind: String ) where T: Nibable {
        register(T.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.identifier)
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath ) -> T {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }

    func register<T: UITableViewCell>(_ viewType: T.Type) where T: Nibable {
        register(T.nib, forCellReuseIdentifier: T.identifier)
    }
    func register<T: UITableViewCell>(_ viewType: T.Type) {
        register(T.self, forCellReuseIdentifier: T.identifier)
    }
}
extension UITextField {

    public var textOrEmptyString: String {
        guard let text = text else { return "" }
        return text
    }


}
extension UIColor {
    var rgba: (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}

public protocol Notificationable {
    var name: NSNotification.Name { get }
    var nameString: String { get }
    var userInfoWhenPost: [AnyHashable: Any]? { get }
    func post(object: Any?)
    func addObserver(_ observer: Any, selector: Selector, object: Any?)
}
extension Notificationable {
    var name: NSNotification.Name { return NSNotification.Name(rawValue: nameString) }

    func addObserver(_ observer: Any, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: self.name, object: object)
    }

    func post(object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfoWhenPost)
    }
}

extension Error {
    var toDictionary: [AnyHashable: Error] {
        return ["error": self]
    }
}

extension Notificationable {
    var notification: Notification {
        return Notification(name: name, object: nil, userInfo: userInfoWhenPost)
    }
}
```

```swift
typealias AttrKey = NSAttributedString.Key

protocol DecorationTypeProtocol {
    func attribute() -> (AttrKey, Any)
}

enum DecorationType {
    // 行間(単位 ponit)
    case lineHeight(CGFloat)
    // 行間(単位 em)
    case lineHeightPerEM(CGFloat)
    // 字間(単位 point)
    case letterSpacing(CGFloat)
    // 行間(単位 point)
    case lineSpacing(CGFloat)
    // フォント(フォント名, フォントサイズ)
    case fontByName(String, CGFloat)
    // 背景
    case backgroundColor(UIColor)
    // 文字色
    case foregroundColor(UIColor)
    // 下線
    case underline(NSUnderlineStyle)
    // 下線色
    case underlineColor(UIColor)
    // 取り消し線
    case strikethrough
    // 太さ指定取り消し線
    case strikethroughWithWidth(Int)
    // 影
    case shadow(CGSize, CGFloat)
    // Baseline
    case baselineOffset(CGFloat)
}
extension DecorationType: DecorationTypeProtocol {


    func attribute() -> (AttrKey, Any) {
        switch self {
        case .lineHeight(let value):       return LineHeightDecorator(height: value).decorate()
        case .lineHeightPerEM(let value):  return LineHeightDecorator(heightPerEm: value).decorate()
        case let .fontByName(name, size):  return FontDecorator(fontName: name, fontSize: size).decorate()
        case .letterSpacing(let value):    return LetterSpacingDecorator(letterSpacing: value).decorate()
        case .lineSpacing(let value):    return LineSpacingDecorator(lineSpacing: value).decorate()
        case .backgroundColor(let color):  return ColorDecorator(background: color).decorate()
        case .foregroundColor(let color):  return ColorDecorator(foreground: color).decorate()
        case .underline(let style):        return UnderlineDecorator(style: style).decorate()
        case .underlineColor(let color):   return UnderlineColorDecorator(color: color).decorate()
        case .strikethrough:               return StrikethroughDecorator().decorate()
        case .strikethroughWithWidth(let width): return StrikethroughDecorator(width: width).decorate()
        case let .shadow(offset, radius):  return ShadowDecorator(shadowOffset: offset, blurRadius: radius).decorate()
        case .baselineOffset(let offset):  return BaseLineOffsetDecorator(offset: offset).decorate()
        }
    }
}

protocol Decoratable {
    func decorate() -> (AttrKey, Any)
}
struct LineHeightDecorator: Decoratable {

    enum Unit {
        case point
        // swiftlint:disable:next identifier_name
        case em
    }

    private let height: CGFloat
    private let unit: Unit

    init(height: CGFloat) {
        self.height = height
        self.unit = .point
    }
    init(heightPerEm: CGFloat) {
        self.height = heightPerEm
        self.unit = .em
    }
    public func decorate() -> (AttrKey, Any) {
        let style = NSMutableParagraphStyle()
        switch unit {
        case .point:
            style.minimumLineHeight = height
            style.maximumLineHeight = height
        case .em:
            style.lineHeightMultiple = height
        }
        return (NSAttributedString.Key.paragraphStyle, style)
    }
}
struct LineSpacingDecorator: Decoratable {
    private let lineSpacing: CGFloat
    init(lineSpacing: CGFloat) {
        self.lineSpacing = lineSpacing
    }
    public func decorate() -> (AttrKey, Any) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        return (NSAttributedString.Key.paragraphStyle, style)
    }
}
struct LetterSpacingDecorator: Decoratable {
    private let letterSpacing: CGFloat
    init(letterSpacing: CGFloat) {
        self.letterSpacing = letterSpacing
    }
    public func decorate() -> (AttrKey, Any) {
        return (NSAttributedString.Key.kern, letterSpacing)
    }
}
struct FontDecorator: Decoratable {
    let font: UIFont
    init(fontName: String, fontSize: CGFloat) {
        font = UIFont(name: fontName, size: fontSize)!
    }
    public func decorate() -> (AttrKey, Any) {
        return (NSAttributedString.Key.font, font)
    }
}
struct ColorDecorator: Decoratable {
    enum `Type` {
        case background
        case foreground
    }
    let color: UIColor
    let type: Type

    init(background color: UIColor) {
        self.color = color
        self.type = .background
    }
    init(foreground color: UIColor) {
        self.color = color
        self.type = .foreground
    }
    public func decorate() -> (AttrKey, Any) {
        let key: AttrKey
        switch type {
        case .background: key = NSAttributedString.Key.backgroundColor
        case .foreground: key = NSAttributedString.Key.foregroundColor
        }
        return (key, color)
    }
}
struct UnderlineDecorator: Decoratable {
    let style: NSUnderlineStyle
    init(style: NSUnderlineStyle) {
        self.style = style
    }
    public func decorate() -> (AttrKey, Any) {
        return (NSAttributedString.Key.underlineStyle, style.rawValue)
    }
}
struct UnderlineColorDecorator: Decoratable {
    let color: UIColor
    init(color: UIColor) {
        self.color = color
    }
    public func decorate() -> (AttrKey, Any) {
        return (NSAttributedString.Key.underlineColor, color)
    }
}
struct StrikethroughDecorator: Decoratable {
    let width: Int

    init() {
        self.width = 1
    }
    init(width: Int) {
        self.width = width
    }

    public func decorate() -> (AttrKey, Any) {
        return (NSAttributedString.Key.strikethroughStyle, width)
    }
}
struct ShadowDecorator: Decoratable {
    let shadow: NSShadow

    init(shadowOffset: CGSize, blurRadius: CGFloat) {
        shadow = NSShadow()
        shadow.shadowOffset = shadowOffset
        shadow.shadowBlurRadius = blurRadius
    }

    public func decorate() -> (AttrKey, Any) {
        return (NSAttributedString.Key.shadow, shadow)
    }
}
struct BaseLineOffsetDecorator: Decoratable {
    let offset: CGFloat

    init(offset: CGFloat) {
        self.offset = offset
    }
    public func decorate() -> (AttrKey, Any) {
        return (NSAttributedString.Key.baselineOffset, offset)
    }
}

extension Array where Element: DecorationTypeProtocol {
    var attributes: [AttrKey: Any] {
        var dict: [AttrKey: Any] = [:]
        self.forEach {
            let (key, value) = $0.attribute()
            dict[key] = value
        }
        return dict
    }
}

extension String {
    func decorate(by decoTypes: [DecorationType], range: NSRange? = nil) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: self)

        var attrs: [AttrKey: Any] = [:]
        decoTypes.forEach({
            let attr = $0.attribute()
            attrs[attr.0] = attr.1
        })

        let unwarppedRange = range != nil ? range! : NSRange(location: 0, length: self.count)

        attrString.addAttributes(attrs, range: unwarppedRange)

        return attrString
    }

    @available(*, unavailable, renamed: "decorate")
    func decorate(withDecorateTypes decoTypes: [DecorationType], range: NSRange? = nil ) -> NSAttributedString {
        return decorate(by: decoTypes, range: range)
    }
}
extension NSString {
    func decorate(withDecorateTypes decoTypes: [DecorationType], range: NSRange? = nil ) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: self as String)

        var attrs: [AttrKey: Any] = [:]
        decoTypes.forEach({
            let attr = $0.attribute()
            attrs[attr.0] = attr.1
        })

        let unwrappedRange = range != nil ? range! : NSRange(location: 0, length: self.length)

        attrString.addAttributes(attrs, range: unwrappedRange)

        return attrString
    }
}
extension NSAttributedString {

    /// AttributedString + AttributedString
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let ret = NSMutableAttributedString(attributedString: lhs)
        ret.append(rhs)
        return ret
    }
    /// String + AttributedString
    static func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString {
        let ret = NSMutableAttributedString(string: lhs)
        ret.append(rhs)
        return ret
    }
    /// AttributedString + String
    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        let ret = NSMutableAttributedString(attributedString: lhs)
        ret.append(NSAttributedString(string: rhs))
        return ret
    }
}
```

### Refresh interval
```swift
protocol RefreshIntervalProtocol {
    var isElapsed: Bool { get }

    var isElapsedInterval: Bool { get }

    var isElapsed9PM: Bool { get }

    mutating func reset()

    mutating func expire()
}

extension RefreshIntervalProtocol {
    /// 21時経過 or 指定時間以上経過していたら true を返す
    var isElapsed: Bool {
        if isElapsed9PM { return true }
        return isElapsedInterval
    }

    mutating func reset() {}

    mutating func expire() {}
}

struct RefreshInterval: RefreshIntervalProtocol {

    let refreshInterval: TimeInterval
    var startTime: Date

    init(refreshInterval: TimeInterval) {
        self.refreshInterval = refreshInterval
        self.startTime = Date()
    }
    init(interval: TimeInterval, doExpired: Bool = false) {
        self.refreshInterval = interval
        self.startTime = Date()

        if doExpired {
            expire()
        }
    }

    mutating func reset() {
        startTime = Date()
    }
    mutating func expire() {
        startTime = Date(timeIntervalSince1970: 0)
    }

    var isElapsedInterval: Bool {
        return Date().timeIntervalSince(startTime) >= refreshInterval
    }

    var isElapsed9PM: Bool {
        return RefreshInterval.isThrough9PM(from: startTime, to: Date())
    }

    static func isThrough9PM(from startTime: Date, to now: Date) -> Bool {
        guard let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else { return false }
        guard let timeZone = TimeZone(secondsFromGMT: 0) else { return false }
        cal.timeZone = timeZone

        guard let next21Hour = cal.date(bySettingHour: 21 - 9, minute: 0, second: 0, of: startTime, options: []) else { return false }

        return startTime <= next21Hour && next21Hour <= now
    }

}
```


### run slather and coverage notify to slack

```ruby
# slather
result = `bundle exec slather coverage --simple-output | grep \"Test Coverage:\"`

# message to slack
slack_url = "https://hooks.slack.com/services/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"
slack_channel = "#dev-ios"
slack_user_name = "slather"
coverage = 0

# カバレッジ率によってアイコンを変更
if m = /(\d*.\d*)%/.match(result)
    coverage = m[0].to_f
    if coverage > 70
        coverage_icon = ":hugging_face:"
    elsif coverage > 50
        coverage_icon = ":face_with_raised_eyebrow:"
    else
        coverage_icon = ":tired_face:"
    end
end

# slackに表示するテキスト
text = "Your *slather* coverage report\n #{coverage_icon} eeyore: #{coverage}%"

# slackへ通知
p `curl -X POST --data-urlencode "payload={'channel': '#{slack_channel}', 'username': '#{slack_user_name}', 'text': '#{text}'}" #{slack_url}`
```

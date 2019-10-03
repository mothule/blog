---
title: StoryboardやXibのロード処理の作りを改善する
categories: ios
tags: ios uitableview uicollectionview
image:
  path: /assets/images/2019-09-29-ios-xib-optimaize.png
---
至る所で使われるStoryboardとxibは、コードの読み込みによくある使い方をする上で少し助長があります。
そしてそれがロード処理で至る所で使われるため、ボイラープレートが増えることからコード可読性が下がるので
あまりよろしくありません。

なので私が普段使っている煩わしいロード処理を抑え込んだロード処理実装について説明します。


## 自由に法則性を与えることで実装を簡易にする

Storyboardやxibは自由度が高いため、1storyboardに複数のView Controllerを作成できたり、
Identifierに好きな名前をつけることができます。

しかしこれだと法則性が生まれないため、今回は次のようにルールを設けることで法則性を作り出します。

- 1 View Controller に対し 1 Storyboard
- Identifier には制御クラス名が入る
- storyboardファイル/xibファイルは`制御クラス名.拡張子`となっている

## 法則性によりロード処理がシンプルになる

Storyboardには1 View Controller しかないのであれば、ロードはシンプルになります。  
加えてIdentifierを制御クラスにすることでよりシンプルになります。

### Storyboard
Storyboardをロードする処理を通常通り書くと次のような処理になります。
下記コードは`Is Initial View Controller`が`ON` and Identifierが未設定のViewControllerのロードにトライし、それが失敗だったら  
Identifierを指定してViewControllerのロードにトライして、HogeViewControllerのロード処理を行っています。

```swift
let storyboard = UIStoryboard(name: "HogeViewController", bundle: nil)
let vc: HogeViewController
if let viewController = storyboard.instantiateInitialViewController() as? HogeViewController
  vc = viewController
} else {
  vc = storyboard.instantiateViewController(withIdentifier: "HogeViewController") as! HogeViewController
}
present(vc, animated: true, completion: nil)
```

これを今回は次のようにします。詳細は後述します。

```swift
class HogeViewController: UIViewController, Storyboardable { }

let vc = HogeViewController.instance()
present(vc, animated: true, completion: nil)
```

### xib
xibのロードに関しては、例えばTableViewCell.xibファイルをUITableViewに登録する処理は通常通りだと下記コードですが

```swift
let nib = UINib(nibName: "TableViewCell", bundle: nil)
tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
```

今回は次のようになります。詳細は後述します。

```swift
class TableViewCell: UITableViewCell, Nibable {}

tableView.register(TableViewCell.self)
```

UICollectionViewのCell登録に関しても同様になります。

### StoryboardableとNibableとは

これらは登録や参照における処理を前述したルールに基づいてロードや参照処理を持つものです。

順を追って説明します。まずはxibから説明します。

## xibのコードを改善してみる

例えばUITableViewCellのサブクラスとなる`TableViewCell`が定義されてたとして、xibファイルは`TableViewCell.xib`だったとします。
xibファイルは前述したルールに制御クラス名でなければいけません。

UITableViewにそのセルを表示するには

1. テーブルに登録
1. セル参照

の2つが必要になります。

### テーブル登録
テーブルへの登録には、 `UITableView.register` が使われます。

これは `UINib`と対象のセルの`Identifier`を渡すことで登録が行われます。
そして`UINib`はxibファイル名が必要になります。

つまり UITableViewCellのサブクラスを登録するには、

- xibファイル名
- セルのIdentifier

の2つが必要になります。

そして、前述したルールに沿えば、xibファイル名は`制御クラス名.xib`でなければならないのと、
セルのIdentifierも`制御クラス名`でなければなりません。

つまり**制御クラス名が分かれば、登録処理に必要な情報が分かります。**

そして制御クラス名とは、登録したいセルと一致しているため、  
次のように制御クラスからUINibを求める処理が書けるようになります。

```swift
class TableViewCell: UITableViewCell {
  static var className: String { return String(describing: self) }
  static var identifier: String { return className }
  static var nib: UINib { return UINib(nibName: className, bundle: nil) }
}
```

これにより登録処理は次のように書けます。

```swift
tableView.register(TableViewCell.nib, forCellReuseIdentifier: TableViewCell.identifier)
```

しかしこれだと、わざわざ1つに固まった情報を外側で２つに分けて登録することになりコードとしては閉じた設計になっていません。  
なので登録処理自体も用意します。

```swift
extension UITableView {
  func register<T: TableViewCell>(_ viewType: T.Type ) {
      register(T.nib, forCellReuseIdentifier: T.identifier)
  }
}
```

こうすることで、処理を閉じ込めることができました。
```swift
tableView.register(TableViewCell.self)
```

xibに分離されたセルの使い方が分からない場合は、こちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-xib %}

### 登録処理を汎用化する
前述したコードはたしかに登録処理がシンプルになりましたが、 TableViewCell専用です。  
なのでこれをどのUITableViewCellサブクラスにも使えるようにします。

まず制御クラス名(`className`)とIdentifierをTableViewCell専用から汎用に変えるためにprotocol抽出します。  
UIViewControllerやUITableViewCellらは根底としてNSObjectを基底クラスとして持っており、そしてNSObjectはNSObjectProtcolを採用しています。

なので今回は NSObjectProtocol protocolを拡張することでUIViewControllerやUITableViewCellのクラス名やIdentifierが取れるようにします。  
多少影響がが広いですが、どちらもただのクラス名を返す属性としてあっても問題ないプロパティなので、大きく剥離した設計ではないと思います。

```swift
extension NSObjectProtocol {
    static var className: String { return String(describing: self) }
    static var identifier: String { return className }
}
```
こうすることで UIViewControllerやUITableViewCellらは、自分のクラス名とIDを持つことができました。
残すは`nib: UINib`になります。

これには新しく `Nibable` protocol を用意して、NIBを持つ制御クラスにこのprotocolを採用させることで、
採用したクラスは`nib: UINib`が持てるようにします。  
またnibにはクラス名がいるので先程の`NSObjectProtcol`に準拠させます。

```swift
protocol Nibable: NSObjectProtcol {
  static var nibName: String { get }
  static var nib: UINib { get }
}
extension Nibable {
  static var nibName: String { return className }
  static var nib: UINib { return UINib(nibName: nibName, bundle: nil) }
}
```

これを`TableViewCell`に採用させると次のようになります。

```swift
class TableViewCell: UITableViewCell, Nibable { }
```
TableViewCell自体に制御クラス名などは持たせる必要はありません。
Nibableを採用したことでデフォルトでそれらを持っているためです。

こうすることで、別のテーブル定義にも `Nibable` を採用させることで登録処理を簡易化できるようになります。

しかし先程同様にデータ側が整理されても登録も整理されていないと動きません。
なので先程改修したregiserを修正します。

```swift
func register<T: UITableViewCell>(_ viewType: T.Type) where T: Nibable {
    register(T.nib, forCellReuseIdentifier: T.identifier)
}
```
型を`UITableViewCell`を継承したサブクラス限定にして、 そのサブクラスが`Nibable`を採用している条件にします。

xibやテーブルだけでなくUICollectionViewにも使われます。

### セルの参照

登録の次はセルを生成 or 参照が必要です。

これは通常は
```swift
let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
```
というふうに `Identifier`と`制御クラス`へのキャストが必要になります。

これを今回は
```swift
let cell = tableView.dequeueReusableCell(TableViewCell.self, for: indexPath)
```
のように制御クラスへのキャストやIdentifierの指定を閉じ込めます。
これは、`制御クラスの型`を渡すだけで中で`Identifler`と`制御クラス`へのキャストをしてくれる拡張メソッドを用意すればいいだけですね。

```swift
extension UITableView {
  func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath ) -> T {
    return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
  }
}
```
今度はNibableは必要ありません。型推論によりキャストもできて、UITableViewCellは`NSObjectProtcol`を採用しているので`identifier`も取ってこれます。


## storyboardのコードを改善してみる

StoryboardもNibableのように`Storyboardable`を用意する方法です。

```swift
protocol Storyboardable: NSObjectProtocol {
    static var storyboardName: String { get }
}
extension Storyboardable {
    static var storyboardName: String { return className }
}
```
前述したルール、Identifierは制御クラスなのでここでもstoryboardNameは制御クラス名になります。

そして、これらを使ってStoryboardにアクセスしView Controllerのインスタンスを生成するコードを用意します。

```swift
extension Storyboardable {
  static var storyboardName: String { return className }

  static func instance() -> Self {
      let storyBoardName: String = Self.storyboardName
      let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)

      if let viewController = storyBoard.instantiateInitialViewController() as? Self {
          return viewController
      }

      let identifier: String = Self.className
      return storyBoard.instantiateViewController(withIdentifier: identifier) as! Self
  }
}
```

これは冒頭に記載したコードと意図は同じです。

## 既存の1storyboardに複数個のViewControllerが紐付いてるstoryboardに対して
`FugaViewController` の対象UIが `HogeViewController.storyboard` にある場合は次のように実装します。

```swift
class FugaViewController: UIViewController, Storyboardable {
  static var storyboardName: String { return "HogeViewController" }
}
```

このようにすれば HogeViewController.storyboard内の`FugaViewController`のIdentifierを持つView Controllerをロードします。

## 全容
部分的にコード抜粋で全容を見ないと分からないと思うのでコードの全容を記載します。

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
extension Storyboardable {
    static var storyboardName: String { return className }

    static func instance() -> Self {
        let storyBoardName: String = Self.storyboardName
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)

        if let viewController = storyBoard.instantiateInitialViewController() as? Self {
            return viewController
        }

        let identifier: String = Self.className
        return storyBoard.instantiateViewController(withIdentifier: identifier) as! Self

    }
}

// MARK: - Nibable
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

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath ) -> T {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }

    func register<T: UITableViewCell>(_ viewType: T.Type) where T: Nibable {
        register(T.nib, forCellReuseIdentifier: T.identifier)
    }
}
```

## StoryboardやXibのロード処理の改善はただのリファクタリング

改善と言っても速度や動作は変わっておらず、コードの可読性や重複性を排除しただけなので、リファクタリングになります。

最初は通常コードで実装し、コード量が増え実装に一定の法則性が見えてきたら、リファクタリングをするとその時に適した実装になりやすいです。  
いきなりリファクタリング後のコードを目指そうとしても大体がうまくいきません。

また今回のようなリファクタリングは自由を削り、出来ることを明確に表したことによる実装のカプセル化になります。  
そのため今は最適なコードでも、時間が立つことで環境や状況が代わり、最適だったコードも、不足が生まれ返って処理が散開するなどダメなコードに成り果てます。  
UIのような上位レイヤーに位置するコードに永続不変なコードは存在しません。

その時その状況を把握して適切なコードをメンテナンスし続けることは避けられません。

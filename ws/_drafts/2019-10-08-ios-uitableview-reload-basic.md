---
title: 【初心者向け】UITableView(テーブル)の更新方法の基本と注意点
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-10-08-ios-uitableview-reload-basic/0.png
---

UITableViewはシステム側が制御しており、一部制御をdelegateすることで制御しています。  
参照データがセルに表示するタイミングもその一つです。  
このシステムの更新ルールから外れて参照データを更新しても反映されません。

今回は動的なテーブルの更新方法について説明します。  
またいくつか更新方法があるのでそれぞれの説明と注意点についても説明します。

## データが反映されないコード
次のようにテーブルの参照データを後から更新すると、テーブルには反映されません。  
なぜならテーブルと参照データは特に紐付いていないためです。  
何らかの方法で参照データの変化をテーブル更新に繋げる必要があります。

```swift
struct User {
    let name: String
}

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        tableView.dataSource = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self ] in
            self?.users.append(User(name: "mothule"))
            print("Changed users")
        })
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#function)
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#function)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")
        let model = users[indexPath.row]
        cell.textLabel?.text = model.name
        return cell
    }
}
```

{% page_image 1.png %}

このときのコンソールは下記を出力してます。

```
viewDidLoad()
tableView(_:numberOfRowsInSection:)
tableView(_:numberOfRowsInSection:)
tableView(_:numberOfRowsInSection:)
tableView(_:numberOfRowsInSection:)
Changed users
```

`tableView(_:cellForRowAt:)`が呼ばれていないためセルの生成がされません。  
呼ばれない理由は、`users`に`User`が追加される前にテーブル更新が完結してるためです。

そのため何らかの方法でテーブルを再更新する必要があります。

ちなみにテーブルの基本的な使い方に関してはこちらの記事をどうぞ

{% post_link 2019-09-26-ios-uitableview-basic %}

### もっとも手軽な解決方法

テーブルの更新方法はいくつかありますが、もっとも手軽なのが `UITableView.reloadData()` になります。

例えば次のコードは参照データが変化したらテーブル全体を更新します。

```swift
private var users: [User] = [] {
    didSet {
        tableView?.reloadData()
    }
}
```

## テーブル更新方法

`UITableView`の次の３つのメソッドで更新します。

- `reloadData`: 全てのセルとセクションを更新します。
- `reloadSections(_:with:)`: 指定セクションと付随するいセルを更新します。
- `reloadRows(at:with:)`: 指定セルをアニメ付きで更新します。

今回のケースでは `reloadData` か `reloadSections(_:with:)` で更新ができます。  
`reloadRows(at:with:)` は更新前と更新後のセクション内のセル数が同じでないとランタイムエラーになります。

### reloadData()の欠点

セル数の少ないテーブルであれば、 `reloadData()` で事足ります。
しかしセル数が増えたりセル内のレイアウトが複雑だったりすると全体更新は負荷がかかります。

動的に変更で呼ばれるメソッドゆえあまり負荷が重くなるとカクツキが起きるようになります。  
場合によってはスパイクといって数ミリ秒~数秒固まります。

### セクション単位とセル単位の更新

負荷がセンシティブな要素であるなら、更新範囲を削ることで更新にかかる時間を短くすることが重要になります。

更新範囲を狭くする方法として `reloadSections(_:with:)` と `reloadRows(at:with:)` があります。
`reloadSections(_:with:)` メソッドはセクション単位での更新になります。

また更に絞り込みしたい場合は、 `reloadRows(at:with:)`がありますが、更新前と更新後のセクション内のセル数が一致してる条件が必要なのでケースによっては使えません。

## 部分更新で役立つメソッド

先程紹介した`reloadSections(_:with:)` と `reloadRows(at:with:)`はどちらもセクションまたはセルなど具体的な場所を指定する必要があります。

しかしケースによっては特定するのが難しいことがあります。

その場合は、次のメソッドを使うと特定のヒントまたはそのまま使えます。

- 選択中のセル位置を取得
  - `UITableView.indexPathsForSelectedRows`
  - `UITableView.indexPathForSelectedRow`
- 指定スクリーン座標のセル位置を取得
  - `UITableView.indexPathsForRows(in:)`
  - `UITableView.indexPathForRow(at:)`
- 指定セルのセル位置を取得
  - `UITableView.indexPath(for:)`
- 表示中のセル位置を取得
  - `UITableView.indexPathsForVisibleRows`

例えば表示中セルの全セクションを更新したい場合、次のコードのように工夫すればセクション一覧を取得できます。

```swift
let sections = Set((tableView.indexPathsForVisibleRows ?? []).map { $0.section }) tableView.reloadSections(IndexSet(sections), with: UITableView.RowAnimation.automatic)
```

Setに入れてるのはセクションの重複排除のためです。Arrayが持ってた順番保証がなくなりますが、必要ないので問題ないです。

## 更新は奥が深い
ほとんどのテーブルでは更新はあまり意識せず簡単なものですが、  
更新を呼びすぎるとシステムは愚直にテーブルを更新してしまいます。

しかも1~2回無駄に増えたと程度ではあまり目立ちません。  
しかしスペックの低いiPhoneや高負荷状態では、非常に目立ちます。つまりデータ依存で再現しにくいケースがあります。

そして部分更新でもっともリスクな不具合として、更新場所が適切ではなくテーブルが更新されないバグです。  
開発中に見つけられればそれは良しとして、データ依存による不具合であれば本番しか起きていない不具合で  
それはアプリとして非常に使いにくい動作として現れます。  
しかも残念ながらクラッシュはほぼしないでしょう。

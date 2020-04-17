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
- `reloadSections(_:with:)`: 指定セクションと付随するセルを更新します。
- `reloadRows(at:with:)`: 指定セルをアニメ付きで更新します。

今回のケースでは `reloadData` か `reloadSections(_:with:)` で更新ができます。  
`reloadRows(at:with:)` は更新前と更新後のセクション内のセル数が同じでないとランタイムエラーになります。

### reloadData()は全体更新しかし…

`reloadData`はテーブル全体の更新を行います。
セルのレイアウトがシンプルなら`reloadData()`を特に何も考えずに呼んでも問題は起こりにくいです。
テーブル全体更新ですが、効率のために表示中のセルのみが再表示されます。
またセル可変してもオフセットを調整する仕組みになっています。

### セル参照(cellForRowAt)は注意が必要
セルの表示には`tableView(_:cellForRowAt:) -> UITableViewCell`が呼ばれ内部でセル構築してセルを返します。

これの注意する点は、スクロールという軽快な動作を求められる場所でセル表示のたびに呼ばれることです。
そのため1セルが複雑だとそれだけ負荷がかかるため、スクロールにカクつきが起きるようになります。
場合によってはスパイクといって数ミリ秒固まります。

例えばセル内にUICollectionViewを入れて横スクロールなどを可能にするカルーセルなどは複雑だと思っていいです。

### セクション単位とセル単位の更新と注意点

セル単位とセクション単位の更新は、`reloadSections(_:with:)` と `reloadRows(at:with:)` があります。

`reloadRows(at:with:)`は、更新前と更新後のセクション内のセル数が一致してる条件が必要なのでケースによっては使えません。
また`reloadSections(_:with:)`もセクションAとBのセル数と紐づくデータが変化した場合に、セクションAだけを`reloadSections`で更新するとランタイムエラーが発生します。
これは`reloadSections`は他のセクションのセル数を求める処理が走っているためです。何故このような処理が走っているのかは公式ドキュメントを見ましたが特に記載がありませんでした。

これらは公式ドキュメントを読む感じだとセルの増減に対する制御処理だと思ったほうが良さそうです。

## 更新は奥が深い
ほとんどのテーブルでは更新はあまり意識せず簡単なものですが、  
更新を呼びすぎるとシステムは愚直にテーブルを更新してしまいます。

しかも1~2回無駄に増えたと程度ではあまり目立ちません。  
しかしスペックの低いiPhoneや高負荷状態では、非常に目立ちます。つまりデータ依存で再現しにくいケースがあります。

そして部分更新でもっともリスクな不具合として、更新場所が適切ではなくテーブルが更新されないバグです。  
開発中に見つけられればそれは良しとして、データ依存による不具合であれば本番しか起きていない不具合で  
それはアプリとして非常に使いにくい動作として現れます。  
しかも残念ながらクラッシュはほぼしないでしょう。

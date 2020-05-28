---
title: 【初心者向け】UITableView(テーブル)の更新方法の基本と注意点
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-10-08-ios-uitableview-reload-basic/0.png
---

UITableViewは主にシステム側が制御してますが、一部制御をdelegate(=お願い)することで柔軟な制御をしています。  
表示データをセルに表示するタイミングもその一つです。  
このシステムの更新ルールから外れて表示データを更新しても反映されません。

この記事では動的なテーブルの更新方法について説明します。  
またいくつか更新方法があるのでそれぞれの説明と注意点についても説明します。

## データが反映されないコード

ここでは、テーブルにデータが反映されないコードとその理由について説明します。

{% page_image 1.png %}

次のコードは、テーブル更新時に`users`を表示データとして参照しています。  
そしてその表示データを`viewDidLoad()`メソッド呼び出し後の1.0秒後に更新しています。  

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
        print("\(#function): users.count: \(users.count)")
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

このコードを実行したときコンソールでは下記を出力してます。

```
viewDidLoad()
tableView(_:numberOfRowsInSection:): users.count: 0
tableView(_:numberOfRowsInSection:): users.count: 0
Changed users
```

`tableView(_:numberOfRowsInSection:)`で0を返したため、  
`tableView(_:cellForRowAt:)`が呼ばれておらずセルの生成がされていません。

そして、表示データ(`users`)を更新してもテーブルが更新されません。  
このように**表示データを後から更新してもテーブルには反映されてません。**

### 反映されない原因

なぜなら「テーブル更新」と「表示データ」は紐付いていません。  
`users`にデータが追加される前にテーブル更新が完了してしまってます。

きちんと**表示データの変化をテーブル更新に繋げる**必要があります。  
表示データの更新とテーブル更新を紐付けるキーは「**テーブルの再更新**」になります。

もしUITableViewの使い方が曖昧でしたら、  
「{% post_link_text 2019-09-26-ios-uitableview-basic %}」記事をおすすめします。

### もっとも手軽な解決方法

テーブルの更新方法はいくつかありますが、もっとも手軽なのが `UITableView.reloadData()` になります。

例えば次のコードは表示データが変化したらテーブル全体を更新します。

```swift
private var users: [User] = [] {
    didSet {
        tableView?.reloadData()
    }
}
```

## テーブル更新方法

`UITableView`の次の３つのメソッドで更新します。

- `reloadData`: テーブルに関する全データを更新します。
- `reloadSections(_:with:)`: 指定セクションと付随するセルを更新します。
- `reloadRows(at:with:)`: 指定セルをアニメ付きで更新します。

今回のケースでは `reloadData`か `reloadSections(_:with:)` で更新ができます。  
`reloadRows(at:with:)` は更新前と更新後のセクション内のセル数が同じでないとランタイムエラーになります。

### reloadData()は全体更新しかし…

`reloadData`はテーブル全体の更新を行います。  
しかし、効率のために表示中のセルのみが再表示されます。  
またセル可変してもオフセットを調整する仕組みになっています。

### セル参照(cellForRowAt)は注意が必要
セルの表示直前に`tableView(_:cellForRowAt:) -> UITableViewCell`が呼ばれます。  
このメソッドで返したセルが表示されます。

これの注意点は、スクロールという軽快な動作を求められる場所でセル表示のたびに呼ばれることです。  
そのため1セルが複雑だとそれだけ負荷がかかるため、スクロールにカクつきが起きるようになります。  
場合によってはスパイクといって数ミリ秒固まります。

例えばセル内にUICollectionViewを入れて横スクロールなどを可能にするカルーセルなどは複雑だと思っていいです。

### セクション単位とセル単位の更新と注意点

セル単位とセクション単位の更新は、`reloadSections(_:with:)` と `reloadRows(at:with:)` があります。

`reloadRows(at:with:)`は、更新前と更新後のセクション内のセル数が一致してる条件が必要なのでケースによっては使えません。

また`reloadSections(_:with:)`もセクションAとBのセル数と紐づくデータが変化した場合に、セクションAだけを`reloadSections`で更新するとランタイムエラーが発生します。  
これは`reloadSections`は他のセクションのセル数を求める処理が走っているためです。  
何故このような処理が走っているのかは公式ドキュメントを見ましたが特に記載がありませんでした。

これらは公式ドキュメントを読むかぎり、セルの増減に対する制御処理だと思ったほうが良さそうです。

## テーブル更新は奥が深い
ほとんどのテーブルにおいて、更新はあまり意識せず簡単なものです。  

### データ可変対応のリスク
しかし、更新を呼んだ数だけシステムはテーブルを更新します。
これが1~2回無駄に更新が増えた程度では問題になりません。
しかし、スペックの低いiPhoneや高負荷状態では、非常に目立ちます。
つまりデータ依存で再現しにくい不具合を発生するリスクがあります。  
特に開発環境と本番環境で表示データ量に差が広がりすぎていると、本番環境でしか気づけない不具合などもあり肝を冷やします。

### 部分更新のリスク
部分更新で気をつける不具合は、更新場所が適切ではなくテーブルが更新されないバグです。  
開発中に見つけられればそれは良しとして、データ依存による不具合であれば本番しか起きていない不具合で  
それはアプリとして非常に使いにくい動作として現れます。  
しかも残念ながらクラッシュはほぼしないでしょう。

また反対にクラッシュするケースとしてセル数やセクション数が変わっているにも関わらず更新範囲の不一致があります。

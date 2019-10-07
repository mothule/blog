---
title: 【初心者向け】UITableViewDataSourceを別クラス化する方法とメリット
categories: ios uitableview
tags: ios uitableview uitableviewdatasource
image:
  path: /assets/images/2019-10-06-ios-uitableview-uitableviewdatasource-separate.png
---
UITableView(テーブル)の構築に必須の`UITableViewDataSource`ですが、ネットで見かける記事のサンプルなどでは、記事の都合上ほぼ必ずUIViewControllerにプロトコルを採用しています。

しかし実際のアプリ開発では、必ずしもそうとは限らず ViewController が複雑になればリファクタリングとして DataSource を別クラスに分離させることもあります。

今回は別クラスで`UITableViewDataSource`プロトコルを実装する方法とそうすることのメリットについて説明します。

## データソースの前提
実装の前に、データソースについて理解する必要があります。この理解が設計に関係するためです。

- DataSourceのスコープはViewControllerが持つUITableViewと同じです。
- つまりViewControllerが終わるときにはDataSourceも同時に不要になります。

## 準備: データモデルとデータを用意

データモデルは今回は簡単なユーザーモデルを用意します。
今回はサーバーではなくローカルに擬似的にデータを用意します。

```swift
struct User {
    let name: String
}

let data: [User] = [
    User(name: "mothule-1"),
    User(name: "mothule-2"),
    User(name: "mothule-3"),
    User(name: "mothule-4"),
    User(name: "mothule-5"),
    User(name: "mothule-6"),
    User(name: "mothule-7")
]
```

### データ受取をなるべくリアルにする
実際の開発ではViewControllerやインメモリがオリジナルデータを持つことはなく、大抵がサーバーから受信したデータを使います。  
しかもサーバーからのデータ受取は通常は非同期です。
これを今回は次のコードで擬似的に実現します。

```swift
class ViewController: UIViewController {
  // ...
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self ] in
        self?.users = data
    })
  }
  // ...
}
```

これは画面が開く直前にサーバーに問い合わせてデータを受け取る想定のコードです。

## UITableViewDataSourceを分離する

次コードは `DataSource` クラスを用意し `User` をデータ連携して `UITableViewDataSource` を ViewControllerから分離しています。

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let dataSource = DataSource()

    private var users: [User] = [] {
        didSet {
            dataSource.setupModel(users)
            tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self ] in
            self?.users = data
        })
    }
}

class DataSource: NSObject, UITableViewDataSource {
    private var models: [User] = []

    func setupModel(_ models: [User]) {
        self.models = models
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")
        let model = models[indexPath.row]
        cell.textLabel?.text = model.name
        return cell
    }
}
```

- `UITableViewDataSource` は `NSObjectProtocol` を採用しているため、 `NSObject`を継承する必要があります。
- `UITableView.dataSource` は **弱参照** のためインスタンスのオーナーを別で保つ必要があるため `ViewController` にもたせています。
- これは前提でも説明したようにデータソースとViewControllerのスコープは同じなので理にかなっています。

## よりDataSourceを疎結合にする

前述した実装でも大抵は問題ないのですが、「テーブルのレイアウトは同じがデータのみが異なる」というケースには対応ができません。  
なぜなら、`DataSource`内部で`User`を持っているためです。

`DataSource`が`User`を知りすぎているのも気になります。   
本来なら`DataSource`は`User`は知る必要はなく、テーブルに表示したいデータが欲しいだけだからです。

これを`DataSource`のために専用のデータモデルを用意して`User`を`DataSource`から追い出します。  
そして他モデルでも使える使えるようにデータモデルを抽象化します。

### データモデルを用意する

`DataSource`ではデータ数と`name`属性を必要としているので、これを抽象化します。

```swift
protocol DataSourceModel {
  var name: String { get }
}
```

### データソースはデータモデルを使うようにする

次のコードのように先程用意したデータモデルを使って、テーブル構築を行います。

```swift
class DataSource: NSObject, UITableViewDataSource {
    private var models: [DataSourceModel] = []

    func setupModel(_ models: [DataSourceModel]) {
        self.models = models
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")
        let model = models[indexPath.row]
        cell.textLabel?.text = model.name
        return cell
    }
}
```

これでデータへのアクセスはすべて`DataSourceModel`を介することで `DataSource` に他ドメインなクラスがいなくなりました。

### データソースにデータを渡す

次にデータソース(`DataSource`)にデータ(`User`)を渡す方法についてです。

これは渡すデータ(`User`)が`DataSourceModel`プロトコルに準拠していれば渡すことができるようになります。

これは次のコードで実現できます。

```swift
extension User: DataSourceModel { }
```

これは `DataSourceModel.name` を `User.name` が満たしているためこのような実装になります。

あとは`DataSource`のオーナーであるViewControllerからデータを渡せば完了です。

```swift
class ViewController: UIViewController {
  // ...
  private var users: [User] = [] {
    didSet {
        dataSource.setupModel(users)
        tableView?.reloadData()
    }
  }
  // ...
}
```

### データ連携に煩わしさを感じるなら

ViewControllerがリモート先から受け取ったデータをデータソースに渡すまでのフローに手続き的な手間を感じます。

これを解決するには RxSwift といったイベントとデータフローを連結すれば解決できます。

{% comment %} TODO: RxSwift版記事またはコードを用意する {% endcomment %}

## DataSourceを分離するメリット

**レイアウト同じだがデータが異なる場合に対応できる**  
ここまで読んだ人ならこのメリットを理解できると思います。
`UITableViewDataSource` はViewControllerではなく`UITableView`と共存してるので  
別のViewControllerで同じUITableViewを使う場合に流用できるためDRY違反になりません。

**ViewControllerからテーブル処理を分離できる**  
これは単純なViewControllerでは実感は全くないと思います。  
単純な分離ではありますが、責務を分けて見る必要のないコードが視界に入らないのはやはり効果は大きいです。

---
title: 【初心者向け】UITableViewの基本的な使い方【入門】
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-09-26-ios-uitableview-basic.png
---

初心者向けにiOSのUITableViewの基本的な使い方について説明します。

Xcodeでプロジェクトを作成し、storyboardを使ってUITextFieldやUILabel, UIButtonを使って簡単な画面を作れるようになりましたか？

しかし、UITableViewを使おうと思ったら、途端に扱うクラスが増えてそれぞれの関係性がなんなのかついていけず、躓いている人が多いのではないでしょうか？  
最初の躓きとなりやすいUITableViewを１つ１つ役割を理解し、それぞれの関係性を頭でイメージできるようになれば、難しいものではなくなります。

## テーブルを表示してタップでアラートを出すサンプルを作成する

完成イメージは次の動画のように、テーブルが表示されタップしたらタップしたデータをアラートで表示します。

<video autoplay loop muted playsinline src="/assets/videos/2019-09-26-ios-uitableview-basic.mp4" width="50%" height="400px"></video>

このサンプルには

- UITableView
- UITableViewDelegate
- UITableViewDataSource
- UITableViewCell
- UIAlertController
- UIAlertAction

が使われています。

全機能を使っているのではなく、部分的に使っているだけなので気構えずに１つずつ読み解いていきましょう。

## UITableViewをViewControllerと紐付ける

まず次の動画のようにstoryboard上のUITableViewをコードとバインディングします。
<video autoplay loop muted controls preload="auto" src="/assets/videos/2019-09-26-ios-uitableview-basic-1.mp4" width="100%"></video>
※動画が再生出来ない場合はキャッシュ無視リロードしてみてください。chromeであればcmd+rでできます。


この時点で一度実行します。実行するとテーブルのセパレータ(区切り線)が表示されるだけですが、実行はできます。

{% page_image -1.png 50% %}

もし実行できずエラーになる場合は、UITableViewの紐付けが次の画像のようになっているか確認してみてください。

{% page_image -2.png %}

コードは次の通りです。

*ViewController.swift*

```swift
import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```


## UITableViewDataSourceとはデータをUITableViewに流し込む役割
先程の状態ではテーブルには何も表示されていません。  
次の画像のようにデータを表示したいですね。

{% page_image -3.png 50% %}

テーブルに何らかのデータを表示するには、`UITableViewDataSource`を使います。

### UITableViewDataSourceとは

UITableViewDataSourceとはUITableViewのデータモデルを表現するプロトコルです。
このプロトコルを使えばテーブルにデータを表示することができます。
```swift
public protocol UITableViewDataSource : NSObjectProtocol { }
```

## データを表示するコードを書く

次のコードはテーブルにABCD1234を上から順番に表示するコードです。

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let items: [String] = ["A", "B", "C", "D", "1", "2", "3", "4"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}
```

順番に説明します。

### 表示するデータ

```swift
private let items: [String] = ["A", "B", "C", "D", "1", "2", "3", "4"]
```

`items`がデータとなります。この並び順がテーブルの表示順となります。  

### UITableView(テーブル)にデータモデルを渡す
```swift
tableView.dataSource = self
```
`tableView.dataSource`とはUITableViewが持つプロパティで型は`UITableViewDataSource`です。  
定義にジャンプすれば
```swift
weak open var dataSource: UITableViewDataSource?
```
と書いてるのを確認できます。

この`UITableViewDataSource`とは前述した、

「**UITableViewDataSourceとはUITableViewのデータモデルを表現するプロトコル**」です。

このプロトコルに対し、`self`を代入しています。  selfとはViewControllerです。  
つまり`ViewController`が`UITableViewDataSource`を採用してることになります。

### ViewControllerがUITableViewDataSourceを採用する

```swift
extension ViewController: UITableViewDataSource {
  // ...
}
```
このコード部分がそれにあたります。

### セル数を返す
```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
}
```
これは `UITableViewDataSource`が提供する実装が必要なメソッドの１つです。  
指定セクション内のロウの数を返すメソッドです。

今回は`items`の中身を表示するので、`items`の要素数を返します。

`section`は今回は使いませんが、詳しくはこちらの記事をどうぞ。
{% post_link 2019-09-26-ios-uitableview-section-basic %}

#### セクションとは？ロウとは？

次の図のような関係になってます。

{% page_image -4.png 182px %}

- ロウ(Row)とはセルを表します。
- セクションとはロウをまとめたグループ。

### セルの1つ1つを返す
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                UITableViewCell(style: .default, reuseIdentifier: "cell")
    cell.textLabel?.text = items[indexPath.row]
    return cell
}
```
ここで指定された位置(indexPath: IndexPath)にどんなセルを返すのかを定義します。

```swift
let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
            UITableViewCell(style: .default, reuseIdentifier: "cell")
```
セルID`cell`があればそれを使いまわします。
なければUITableViewCellをスタイル`default`でID名を`cell`で用意します。
`reuseIdentifier: "cell"`はセルを使い回すための識別子を名付けます。
これは複数種類のセルを扱う場合、ユニークである必要があります。

#### セルには予め何パターンか用意されている
`style: .default`とはUITableViewCellに予め何パターンか用意されているのでそれの指定になります。  

詳しくはこちらの記事で書いてあります。

{% post_link 2019-09-26-ios-uitableview-uitableviewcell-styles %}

#### セルはカスタマイズできる
既存スタイルにはなく自分でセルを自作(カスタマイズ)することもできます。

詳しくはこちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-uitableviewcell-customize %}

#### セルは使い回す
UITableViewCellはIDによる種類別で用意しておき、セルを再利用することでメモリ効率を満たしています。  

詳しくはこちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-lifecycle %}

UITableViewのUI特性はたくさんのデータを縦に積むことで、スクロールすればそれらを閲覧できます。  

そのため例えばテーブルに1000個のデータを並べた場合、UITableViewCellは1000個必要になります。  
それだと、メモリ効率が非常に悪いため、同じレイアウトなら使いまわそう。という考えがあります。  
それが`ReusableCell`と名付けられた由来になります。

## UITableViewDelegateとはUITableViewのイベントハンドラ

データを表示することができました。  
しかしアプリとしては表示だけで済むケースはほぼなく、大抵はセルをタップしたら何かしらアクションを起きます。

次のように押されたセルに関連するアクションを出すなど。

{% page_image -5.png 50% %}


セルのタップを検知するには、`UITableViewDelegate`を使います。


### UITableViewDelegateとは
`UITableViewDelegate`とは`UITableView`の操作イベントをハンドリングするプロトコルです。  
今回はタップのみですが、それ以外にも様々なイベントを検知することができます。

詳しくはこちらにまとめてあります。

{% post_link 2019-09-27-ios-uitableview-uitableviewdelegate-basic %}

## セルをタップしたらアラート出すコードを書く

次のコードはセルをタップすると選択したデータをアラートに表示するコードです。

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let items: [String] = ["A", "B", "C", "D", "1", "2", "3", "4"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let alert = UIAlertController(title: "タイトル", message: item, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
```

前述したデータ表示のコードに加えてあります。順番に説明します。

```swift
tableView.delegate = self
```

`tableView.dataSource = self`と同様になります。  
`delegate`は`UITableViewDelegate`というプロトコルになります。

### タップしたら呼ばれるメソッドがある

```swift
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let alert = UIAlertController(title: "タイトル", message: item, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
```

このメソッドはセルがタップされたら呼ばれるメソッドです。`UITableViewDelegate`プロトコルによって定義されています。

### アラートを出す
```swift
let item = items[indexPath.row]
let alert = UIAlertController(title: "タイトル", message: item, preferredStyle: .alert)
alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
present(alert, animated: true, completion: nil)
```

データアクセス方法をセル表示と同様に行うことで、タップした場所に表示されたデータ取得を実現しています。
アラートに関してはこちらにまとめてあります。

{% post_link 2019-09-27-ios-uialertcontroller-basic %}

## もう少し細かい部分を良くする

基本的な部分は前述した説明とコードになります。

しかし、ついでにデザイナーから要望を受けやすい一部とその実装を簡単に説明します。
### なにもないセルをなくしたい

「データが入っているセルはいいのですが、データが何も表示していないセルをなんとかできませんか？」と言われた場合、
セルに見えている原因となるセパレート(区切り線)を消すことで解決します。

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // ...
    tableView.tableFooterView = UIView()
}
```

このようにフッタービューに対して空のUIViewを代入することで空セルの区切り線は表示されなくなります。

|区切り線あり|区切り線なし|
|---|---|
| {% page_image -6.png %} |{% page_image -7.png %}|

### タップした後が残るのを消して欲しい

特に何もしないとタップしてアラートが終わった後もタップした後が残ります。これを解決します。

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    // ...
}
```
このように `deselectRow`メソッドを呼ぶことで選択解除されます。

<video autoplay loop muted playsinline src="/assets/videos/2019-09-26-ios-uitableview-basic-2.mp4" width="50%" height="400px"></video>

## UITableViewの使い方は奥が深い

UITableViewはiOSを習い始めでは慣れないクラス構造でつまづきやすいポイントかと思います。
しかし、アプリのレイアウトにおいてほぼ100%使われるので、極めておいて損はないです。

今回は基本的な部分の説明でしたが、実際の開発ではこの基本実装だけでは到底無理なので、
めげずにどんどんUITableViewの使い方を覚えていったほうが体系的に理解できます。

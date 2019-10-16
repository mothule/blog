---
title: 【初心者向け】UITableViewControllerの使い方
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-10-08-ios-uitableviewcontroller-basic/1.png
---
UITableViewControllerの使い方について説明します。

UIViewControllerと対等の位置にありますが、実態はUIViewControllerにテーブル機能を追加して、他の機能を削っただけです。


## まずはただ表示する

次のファイルを作成する

- TableViewController.swift
- TableViewController.storyboard

### TableViewController.swift

`Cocoa Touch Class` を選択して、 `Subclass of` を `UITableViewController` にすると自動でコードが生成されます。

{% page_image 2.png 50% %}

コードの定義を見ると分かるように `UITableViewController` は `UITableViewDataSource` と `UITableViewDelegate` を採用しています。  

```swift
open class UITableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
```

テーブルの基本について分からない場合はこちらの記事をどうぞ

{% post_link 2019-09-26-ios-uitableview-basic %}

自動生成されたコード量に少し面倒くささを感じますが、コメントアウトされたコードを見ると  
`UITableViewDataSource` と `UITableViewDelegate` の必須とよく使うメソッドば抜粋されているだけです。

もし`UITableViewDelegate`で分からない場合は、こちらの記事を先にどうぞ

{% post_link 2019-09-27-ios-uitableview-uitableviewdelegate-basic %}

### TableViewController.storyboard

`UITableViewController`を配置します。

{% page_image 1.png 50% %}

制御クラスは `TableViewController` にします。

## 唯一の特性であるStaticCell

UITableViewControllerはテーブルを静的にデータとして扱うことができます。

これは例えば次のようなテーブルにいくつかのカスタムセルがあったとして、

{% page_image 4.png %}

コード側では次のように直接Outletとして持つことができます。

```swift
class TableViewController: UITableViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBAction func onTouchedButton(_ sender: Any) {
        let vc = UIAlertController(title: "", message: textField.text ?? "", preferredStyle: .alert)
        present(vc, animated: true, completion: nil)
        textField.text = ""
    }
    // ...
}
```

{% page_image 5.gif %}

テーブルのセル内のイベントやUIを用意に取れるのはかなり協力ですが、弱点としては名前の通り静的構造限定です。  
動的にセルが変化したり増えたりするのはできません。




## UITableViewControllerでrefreshcontrol実装
UITableViewControllerに下に引っ張って更新するPull to refreshを実装するのは他と変わらずです。

{% page_image 3.gif %}

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    self.refreshControl = UIRefreshControl()
    self.refreshControl?.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)    
}

@objc private func onRefresh(_ sender: AnyObject) {
    print(#function)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self ] in
        self?.refreshControl?.endRefreshing()
    })
}
```

## titleは使えない
`UITableViewController` にはタイトルを設定する項目はありますが、`UINavigationController` や `UITabBarController` などViewControllerコンテナで呼ばない限りタイトルは表示されません。

## UITableViewControllerは用途は限定的

UITableViewControllerは UIViewController+UIViewTableで実装が楽になると思いますが、    
それ以上に柔軟性を犠牲にしており、実際のアプリ開発の画面ではUITableView単体で完結することはほとんどなく  
大抵が複数のViewを組み合わせて画面が構築されます。

そのため`UITableViewController`で実装を進めていると後で痛い目をみます。  
私個人としては使うべきではないです。

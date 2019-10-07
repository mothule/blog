---
title: UITableViewに引っ張る更新Pull to Refreshを実装する
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2017-12-10-ios-swift-uitableview-pull-to-refresh.png
---
## 概要
[iOS](/categories/ios)で使われるUIベスト3に入る[UITableView](/tags#uitableview)

そのUITableViewに引っ張って更新する機能（Pull to Refresh）の実装についてまとめました。


### 注意
1クラスにねじ込んだので、データフロー周りは参考にしないでください。


## 実装方法
**UIRefreshControl** を使うことで簡単に実装できます。

### サンプルコード
下記サンプルコードになります。 記事用に短く書いてます。


```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
    }

    @objc private func onRefresh(_ sender: AnyObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
}
```

## 実装ポイント

上のサンプルコードで重要なメソッドは下記の２つだけになります。

iOS10からは `UIScrollView` に標準で入っており弱参照でもないので、独自に管理も不要で、直接インスタンスを渡すことができます。
リフレッシュ終了は `endRefreshing()` を呼ぶだけです。

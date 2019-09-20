---
title: UITableViewに引っ張る更新Pull to Refreshを実装する
categories: ios uitableview
tags: ios swift uitableview
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
    private weak var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        initializePullToRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }


    // MARK: - Pull to Refresh
    private func initializePullToRefresh() {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(onPullToRefresh(_:)), for: .valueChanged)
        tableView.addSubview(control)
        refreshControl = control
    }

    @objc private func onPullToRefresh(_ sender: AnyObject) {
        refresh()
    }

    private func stopPullToRefresh() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    // MARK: - Data Flow
    private func refresh() {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1.0)
            DispatchQueue.main.async {
                self.completeRefresh()
            }
        }
    }

    private func completeRefresh() {
        stopPullToRefresh()
        tableView.reloadData()
    }
}
```

## 実装ポイント

上のサンプルコードで重要なメソッドは下記の２つだけになります。

- initializePullToRefresh
  - **UIRefreshControl** の初期化
- stopPullToRefresh
  - **UIRefreshControl** の状態を見て停止

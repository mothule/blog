---
title: UITableViewの空セルの線(separator)を消す実装
categories: ios uitableview
tags: ios swift uitableview
image:
  path: /assets/images/2017-12-10-ios-swift-uitableview-hidden-separator.png
---

## 概要

[iOS](/categories/ios)で使われるUIベスト3に入る[UITableView](/tags/#uitableview)

そんなUITableViewですがデザイナーからよく指摘される空セルには線(separator)を引かないで消す実装についてまとめました。

## 実装方法

**UITableView.tableFooterView** を空にするだけです。

## サンプルコード

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
}
```

たったこれだけで線(separator)を消すことができます。

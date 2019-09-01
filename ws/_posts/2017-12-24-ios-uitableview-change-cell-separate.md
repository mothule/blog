---
title: UITableViewのセル間の境界線を変更する
date: 2017-12-24
draft: true
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2017-12-24-ios-uitableview-change-cell-separate.jpg
---

セル間の境界線のスタイルと色と開始位置／終了位置を変更する方法です。
凝ったことはせずデフォルトの機能だけで実現することができます。

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 線の種類
        tableView.separatorStyle = .singleLine
        // 線の色
        tableView.separatorColor = UIColor.red
        // 先のインセット
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
```

## 線の種類を変更する

`UITableViewCellSeparatorStyle` を使います。

|値|意味|
|----|----|
|.none|境界線なし|
|.singleLine|境界線あり|

## 線の開始位置と終了位置を調整する

separatorInsetを変更することで線の開始位置（左端）と終了位置（右端）を移動できます。
topとbottomの値は使われません。

デフォルトは UIEdgeInsetsMake(0, 3, 0, 11) です。

[separatorInset - Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uitableview/1614851-separatorinset)

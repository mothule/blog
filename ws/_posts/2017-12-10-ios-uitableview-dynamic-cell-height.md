---
title: UITableViewのセルの高さを動的に変更する
description: UITableViewのセルの高さを動的に変更する
date: 2017-12-10
categories: ios uitableview
tags: ios swift uitableview
image:
  path: /assets/images/2017-12-10-ios-uitableview-dynamic-cell-height.png
---
## 概要

[iOS]({{ site.baseurl }}/categories/ios)で使われるUIベスト3に入る[UITableView]({{ site.baseurl }}/tags#uitableview)
そのUITableViewのセルの高さを内容に応じて動的に変更する方法についてまとめました。

## 実装方法
- **UITableView.rowHeight** に **UITableViewAutomaticDimension** を設定する
- セルのAuto Layoutの縦軸が全て繋がるように設定する


## サンプルコード

サンプルコードは少し長いですが、実際はカスタムセルとセル内に表示するでかい文字列を生成するコードが大半です。

ViewController.swift
```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil),
                           forCellReuseIdentifier: "TableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.configure(with: TableViewCell.Model(title: cellTitle, desc: text, date: Date()))
        return cell
    }

    var cellTitle: String {
        return [title1, title2, title3][Int(arc4random()) % 3]
    }
    var text: String {
        return [text1, text2, text3][Int(arc4random()) % 3]
    }

    var title1: String { return "HogeHoge" }
    var title2: String { return "ダミー太郎" }
    var title3: String { return "本日晴天なり🇯🇵" }
    var text1: String {
        return """
        この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。この文章はダミーです。文字の大きさ、量、字間、行間等を確認するために入れています。
        """
    }
    var text2: String {
        return "ダミーテキスト。"
    }
    var text3: String {
        return """
        Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """
    }
}
```

TableViewCell.swift
```swift
class TableViewCell: UITableViewCell {
    struct Model {
        let title: String
        let desc: String
        let date: Date

        var dateString: String {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy/MM/dd"
            return fmt.string(from: date)
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    private(set) var model: Model? {
        didSet {
            titleLabel.text = model?.title
            descLabel.text = model?.desc
            dateLabel.text = model?.dateString
        }
    }

    func configure(with model: Model?) {
        self.model = model
    }
}
```

レイアウト
<a href="/assets/images/2017-12-10-ios-uitableview-dynamic-cell-height-1.png"><img src="/assets/images/2017-12-10-ios-uitableview-dynamic-cell-height-1.png" width="50%" alt="高さ可変のUITableView"></a>

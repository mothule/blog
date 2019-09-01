---
title: UITableViewで一番下までスクロールする方法
date: 2017-12-15
categories: ios uitableview
tags: ios uitableview
---
UITableViewで一番下のセルまでスクロールする方法についてまとめました。


## 実装方法
UITableView#scrollToRow(at:at:animated)を使います。

第一引数のIndexPathにはrowとsectionを指定します。
この時にデータ配列から一番最後を指定することで一番下のセルまでスクロールできるようになります。

もしセクションが複数個の場合は、一番最後のセクション番号を指定しないといけません。
セクションは固定であれば数えて一番最後のセクション、動的であれば元となるデータ配列の一番最後を指定してください。


## 実装コード

```swift
class ViewController: UIViewController,
                      UITableViewDataSource,
                      UITableViewDelegate {
    @IBOutlet private weak var tableView: UITableView!
    private var data: [Data] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        Array(0..<100).forEach {
            data.append(Data(name: "\($0)"))
        }
    }

    // MARK: - UITableViewDataSource and UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = data[indexPath.row].name
        return cell!
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.scrollToRow(at: IndexPath(row: data.count - 1, section: 0),
                              at: UITableViewScrollPosition.bottom, animated: true)
    }
}

struct Data {
    let name: String
}
```

`UITableViewScrollPosition.bottom` はセルをスクリーンのどの位置に合わせるかのパラメータになります。
今回は一番のセルなのでbottom にしていれば問題ありません。

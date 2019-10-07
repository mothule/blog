---
title: Slackアプリみたいなアイコンと可変文字のセルの作り方
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-10-01-ios-uitableview-slack-like-cell/2019-10-01-ios-uitableview-slack-like-cell.png
---
Slackみたいなセルを作る方法について説明する。
Slackみたいなセルとは、

- 文字列の高さがアイコンより小さい場合はセルの高さ幅はアイコンより小さくならない。
- しかし文字列が長くなり高さがアイコンより大きくなる場合は、セルの高さ幅はアイコンより大きくなり、文字列の高さに追従する

Twitterみたいなセルでもイメージは同じです。

## コードは特に凝ったつくりではない

コード側は特に変わった部分はありません。
普通のセル高さを自動算出にしたセル表示です。

*ViewController.swift*
```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    let text = """
Slackみたいなセル。文字列の高さがアイコンより小さい場合は、セルの高さ幅はアイコンより小さくならない。
しかし文字列が長くなり、高さがアイコンより大きくなる場合は、セルの高さ幅はアイコンより大きくなり、文字列の高さに追従する
"""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 81
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 400
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        if let c = cell as? TableCell {
            let comment = String.init(repeating: text, count: indexPath.row + 1)
            c.setup(image: #imageLiteral(resourceName: "icon"), name: "mothule", comment: comment)
        }
        return cell
    }
}
```

*TableView.swift*
```swift
class TableCell: UITableViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!

    func setup(image: UIImage, name: String, comment: String) {
        iconImageView.image = image
        nameLabel.text = name
        commentLabel.text = comment
    }
}
```

もしセルの高さ可変について分からない場合はこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-height-customize %}

## 凝っているのはConstraints設計

{% page_image -1.png %}

画像より文字が大きくなれば文字の制約に追従し、反対に文字が画像より小さくなれば画像の制約に従う。

言葉にすると難しいですが、仕組みは分かると単純です。

まず画像下部から伸びてる制約は次のようにします。

{% page_image -2.png 50% %}

`8以上` つまり8より小さくなってはならない。

次にコメント用UILabelの下部から伸びている制約です。  
制約は2つあります。

{% page_image -3.png 50% %}

`52以下` つまり52より大きくなってはいけない。  
52とはUILabelからセルの下部までの距離です。  
これはセルは文字列がアイコンより小さい時のセルのサイズ時の文字列からセル下部までの距離です。  
つまりこれ以上距離が短くなってしまうと、セルの高さは狭まりアイコンが切れてしまいます。

{% page_image -4.png 50% %}

`8以上` つまり8より小さくなってはならない。  
これは文字列がアイコンより大きくなった場合に、文字列とセル下部の距離が8より短くならないための制約です。

この3つの制約で成り立ってます。

他の制約はただ隣接までの距離を8固定で制約をつけているだけです。

## 2つ制約をつけるテクニックはよくある

N以上X未満みたいな表現をしたい場合、制約を2つ用意することで実現可能です。

この時 `=` だと制約衝突してしまいます。

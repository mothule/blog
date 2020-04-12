---
title: iOSでSlackアプリみたいなアイコンと可変文字のセルの作り方
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-10-01-ios-uitableview-slack-like-cell/2019-10-01-ios-uitableview-slack-like-cell.png
---
この記事はiOSでUITableViewとUITableViewCellでSlackみたいな **「可変テキストがアイコン高さ幅より下回ってもアイコンよりは小さくならず」「可変テキストがアイコン高さ幅より上回っていたらセルの高さ幅が可変テキストに追従する」** セルをプログラムは特別な実装は不要でUITableViewCellの **AutoLayout設計** で **Constraintsを2つ制約つけるテクニック** で実装する方法について説明します。Twitterみたいなセルでもイメージは同じです。

## View構成はUIViewController内UITableView

この記事で紹介するView構成について説明します。

- *ViewController: UIViewController*
  - *views: UIView*
    - *tableView: UITableView*

見てすぐ分かるとおりView構成は、ViewControllerがTableを持ってるだけの非常に一般的な構成となります。

### UIViewControllerやUITableViewのコードは特に凝ったつくりではない

コード側もカスタムセルを高さ自動算出にしただけで特に変わった部分はありません。
ファイルは2ファイルです。

- ViewController.swift
- TableView.swift

単純ではありますが、それぞれいくつか処理を説明します。

もしセル高さの自動算出について詳しく知りたい場合は、「{% post_link_text 2019-09-29-ios-uitableview-uitableviewcell-height-customize %}」の記事に詳しくまとめてあります。

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

今回はサンプルなので構造をシンプルにするためセル数は固定で400にしてあります。  
`estimatedRowHeight`の数字は`Interface Builder`の高さ幅を適当に参照します。
この値は工夫したところでslackのようなコミュニケーションツールは発言量に差があるので全ての発言量をカバーする推測値は不可能です。  
セル参照では`TableCell`という名前のセルを使っています。これは`Table View Cell`の`Identifier`で設定された文字列を指定してます。

```swift
let comment = String.init(repeating: text, count: indexPath.row + 1)
```

こちらはセル位置の値に比例してたテキスト量を生成してるだけです。

```swift
c.setup(image: #imageLiteral(resourceName: "icon"), name: "mothule", comment: comment)
```

こちらはカスタムセルの制御クラス(`TableCell`)で用意したセットアップメソッドで、アイコン情報と発言者名、発言内容の情報をセルに渡しています。

次にカスタムセルの制御クラス(`TableCell`)について説明します。

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

前述したアイコン情報と発言者名、発言内容を表すViewとそれら情報を受け取るためのセットアップメソッドのみの非常にシンプルな構成となります。


## UITableViewCellのConstraints設計が重要

下の画像はセル(`TableCell`)の`Interface Builder`上でのデザインです。  
画像とラベル２つのシンプルな構成です。

{% page_image -1.png %}

セル高さを次のConstraints制約で算出可能にします。

- 画像より文字領域が大きくなれば文字の制約に追従する
- 反対に文字が画像より小さくなれば画像の制約に従う

言葉にすると難しいですが、仕組みは分かると単純です。
まず画像下部から伸びてる制約は次のようにします。

### 画像からセル下の幅は8以上

{% page_image -2.png 50% %}

**`8以上` つまり8より小さくなってはならない。**

次にコメント用UILabelの下部から伸びている制約です。  
**制約は2つあります。**

### 制約1つ目: ラベルからセル下の幅は52以下

{% page_image -3.png 50% %}

**`52以下` つまり52より大きくなってはいけない。**  
52とはUILabelからセルの下部までの距離です。  
これはセルは文字列がアイコンより小さい時のセルのサイズ時の文字列からセル下部までの距離です。  
つまりこれ以上距離が短くなってしまうと、セルの高さは狭まりアイコンが切れてしまいます。

### 制約2つ目: ラベルからセル下の幅は8以上

{% page_image -4.png 50% %}

**`8以上` つまり8より小さくなってはならない。**  
これは文字列がアイコンより大きくなった場合に、文字列とセル下部の距離が8より短くならないための制約です。

この3つの制約で成り立ってます。  
他の制約はただ隣接までの距離を8固定で制約をつけているだけです。

## iOSのConstraintsで2つ制約をつけるテクニックは覚えよう

N以上X未満みたいな表現をしたい場合、制約を2つ用意することで実現可能です。  
この時 `=` だと制約衝突してしまいます。

iOSのデザインはあまり凝ったことすると、管理が複雑になって破綻しなけません。
しかし今回のようにConstraintsを2つ使うなどちょっとした工夫で、大きくデザイン表現の枠を広げることも可能となります。
可能な範囲で可能なことを増やすことは重要です。

---
title: 【初心者向け】UITableViewCellの高さを可変にする
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-29-ios-uitableview-uitableviewcell-height-customize-1.png
---

次の`UITableViewDelegate`のメソッドを使うことでセル毎やセクション毎の高さ設定ができますが、まず大抵のケースでは使いません。
なぜなら`UITableView.rowHeight`に `UITableView.automaticDimension` を渡し、各セルをAuto-Layoutが効くような実装にすれば  
自動でセルの高さを計算してくれるためです。

あるとすればセルごとの推測値`estimated`の値を返す。または状態によって一部セルを非表示にするために高さを0.0にしたいときでしょうか。

今回はAutoLayoutで可変に対応したセルの実装方法についてまとめてます。

- セルの高さを返す: `func tableView(_:heightForRowAt:) -> CGFloat`
- セクションヘッダーの高さを返す: `func tableView(_:heightForHeaderInSection:) -> CGFloat`
- セクションフッターの高さを返す: `func tableView(_:heightForFooterInSection:) -> CGFloat`
- セルの推定高さを返す: `func tableView(_:estimatedHeightForRowAt:) -> CGFloat`
- セクションヘッダーの推定高さを返す: `func tableView(_:estimatedHeightForHeaderInSection:) -> CGFloat`
- セクションフッターの推定高さを返す: `func tableView(_:estimatedHeightForFooterInSection:) -> CGFloat`

## 前提

UITableViewCell内のレイアウトは縦軸が全てAutoLayoutが聞いている必要があります。  
AutoLayoutが効いていることで自動計算ができるためです。

次のセルのように縦軸が制約で繋がっている必要があります。

- UILabelとセル上部は8で固定
- UILabelの高さはLinesを0にして行数制限を解除（つまり可変）
- UILabelとセル下部は8で固定

{% page_image -2.png %}

UILabel１つだとわかりにくいのでUIButtonを置いた場合はこうなります。

このとき UIButton の Heightは20で固定してます。  
セルの縦軸が全て制約で結びついています。

{% page_image -3.png %}



## セルを用意する

今回はテキストの長さが可変するセルを用意し、テキストが長くなってもセルの外にはみ出さず、セルも長くなるようにします。  

## 実装する

実は実装といってもただのテーブル表示とほとんど変わりありません。

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    let text = """
どんどん文字列が増えればセルの高さが長くなる。
"""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
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
            c.setup(comment: comment)
        }
        return cell
    }
}

class TableCell: UITableViewCell {
    @IBOutlet private weak var commentLabel: UILabel!
    func setup(comment: String) {
        commentLabel.text = comment
    }
}
```

以前のXcodeバージョンであれば
```swift
tableView.rowHeight = UITableView.automaticDimension
```
のように`automaticDimension`をセットする必要がありましたが、今はデフォルトなので設定不要です。
また高さ自動計算のパフォーマンスにおいては
```swift
tableView.estimatedRowHeight = 81
```
のように`estimatedRowHeight`で想定値が入っているといいですが、なくても動きます。

もしUITableViewの使い方が分からなければこちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-basic %}

## まとめ

めちゃくちゃ簡単な設定だけで実装できましたが、セルの可変は恐ろしいほど使われます。

AutoLayoutによる制約で縦軸が繋がっていることが重要です。  
これによりシステムは高さ幅の自動計算ができるようになります。

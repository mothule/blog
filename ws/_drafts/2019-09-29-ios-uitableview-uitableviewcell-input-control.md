---
title: 【初心者向け】UITableViewでボタンやテキスト入力の使い方や注意事項
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-29-ios-uitableview-uitableviewcell-input-control-2.png
---
UITableViewのセル(UITableViewCell)にButtonやTextFieldをセットした場合の注意点についてまとめました。

## サンプル

検証コードになります。  
セルにUIButtonとUITextFieldを配置しています。

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        if let c = cell as? TableCell {
            c.setup(buttonTitle: "ボタン", valueText: "でふぉると") { (button, tf) in
                button.setTitle("ぼたん", for: .normal)
                tf.text = ""
            }
        }
        return cell
    }
}

class TableCell: UITableViewCell {
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var textField: UITextField!

    typealias Handler = (UIButton, UITextField) -> Void

    private var handler: Handler?

    @IBAction func onTouchedButton(_ sender: Any) {
        handler?(button, textField)
    }

    func setup(buttonTitle: String, valueText: String, tapHandler: @escaping Handler) {
        button.setTitle(buttonTitle, for: .normal)
        textField.text = valueText
        handler = tapHandler
    }
}
```

Interface Builderは次のようなレイアウトです。

{% page_image -3.png %}

セルのカスタマイズについて分からない場合はこちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-uitableviewcell-customize %}


## タップの反応が遅い

セル上にボタンがあると、タップしてから遅延があります。  
これをなくすには、

```swift
tableView.delaysContentTouches = false
```

を設定することで遅延がなくなります。  

## セルのタップが反応してしまう

{% page_image -1.png %}

次のようにセルをタップできてしまい、タップしたらハイライトがついてしまいます。
セル上のボタンは動いて欲しいが、セルには反応してほしくないと思います。
その場合は、セルのタップを無効化にします。

`UITableViewDelegate` の `tableView(_:shouldHighlightRowAt:) -> Bool`を`false`を返すとハイライトにならず、タップが無効になります。

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    // ...
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
```

## セルの状態が消える
これは自分の実装による症状ですが、陥りがちな罠です。

セルは一度スクリーンから外れ再度入ると、再度セル参照が呼ばれます。
そのため、ボタンのタイトルやテキストフィールドの中身が再セットされるので、リセットされたと勘違いします。

次の動画のように、ボタンのタイトルやUITextFieldの中身を変えてももとに戻ってしまいます。

<video autoplay loop muted playsinline src="/assets/videos/2019-09-26-ios-uitableview-basic.mp4" width="50%" height="400px"></video>

まさかこんなのにはハマらないでしょ？と思うかもしれませんが、セル内のUI処理をセルが画面外に出る前にデータ側に反映させておかないと、セルが再表示するときに反映前のデータがセットされるので、もとに戻ります。

「テーブル一覧があって、最後に決定ボタン」そんなレイアウトだと陥りがちです。

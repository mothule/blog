---
title: UITableViewCell(セル)のサブビュー背景色が消える原因と解決法
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-29-ios-uitableview-uitableviewcell-selected-subviews-gone-1.png
---
UITableViewのUITableViewCell(セル)をカスタマイズでサブビューに背景色をつけることがありますが、  
そのセルをタップしてハイライト状態(Highlighted)や選択状態(Selected)にしたときに、サブビューの背景色が消える現象に遭遇した人は多いと思います。  
そんなバグの直し方を説明します。

## 原因は色を透明化してるため
例えば次のようにレイアウトされたセルを用意する。

{% page_image -2.png 80% %}

このセルをタップ直後のボタン(button)の背景色を確認すると下記のようになる。

```
(lldb) po button.backgroundColor
▿ Optional<UIColor>
  - some : UIExtendedGrayColorSpace 0 0
```

ピンクではなく透明になっている。  
背景色が消える原因はこれになる。

## 色を復元して対処する

対処法はセルが選択されて色が透明になったら復元させて対処する。

```swift
class TableCell: UITableViewCell {
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var label: UILabel!

    private var defaultButtonBackgroundColor: UIColor?
    override func awakeFromNib() {
        super.awakeFromNib()
        defaultButtonBackgroundColor = button.backgroundColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            button.backgroundColor = defaultButtonBackgroundColor
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            button.backgroundColor = defaultButtonBackgroundColor
        }
    }
}
```

なおコードではボタンのみを解決している。  
他の背景色をもったビューも同様の方法で解決する。

{% page_image -3.png %}

### Highlightedとは？
指が画面内のセルに触れている状態、つまり押しっぱです。

### Selectedとは？
セルが選択されて色がついている状態。  
Highlightedと違い指を画面から離した状態。

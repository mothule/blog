---
title: 【初心者向け】UITableViewCellをxibから使う
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-29-ios-uitableview-uitableviewcell-xib.png
---
この記事ではUITableViewCellをxib化して外部からセルを使う方法について説明します。

UITableViewCellをカスタマイズして多彩なテーブル実装はできますが、設計観点においてUITableView上に直接UITableViewCellを配置してカスタマイズするのは、ときとして完全ではありません。

例えば画面Aと画面Bで同じレイアウトのセルを必要になったときに、UITableViewに直接配置したセルでは、画面毎のstoryboardに同じレイアウトが存在してしまい、DRY原則違反になります。

xib化することで２つあった同じレイアウトが1つに集約し、DRYも守れるようになります。

## UITableViewCell(セル)を用意する

まずはセルを用意から始めます。
最初に制御クラスとxibファイルを作成します。

### xibの作成

個別でファイル作るでもいいのですが、楽な方法を選びます。  
ファイル作成で `Cocoa Touch Class` を選びます。

{% page_image -1.png 340px %}

次に`Subclass of`をUITableViewCellにしてください。

**`Also create XIB file`にチェックをいれてください。**

{% page_image -2.png %}

あとは画面に従って進めばファイルを作成できます。  
ファイルは制御クラスとxibファイルの２つが出来ているはずです。

#### レイアウト
xibファイルはstoryboardと基本操作は変わりません。  
今回は次のようなレイアウトを作成しました。

{% page_image -3.png %}

制御クラスの紐付けとセルIDの設定も忘れずに行います。

{% page_image -4.png 50% %}

{% page_image -5.png 50% %}


もし制御クラスやセルIDの設定など、セルのカスタマイズに関する詳細こちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-uitableviewcell-customize %}

### 制御コードの実装

```swift
class TableViewCell: UITableViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setup(image: UIImage, name: String, description: String) {
      iconImageView.image = image
      nameLabel.text = name
      descriptionLabel.text = description
    }
}
```

といっても生成されたコードに対してOutletを結んだだけです。

今回の重要部分は、ロード処理になります。

## カスタムUITableViewCellの登録

xibのセルを使いたいUITableViewに対してxibの存在を登録する必要があります。  
でないと、テーブルはセルIDだけ言われても見つけることができません。

登録は `UITableView.register(_,forCellReuseIdentifier:)`を使います。  
xibのロードは `UINib(nibName:bundle:)`を使います。

(なぜNIBなのか？に関しては歴史的経緯のすえこうなった。程度でとりあえず問題ありません。)

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // ...
    let nib = UINib(nibName: "TableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
    // ...
}
```

あとは通常の実装で動きます。

UITableViewの基本的な実装に関してはこちらの記事どうぞ

{% post_link 2019-09-26-ios-uitableview-basic %}

## UITableViewCellをxibから使うのは設計観点

要件を満たすだけで言えば、xibにする必要はありません。  
レイアウトデータが重複しても、制御クラスは1つで動きます。

分離する目的は未来投資またはメンバーへの思いやりです。

- 仕様変更により改修ポイントや影響範囲を抑えること
- 散らばって把握に時間がかかる実装よりも読みやすい想像しやすい実装でメンバーが理解しやすくするための思いやり

チーム開発でない人は、「10日後の自分」に思いやりを持ってください。

---
title: 【初心者向け】UITableViewのSectionHeader(セクションヘッダー)を変更する
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-09-29-ios-uitableview-section-header-customize.png
---
SectionHeader(セクションヘッダー)やSectionFooter(セクションフッター)のカスタマイズについて説明します。  
基本的な変更であれば`UITableDataSource`protocolの`titleForHeaderInSection`などを変更すれば可能ですが、  
より複雑な独自のUIViewなどを設定したい場合はこれとは違う `UITableViewDelegate`を使った実装が必要になります。

もし基本的なセクションヘッダーの変更であれば、こちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-section-basic %}

## 完成イメージ
リソースは適当に用意したものなので見た目としては酷いですが、機能は満たしてあります。

<video autoplay loop muted playsinline src="/assets/videos/2019-09-29-ios-uitableview-section-header-customize-1.mp4" width="100%" height="400px">うまく読み込めない場合はリロード</video>

## 基礎理解
セクションヘッダーの定義元には次のようなコメントがあります。

> fixed font style. use custom view (UILabel) if you want something different

つまり、この方法ではフォントは固定で、もしカスタマイズしたい場合は、UILabelを使います。
これを実装するには、`UITableViewDelegate` の `func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?` を実装します。  
なぜ急に`delegate`？ と多少違和感を感じますが、少なくとも`DataSource`ではないと思うと多少疑念が和らぎます。

## セクションヘッダーとなるUITableViewHeaderFooterViewを用意する

レイアウトは今回は画像とラベル１つずつ使おうと思います。なので次のようなコードになります。

```swift
class HeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    func setup(image: UIImage, title: String) {
        imageView.image = image
        titleLabel.text = title
    }
}
```

## xibでレイアウトを作成

次にxibでレイアウトを用意します。

デフォルトではiPhoneサイズのViewになっており変更もできないので、下記画像のように状態を変更します。

{% page_image -1.png 514px %}

これで角をドラッグすることでサイズ変更が可能となります。  
またバッテリーアイコンなど余計なアイコンもでなくなります。  
ホームバーについては消す方法がなかったです。

レイアウトは今回は画像とラベル１つずつ次のように配置しました。

{% page_image -2.png %}

制御クラスは先程作成したクラスを紐付けます。

{% page_image -3.png 506px %}

## xibをUITableViewに登録する

```swift
override func viewDidLoad() {
  super.viewDidLoad()
  let nib = UINib(nibName: "HeaderView", bundle: nil)
  tableView.register(nib, forHeaderFooterViewReuseIdentifier: "HeaderView")
  // ...
}
```

## セクションヘッダーの高さを変更する

デフォルトではセクションヘッダーも高さが決まっているので変えておかないと小さいです。
変更方法は `UITableViewDelegate` の `heightForHeaderInSection` でセクション単位で変更する方法と、  
`UITableView.sectionHeaderHeight` で一律変更する方法です。

今回は一律でサイズは予め分かっているので固定値にします。`delegate`や`dataSource`の設定の下あたりに置いときます。
```swift
tableView.sectionHeaderHeight = 88
```

## セクションヘッダーを独自ビューで生成する

ではパーツの準備ができたので、実際のそのパーツを組み込みます。

```swift
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView")
        if let headerView = view as? HeaderView {
            headerView.setup(image: #imageLiteral(resourceName: "icon2") , title: "Hoge")
        }
        return view
    }
}
```

`dequeueReusableHeaderFooterView` を使ってID指定で取り出します。  
注意点としては、メソッド名に書いてるようにヘッダーとフッター両方が取れます。  
実装によっては判別を行う必要があります。

なお他のコードはただのテーブル表示なので省略します。

もしUITableViewの使い方に関しては、こちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-basic %}

## セクションフッターも同様に可能

セクションフッターもヘッダー同様に追加することが可能です。
変更点は、呼び出すメソッドが `tableView(_:viewForFooterInSection:) -> UIView?`になります。

---
title: 【初心者向け】UITableViewCellをカスタマイズする
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-26-ios-uitableview-uitableviewcell-customize/2019-09-26-ios-uitableview-uitableviewcell-customize-5.png
---
簡単なユーザー情報を表示するテーブルを題材に話を進めます。

## UITableViewCellを継承したセルクラスを用意する

Xcodeのファイル作成でCoCoa Touch Classを選び、Subclass ofにUITableViewCellを選んで作成すると、次のようなコードが生成されます。

{% page_image -2.png 50% %}

```swift
class UserTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
```

### `func awakeFromNib()`: Storyboardまたはnibファイルからロードされた直後に呼ばれる
初期化などUserTableViewCellがロードされた直後に１度だけ実行したい処理をここに実装します。

### `func setSelected(, animated:)`: 選択状態と通常状態の状態アニメーション処理
セルがタップにより選択状態/通常状態の切り替わり処理をするときに呼ばれる処理です。
特になくても状態アニメーションは行われます。

ここを確実に使う場面は少なく、セル内の色付きビューや画像の選択処理がうまく動かない場合に使います。
詳しくはこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-selected-subviews-gone %}

## StoryboardのUITableViewに直接UITableViewCellを追加する

下記画像のようにUITableViewCellをテーブルに追加します。

{% page_image -1.gif 320px %}


## セルと制御クラスを紐付ける

動画のようにStoryboard上のセルを選択して`Identity Inspectorタブ > CustomClass > Class`に制御クラスを入力します。  
今回は UserTableViewCell と入力します。動画のようにサジェストで入力補完されるのであっていればエンターを押してください。  
このとき下の`Module`が変わることを確認してください。ここも正しいModuleじゃないと見つけられずランタイムエラーになります。


<video autoplay loop muted playsinline src="/assets/videos/2019-09-26-ios-uitableview-uitableviewcell-customize-1.mp4" width="100%" height="400px"></video>

## セルをレイアウトする

追加方法は、通常のビュー追加と同じです。特に注意することはないと思います。

今回は次のようなレイアウトにしました。

{% page_image -3.png %}

## 制御クラスに実装する

制御したいビューは

1. イメージ
1. ラベル(左)
1. ラベル(右)

の3つになります。

コードだと次のようになります。

```swift
@IBOutlet private weak var iconImageView: UIImageView!
@IBOutlet private weak var nameLabel: UILabel!
@IBOutlet private weak var ageLabel: UILabel!

func setup(icon: UIImage, name: String, age: Int) {
    iconImageView.image = icon
    nameLabel.text = name
    ageLabel.text = String(age)
}
```

と名付けて前述した`UserTableViewCell`に追記します。

`setup(icon:name:age:)`メソッドは、決められたものではなく自分で用意したものです。
制御クラスからビュープロパティを出さずに目的を提供することで、使い手側の内部依存をなくすことが目的です。  
セルのカスタマイズには不要で、public化して直接外からビュー設定をすることも出来ますが、  
だからといって逸脱しすぎた実装をするのは好きではないので、このようなメソッドを用意しています。

### 注意：UITableViewCellが定義した名前は使えない

単純に `imageView: UIImageView` と名付けたくなりますが、
**UITableViewCellには予め定義されているため使うことができません。**

*UItableViewCell抜粋*
```swift
// Content.  These properties provide direct access to the internal label and image views used by the table view cell.  These should be used instead of the content properties below.
@available(iOS 3.0, *)
open var imageView: UIImageView? { get } // default is nil.  image view will be created if necessary.

@available(iOS 3.0, *)
open var textLabel: UILabel? { get } // default is nil.  label will be created if necessary.

@available(iOS 3.0, *)
open var detailTextLabel: UILabel? { get } // default is nil.  label will be created if necessary (and the current style supports a detail label).
```

## Identifierを定義する

Identifierとは次の画像の箇所を指します。

これはカスタムセル自体のIDを指します。

{% page_image -4.png 518px %}

ユニークであれば何でもいいのですが、制御クラス名にするのが慣習です。  
今回も`UserTableViewCell`にしてます。

ここのIDとコード側の指定が間違うと次のようなランタイムエラーが発生します。

```
*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'unable to dequeue a cell with identifier UserTableViewCell - must register a nib or a class for the identifier or connect a prototype cell in a storyboard'
```


## カスタムセルを使う

カスタムセルのビューを用意し、制御クラス(`UserTableViewCell`)も用意しそれらの紐付けも行いました。  
次は、それを実際に使います。主に見るべき場所は `func tableView(tableView:cellForRowAt:) -> UITableViewCell`内になります。

```swift
struct User {
    let icon: UIImage?
    let name: String
    let age: Int
}

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let users: [User] = [
        User(icon: #imageLiteral(resourceName: "icon") , name: "Angel", age: 20),
        User(icon: #imageLiteral(resourceName: "icon") , name: "Bob", age: 21),
        User(icon: #imageLiteral(resourceName: "icon") , name: "Chirs", age: 22),
        User(icon: #imageLiteral(resourceName: "icon") , name: "David", age: 23),
        User(icon: #imageLiteral(resourceName: "icon") , name: "Elly", age: 24)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell

        let user = users[indexPath.row]
        cell.setup(icon: user.icon ?? #imageLiteral(resourceName: "icon2"), name: user.name, age: user.age)

        return cell
    }
}
```

もしUITableViewの使い方がわからない場合は次の記事を確認してください。

{% post_link 2019-09-26-ios-uitableview-basic %}

### `struc User`: テーブル表示したいデータ構造

今回はユーザー情報を表示するので、それを表すモデルとして用意しました。  
本来の開発であれば、データモデルにUIKitデータとなるUIImageをオリジナルとして直接持つことはないのですが、  
今回の記事はそこを正すとコード量が増えて、目的を正しく伝えれずブレてしまうので、このような形にしてあります。

- `ViewController.users`にデータ元を用意してます。
- `#imageLiteral(resourceName: "icon")` は、`Assets.xcassets` 内のリソースを指定してあります。

`xcassets`については詳しくはこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-xcassets-basic %}

### セル参照の実装

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell

    let user = users[indexPath.row]
    cell.setup(icon: user.icon ?? #imageLiteral(resourceName: "icon2"), name: user.name, age: user.age)

    return cell
}
```

`cell.setup`は前述で説明した自前コードです。 このメソッドは`UserTableViewCell`で定義されています。このメソッドを使うために
その前のセル取得でキャストしてます。

Identifierに`UserTableViewCell`を指定してるのは、前述の `Identifier`を定義したときの値です。
これは一致している必要があります。

これを実行すると次の画像のようになります。

{% page_image -5.png %}

`Angel` の `g` が切れてます。これはセル内のUILabelの高さを調整するか, UILabelのStringではなくUIAttributedStringを使い、`baseline`を上げることで解決します。前者が楽です。

## 応用編

このままではまだ実践には耐えられないです。

### UITableViewCellをxibに分けて使う

今回は StoryboardのUITableView上に直接UITableViewCellを配置するケースで説明しました。
しかし、別画面で同様のセルを使いまわしたい場合など、画面毎にセルを用意するのはDRY原則違反になり、メンテナンス性が低下します。

そのため、xibファイルに分けることで流用性をあげます。詳しくはこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-xib %}

### コードで重複しやすい呼び出し処理を解決する

UITableViewCellのカスタマイズはとても多くの場面で使います。
比例してコードも増えるため、ボイラープレートと呼ばれる部分を共通化することで、コード量の増加を抑えつつも
手続きコードを分離できるためコードの可読性も期待できます。

詳細はこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-xib-optimaize %}

### セルの高さを可変にする

今回のサンプルではセルの高さをデフォルトの44のままにしてあります。

しかし実際のアプリでは、44固定であるわけもなく必ずカスタムの高さであったり、
同じセルでも中身によっては高さ幅が変わったりします。

その対応方法についてはこちらの記事に詳細を書いてあります。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-height-customize %}

### セル上にボタンやテキストフィールドを配置する

今回のサンプルではカスタマイズしたセルは全て参照UIのみでボタンやテキスト入力といったUIは使っていません。

しかし実際のアプリでは、プロフィール入力や設定変更といった画面ではUITableViewを使って、
項目別にフィールド編集がされます。

ただUIを配置するだけでいいと思ったら色々と細かい設定が必要になります。
そういった詳細はこちらの記事でまとめてあります。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-input-control %}

## さいごに

UITableViewCellのカスタマイズはiOSアプリ開発では必須スキルです。  
これを知らないとiOSアプリエンジニアと名乗る資格はないです。

それほど多岐にわたり使われています。

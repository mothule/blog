---
title: UITableViewのサイズ可変なセル内画像を非同期で単体更新する
description: UITableViewのUITableViewCell(セル)内のUIImageViewに設定する画像をサイズ可変で非同期で単体更新するにはLayoutConstraintとセル単体更新とIndexPathの取得方法が重要で実装方法についてまとめました。
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2020-05-09-ios-uitableview-cell-layout-update/0.png
---
キャッシュとLayoutConstraintとセル単体更新と`indexPath(for:)`を使います。

今回は、要件てんこ盛りなUITableViewのセル制御について説明します。
要件について整理します。

- セル内にUIImageViewがある
- 画像はネットから取得する
- 画像のサイズはバラバラ
- 画像取得が終わったセルのみを更新

## 実際に動いてる映像

要件だけだとイメージしにくいので実際に動いてるとこを見たほうが早いです。

{% page_image 1.gif 50% 画像サイズ可変 %}

セル表示時にhttps://placehold.jp/ からランダムな画像を取ってきて  
画像のアスペクトを維持して横幅をベースに表示しています。

今回は説明しやすいようにフェードやキャッシュ状態によるフェードやアニメなしかの表示制御といった処理は入れず一律アニメなしでセル更新を行っています。

## セルの可変な画像、非同期、単体更新のポイント

セル内の可変画像の対応は、画像ダウンロード後に画像比率を調べて、動的にAutoLayoutのAspectを使って可変にします。

非同期に関しては、色々と試しましたが、キャッシュを用いなければ実現はできないと思います。

単体更新は、`UITableView.reloadRows(at:,with:)`で実現できるのですが、 **渡すパラメータを間違うとクラッシュします。** 今回ここが一番の穴だと思います。

## レイアウトを構築する

今回ビューデータ側はなるべくシンプルに抑えてあります。

|ビューツリー|画面プレビュー|
|---|---|
|{% page_image 2.png %}|{% page_image 3.png %}|

ビューツリーを単純化するとこうなります。

- View
  - Table View
    - Table View Cell
      - Image View
      - Label

結構単純なレイアウトになっていることがわかると思います。

いくつかポイントを説明します。

- まずは、セル高さ幅が自動算出できるレイアウトを作ります。  
- UIImageViewは親セルやラベルに密着させます。  

自動算出できるレイアウトの組み方が分からない方は「{% post_link_text 2019-09-29-ios-uitableview-uitableviewcell-height-customize %}」を見てください。

### 重要ポイント
レイアウトの中で通常とは異なる設定をしている点とその理由について説明します。

- UIImageViewのConstraintの四辺いずれかの優先度を1000未満にする(下画像参照)
  - 画像ロード前でセル内の自動生成されるAutolayoutと衝突回避のため
- UIImageViewの高さはざっくり表示したい画像の高さ幅にする
  - セル高さが小さくなり一度に多量にセルが表示されて通信が発生します
  - 高さ幅を与えておくことで表示セル数を通常時と同じにできて無駄な通信を抑えます
- UIImageViewの高さも優先度を1000未満にしてください。(下図参照)
  - ここを1000のままにしてると画像がConstraintの高さ幅より長くても伸びなくなります。

2つの優先度を下げるとこうなります。

{% page_image 4.png 50% 優先度下げたConstraints %}

レイアウトの準備はこれで終わりです。

## UIViewControllerを実装する

まずUIViewControllerから説明します。
なぜならとても単純過ぎて説明するポイントが特にないからです。

```swift
class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 300
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sales.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.setup(sale: sales[indexPath.row], owner: tableView)
        return cell
    }
}
```

`sales`については表示用モデルとしてこのように定義してます。

```swift
struct Sale {
    let name: String
    let imageURL: String
}

let sales: [Sale] = Array(0..<100).map { _ in
    let w = Int.random(in: 300..<400)
    let h = Int.random(in: 200..<300)
    let url = "https://placehold.jp/\(w)x\(h).png"
    return Sale(name: "\(w)x\(h)", imageURL: url)
}
```

## 画像キャッシュ機構を構築する
簡易ではありますが、画像をキャッシュするクラスを用意します。この構造に従う必要はありません。各自独自のオンメモリキャッシュを活用してください。今回は画像ロードライブラリやデータ管理などを簡易させるために用意してあります。

```swift
class ImageCache {
    static var shared: ImageCache = .init()
    private let cacheSize = 20
    private let clearSize = 5

    private var cachedImages: [String: UIImage] = [:]

    func fetch(key: String) -> UIImage? { cachedImages[key] }
    func set(key: String, value: UIImage?) {
        cachedImages[key] = value

        if cachedImages.count > cacheSize {
            cachedImages.keys.shuffled().prefix(clearSize).forEach({ key in
                cachedImages.removeValue(forKey: key)
            })
            print(String(describing: self), #function, "Cleared some cache.")
        }
    }
}
```
URLをキーにUIImageをキャッシュしておくデータ構造です。  
実際の動きににせるため、キャッシュ処理時にキャッシュ数が上限超えたらいくつかランダムでキャッシュ画像をクリアする処理をいれてあります。


## テーブルセルを実装する

今回もっとも複雑なコードになります。

メソッドはそれぞれ次のときに呼ばれます。

- セル参照時に`setup(sale:owner:)`
- 画像ロード後に`onFetchedImage(image:table:)`

```swift
class TableViewCell: UITableViewCell {
    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    var imageAspect: NSLayoutConstraint!

    private var sale: Sale?

    func setup(sale: Sale, owner: UITableView?) {
        if let s = self.sale {
            guard s != sale else { return }
        }

        captionLabel.text = sale.name
        let url = URL(string: sale.imageURL)!

        mainImageView.image = nil
        URLSession.shared.dataTask(with: url) { [weak self] (data, res, error) in
            guard let data = data else { return }
            guard error == nil else { return }
            let image = UIImage(data: data)

            DispatchQueue.main.async {
                self?.sale = sale
                self?.onFetchedImage(image: image,
                                     table: owner)
            }
        }.resume()
    }

    func onFetchedImage(image: UIImage?, table: UITableView?) {
        guard let mainImageView = mainImageView else { return }

        if imageAspect != nil {
            NSLayoutConstraint.deactivate([imageAspect])
        }

        if let image = image {
            let aspect = image.size.height / image.size.width
            let constraint = NSLayoutConstraint(item: mainImageView,
                                           attribute: .height,
                                           relatedBy: .equal,
                                           toItem: mainImageView,
                                           attribute: .width,
                                           multiplier: aspect,
                                           constant: 0)
            NSLayoutConstraint.activate([constraint])
            imageAspect = constraint
        }

        mainImageView.image = image

        if let ip = table?.indexPath(for: self) {
            table?.reloadRows(at: [ip], with: .none)
            print("##", ip)
        }
    }
}
```


### コードを解説する

まず親テーブルがセル参照時に`setup(sale:owner:)`メソッドが呼ばれます。  
ここでテーブルセルに表示モデルと親テーブルを渡します。

`setup(sale:owner:)`メソッド内では、自身がキャッシュしてる表示モデル(`sale`)と同一か調べます。  
同一であれば表示状態は同じとみなして処理を終了します。

表示データが異なればURLSessionを使って画像データをダウンロードします。  
ダウンロードができたら、表示モデルをキャッシュした後に`onFetchedImage(image:table:)`を呼びます。

`onFetchedImage(image:table:)`ではまず登録中の画像アスペクト用Constraintを解除します。  
その後渡された画像のサイズ比率から新しく画像アスペクト用Constraintを登録します。

画像の表示設定が終わったら、最後は自身のセルを更新します。  
セルのIndexPathは`reloadRows(at:,with:)`で取得します。

#### 注意
**IndexPathをセル参照時のIndexPathをセル更新時に渡してもクラッシュを起こします。**

## まとめ

今記事執筆となった事の経緯は、画像サイズに依存しないテーブルセルを作りたかったためです。  
その上で課題となるのが、

1. 可変画像の対応方法
1. セル幅変更後の更新方法

この2点でした。

前者はConstraintの画像比率を使うことで実現可能なことは分かってました。  
後者はreloadDataを呼ぶと負荷がかかると思い、セル単体の更新方法について調べてました。  
結果的にできたからいいのですが、意外な問題となったのは、キャッシュの存在でした。

### キャッシュ必須性

もともとは、セルの更新都度に非同期で画像をダウンロードしてセルを更新させるつもりでした。

しかし、更新の都度非同期でセル操作を行うとテーブル表示が安定せずにセルの再表示が呼ばれ続けます。  
その結果、レイアウトは崩れ続け、ずっと非同期処理が走るという無限ループに陥りました。  
実際今回のコードでもキャッシュ処理をコメントアウトするとそれが再現されると思います。

実際の開発ではメモリ内キャッシュなしで動的に画像ロードを行うことはないとは思います。  
が、自分が想定していた挙動とは異なる結果を得ることができました。

#### 注意
今回のキャッシュモデルは実務ではとても耐えられない仕組みなのでご注意ください。
その理由は下記点となります。

1. キャッシュ期限がない
1. URLは同じでも画像は変更可能

今回キャッシュは、目的とは異なるため簡易化させています。

### スマートUIグレイ判定
UI、つまりビューにロジカルな処理を入れ込み完結させるのは、ビュー層にロジックが入るこむため、スマートUIとしてアンチパターンと言われてます。
今回はサンプルのためこのアンチパターンに片足突っ込んでいます。

- ビュー層以外の処理(インフラ層)が入ってる
- 画像の非同期ダウンロードは、他UIでも同様のニーズがある
- 拘ればエラーハンドリングが介入する

このような場合は、SDWebImageのようにライブラリ化して関心事を分離とDRY違反解決などが必要となります。

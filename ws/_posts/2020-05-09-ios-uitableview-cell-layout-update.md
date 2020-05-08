---
title: UITableViewのサイズ可変なセル内画像を非同期で単体更新する
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

- セル参照時に`setup(sale:owner:)`
- 画像ロード後に`onFetchedImage(image:table:)`

という流れになっています。

```swift
class TableViewCell: UITableViewCell {
    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    var imageAspect: NSLayoutConstraint!

    func setup(sale: Sale, owner: UITableView?) {
        captionLabel.text = sale.name
        let url = URL(string: sale.imageURL)!

        if let image = ImageCache.shared.fetch(key: sale.imageURL) {
            onFetchedImage(image: image, table: owner)

        } else {
            mainImageView.image = nil
            URLSession.shared.dataTask(with: url) { [weak self] (data, res, error) in
                guard let data = data else { return }
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    if let img = image {
                        ImageCache.shared.set(key: sale.imageURL, value: img)
                    }
                    self?.onFetchedImage(image: image,
                                         table: owner)
                }
            }.resume()
        }
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

まず、親テーブルがセル参照時に`setup(sale:owner:)`メソッド使って、テーブルセルに表示モデルと親テーブルを渡します。  
`setup(sale:owner:)`メソッド内では、表示モデル(`sale`)が持つ画像URLがキャッシュにないか調べます。
キャッシュヒットすれば画像を受け取り`onFetchedImage(image:table:)`を呼びます。

キャッシュになければURLSessionを使って画像データをダウンロードします。
画像ロードが終われば、キャッシュした後に`onFetchedImage(image:table:)`を呼びます。

キャッシュ有無問わず画像を得たら必ず`onFetchedImage(image:table:)`が呼ばれます。

`onFetchedImage(image:table:)`では、最初に保持している画像アスペクト用Constraintを解除した後に
画像のサイズ比率から新しく画像アスペクト用Constraintを登録します。

画像の表示設定が終わったら、最後は自身のセルのIndexPathを親テーブルから取得します。  
**このときにIndexPathをセル参照時のIndexPathをテーブルセルが保持しておいて、セル更新時に渡してもクラッシュを起こします。**  
親テーブルから取得したIndexPathを使って`reloadRows(at:,with:)`で更新します。

## まとめ：課題はキャッシュ必須性

今記事執筆となった事の経緯は、画像サイズに依存しないテーブルセルを作りたかったためです。
その上で課題となるのが、

1. 可変画像の対応方法
1. セル幅変更後の更新方法

この2点でした。

前者はConstraintの画像比率を使うことで実現可能なことは分かったのですが、後者はreloadDataを呼ぶと負荷がかかるだろうと思いセル単体の更新方法について調べてました。結果的にできたからいいのですが、以外な問題となったのは、キャッシュの存在でした。

もともとはキャッシュなしで画像をダウンロード後にセルを更新する処理を書いていました。
しかし、非同期でセル操作を行うとそのあとにセルの表示が荒ぶり、セルの再表示が繰り返し呼ばれ、ずっと非同期処理が走るという無限ループに陥りました。

実際今回のコードでもキャッシュ登録をコメントアウトするとそれが再現されると思います。

実際の開発ではメモリ内キャッシュなしで動的に画像ロードを行うことはないとは思いますが、自分が想定していた挙動とは異なる結果を得ることができました。

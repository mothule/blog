---
title: 【初心者向け】UICollectionViewでCarousel(カルーセル)を実装する
categories: ios uicollectionview
tags: ios uicollectionview
image:
  path: /assets/images/2019-10-12-ios-uicollectionview-carousel-simple/1.png
---
UICollectionViewを使ったCarousel(カルーセル)を実装します。

カルーセルとは横にバナー画像が並んだ画像ビューワーです。
主な用途として期間中のキャンペーンバナーの表示として使われます。

色々な実装方法がありますが、今回はとにかくシンプルを優先して実装します。

なお記事中の解説画像は[Placeholder.com](https://placeholder.com)で生成したものを使っています。

## 実装する

今回実装するのは次のようなカルーセルです。

背景色は識別用に出しているだけなのでデフォルトに戻しても問題ありません。

{% page_image 3.gif %}

### storyboard

{% page_image 2.png %}

縦幅を変えられるように`UICollectionView.height`の`Constraint`を取ってあります。  
この時値は仮で200を渡してあります。

### コード

```swift
let images: [UIImage] = [
    UIImage(named: "image1")!,
    UIImage(named: "image2")!,
    UIImage(named: "image3")!,
    UIImage(named: "image4")!,
    UIImage(named: "image5")!,
    UIImage(named: "image6")!,
    UIImage(named: "image7")!
]

class ViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = collectionView.bounds.size
        collectionView.collectionViewLayout = layout
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
}

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet  weak var imageView: UIImageView!
}
```

`viewDidLoad` ではなく `viewDidLayoutSubviews` に実装してるのは、画面回転に対応するためです。

`itemSize` を UICollectionViewのサイズと同じにすることで1スクリーンに1セルになります。

あとはこれを横スクロールにすれば、カルーセルの完成です。

よりカルーセルらしく見せるには画像の比率を合わせることで余白がなくなりそれっぽく見えます。


## まとめ

UIデザインパターンの1つで、ECサイトやキュレーションサイトなど様々なサービスで使われやすいデザインなので覚えておいて損はないと思います。

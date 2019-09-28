---
title: 【初心者向け】UITableViewCellの再利用を理解する
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-26-ios-uitableview-lifecycle.png
---
UITableViewCellは再利用セルとして使われていますが、どういった感じで再利用されているかイメージついてる初心者は少ないかと思います。

なので少しでもイメージがついて再利用の利点が分かることで、より一層理解が深まると思います。

## いつ再利用されるのか？

**セル参照時です。**

つまり `func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell` メソッドが呼ばれるときです。

なぜなら内部で、 `tableView.dequeueReusableCell(withIdentifier:)`メソッドが呼ばれており、このメソッドがIDをキーにインスタンスを参照しているためです。

## ではセル参照はいつ呼ばれるのか？

**セルが画面に表示される直前です。**

次のコードのように表示するデータをログとして出力するようにします。

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print(#function + "\(items[indexPath.row])")
    // ...
}
```
これを実行すると、下記画像のタイミングで次のログが出力されます。
```
tableView(_:cellForRowAt:)4
```

数字の4が呼ばれていることが分かります。  
つまりこれは画面に表示される直前です。
{% page_image -1.png %}


## どうやって再利用してるか調べるか？

前提としてUITableViewCellは再利用されています。
といっても実際に確認しないと分かりません。

ということで次の方法で検証します。

- 再利用してるならメモリ解放されないはず、つまりinitの呼ばれる回数は限られている
- 再利用してるなら最後に利用したセルの状態が残っている
- `UITableViewCell.prepareForReuse()`が呼ばれている

この3つで再利用されていることを検証します。

### 再利用してるならメモリ解放されないはず、つまりinitの呼ばれる回数は限られている

もしセルが再利用されていないのなら、たくさんのinitが呼ばれているはずです。
セルが利用されているなら、画面表示に必要な数程度しか呼ばれないはずです。

### 再利用してるなら最後に利用したセルの状態が残っている

再利用する前に最後の状態が残っているはずです。

例えばアルファベットのデータの場合だけセルの背景色を変えていれば、
数字のデータを表示したときに、背景色が残っているはずです。

### `UITableViewCell.prepareForReuse()`が呼ばれている
[Apple公式](https://developer.apple.com/documentation/uikit/uitableviewcell/1623223-prepareforreuse)によると、再利用可能なセルを準備するときに呼ばれるようです。

またこのメソッドは `dequeueReusableCell(withIdentifier:)`メソッドを呼ぶと呼ばれるようです。
デフォルト動作では、アルファ値、編集状態、選択状態などコンテンツに無関係なセル属性をリセットしているみたいです。

## 検証コードを実装する

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let items: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#function + "\(items[indexPath.row])")
        let ret: MyTableViewCell

        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? MyTableViewCell {
            ret = cell
        } else {
            ret = MyTableViewCell(style: .default, reuseIdentifier: "cell")
        }

        if Int(items[indexPath.row]) == nil {
            ret.backgroundColor = UIColor.red
        }

        ret.textLabel?.text = items[indexPath.row]
        return ret
    }
}

class MyTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print(#function)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        print(#function)
    }
}
```

基本的なUITableViewの使い方です。分からない場合はこちらで解説してあります。
{% post_link 2019-09-26-ios-uitableview-basic %}

加えて2点コード追加があります。

### UITableViewCellのサブクラス
`MyTableViewCell`という`UITableViewCell`を継承したクラスを用意しています。
これはセルのカスタマイズと違って、単純にinitとprepareForReuseメソッドをオーバーライドするためだけに用意しました。

セルのカスタマイズに関してはこちらをどうぞ。
{% post_link 2019-09-26-ios-uitableview-uitableviewcell-customize %}

### 整数以外は赤色にする
```swift
if Int(items[indexPath.row]) == nil {
    ret.backgroundColor = UIColor.red
}
```
データが整数以外、アルファベットならセル背景色を赤色にします。
整数の場合は**何もしません**

## 実行してみる

実際に前述したコードを実行して動かしてみました。

### 動画を見る
最初は白色だった背景が、一度赤色にして戻ってきたら、赤色になっていることが分かります。
セルを赤色にしてるのは、アルファベット時のみなので、再利用していることが分かります。

<video autoplay loop muted playsinline src="/assets/videos/2019-09-26-ios-uitableview-lifecycle-1.mp4" width="100%" height="100%"></video>

### 出力されたログを見る
次にログを抜粋しました。  
画面表示に必要なセル数がinitされた後、再利用されているのが分かります。
```
tableView(_:cellForRowAt:)1
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)2
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)3
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)4
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)5
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)6
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)7
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)8
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)9
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)a
init(style:reuseIdentifier:)
tableView(_:cellForRowAt:)b
prepareForReuse()
tableView(_:cellForRowAt:)c
prepareForReuse()
tableView(_:cellForRowAt:)d
prepareForReuse()
tableView(_:cellForRowAt:)e
prepareForReuse()
tableView(_:cellForRowAt:)f
prepareForReuse()
tableView(_:cellForRowAt:)7
prepareForReuse()
```

## 再利用していることが分かった

検証結果を振り返り、再利用していることが分かりました。

セルは画面を埋め尽くす程度の数だけインスタンスは用意され、  
スクロールすることでスクロールアウトするセルをスクロールインするセルに再利用していました。

このことから次のケースは使用メモリが増えることが分かります。

- セル高さが狭い
- スクリーン解像度が高い
- セル種類数が多い

### セル高さが狭い
スクリーンを埋め尽くすためのセル高さ幅が小さいとそれだけ必要になるセル数は増え、確保するインスタンスは増えます。

### スクリーン解像度が高い
こちらもセル高さ同様です。

### セル種類数が多い
今回はセル種類数は1種類ですが、これが複数種類になるとそれだけインスタンス数は増えます。
最大で2種類なら2倍です。これはそのセルがどういった並びになるのかに依存します。


### バグ解決のヒントになる

別観点として再利用してることで前の状態が残るので、想定とは異なるビュー状態になります。

今後似たような症状が起きた場合は、再利用によるセルリセットし忘れを疑うことができるようになります。

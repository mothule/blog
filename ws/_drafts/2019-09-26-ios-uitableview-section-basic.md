---
title: 【初心者向け】UITableViewのSection(セクション)の使い方
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-09-26-ios-uitableview-section-basic/2019-09-26-ios-uitableview-section-basic.png
---

あまり使う機会の少ないと油断してると、必要性が急上昇するSection（セクション）です。
Section(セクション)を使うとどうなるのか？どういった見た目になるのか？注意点や使い所に関して説明します。

## UITableViewのおさらい

テーブルはヘッダー、フッター、SectionとRowに分かれています。

そしてSectionごとにもヘッダーとフッターがあります。


### Section(セクション)とは？Row(ロウ)とは？

{% page_image -1.png 182px %}

- Row(ロウ)とはセル
- Section(セクション)とはRow(ロウ)をまとめたグループ

## Section(セクション)を増やす

`UITableViewDataSource` の `func numberOfSections(in tableView: UITableView) -> Int` を実装し、返した値がセクション数になります。

`func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int` は `numberOfRowsInSection section: Int` がSection(セクション)になります。

`func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell` は `indexPath: IndexPath`の　`IndexPath.section` がSection(セクション)になります。

### 実装してみる

```swift
class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let addresses: [[String]] = [
        ["A1", "A2", "A3", "A4", "A5"],
        ["B1", "B2", "B3", "B4", "B5", "B6"],
        ["C1", "C2", "C3", "C4", "C5", "C6", "C7"],
        ["D1", "D2", "D3", "D4", "D5", "D6", "D7", "D8"],
        ["E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8"],
        ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9"],
        ["G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return addresses.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ret = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")
        ret.textLabel?.text = addresses[indexPath.section][indexPath.row]
        return ret
    }
}
```

### だけど変化が見えない

{% page_image -2.gif 50% %}

内部的には異なっていても見た目が同じなので変化がありません。

しかし、Sectionにヘッダーとフッターを増やすことで変化が生まれます。

## Section(セクション)ヘッダーとフッターを増やす

最初に書いたようにSectionにはヘッダーとフッターがあります。

それを追加するにはヘッダーとフッターそれぞれ次のメソッドを実装が必要です。

- `func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?`
- `func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?`

### 実装してみる
次のコードを前述したコードに追記します。

```swift
func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let char = addresses[section].first?.first {
        return String(char)
    }
    return ""
}

func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if let char = addresses[section].last?.first {
        return String(char)
    }
    return ""
}
```

### セクションの境目が見えるようになった

表示中のセクションのヘッダーとフッターに情報を与えたことで、セクションの境目が見えるようになりました。
{% page_image -3.gif 50% %}

#### グルーピング

Section(セクション)には種類があります。

{% page_image -5.png 50% %}

赤線の中を「`Grouped`」にして実行すると、次の動きになります。

違いに気づきますか？

{% page_image -4.gif 50% %}

- ヘッダーとフッターの**高さ幅が少し広がった**
- ヘッダーとフッターが**追従しなくなった**
- フォントウェイトが**小さくなった**

どちらがいいというものはありません。

## SectionIndexView(セクションインデックスビュー)を表示する

SectionIndexView(セクションインデックスビュー)とは、次の画像のように画面右にSection(セクション)ごとに表示するビューです。

{% page_image -6.png 214px %}

### 実装してみる

次のコードを前述したコードに追記します。

```swift
func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return addresses.map { array in
        if let char = array.first?.first {
            return String(char)
        }
        return ""
    }
}
```

### 表示されるようになる

<video autoplay loop muted playsinline src="/assets/videos/2019-09-26-ios-uitableview-section-basic-6.mp4" width="100%" height="100%"></video>

動画を見ると分かりますが、ビューをタップするとそのセクションに飛びます。

### セクションインデックスラベルの文字色を変える

{% page_image -7.png 238px %}

この画像のように文字色を変えたい場合は、次のコードを入れるだけでセクションインデックスの文字色が変わります。

```swift
tableView.sectionIndexColor = UIColor.red
```

### セクションインデックスラベルの背景色を変える

{% page_image -8.png 280px %}

この画像のように背景色を変えたい場合は、次のコードを入れるだけでセクションインデックスの背景色が変わります。

```swift
tableView.sectionIndexBackgroundColor = UIColor.blue
```

### セクションインデックスラベルのトラッキング中の背景色を変える

トラッキング中とはタップしたまま移動させることをいいます。

セクションインデックスビューはタップだけでなくトラッキングすることで、次のようにセクション間をスムーズに移動することができます。

{% page_image -9.gif 320px %}

このようにトラッキング中の背景色を変えたい場合は、次のコードで変更できます。

```swift
tableView.sectionIndexTrackingBackgroundColor = UIColor.magenta
```


## セクションヘッダーとセクションフッターをカスタマイズする

デフォルトで用意されているヘッダーとフッターのフォントまたはビューでは要件を満たせない場合、カスタマイズが必要になります。

その場合はこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-section-header-customize %}



## 実業務でのSection(セクション)の使い所

Section(セクション)は分類が異なるデータを分ける場合に重宝します。

詳しくはこちらの記事をどうぞ。

{% post_link 2019-10-14-ios-uitableview-actual-practice %}

## 終わりに

Section(セクション)はUITableViewにおいて使い方にセンスが求められる機能だと思います。

単純に全てのセルを1セクション内で完結し、データの構造やアクセスを工夫することでSection(セクション)を使わずに実装することも可能です。

それとは別に、SectionIndexView(セクションインデックスビュー)を活用する場面となると必須機能になります。

もちろんどちらの用途であれば覚えといて損しないです。

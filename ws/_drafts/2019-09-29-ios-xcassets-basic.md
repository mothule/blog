---
title: 【初心者向け】Assets.xcassetsを理解して使う
categories: ios
tags: ios
image:
  path: /assets/images/2019-09-29-ios-xcassets-basic.png
---

## 登場以前
プロジェクトファイルに直接画像ファイルを登録していたため、チーム開発するとプロジェクトファイルの衝突が多発してた。

解像度別画像(x2)の管理が面倒で、x2版 x1版どちらのファイルをロードすればいいか分からなくなることもあった。

## Asset Catalogのメリット
- 画像追加によるプロジェクトファイルのコンフリクトがなくなる
- デバイスサイズ毎の画像管理が分かりやすくなる
- 起動イメージ, アプリアイコンも管理できる
- あらゆるアセットデータが管理できる

Xcode10では次のアセットを管理できる。

{% page_image -1.png 50% %}

使い方は簡単で+ボタンを押せば上記メニューが表示されるので、該当する種類を選べば追加される。

{% page_image -7.png 156px %}


管理方法は名前になっており、例えば Image set で icon という名前があれば

{% page_image -8.png %}

```swift
UIImage(named: "icon")
```
でロードできる

加えて、Interface builder上でも選択できる

{% page_image -2.png 50% %}

## Image set
- 解像度別画像管理
- 画像スライス
- 中心点変更

### 端末別解像度別で画像を分けれる

{% page_image -9.png 50% %}

上記画像のように Image Set には　`Devices` というプロパティがあり、デバイス毎にどの画像を使うのかを指定することができる。
指定がされていないDeviceはUniversalが使われる。

また 1x, 2x, 3x と端末の解像度毎に使われる画像も指定ができる。

### 画像スライス

画像スライス機能があり、画像をマスキングした部分を取り除いた画像をビルド生成してくれる。

<video autoplay loop muted playsinline src="/assets/videos/2019-09-29-ios-xcassets-basic-1.mp4" width="100%" height="400px"></video>

生成された画像は次のようになる。 中心点の編集は活用ケースは多くありそうだが、スライスはいまいち。

{% page_image -3.png %}

スライス情報はAttribute Inspectorの一番下で確認できる

{% page_image -4.png 50% %}

スライス軸は縦,横,両方がある。
取り消す場合はNoneを選ぶと解除できる。

{% page_image -5.png 50% %}

## Color Set

{% page_image -10.png %}

Color set とは色のセットであり、**コードとInterface Builder** で色を統一できる。  

例えば `HogeColor` という名前だったら Interface Builder 上では次のように指定が出来る

{% page_image -11.png 75% %}

Color set でアプリで使うカラー一覧を定義しておくことで、色の変更がUIを触らずAsset Catalogで完結する。  
これも別ファイルとなるので、色変更によるxibやstoryboardの改修衝突が発生しない。

コード上では次のように `UIColor(named:)`で指定できる
```swift
label.textColor = UIColor(named: "HogeColor")
```

### Appearances で Dark/Light ごとに色を変えれる

iOS13からDarkモードが追加されたが、DarkかLightによって使う色を変えることも可能となっている。


{% page_image -12.png 75% %}


### High Contrastでコントラストを上げた環境が追加されるはず

こちら試したがうまく動かず。もしかしたら何か間違えているのかもしれない。

{% page_image -13.png 75% %}

## Data Set

画像だけでなく音楽データやテキストデータといったリソースなら何でも管理できるようになった。
登録は Data set を選び、Drag and Dropで登録するだけ。

利用する場合は、次のコードで使うことができる。  
Nugaという名前で中身にテキストファイルを入れてある。
```swift
if let asset = NSDataAsset(name: "Nuga") {
    let text = String(data: asset.data, encoding: .utf8)
    print(text)
}
```


## アセットを有効活用しよう

以上のように様々なデータを集合管理することができて、管理方法も変更がコンフリクトしにくいファイル設計になっている。

そしてここで定義したデータがInterface Builderで使えるなど連携が出来ることから、使わないメリットはないので積極的にここを使っていくべきです。

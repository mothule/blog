---
title: 【初心者向け】UITableView separator(区切り線)を色々試す
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-10-08-ios-uitableview-separator-basic/5.png
---
UITableViewのseparator(区切り線)は


## separator(区切り線)を消す

### 全セルのseparator(区切り線)を消す

{% page_image 1.png %}

```swift
tableView.separatorStyle = .none
```

### 指定セルのseparator(区切り線)を消す

{% page_image 2.png %}

次のコードは、1つ目のセルの下の区切り線を消しています。

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  // ...
  if indexPath.row == 0 {
      cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 10000)
  }
}
```
右側のインセットを画面を超えるような大きな数字にすることで線を画面外に飛ばし実質消しています。  
注意点として `left` にすると文字のインデントまでずれるので `right` になります。


もしテーブルの使い方が分からない場合は、こちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-basic %}

## 左余白をなくす

{% page_image 3.png %}

```swift
tableView.separatorInset = .zero
```

前述した区切り線を消す要領と同じです。デフォルトでは `left`が15になっています。

またInterface builder上で消す場合は次のプロパティで操作できます。

{% page_image 4.png 50% %}

デフォルトでは `Separator Inset`が`Automatic`になっているので`Custom`にすると項目が表示されます。

### 指定セルの左余白をなくす

前述した区切り線を消すと同じ要領です。`left`を0にするだけです。
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  // ...
  if indexPath.row == 0 {
      cell.separatorInset = .zero
  }
}
```

## 色を変える

{% page_image 5.png %}

次のコードは線を赤色に変えてます。

```swift
tableView.separatorColor = .red
```

なおセル単位では用意されていないため、デフォルトのseparatorは消して自前のseparatorを用意する必要があります。

## 線を太くする

デフォルトの機能では線を太くする機能はありません。  
自前でseparatorを用意する必要があります。

## 線なれど侮るなかれ

たかが線ですが、デザインにおいて情報の見せ方で線のありなし、線のインセットで情報整理を行うのがデザインの基本です。

そのためデザイナーからあげられるデザインにはセル単位で線の制御が入ることがあります。

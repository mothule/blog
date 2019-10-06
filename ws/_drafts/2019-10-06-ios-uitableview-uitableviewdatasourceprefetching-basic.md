---
title: 【初心者向け】テーブルのセルデータをプリフェッチする UITableViewDataSourcePrefetchingで事前処理して最適スクローリングする
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-09-18-ios-swift-rxswfit-basic.png
---
UITableView(テーブル)には表示するUITableViewCell(セル)には様々な情報が乗せることが可能です。

テーブルの特性からしても大量のデータを表示することに適しておりユーザーもまたそれを望んでいます。

しかしセル表示処理に負荷がかかるとスクロールにカクツキやFPS低下がおき、快適なスクロールにストレスが生じます。

今回はそれを解決する一つのアプローチ法となる事前処理が可能となる `UITableViewDataSourcePrefetching` を実装します。

## 重いセルとは
実務で最もポピュラーな重いセルとは、セル内の情報がネットワーク先にあるセルです。

例えばセルに画像(UIImageView)と名前(UILabel)と説明(UILabel)があったとしたら、サーバーサイドから画像URL, 名前, 説明の情報を受信後に
画像URLに対して画像としてデータをダウンロードします。

画像ダウンロード後、それぞれのデータが揃うことでセルにデータが表示されます。

これでサーバーサイドへの通信負荷により遅延が起きるなどすると、セルはあっと言う間に重いセルとなります。

## 重いセルを再現する

では重いセルを再現するために擬似環境を実装します。



## UITableViewDataSourcePrefetchingを実装する

### 挙動を確認する

### 事前処理を行ってみる

### 結果

## UITableViewDataSourcePrefetchingのリスク
下スクロールを突然上スクロールにすると、ロード不要なセルの事前情報に対して処理を行うので、無駄な処理をしてしまいます。

無駄な処理だと分かったタイミングで処理を中断(キャンセル)が必要になります。

`UITableViewDataSourcePrefetching` では `tableView(_:cancelPrefetchingForRowsAt:)` がキャンセル時に呼ばれるのでこのメソッドでキャンセル処理を行わないと、無駄な処理が完遂まで走り続けます。

### キャンセル処理を実装する


## UITableViewDataSourcePrefetchingは必須で使うべきか？

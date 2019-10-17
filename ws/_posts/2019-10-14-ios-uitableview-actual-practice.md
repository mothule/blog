---
title: 【初心者必見】UITableViewの実践デザイン分析
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-10-14-ios-uitableview-actual-practice/0.png
---
UIKitの基本的な使い方を理解したが、App Storeにあるアプリを実際にどうやって作られているのか分析できない向けの記事です。

App Storeに登録されているアプリには様々なデザインがあります。
今回はUITableViewを使ってどのように実装されるのかをこの記事で説明します。

**基本は覚えたけど、どう実装すればいいのか分からない人** にはとても価値ある記事になると思います。

## この記事の読み方

- よくあるレイアウトの確認
- 分析フェイズ
- 実装フェイズ

## 実装するサンプルの動画

解説に使ったサンプル実装の動かしたときの動画になります。

<video src="/assets/videos/2019-10-14-ios-uitableview-actual-practice-1.mp4" playsinline muted autoplay loop width="100%" height="400px">
　<source src="movie/movie.mp4" type="video/mp4">
　<source src="movie/movie.webm" type="video/webm">
</video>


## よくあるレイアウト

今回はApp Storeに上がっているいくつか複数のアプリをピックアップして、だいたい共通しているレイアウトなどを模様した架空のレイアウトを用意しました。

{% page_image 1.png 50% %}

このレイアウトをUITableViewベースで実装していきたいと思います。
なお無理にUITableViewにこだわらずともUIStackViewやUICollectionViewでも実装は可能ですが、今回はUITableViewベースで話を進めます。


## 分析フェイズ

いきなり実装に入らず、まずはどのようにテーブルのセルやセクションを分けるのか考えます。

このレイアウトはテーブルで構築することができます。

次のイメージのようにセルやセクションを今回は分けます。

{% page_image 2.png 50% %}

### なぜ Section Header は使わないのか？

UITableViewはデフォルトだとSectionを表示中の間は、Section Headerが画面上部に残ります。  
残したい場合は Section Header で実装でいいと思います。

しかし大体は残らないようにして欲しいとデザイナーからの要望は多いので、セルとして実装しています。  
またSection Header内にボタンなどがあるので、セルの方が実装がシンプルになる場合もあります。

UITableViewではStyleをGroupだとSection Headerは残らないのですが、不要な余白が生まれるので私はセルで実装することが多いです。

### セル数が可変する場合はセクションを分けるといい

今回はセクション内のセル数がデータなどで可変するレイアウトはありませんが、

例えば、最後の「おすすめ」↓ が可変の場合は、ヘッダーセルと商品セルを別セクションにすると、制御がしやすくなります。

{% page_image 3.png %}

## 実装フェイズ

分析にて必要なセルのレイアウトや制御クラスは分かったと思います。次は分析結果を元に実装していきます。

なお今回の実装コードは量が多いためGitHubにあげてあります。

[mothule/uitableview-base-layout](https://github.com/mothule/uitableview-base-layout)

GitHubのコードを落としてXcodeと記事両方を開くことを推奨します。

## storyboardでレイアウトに必要なセルを作成する

{% page_image 4.png %}

こんな感じでセルを用意します。

## ファイル構成

{% page_image 5.png 50% %}

いくつか抜粋して説明します。

### ViewModel.swift  
ネットでよくあるRxSwiftを使ったものではありません。純SwiftによるViewModelになります

### SectionType.swift  
UITableViewのセクション定義になります。Rowの定義は用意していません。Rowの並び順が変わるなど、Section内がより複雑になるのであればあったほうがいいです。

### DataSource.swift  
`UITableViewDataSource` と `UITableViewDelegate` を採用したクラスです。  
こちらに関しては次の記事が参考になります。

{% post_link 2019-10-06-ios-uitableview-uitableviewdatasource-separate %}

### Viewsフォルダ以下
UITableViewやUICollectionViewのセル制御クラスになります。

UITableViewの基本に関して分からない場合はこちらの記事をどうぞ。

{% post_link 2019-09-26-ios-uitableview-basic %}

またUICollectionViewに関してはこちらの記事が参考になります。

{% post_link 2019-10-12-uicollectionview-in-table %}

### Item.swift
今回唯一のモデルクラスです。  
と言っても今回はUIの話なので、特にロジックはなくただのデータ構造クラスです。

### Nibable.swift

UITableViewやUICollectionViewのポイラープレートを収束させたクラスです。  
詳しくはこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-xib-optimaize %}

### ApiClient.swift

API通信クライアントです。しかし今回は実際に通信はしておらず別スレッドで待機後にダミーデータを返すようにしてあります。  
またここは力入れてないので、DataレイヤーでありながらItemクラスを直接使ってサボってます。

## クラス構成

重要な部分のみ抜粋します。

{% page_image 6.png 267px %}

### ViewController

おなじみ画面制御クラスです。
このクラスが `ViewModel` と `DataSource` のスコープ管理をしています。

### DataSource
`ViewController` によってスコープ管理されています。  
`ViewModel`は参照用で、スコープ管理はしていません。  
しかし`ViewModel`のスコープは`DataSource`と同じである保証が`ViewController`によってスコープ保証されているので、弱参照にはしていません。

### ViewModel
アクション処理とそれに関連するイベント発行をしています。 イベント発行は `ViewModelDelegate`を介して受け取ることができます。  
`ViewController`が`ViewModelDelegate`を採用して、イベントを受け取るようにしています。

## クラス間のメッセージ通信方法

クラス分離することによりクラス間のメッセージ通信について気になると思うので、まとめました。

### ViewController <-> ViewModel

*ViewController -> ViewModel* は `ViewModel`のメソッド  
*ViewController <- ViewModel* は前述したように `ViewModelDelegate` でメッセージやりとりしています。

### DataSource <-> 各Views

*DataSource -> Views* は 各Viewsのsetupメソッド  
*DataSource <- Views* は 各Viewsが持つクロージャによるコールバックでメッセージやりとりしています。

### ViewController <-> DataSource
*ViewController -> DataSource* は `DataSource`のメソッド  
*ViewController <- DataSource* は `ViewModel`を介しています。

### DataSource <-> ViewModel
*DataSource -> ViewModel* は `ViewModel`のメソッド  
*DataSource <- ViewModel* はありません。 `ViewController` 側に集約させています。  
こうした理由は `DataSource`はUITableViewの制御であって、イベント制御ではないためです。  
「セルがタップされた」などユーザー発火イベントはViewControllerの責務になるので、こっちに集めるようにしています。

## 実は基本の組み合わせ
実はこのブログのUITableViewの記事を読んでいれば、今回の実装はほとんどが簡単な組み合わせになります。  

難しいように見えて簡単です。ただ手間なだけですね。

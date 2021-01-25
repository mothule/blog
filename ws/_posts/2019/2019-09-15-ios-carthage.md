---
title: Carthageの使い方を体系的に理解する
description: iOSのCarthageのインストールやCocoaPodsとの違いやメリット長所やデメリット、Cartfileの書き方や注意点やバージョン指定方法やupdateとbootstrapの違いやテストライブラリ管理など実務に必要な知識を体系的に説明します。
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2019-09-15-ios-carthage/eyecatch.png
---
ライブラリ管理ツールとして市民権を得て暫く経つCarthageですが、  
次のケースに該当する方もいると思います。

## はじめに

### 対象読者

- 使う機会がなかった人
- 個人利用はあるが会社ではまだの人
- iOS/Swiftに入門したての人

### 記事の内容
Carthageの基礎から利用、そして運用など、  
実務で必要な知識を体系的に説明します。

- 基本情報
- 導入手順
- git管理について
- デバッグ環境
- ライブラリのバージョン制御
- ライブラリの更新
- テスト用ライブラリ
- 新しいバージョンを確認する
- GitHub以外のライブラリ

### 記事の読み方
1記事に収まらないボリュームのため、複数の記事に分けてます。  
分けた記事はこの記事からリンクで追跡できます。合わせてお読みください。

### 注意点
この記事の内容は、主に実務から得た知見ベースです。  
iOSアプリに主軸を置いて説明しています。

## Carthageの基本情報

- Carthageとは何か？
- なぜCocoaPodsと比較されるのか？
- メリットとデメリットは何か？

CocoaPodsとの違いで方針を知りましょう。

### Carthageの読み方
[Wikipedia](https://ja.wikipedia.org/wiki/カーセッジ)だと`カーセージ`と`カルタゴ`の２つあります。  
作者の出身や公式ロゴ背景から考えて`カルタゴ`な気がしますが、  
呼びやすい方でいいと思います。

### Carthageとは？

Swift製の**Cocoa用ライブラリ管理ツール**です。

機能は大きく2つです

- ライブラリ毎の.frameworkを作成と更新
- ビルド時の.frameworkコピーをサポート

なお、プロジェクトへの追加は手動です。

### CarthageとCocoaPodsの違い
2つの違いは「手軽」と「柔軟」です。  
簡単に説明します。

#### CocoaPodsは使いやすさ重視

- Xcodeワークスペースを自動作成・更新
- ライブラリのビルドからリンクまで統合

#### Carthageは柔軟性と独立性を重視

- フレームワークをビルド
- Xcodeプロジェクト操作をしない
- ライブラリのリンクはしない

### Carthageのメリットとデメリット

- メリット
  - CocoaPodsよりビルド時間が短い
  - Xcodeの仕様変更に影響されにくい
- デメリット
  - CocoaPodsより対応ライブラリが少ない
  - CocoaPodsより導入とフレームワーク管理が面倒

#### CocoaPodsより対応ライブラリが少ない

CocoaPodsと比べると、対応ライブラリは多く印象です。  
使用ライブラリがCocoaPodsしか対応していないことはよく目の当たりにします。

#### CocoaPodsよりビルド時間が短い

測定結果によると、CarthageはCocoaPodsよりビルド時間が半分近く短いです。

詳細と残りのメリット・デメリットは「{% post_link_text 2020-05-14-ios-carthage-vs-cocoapods %}」にまとめてあります。


## Carthageの導入手順

CarthageのMacへのインストールも含めると大きく4手順になります。

1. HomebrewでCarthageインストール
1. Podfile作成と編集
1. Podfileからframework作成
1. frameworkリンキングとコピー

これら手順毎に説明すると記事ボリュームが大きくて読みにくいので  
別記事として「{% post_link_text 2020-05-14-ios-carthage-install-guide %}」にまとめてます。


## Carthageのgit管理について
`carthage update`が生成したデータは、**全てをgit管理する必要はありません。**  
git管理下には別PCでも環境再現ができればいいのですから、  
最低限で言えば`Cartfile.resolved`だけで環境の再現は可能です。  
しかしそれだと大抵はCIで困ることが起きます。  
詳細は「{% post_link_text 2020-05-15-ios-carthage-team-collaboration %}」にまとめてます。


## Carthageのデバッグ環境について
fromeworkをDebug Configurationでビルドする必要があります。

Xcodeでは他環境で作成されたframeworkをステップ実行できません。
またビルドConfigurationがReleaseだとコンパイラがコード最適化することでコードと実際のステップ数に違いが起きたり変数が使えなくなります。
ライブラリによってはGitHubなどに既にビルド済みのフレームワークが用意されており、  
Carthageは特に指定がなければそれを使ってインストールして時間短縮を行っています。
しかし大抵はRelease Configurationでビルドされているため、ステップ実行はできません。

手元でかつDebug Configurationでビルドすればステップ実行できるようになります。  
Build Configurationを指定するには、**--configuration** オプションを使います。

```sh
$ carthge update --platform iOS --no-use-binaries --configuration Debug
```
`update`ではなくとも`bootstrap`でも大丈夫です。

またBuild ConfigirationがReleaseなどでコード最適化されている場合は、ステップ実行すると次のログがコンソールに表示されます。

> SwiftyJSON was compiled with optimization - stepping may behave oddly; variables may not be available.

## Carthage管理下ライブラリのバージョン制御について
ライブラリを導入すればバージョン制御が必要になります。  
Carthageでライブラリを導入してる場合の新規登録時や更新時などのバージョン制御があります。

例えば次のようなCartfileでバージョンを指定することが出来ます。
```
github "SwiftyJSON" ~> 4.2.0
```

詳しくは「{% post_link_text 2020-05-17-ios-carthage-cartfile-format %}」にまとめてあります。

## Carthage管理下のライブラリの個別更新

ライブラリが更新されたらCarthageにはライブラリを更新するコマンドが用意されています。  
例えば次のシェルはこのような意味になります。

- `SwiftJSON`と`APIKit`を更新
- GitHubなどにアップロード済みのzipなどを使わず、コードから
- iOSプラットフォームだけを対象

```sh
$ carthage update SwiftyJSON APIKit --platform iOS --no-use-binaries
```

`--platform iOS`はiOSアプリでしか使わないのであれば他プラットフォーム用ビルドをしても意味ないので、  
その場合はこのオプションをつけます。

`--no-use-binaries`はGitHubにビルド済みがアップロードされてる場合はそれを使おうとするので、  
それを使わずコードからビルドしたい場合はこのオプションをつけます。  
バイナリ使ったほうが更新処理は早いのですが、  
もしアップロードされてるSwiftバージョンが異なったりするとエラーとなるので、  
そこが気になるならこのオプションをつけといたほうがいいです。  
少し時間がかかるぐらいなので。


## Carthageにテスト用ライブラリをインストールする方法
テストでしか使用しないフレームワークはCartfileではなく  
`Cartfile.private`ファイルを用意して、インストールします。

```
$ touch Cartfile.private
```

中身の書き方は通常のCartfileと変わりません。  
注意点としては、プロジェクトへのリンク設定で、ターゲットをテストに対して行うことを忘れずに。



## 新しいバージョンを確認する
開発ではライブラリを使っていると新しいバージョンがリリースされたら追従させる必要があります。
Carthageで管理してるライブラリに新しいバージョンがリリースされているかどうかを調べる方法があります。
`carthage outdated`コマンドを実行すると一覧で確認することができます。

例えばSwiftyJSONに新しいバージョンが出てる場合です。
```sh
$ carthage outdated
*** Fetching SwiftyJSON
The following dependencies are outdated:
SwiftyJSON "4.3.0" -> "4.3.0" (Latest: "5.0.0")
```

## CarthageでGitHub以外のライブラリを使う方法

大半のライブラリはGitHubにあるとは思いますが、全てのライブラリではありません。  
例えば社内限定であれば自社内にOSSのGitレポジトリがありますし、GitLabやGitBucketもあります。  
その場合はCartfileに次の書き方でそれぞれのライブラリをインストールできるようになります。

```
github "https://enterprise.local/hoge/fuga/perfect-library" # GitHub Enterprise
git "https://enterprise.local/hoge/fuga/perfect-me.git" # Other Git repositories
```

## まとめ

他にも色々な機能や仕様を含んでおりますが、全部紹介せずとも実務で使う分には十分なボリュームになっているかと思います。

当然ながら、[公式](https://github.com/Carthage/Carthage)には記載がされているので暇があったら少しずつ追うのもいいかもしれません。  
README.mdだけでなく[Documentation](https://github.com/Carthage/Carthage/tree/master/Documentation)もあるので見落とさず。

今後も`Carthage`自体がシンプルなままで、対応ライブラリが増えるといいですね。

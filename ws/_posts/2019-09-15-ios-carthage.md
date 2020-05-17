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
- チーム運用
- テスト用ライブラリ
- GitHub以外のライブラリ
- Shell completion

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
 <!-- \--no-use-binariesでデバッグ可能にする -->
ライブラリによってはGitHubなどに既にビルド済みのフレームワークが用意されており、  
Carthageは特に指定がなければそれを使ってインストールして時間短縮を行っています。

しかし、事前に構築されたフレームワークは、フレームワークが構築されたPC以外でのステップ実行などはできません。  
その場合は、
```sh
$ carthage update --platform iOS --no-use-binaries <library name>
```
というふうに **`--no-use-binaries`** オプションんを使うことで解決することができます。

## Carthage管理下ライブラリのバージョン制御について

Carthageでライブラリのバージョンを指定するには、  
Cartfileに決まった書き方をすることでライブラリのバージョンを制御することができます。

例えば次のようなCartfileが

```
github "SwiftyJSON" ~> 4.2.0
github "Hoge" >= 4.2.0
github "Fuga" == 4.2.0
github "Nuga" "develop"
github "Moga" "ab12c3ef4"
```

それぞれ順に説明していきます。

### ~>で範囲指定する
最も多く使われてるであろう書き方です。
例えばバージョン履歴が下記だった場合で説明します。

- 4.2.0
- 4.2.1
- 4.3.0
- 5.0.0

このときにCartfileで`github "Hoge" ~> 4.2.0`が記入された状態で  
`update`を実行したら`4.2.1`までアップデートします。  
もし`github "Hoge" ~> 4.2`が記入されてたら`4.3.0`までアップデートします。

なかなか範囲が覚えにくいと思いますが、最後の数字が`x`に置き換えて見れば分かりやすくなります。  
例えば `github "Hoge" ~> 4.2.0`であれば`4.2.x`系です。  
`4.2`なら`4.x`系です。つまり4系バージョンですね。

### >= で指定バージョン以上

指定バージョン値以上のバージョンを指定します。  
Cartfileに`github "Hoge" >= 4.2.1`と記入された状態で  
バージョン履歴が下記だった場合は、`5.0.0`がインストールされます。

- 4.2.0
- 4.2.1
- 4.3.0
- 5.0.0

この書き方は少し破壊変更リスクが伴うため使う側としてはオススメしないです。  
こっちよりも前述した範囲指定のほうが安全性をそれなりに維持できます。

### == で指定バージョンのみ

もっとも安全なバージョン指定方法です。  
Cartfileに`github "Hoge" == 4.2.1`と記入されていたら  
他にバージョンが出ていても `4.2.1`しかインストールされません。

丁寧にバージョンアップをしたいライブラリや開発運用に適した方法です。

### revisionでコミット指定

GitHub上のコミットを名指しでインストールします。コミットで発行されているrevisionを使います。  
またrevisionだけでなくブランチ名でも使えます。

使っていたライブラリに不具合や脆弱性、iOS最新版が出たけどライブラリ側がバージョンを切っていない状態など  
緊急時で使うことがあるので覚えておいたほうがいいです。

[Carthage公式のVersion requirement](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement)でも英語ですが説明セクションはあります。

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

## CarthageでGitHub以外のライブラリを使う方法

大半のライブラリはGitHubにあるとは思いますが、全てのライブラリではありません。  
例えば社内限定であれば自社内にOSSのGitレポジトリがありますし、GitLabやGitBucketもあります。  
その場合はCartfileに次の書き方でそれぞれのライブラリをインストールできるようになります。

```
github "https://enterprise.local/hoge/fuga/perfect-library" # GitHub Enterprise
git "https://enterprise.local/hoge/fuga/perfect-me.git" # Other Git repositories
```

## Shell completion

## まとめ

他にも色々な機能や仕様を含んでおりますが、全部紹介せずとも実務で使う分には十分なボリュームになっているかと思います。

当然ながら、[公式](https://github.com/Carthage/Carthage)には記載がされているので暇があったら少しずつ追うのもいいかもしれません。  
README.mdだけでなく[Documentation](https://github.com/Carthage/Carthage/tree/master/Documentation)もあるので見落とさず。

今後も`Carthage`自体がシンプルなままで、対応ライブラリが増えるといいですね。

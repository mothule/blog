---
title: iOSアプリ開発のエコシステムを考えてみた
categories: ios swift
tags: ios swift program-design cocoapods carthage xcodegen mint quick nimble rbenv bundler homebrew swiftlint bitrise fastlane
image:
  path: /assets/images/2020-08-02-ios-swift-ecosystem-design/0.png
---

iOSアプリ開発で開発の周辺環境いわゆるエコシステムについて、現状どうなってるか整理も踏まえて考えて見ました。  

## この記事では説明しない部分

- アーキテクチャパターンやログ機能などアプリの骨組みデザイン
- ニッチ過ぎるサービスやツール

## エコシステムをなすツールやサービス一覧

{% page_image ecosystem-design.png 100% ios-ecosystem-design %}

上図は今回構築に使ったツールとその関係を階層構造で表した図です。

### Framework管理

frameworkの作成や管理をするツール群です。

- **CocoaPods**
  - {% post_link_text ios-cocoapods-managed-rbenv-bundler %}
- **Carthage**
  - {% post_link_text 2019-09-15-ios-carthage %}

説明は省きます。詳細は各リンク先を見てください。

### タスク管理

ビルド、テスト、アーカイブなど開発における処理の作成・管理として**Fastlane**を使います。

Fastlaneでタスク管理することで、細かな手続きを一塊にして呼び出しを簡略化します。  
またコマンドラインで呼び出せることでCIに乗せれたりもできます。  
そして、CIサービスの中でFastlaneのタスクを呼ぶことでCIの種類に依存せず処理を管理できます。

### プロジェクト管理

Xcodeプロジェクトの管理として**XcodeGen**を使います。  
XcodeGenのメリットや使い方に関しては「{% post_link_text ios-xcodegen-basic %}」で説明してます。

### 静的解析ツール
機械的にコード品質チェックを行うツールとして**SwiftLint**を使います。

### 管理ツール管理
FastlaneやCocoaPodsなどを管理ツールのバージョンを管理するツール群です。

- **rbenv**  
  Rubyのバージョン管理ツール。  
  FastlaneやCocoaPods, bundlerなどRuby製ツールの言語バージョンを制御する。  
  これがないとグルーバルのRubyバージョンを使うことになり、もし別都合でバージョンアップして、そのバージョンが下位互換だった場合に動かなくなる。
- **bundler**  
  gemの一元管理gem。  
  FastlaneやCocoaPodsなどのRuby製ツールのツールバージョンを制御する。  
  これがないとグローバルのFastlaneやCocoaPodsを使うことになり、他プロジェクト都合のバージョンアップに影響受ける。

### パッケージ管理
SwiftLintやCarthageなどのバージョンを管理するツール類です。

- **Homebrew**  
  {% post_link_text mac-homebrew-basic %}
- **Mint**
  Mintを使うことでプロジェクト間のツールバージョンを疎結合にできます。  
  {% post_link_text ios-mint-basic-usage %}  

#### Mintバージョンで問題が起きる場合
今回MintはHomebrewからインストールする構成です。  
もし、プロジェクト毎にMintのバージョンを持つ必要がある場合は、インストールを[自身でインストールする方法](https://github.com/yonaskolb/Mint#install)にすることで、Mintのバージョンを制御することが可能になります。  

またSwiftバージョンにズレが起きてる場合は,[SwiftEnv](https://github.com/kylef/swiftenv)を使って`.swift-version`ファイルでSwiftバージョンを固定することもできます。

### テスト環境
テストプロジェクトで使うテストフレームワーク・ツール群です。

- **Quick**
  BDDフレームワークです。通常のXCTestを使うよりテストケース管理がしやすくなります。
- **Nimble**
  Matcherです。XCTAssertを直接使うよりコードが読みやすく書きやすくなります。

### CIサービス
モバイルに特化した**Bitrise**を使います。  
ここに関してはCircleCIなど他領域(backend, frontend)などの費用関係もあるのである程度ゆらぎはあると思います。

## 組み合わせてみる
実際に組み合わせたiOSプロジェクト雛形を[GitHub](https://github.com/mothule/ios_project_template)に用意しました。  
Homebrewなど一部はGitHubにアップしないので反映されないものもあります。

### ビルド構成が複雑なら設定を外部ファイル化する
`project.yml`の中身が複雑になるのは主にSettings周りなので、そうなってきた場合は`settingGroups`と`configFiles`を使って  
外部ファイルに抽出する必要が出てくると思います。  
ここらへんは{% post_link_text ios-xcodegen-settings %}にやり方を書いてあります。

### レイヤードアーキテクチャデザインによってEmbedded frameworkを増やす
レイヤードアーキテクチャはサンプルなので2層に留めてます。  
実際のアプリ開発時ではアーキテクチャデザインに合わせます。

## マーケティング領域

アプリ開発のエコシステムの遠い位置にはマーケティング領域が出てくると思います。  
これらはビジネスサイドの領域ではありますが、データ集計フローは開発サイドの役割になります。  
ただ、今回は本筋から離れてしまうので説明しません。

- Firebase Analytics
- BigQuery
- Redash
- Slack
- Google Data Studio

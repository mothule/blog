---
title: XcodeGenでCarthageやCocoaPods環境のXcodeプロジェクトを生成する
description: XcodeGenでCarthageやCocoaPodsでライブラリ管理されたXcodeプロジェクトを生成する流れを説明します。
categories: ios xcodegen
tags: ios swift xcodegen carthage cocoapods
image:
  path: /assets/images/2020-07-28-ios-xcodegen-carthage-cocoapods/0.png
---
Xcodeプロジェクト(.xcodeproj)のコンフリクトはストレスです。  
この記事ではXcodeGenを使ってCarthageやCocoaPodsによるライブラリ管理されたXcodeプロジェクトを生成する方法を説明します。

もしXcodeGenの特徴やメリットを把握していない場合は、「{% post_link_text 2020-07-28-ios-xcodegen-basic %}」に詳細をまとめてあります。  
また基本的な使い方について理解したい場合は「{% post_link_text 2020-07-28-ios-xcodegen-basic-usage %}」に詳細をまとめてあります。  
もしCarthageについて分からない部分があれば、「{% post_link_text 2019-09-15-ios-carthage %}」に詳細をまとめてあります。



## XcodeGenで通常のiOSプロジェクトを用意する

```yml
name: iOSWithCarthageProj
options:
  bundleIdPrefix: com.mothule

targets:
  iOSWithCarthageProj:
    type: application
    platform: iOS
    sources: iOSWithCarthageProj
  iOSWithUTProjTests:
    type: bundle.unit-test
    platform: iOS
    sources: iOSWithCarthageProjTests
    dependencies:
      - target: iOSWithCarthageProj
```

sourcesの`iOSWithCarthageProj`と`iOSWithCarthageProjTests`はターゲット追加時にXcodeによって自動生成されるファイル群です。  
このyamlを`project.yml`として保存して`xcodegen generate`コマンドを実行するとUnitTest付きのiOSアプリのXcodeプロジェクトが生成されます。


## プロジェクトにCarthage管理のライブラリを追加する

例えばCarthageで`Alamofire`と`AlamofireImage`をビルドして、それらをプロダクトターゲットに追加する場合は次のように書きます。

```yml
iOSWithCarthageProj:
  # ~ 略 ~
  dependencies:
    - carthage: Alamofire
    - carthage: AlamofireImage
```

これらを追記して実行すると、フレームワークのリンクとビルドフェイズにcarthage copy-frameworksのスクリプトフェイズを自動生成してくれます。  
これは便利ですね。Carthageの面倒な点をキレイにカバーできています。

### 注意事項
XcodeGenはあくまでもXcodeプロジェクトをプロジェクト仕様に基づいて生成するだけです。  
そのためCarthageによるフレームワークビルド自体は、事前に行っておく必要があります。  
Carthageでフレームワークビルドをせず先に`xcodegen generate`を実行すると次のように形はあるけど存在しないリンク情報がセットされてしまいます。

{% page_image 1.png 50% MissedFrameworks %}

CartfileやフレームワークビルドはXcodeGenの責任範囲外なので自分で用意します。

### Carthageの実行パスを変更する

Carthageにパスが通っていれば特に問題は起きません。
しかし、MintでCarthageを管理している場合、実行パスを指定する必要があります。

```yml
options:
  carthageExecutablePath: mint run Carthage/Carthage
```

### Carthageのビルド結果のパスを変更する

デフォルトでは`Carthage/Build`です。
もしこれを別のパスに変更したい場合は、`options.carthageBuildPath`で指定します。

```yml
options:
  carthageBuildPath: ../../Carthage/Build # 例
```

## プロジェクトにCocoaPods管理のライブラリを追加する

XcodeGenで管理されたXcodeプロジェクトにCocoaPods管理のライブラリを追加する場合について説明します。

実は非常に単純です。

というのもXcodeGenはワークスペースではなくプロジェクトを生成しているだけなので、
プロジェクト仕様ファイルでPodfileなどを参照する必要ありません。
XcodeGenでプロジェクト生成後に、`pod install`を実行するだけです。

そして実はプロジェクト仕様ファイルには、生成コマンド実行後フックが用意されているのでプロジェクト仕様ファイル内で`pod install`を呼び出すことを設定できます。

```yml
options:
  postGenCommand: pod install
```

このオプションを追加することで`xcodegen generate`を実行するとそのまま`pod install`も実行されます。

### 疑問点
公式では`--use-cache`と`postGenCommand`オプションを組み合わせを推奨しています。
しかし、`Podfile`を変更して`xcodegen generate`を実行してもスキップされてしまいます。
Podfileだけの更新であれば`pod install`を実行すれば良いという話ではありますが…

## findCarthageFrameworksというオプション

Carthageのオプションに`findCarthageFrameworks`というものがあります。
これは例えば`ReactiveMapKit`を使う場合通常であれば依存してるフレームワーク全部を記載します。

```yml
targets:
  App:
    dependencies:
      - carthage: ReactiveCocoa
      - carthage: ReactiveMapKit
```

しかし`findCarthageFrameworks`オプションを使うことで`ReactiveCocoa`の時点で`ReactiveMapKit`も一緒に依存解決してくれるオプションです。

```yml
options:
  findCarthageFrameworks: true
targets:
  App:
    dependencies:
      - carthage: ReactiveCocoa # ReactiveMapKitも見つける
      - carthage: OtherCarthageDependency
        findFrameworks: false # 個別にグローバルオプションを無効化することもできる
```

## XcodeGenでBuild Configurationの設定をする
XcodeGenを使って、Carthage＋CocoaPods＋UnitTestのXcodeプロジェクトを生成することができました。
次はDebugやReleaseなどBuild Configurationの設定を「{% post_link_text 2020-07-28-ios-xcodegen-build-configuration-scheme %}」で説明します。

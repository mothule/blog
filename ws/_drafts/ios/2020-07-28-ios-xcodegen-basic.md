---
title: XcodeGenを基本から理解する
description: Xcodeプロジェクト(.xcodeproj)はファイル追加や削除したPullRequestでコンフリクト発生すると解消にストレスが溜まる。これをXcodeGenを使ってXcodeプロジェクトを作成することでGit管理せず解決することができる。
categories: ios xcodegen
tags: ios swift xcodegen
---
Xcodeプロジェクト(.xcodeproj)のコンフリクトはストレスです。  
でもXcodeGenでXcodeプロジェクトを生成することで、このストレスから解消できます。

## XcodeGenとは？
[XcodeGen](https://github.com/yonaskolb/XcodeGen)とは、フォルダ構造と`プロジェクト仕様ファイル`からXcodeプロジェクトを構築するコマンドラインツールです。なおSwiftで作られてます。

<img src="https://github.com/yonaskolb/XcodeGen/raw/master/Assets/Logo_animated.gif" width="100px" alt="XcodeGen Logo">

## プロジェクト仕様ファイル
YAMLまたはJSONで記述されており、次の項目を定義できます。

- ターゲット
- 構成
- スキーム
- カスタムビルド設定
- その他オプション

フォルダ構造がそのままXcodeプロジェクトのディレクトリ構造に反映される仕組みとなってます。  
またデフォルト値が用意されているので必要な部分だけをカスタマイズするだけで構築できます。

### プロジェクト仕様ファイルの中身

例えば下記は、YAML形式のプロジェクト仕様ファイルです。

```yml
name: MyProject
options:
  bundleIdPrefix: com.myapp
packages:
  Yams:
    url: https://github.com/jpsim/Yams
    from: 2.0.0
targets:
  MyApp:
    type: application
    platform: iOS
    deploymentTarget: "10.0"
    sources: [MyApp]
    settings:
      configs:
        debug:
          CUSTOM_BUILD_SETTING: my_debug_value
        release:
          CUSTOM_BUILD_SETTING: my_release_value
    dependencies:
      - target: MyFramework
      - carthage: Alamofire
      - framework: Vendor/MyFramework.framework
      - sdk: Contacts.framework
      - sdk: libc++.tbd
      - package: Yams
  MyFramework:
    type: framework
    platform: iOS
    sources: [MyFramework]
```

XcodeGenはこのファイルを元にXcodeプロジェクトを生成します。  
つまりこのファイルをGit管理するだけでXcodeプロジェクトをGit管理から外すことができます。

## XcodeGenのメリットはコンフリクト解決のしやすさ

フォルダ構造とプロジェクト仕様ファイルに基づいてXcodeプロジェクトを生成するため、  
ファイル管理等はXcodeプロジェクト(.xcodeproj)ではなくなりことで、  
.xcodeprojをgit管理する必要がなくなり、マージ時の衝突がなくなります。

またxcoderpoj(xml)よりも読みやすいプロジェクト設定で管理することができるようになります。  
なのでもしコンフリクトが発生しても通常のJSONやyml同様に衝突解決が容易になります。

## XcodeGenの特徴は衝突解決だけじゃない

- ビルド設定をグループという単位で管理するため、複数のターゲット間でビルド設定を共有できます。
- スキームの増減管理も簡単に行えます。
- CIなどからXcodeプロジェクトを構築できます。
- プロジェクト仕様を複数ファイルに分散させて共有や上書きなどができます。
- Carthage経由のフレームワークを統合できます。
- 依存関係をGraphvizを使って図をエクスポートできます。


## XcodeGenのインストール方法

### 必須条件
- Xcode11

### Mint
```sh
$ mint install yonaskolb/xcodegen
```

### Homebrew
```sh
$ brew install xcodegen
```

## 利用方法

```sh
$ xcodegen generate
```

これを実行すると、カレントディレクトリ上でプロジェクト仕様ファイル(`project.yml`)を検索し、仕様に沿ったXcodeプロジェクトが作成されます。

### 一部オプションの説明

- `--spec`: 検索するファイルパスを指定します。ファイルは`.yml`または`.json`になります。デフォルトは`project.yml`です。
- `--project`: 生成先のパス。デフォルトはプロジェクト仕様ファイルと同じディレクトリ。
- `--quiet`: 通知と成功時の通知を表示しなくなります。
- `--use-cache`: このオプションをつけて実行するとXcodeプロジェクト生成時にキャッシュファイルも生成し、次回以降不要であれば生成をスキップします。
- `--cache-path`: `--use-cache`で作成されるキャッシュファイルのパス指定。デフォルトは`~/.xcodegen/cache/{PROJECT_SPEC_PATH_HASH}`

その他オプションやコマンドに関しては`$ xcodegen help`で確認できます。

## 初期プロジェクトをXcodeGenで生成してみる

XcodeGenの概要からインストールまでを説明しました。  
実際にXcodeプロジェクト生成は、「{% post_link_text 2020-07-28-ios-xcodegen-basic-usage %}」で説明してます。

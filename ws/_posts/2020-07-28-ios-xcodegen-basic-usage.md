---
title: XcodeGenで最低限のXcodeプロジェクトを生成する
description: XcodeGenを実際に使って最小プロジェクトを作りながら少しずつ付け足して単体テスト付きのiOSアプリプロジェクトを作るまでの流れを説明します。
categories: ios xcodegen
tags: ios swift xcodegen
image:
  path: /assets/images/2020-07-28-ios-xcodegen-basic-usage/0.png
---
Xcodeプロジェクト(.xcodeproj)のコンフリクトはストレスです。  
この記事ではXcodeGenを実際に使って最小プロジェクトを作って使い方を説明します。

もしXcodeGenの特徴やメリットを把握していない場合は、「{% post_link_text 2020-07-28-ios-xcodegen-basic %}」に詳細をまとめてあります。

## 最小仕様でXcodeプロジェクトを生成する

XcodeGenの特徴の一つとしてデフォルト値が用意されているので指定がない場合はデフォルト値を使ってXcodeプロジェクトを生成するようです。

### 空フォルダ上で実行

```sh
$ xcodegen generate
No project spec found at /your/workspace/project.yml
```

プロジェクト仕様ファイルがないと怒られます。ファイルは必要なようです。

### 空のプロジェクト仕様ファイルで実行

```sh
$ xcodegen generate
Parsing project spec failed: Decoding failed at "name": Nothing found
```
`name`のデコードに失敗しました。どうやら`name`を探しているようです。

### nameを入れたプロジェクト仕様ファイルで実行

次のようにproject.ymlにnameを追加して実行してみます。
```sh
$ cat project.yml
name: MinimumProject

$ xcodegen generate
⚙️  Generating plists...
⚙️  Generating project...
⚙️  Writing project...
Created project at /your/workspace/MinimumProject.xcodeproj
```

どうやら作成に成功したようです。下記スクショのようにファイルもフォルダ設計もターゲットも何もない状態です。

{% page_image 1.png 100% MinimumProjectXcode %}

なお今回のファイルは[GitHub](https://github.com/mothule/research_xcodegen/tree/master/minimum_proj)に上げてますので全体像が分からない場合はこちらを見てください。


## iOSプロジェクトを生成する
ではiOSをプラットフォームとした空プロジェクトを目指して見ます。

その前に簡単にXcodeがデフォルトで用意してるテンプレートで目指すゴールを用意します。

{% page_image 2.png 100% iOSMinimumProjectXcode %}

ざっと見て追加する点は

- ターゲット
  - 表示名
  - バンドルID
  - バージョン
  - ビルド番号
  - 端末制限(iOSとiPad)
  - 初期表示storyboard
  - 画面横向きサポート
  - ステータスバー
  - アイコンと起動画面
- フォルダとファイルがある

あたりが必要そうです。

### ターゲットを追加する

```yml
targets:
  iOSMinimumProject:
    type: application
    platform: iOS
```

`targets`の子にはプロジェクト名が入ります。  
今回は`iOSMinimumProject`というターゲット名にしてます。

`type`には[Product Type](https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#product-type)の何れかをセットします。
今回は単純なアプリケーションなので`application`になります。

`platform`には[Platform](https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#platform)の何れかをセットします。
今回はiOSなので`iOS`になります。

これで`xcodegen generate`を実行した結果が下図になります。
{% page_image 3.png 100% iOSMinimumProjectXcode %}

プロジェクトは追加されています。
しかしIdentityやDevice Orientationなど中身がスカスカです。今度はこれを埋めていきます。

#### マルチプラットフォームは[]で囲む
もし複数プラットフォーム対応の場合は
`platform: [iOS, tvOS]`のように`[]`で囲みます。

### Info.plistが必要
IdentityやDevice Orientationなどは元データはXcodeプロジェクトに登録されているのではなく、Info.plistに登録されてます。

{% page_image 4.png 100% Info.plist %}

なので次はInfo.plistやソースファイルなどが入ったフォルダを用意します。  
フォルダ名は任意ですが、`iOSMinimumProject`という名前にしときます。  
そしてtargetのルートディレクトリとして`sources`プロパティでパスを渡します。

```yml
sources: iOSMinimumProject
```

これで`xcodegen generate`を実行すると無事不足してた部分が追加されます。

{% page_image 5.png 100% iOSMinimumProjectXcode %}


#### 初期ファイル群は自分で用意が必要
AppDelegate.swiftやInfo.plistなどは自身が追加したファイル同様外部ファイルなため、自分で用意する必要があります。  
しかしXcodeGenには特別初期ファイル群を用意する機能は備わっていないようなので、  
Xcodeを立ち上げて適当にプロジェクトを生成した後に、一緒に作成される初期ファイル群を使う手間があります。

このことからターゲット追加における最適フローは、

1. 一度Xcodeプロジェクトでターゲット作成する
1. 作成されたフォルダとファイル類をプロジェクト仕様に使う

という流れが手軽です。

もし違和感覚える方は、**「大事なのはXcodeプロジェクト管理を脱却することであり、Xcodeからの脱却ではない」** ことを改めて思い出すと腹落ちするのではないかと思います。

### バンドルIDを設定する

キャプチャ見ると分かりますが、Bundle Identifierが空のままです。  
これは`bundleIdPrefix`プロパティをセットすることでいい感じにセットしてくれます。  
このプロパティは`targets`ではなくルートに`options`を用意してその中でセットとなります。

```yml
options:
  bundleIdPrefix: com.mothule
```

これで`xcodegen generate`を実行すると無事bundle Identifierがセットされます。

{% page_image 6.png 100% iOSMinimumProjectXcode %}

こちらも[GitHub](https://github.com/mothule/research_xcodegen/tree/master/ios_minimum_proj)に上げてますので全体像が分からない場合はこちらを見てください。

## カテゴリ毎の必須プロパティの確認方法

[公式のプロジェクト仕様ページ](https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md)には各カテゴリ毎に定義されているプロパティと説明が列挙されています。

そして各プロパティ横のチェックボックスがマークされたものが必須プロパティとなります。

## テストターゲットを追加する
実務ではプロダクトターゲットだけでなく単体テストとしてテストターゲットも必要になります。  
先程の`iOSMinimumProject`にテストターゲットを追加してみます。

### Xcodeでテストフォルダを生成する
まず最初にXcodeから`Unit Testing Bundle`を選択して追加します。

{% page_image 7.png 200px UnitTestingBundle %}

するとターゲットとそれに紐づくフォルダが追加されるので、ターゲット名をコピーします。

### プロジェクト仕様にテストターゲット追加する
そして新しくプロジェクト仕様にターゲットを次のように追加します。　　
例えばテストターゲット名が`iOSWithUTProjTests`だとしたら次のようになります。

```yml
targets:
  iOSWithUTProjTests:
    type: bundle.unit-test
    platform: iOS
    sources: iOSWithUTProjTests
    dependencies:
      - target: iOSWithUTProj
```

新しいプロパティとして`dependencies`と`target`プロパティがあります。  
`dependencies`はこのターゲットに依存するライブラリなどを列挙します。  
今回はターゲットなので`target`プロパティを使い、テスト対象のターゲット名(`iOSWithUTProj`)をセットします。

こちらも[GitHub](https://github.com/mothule/research_xcodegen/tree/master/ios_with_ut_proj)に上げてます。

#### dependencies > targetなくともテストターゲットは追加されるが
`dependencies > target`を入れずともXcodeプロジェクトにUTターゲットは生成されます。  
が、実行できません。  
なぜなら、`Testing > Host Application` がNoneになっているためです。  
この部分をセットするために、`dependencies`を追加してます。

## CarthageやCocoaPods環境を構築する
XcodeGenを使って最小プロジェクトからUnitTest付きiOSアプリの最小プロジェクトを作りました。

次はCarthageやCocoaPodsを使ったライブラリ追加を「{% post_link_text 2020-07-28-ios-xcodegen-carthage-cocoapods %}」で説明します。

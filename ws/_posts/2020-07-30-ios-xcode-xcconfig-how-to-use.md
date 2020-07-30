---
title: Xcodeのxcconfigの理解と使い方
description: XcodeのBuild Settingsでビルド構成を管理する不便をxcconfigを使って解決するためにxcconfigの理解や使い方、実際のアプリ開発での構成について説明した記事。
categories: ios xcode
tags: ios xcode xcconfig
image:
  path: /assets/images/2020-07-30-ios-xcode-xcconfig-how-to-use/0.png
---

## xcconfigとは？
Xcodeのビルド構成ファイルです。略称からして**XC**ode**CONFIG**urationといったところだと思います。

Xcodeではビルドパラメータ等を「プロジェクト」や「ターゲット」単位で設定ができます。  
これらは通常XcodeのBuild Settingsから閲覧・編集することができますが、以下の不便があります。

- やり直し(アンドゥ)が効かない
- クリック操作が多く編集効率が悪い
- カスタマイズしたプロパティが把握しにくい

xcconfigはこれら**設定情報をテキスト形式の外部ファイルとして扱えるようにしたファイル**です。  
xcconfigを使うことでプロジェクトやターゲットのビルドパラメータを定義・上書きできます。

### xcconfigの利点

xcconfigによる利点は元の編集状況が抱える課題を解決する利点を持ちます。

- テキストとして扱える
- カスタマイズした設定だけが並ぶ
- Gitとの相性が良い(コンフリクト解消難易度が低い)

## xcconfigの書き方

下記の項目について説明します。

- ファイル作成
- ビルドパラメータの設定
- パラメータの型
- 変数展開
- ビルドパラメータにプラットフォーム条件の追加
- 他ビルド構成ファイルの読み込み

構成設定ファイルのフォーマット説明はAppleの[Configuration Settings File (xcconfig) format](https://help.apple.com/xcode/mac/11.4/#/dev745c5c974)を参考してます。

### ファイル作成

{% page_image 1.png 50% xcconfig %}

テキスト形式の外部ファイルなので拡張子さえあっていれば追加方法は何でもいいです。  
もしXcode上から追加する場合は、`Configuration Settings File`を選んでください。↓

{% page_image 2.png 75% NewFileOnXcode %}

### ビルドパラメータの設定

設定フォーマットは`ParameterName = ParameterValue`となります。  
1ビルドパラメータ1行で表現します。  
例えば下記はアプリアイコンで使うAppIcon名を設定する例です。

```js
// アプリアイコンとして使うAppIconの名前
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
```

また利点にも記載しましたが、全てのビルドパラメータを記載する必要はありません。  
カスタマイズしたパラメータだけを列挙します。  
未記載のビルドパラメータはXcode側が持つデフォルト値が使われます。

#### 上書き
ビルドパラメータは上書きが可能です。
後から書いた同一パラメータが使われます。

```js
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon2 // ← これが使われる
```

この上書きルールは同一ファイルだけでなくファイルを横断して適用されます。  
つまりプロジェクトで`ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`と設定しても  
ターゲットで`ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon2`と設定してれば、  
そのターゲットでは`AppIcon2`になります。

### パラメータの型

パラメータの値には多様な型をサポートしています。

|型|説明|
|---|---|
|Boolean|YES or NO|
|string|テキスト|
|enumeration(string)|定義済みテキスト|
|string list|空白区切りのテキスト一覧。もしテキスト内に空白があるなら引用符(")で囲みます。|
|path|ファイルまたはディレクトリのパス(形式はPOSIXに準拠)|
|path list|string listのpath版|

### 変数展開

パラメータ値では変数展開ができます。形式は`$(variable_name)`になります。
例えば下記は、既存パラメータを上書きせず追加する例です。

```
OTHER_SWIFT_FLAGS = $(inherited) -v
```

下記のように他のビルドパラメータも参照可能です。

```
OBJROOT = $(SYMROOT)

DSTROOT = /tmp/$(PROJECT_NAME).dst

CONFIGURATION_BUILD_DIR = $(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)
```

### ビルドパラメータにプラットフォーム条件の追加

ビルドパラメータには簡易ですが、条件をつけれます。  
条件はSDKとArchitectureの2種類です。

SDKとはmacOSやiOSなどで、Architectureはx86_64やarm64などです。

|条件名|値(例)|
|---|---|
|sdk|macos10.12, iphoneos10.2, iphoneos*|
|arch|x86_64, arm64|

設定フォーマットは`ParameterName[Conditional=ConditionalValue] = ParameterValue`になります。

例えば下記はiOSの場合のみ`OTHER_SWIFT_FLAGS`に`-v`を追加する例です。

```
OTHER_SWIFT_FLAGS[sdk=iphoneos*] = $(inherited) -v
```

#### 組み合わせ可能
条件sdkとarchは組み合わせ可能です。

下記はx86_64系iOSの場合のみ`OTHER_SWIFT_FLAGS`に`-v`を追加する例です。
```
OTHER_SWIFT_FLAGS[sdk=iphoneos*][arch=x86_64] = $(inherited) -v
```

### 他ビルド構成ファイルの読み込み
xcconfigは他のxcconfigを読み込み展開できます。
他xcconfigを読み込むには`#include "other file path"`を使います。  
パスは「ファイル名」「相対パス」「絶対パス」を利用できます。

- ファイル名: 同一ディレクトリ上から一致するファイルを探します。
- 相対パス: 同一ディレクトリ上を基点として一致するファイルを探します。

他xcconfigへのパス解決は、ビルド設定を処理する前に実施されます。

#### 指定ファイル見つからない場合
ビルド時に指定のファイルが見つからない場合は、ビルド警告が表示されます。  
もしこの警告を抑制したい場合は、`#include? "other file path"`と、`?`をつけます。

### ビルドパラメータ名が分からない場合

もしビルドパラメータ名が分からない場合は「{% post_link_text 2020-07-30-ios-xcode-xcconfig-how-to-search-build-config %}」に探し方をまとめてあります。


## xcconfigの実践活用

実際のアプリ開発ではどういった運用にすればよいか考えてみます。


ターゲットの数ですが、最近の動向から考えて次の観点で考えてみます。

- 4層構造
- AppExtension N個
- 各ターゲットにUT

これを元にプロジェクトとターゲットの構図で表すと次のツリー構造です。

- Project
  - App
  - AppTests
  - AppUITests
  - AppCore
  - AppCoreTests
  - Infrastructure
  - InfrastructureTests
  - Library
  - LibraryTests
  - AppExtensionA
  - AppExtensionB

11個のターゲットに分かれました。
分類としては、

- レイヤー別
- テスト or プロダクト
- AppExtension

の3カテゴリに分けられるかと思います。

これを11個それぞれにビルドパラメータを設定するのは多量の重複が発生するので、`include`を利用したxcconfigの階層化が必要かと思います。
階層の分け方としては先程分けた分類に加えてBuild Configurationを考慮した形が良さそうです。

つまり整理すると、

- プロジェクトのビルド構成を用意
- テスト共通ビルド構成を用意
- プロダクト共通ビルド構成を用意
- ターゲット毎にビルド構成を用意
- Build Configuration共通ビルド構成を用意
- Build Configuration毎にビルド構成を用意

になります。

Xcode上で見るとこうなります。

{% page_image 3.png 50% LayeredTargets %}

これを今回はxcconfigを次のように分けました。

{% page_image 4.png 100% xcconfigMapping %}

xcconfigファイル自体はターゲットフォルダと1:1ではないので、別フォルダとして集約しました。

{% page_image 5.png 50% xcconfigFiles %}

これら親子関係をツリー表現すると次のようになります。

- Project.base.xcconfig
  - Project.debug.xcconfig
    - App.base.xcconfig
      - App.debug.xcconfig
    - UnitTest.xcconfig
    - UITest.xcconfig
    - Extension.base.xcconfig

releaseはdebugと同じなので省略してあります。

### 今回この構成にした理由

テスト系xcconfigはReleaseで実施するケースは考えにくいためBuild Configurationによる分割はしていません。  
AppExtension系xconfigは今の所この2つのターゲットではDebugでもReleaseでも差異はなかったのですが、開発を進めるにあたって分岐しやすいと予想し、
そのときの半分準備としてbaseを使うようにしています。今後DebugとReleaseで分岐が生まれたら、他同様になります。  

当然ですが、この構成が絶対正解ではありません。プロダクトの特性や状況に応じその時点でのベストは異なります。  
エンジニアはこれを考えるのが重要な仕事です。

### xcconfigの中身

中身は予定通り`#include`プレフィックスを使って共通xcconfigを読み込んでから、それぞれ特別値を個別設定してあります。

例えば下記は`Project.debug.xcconfig`の全容です。

```
#include "Project.base.xcconfig"

//:configuration = Debug
ONLY_ACTIVE_ARCH = YES
DEBUG_INFORMATION_FORMAT = dwarf
ENABLE_TESTABILITY = YES
GCC_DYNAMIC_NO_PIC = NO
GCC_OPTIMIZATION_LEVEL = 0
GCC_PREPROCESSOR_DEFINITIONS = DEBUG=1 $(inherited)
SWIFT_OPTIMIZATION_LEVEL = -Onone
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE
```

### xcconfigは少なく抑えたほうが良い

なるべくxcconfigのファイル数は少なくなるような構成にしてたほうがいいです。  
なぜならxcconfigの分岐ポイントが「Build Configuration」「Platform」「Testing」と分岐要素が多いことでファイル数が増えやすいためです。  
例えば、今回はBuild Configurationはデフォルト値となるDebugとReleaseの2つでした。  
しかしこれがDebug,Staging,AppStore,CIと4つに増えた場合にその分増えてしまいます。

もしBuild Configurationも増えるようであれば、組み合わせ爆発を起こさないためにも工夫が必要です。

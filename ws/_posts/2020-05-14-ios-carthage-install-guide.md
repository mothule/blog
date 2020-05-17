---
title: iOSのCarthage導入手順と注意点
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2020-05-14-ios-carthage-install-guide/eyecatch.png
---
Carthageの導入はちょっとした漏れでエラーにハマります。  

この記事は、iOSアプリにCarthage環境を導入する手順について説明します。

1. MacにCarghageをインストールする
1. Cartfileにライブラリを記入
1. Cartfileからframework作成
1. プロジェクトにframeworkをリンク
1. ビルドフェイズにframeworkのコピースクリプトを作成

なお、チーム運用、git管理、ライブラリのバージョン運用など詳細は、  
「{% post_link_text 2019-09-15-ios-carthage %}」からまとめて知ることができます。

## MacにCarghageをインストールする

CarthageはHomebrewでインストールできます。

```sh
$ brew install carthage
```

{% comment %} Homebrewインストール記事を書いたらここにリンクを貼る {% endcomment %}

## Cartfileにライブラリを記入

`Cartfile`とはCarthageのライブラリ管理ファイルです。  
テキストファイルになってて、  
この中にCarthageで管理したいライブラリをまとめます。

- Cartfileファイルの用意
- Cartfileの編集


### Cartfileファイルの用意

`Cartfile`はプロジェクト毎に用意できます。  
対象プロジェクトのディレクトリ上に`Cartfile`を用意します。

```sh
$ cd ~/your/xcode/project/path
$ touch Cartfile
```

### Cartfile編集
インストールしたいライブラリを`Cartfile`に記入します。  
例えば[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)であればに次のように記入します。

```
github "SwiftyJSON/SwiftyJSON"
```

{% comment %} バージョン指定をしたい場合は「」に書き方をまとめてあります。 {% endcomment %}

## Cartfileからframework作成
`Cartfile`の準備ができたら`carthage update`コマンドでフレームワークを作成します。  
オプションに`--platform`と`--no-use-binaries`をつけます。

|オプション|説明|
|---|---|
|\--platform|対象プラットフォーム指定。未指定は全環境のフレームワークを作成します|
|\--no-use-binaries|予めビルドされたバイナリを使わずコードからビルドします|

`carthage update`コマンドを実行するとframework作成処理が走ります。

```sh
$ carthage update --platform iOS --no-use-binaries

*** Fetching SwiftyJSON
*** Checking out SwiftyJSON at "5.0.0"
*** xcodebuild output can be found in /var/folders/45/7f_wlrcs3xv6rmstcz2l5_000000gn/T/carthage-xcodebuild.IBF3eg.log
*** Building scheme "SwiftyJSON iOS" in SwiftyJSON.xcworkspace
```

成功すると`Carthage`ディレクトリと`Cartfile.resolved`ファイルが作成されます。

- Cartfile.resolved
  - `carthage update`で最終的な依存ライブラリ情報をまとめたテキストファイル
- Carthage
  - `carthage update`で作成されたライブラリのフレームワークが格納されたディレクトリ

Cartfile.resolvedの詳細については「{% post_link_text 2020-05-15-ios-carthage-team-collaboration %}」でまとめてあります。

## プロジェクトにframeworkをリンク
frameworkはプロジェクトにリンクしないと使えません。  
プロジェクトの`Target > General > Linked frameworks and Libraries`を ＋ ボタンを押してください。

{% page_image 1.png %}

フレームワーク／ライブラリの選択画面が出るので、`Add Other...` ボタンを押してください。
{% page_image 2.png %}

ここで先程作成したframeworkを指定します。  
なおフレームワークは、`Carthage/Build/iOS`ディレクトリの中にあります。

{% page_image 3.png %}

frameworkを選ぶとXcodeプロジェクトに追加されます。  
このとき**Do Not Embed**になってることを確認してください。

{% page_image 4.png %}

これでプロジェクトにframeworkがリンクされて、  
コード上のimportで対象frameworkを見つけられるようになります。

なお、ボタンをポチポチせずにframeworkをドラッグ＆ドロップでも追加できます。

### 注意：Embed Contentだとビルドエラーになる

frameworkのリンク経路は、`Target > General`と`Target > Build Phases`の2つあり  
`General`からframeworkを追加すると、デフォルトでは`Embed & Sign`になります。  
このままビルドすると次のようなビルドエラーが起きます。

```
Multiple commands produce '.../YOUR-APP-NAME.app/Frameworks/<FRAMEWORK NAME>.framework':

1) Target '<YOUR TARGET NAME>' has copy command from
'/your/project/path/Carthage/Build/iOS/<FRAMEWORK NAME>.framework' to '.../YOUR-APP-NAME.app/Frameworks/<FRAMEWORK NAME>.framework'

2) That command depends on command in Target '<YOUR TARGET NAME>': script phase “Run Script”
```

Embedded Frameworkではないので、`Do Not Embed`に直してください。

## ビルドフェイズにフレームワークのコピースクリプトを作成
リンクでビルドは通りますが、プロダクト内にframeworkが配置されていません。  
**ビルド時にframeworkをコピーするスクリプトを用意します。**  
コピー処理は`carthage copy-frameworks`コマンドを使います。

1. ビルドフェイズにスクリプトフェイズ追加
1. `carthage copy-frameworks`コマンドをセット
1. スクリプトの入力情報をセット
1. スクリプトの出力情報をセット


### 1. ビルドフェイズにスクリプトフェイズ追加
`Build Phases`上の ＋ ボタンを押して`New Run Script Phase`を選ぶと`Run Script`フェイズが作成されます。

{% page_image 5.png %}

### 2. `carthage copy-frameworks`コマンドをセット
Shellはシェルコマンドが呼べればいいので`/bin/sh`のままです。  
スクリプト内で`carthage copy-frameworks`コマンドを追記します。  
絶対パスでも相対パスでもパスが通っていればどちらでも大丈夫です。

{% page_image 6.png %}

### 3. スクリプトの入力情報をセット
`carthage copy-frameworks`はframeworkのパスを渡すと、ビルド対象プロジェクト内にコピーします。  
厳密には`$BUILD_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH`パスにコピーします。[GitHub/Carthage](https://github.com/Carthage/Carthage/blob/f656edfe35651b54eec50d814e79d079f8eea7c4/Source/carthage/CopyFrameworks.swift#L25)

{% page_image 7.png, 100%, Carthage Xcode Build Phases Run Script Input Files %}

### 4. スクリプトの出力情報をセット
`Output Files`はコピー先を指定します。

実は`Output Files`は指定せずとも動作に問題はありません。**しかしビルドパフォーマンスに影響します。**  
詳しくは「{% post_link_text 2020-05-13-ios-carthage-measure-copy-speed-with-output-files %}」に調査結果をまとめてあります。

{% page_image 8.png, 100%, Carthage Xcode Build Phases Run Script Output Files %}

### 注意: carthage copy-frameworksを忘れるとランタイムエラー

`carthage copy-frameworks`コマンドを実行しなくてもビルドは通ります。  
しかし実行すると次のようなにライブラリのロードエラーが起きます。

```
dyld: Library not loaded: @rpath/SwiftyJSON.framework/SwiftyJSON
  Referenced from: /Users/mothule/Library/Developer/CoreSimulator/Devices/1DB7E7C4-D7CD-44BA-B3F9-F66DC4E5EC51/data/Containers/Bundle/Application/6B0FDFCC-9D12-47D5-9B74-B837BE8FC983/UseCarthage.app/UseCarthage
  Reason: image not found
```

これはプロダクト内にframeworkが配置されてないことで、  
実行環境にプロダクトがインストールされてもframeworkが見つからずdyldがランタイムエラーを起こすためです。

### 注意: Input Filesで渡すframeworkのパスを間違えるとビルドエラー

`carthage copy-frameworks`コマンドに渡すframeworkのパスが間違っているとビルドエラーが発生します。  
`Input Files`または`Input File Lists`で渡してるframeworkのパスが正しいか確認してください。

```
Could not find framework "<framework name>" at path <wrong framework path>.
Ensure that the given path is appropriately entered and that your "Input Files" and "Input File Lists" have been entered correctly.
```

### フレームワークのパスはまとめて指定も可能

Input Filesに各フレームワークのパスをセットしなくても、xcfilelistという拡張子で指定することで一律管理も可能です。
詳細は「{% post_link_text 2020-05-13-ios-carthage-use-xcfilelist %}」にまとめてあります。

## ライブラリを追加する
新しくframeworkを追加や更新する場合は、  
`carthage copy-frameworks`コマンドの登録以外の作業をやります。  
また`update`にオプションが一つ増えます

1. Cartfileにライブラリ追加
1. `carthage update`でライブラリ個別更新
1. リンクにframeworkを追加
1. コピースクリプトのInput FilesとOutput Filesに追加

新しくビルドフェイズにスクリプトを追加はしません。

### `carthage update`でライブラリ個別更新

`carthage update`とするとCartfileにかかれている全てのライブラリが対象となります。  
他のライブラリのバージョンは更新せず追加したライブラリだけのframework作成をしたい場合は、  
`carthage update`にライブラリ名を渡します。

例えば新しく追加したライブラリが`SDWebImage`であれば、コマンドラインは次のようになります。

```sh
$ carthage update --platform iOS --no-use-binaries SDWebImage
```

これで既存ライブラリは更新されません。

## もっと体系的に理解する

この記事では、記事の読みやすいよう導入に絞ってます。
もしチーム運用、git管理、ライブラリのバージョン運用など使い続けたら必要になる部分は別記事に分けており、  
「{% post_link_text 2019-09-15-ios-carthage %}」からまとめて知ることができます。

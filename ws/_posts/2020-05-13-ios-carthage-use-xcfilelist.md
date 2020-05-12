---
title: CarthageでInput File Listsにxcfilelistを渡す利点と方法
description: CarthageをXcodeで使うには環境構築が必要でcarthage copy-frameworksコマンドにパラメータを渡すのにInput FilesではなくInput File Listsにxcfilelistを渡す利点と方法について説明します。
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2020-05-13-ios-carthage-use-xcfilelist/eyecatch.png
---
`xcfilelist`で依存ライブラリを管理すると楽です

この記事は`xcfilelist`を使って`Carthage`の環境を構築する方法と利点について説明します。

`Carghage`の基本や使い方の詳細は「{% post_link_text 2019-09-15-ios-carthage %}」にまとめてあります。

## Carthage公式解説に出てくるxcfilelist

Carthageのインストール解説記事には、`xcfilelist`を使った解説は見かけません。  
大抵`Input Files`に直接パスを指定する記事が多いです。  
しかし、[Carthageの公式](https://github.com/Carthage/Carthage)では`xcfilelist`を使っており、むしろそっちがメインにも見えます。

### xcfilelistの正体

`xcfilelist`はXcodeのファイル一覧を表すファイル・タイプです。  
といってもただのテキストファイルです。  
テキストエディタでファイルパスを列挙して、ファイル保存時に拡張子を`.xcfilelist`とするだけです。

## xcfilelistを使う場所

公式では英文で`xcfilelist`を見かけますが、これを使う場所がパッと見では分かりません。  
`xcfilelist`を使う場所は下の画像の`Input File Lists`と`Output File List`です。  
この中に`xcfilelist`のパスを指定します。

{% page_image 1.png 100% XcodeBuildPhaseのCarthage用RunScriptPhase %}

## Input File Listsを使う利点

`Input Files`でframeworkのパスを指定するほうが仕組み理解という点では分かりやすいです。
`Input File Lists`を使う利点がないと使う気にならないと思います。  

使う利点は、一度`xcfilelist`のパスを指定すれば、`Run Script`の使いにくいUIを使わなくて済みます。

## xcfilelistを用意する

`xcfilelist`はパスさえ合っていればどこに置いても問題ないですが、  
他環境でも動くようにまずはgit管理下が必須だと思います。  
次に編集しやすさ、環境パスが使える、Xcodeで使うファイルと考えたら  
**プロジェクトディレクトリ配下に置くことが最適です。**

{% page_image 2.png 50% Xcode-Project-Navigator %}

中身は次のように`Input Files`で指定するパスを並べるだけです。
これを`.xcfilelist`として保存すれば準備は整います。
ファイル名は何でもいいです。

```
$(SRCROOT)/Carthage/Build/iOS/AdjustSdk.framework
$(SRCROOT)/Carthage/Build/iOS/SKPhotoBrowser.framework
$(SRCROOT)/Carthage/Build/iOS/SDWebImage.framework
$(SRCROOT)/Carthage/Build/iOS/AFNetworking.framework
$(SRCROOT)/Carthage/Build/iOS/AdjustSdkWebBridge.framework
$(SRCROOT)/Carthage/Build/iOS/PAYJP.framework
$(SRCROOT)/Carthage/Build/iOS/AdjustSdkIm.framework
$(SRCROOT)/Carthage/Build/iOS/SVProgressHUD.framework
$(SRCROOT)/Carthage/Build/iOS/SwiftyJSON.framework
```

## xcfilelistをInput File Listsに渡す

Xcodeの`Build Phases`の`Carthage`用スクリプトフェイズの`Input File Lists`に先程用意した`.xcfilelist`のパスを指定します。

先程の用意した場所であれば、`$(SRCROOT)/$(PROJECT_NAME)/carthage-input-file-list.xcfilelist`になります。

{% page_image 3.png 100% XcodeのInputFileLists %}

## Output File Listsもxcfilelistを使う

`Output File Lists`も同様に`xcfilelist`として出力パスを列挙しておけば`xcfilelist`のパスを指定するだけです。

```
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/AdjustSdk.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SKPhotoBrowser.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SDWebImage.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/AFNetworking.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/AdjustSdkWebBridge.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/PAYJP.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/AdjustSdkIm.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SVProgressHUD.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SwiftyJSON.framework
```

こちらも`Input File Lists`と同じ場所場所であれば`Output File Lists`で指定するパスは、`$(SRCROOT)/$(PROJECT_NAME)/carthage-output-file-list.xcfilelist`になります。

{% page_image 4.png 50% XcodeのOutputFileLists %}

### Output File Listsを指定する理由
`Output Files`や`Output File Lists`でコピー先のパスを指定しますが、実は指定しなくてもコピー処理は成功し、動作も問題ありません。  
なぜ指定するのかは「{% post_link_text 2020-05-13-ios-carthage-measure-copy-speed-with-output-files %}」に詳細をまとめてます。

## 後からでも対応できる
この対応は、プロジェクトが初期段階でも後からでも対応できます。  
ライブラリが多くても手間はそこまで変わりません。  

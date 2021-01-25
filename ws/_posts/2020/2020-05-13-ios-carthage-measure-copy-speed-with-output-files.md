---
title: CarthageのビルドフェイズでOutput Files指定による速度調査
description: Carthageはビルドフェイズでcarthge copy-frameworksでフレームワークをコピーしているが、これを差異があればコピースクリプトを走らせる方法があり高速化に繋がる。その方法と効果について調査した記事。
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2020-05-13-ios-carthage-measure-copy-speed-with-output-files/eyecatch.png

---
この記事はXcodeのビルドフェイズ時にCarthageのフレームワークコピー用スクリプトのOutput Filesの有無によるビルドパフォーマンスについて調査した記事です。

なおCarthageのインストールや基礎など詳細は「{% post_link_text 2019-09-15-ios-carthage %}」にまとめてあります。

## 調査のきっかけ

[Carthage Quick Start](https://github.com/Carthage/Carthage#quick-start)や[Carghage Adding frameworks to an application](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)には、`Output Files`や`Output File Lists`を設定しろと書かれています。

しかし、[carthage copy-frameworksのコード](https://github.com/Carthage/Carthage/blob/master/Source/carthage/CopyFrameworks.swift)では使われていません。

最初はただの更新漏れかと思ったが、調べたら[Pull Request](https://github.com/Carthage/Carthage/pull/2025)を見つけました。

どうやらWWDCの発表によると、`Output Files`が設定されていると、`Input Files`の変更がなければスクリプトの実行をスキップするらしいです。

つまり**`Output Files`は未設定でも動作上問題はないですが、設定はすることでビルド時間の短縮に繋がる**ようです。

では「どれぐらい違うのか？」を調べようと思いました。

小さな差分でも、開発では何十回もビルドを走らせます。  
トータルタイムでいくと効果は侮れません。


## 調査方法

- プロジェクトは新規プロジェクトの初期状態＋Carthage
- `Output Files`の「あり」「なし」それぞれのビルド時間を10回ずつ測定
- ビルドを走らせる前に適当なソースファイルを1つ弄ってから実行する
- ビルド時間はXcodeのPreferences(ShowBuildOperationDuration)を使う

{% comment %}ShowBuildOperationDurationやビルド時の使用コア数の設定などの記事を書いたらここにリンクを貼る{% endcomment %}


フレームワークのコピー処理の有無ということで、*Cartfile* はそれっぽい数7個用意。
```
github "AFNetworking/AFNetworking"
github "suzuki-0000/SKPhotoBrowser"
github "SVProgressHUD/SVProgressHUD"
github "SwiftyJSON/SwiftyJSON"
github "SDWebImage/SDWebImage"
github "payjp/payjp-ios"
github "adjust/ios_sdk"
```

この場合はInput Filesはこうなります。

```
$(SRCROOT)/Carthage/Build/iOS/AFNetworking/AFNetworking.framework
$(SRCROOT)/Carthage/Build/iOS/suzuki-0000/SKPhotoBrowser.framework
$(SRCROOT)/Carthage/Build/iOS/SVProgressHUD/SVProgressHUD.framework
$(SRCROOT)/Carthage/Build/iOS/SwiftyJSON/SwiftyJSON.framework
$(SRCROOT)/Carthage/Build/iOS/SDWebImage/SDWebImage.framework
$(SRCROOT)/Carthage/Build/iOS/payjp/payjp-ios.framework
$(SRCROOT)/Carthage/Build/iOS/adjust/ios_sdk.framework
```

そして、**Output Files** はこうなります。

```
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/AFNetworking/AFNetworking.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/suzuki-0000/SKPhotoBrowser.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SVProgressHUD/SVProgressHUD.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SwiftyJSON/SwiftyJSON.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SDWebImage/SDWebImage.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/payjp/payjp-ios.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/adjust/ios_sdk.framework
```

## 測定結果

次の表は調査方法に基づいた調査結果です。

|#|`Output Files`なし|`Output Files`あり|
|1|2.300|1.569|
|2|2.521|1.427|
|3|2.229|1.455|
|4|1.867|1.493|
|5|2.516|1.343|
|6|2.364|1.710|
|7|2.158|1.568|
|8|2.360|1.467|
|9|2.123|1.575|
|10|2.243|1.479|
|Avg|2.2681|1.5086|

平均値の差分は0.7595秒つまり34%短縮しました。

## 感想

想定以上の効果がありました。  
調査中も違いを体感で分かるほどです。  
ワンテンポ違いました。

しかし、仮に仕事で15分おきに1回ビルドを走らせてるとした場合、  
9時間 x 4回 * 0.7595秒 = 27.342秒の違いが出ます。  
大したことないですね…  
でも短時間に何度もビルドを走らせる状況ではチリツモ効果は出てると予想します。

なお、このパフォーマンスは、Cartfile管理下のライブラリ数とライブラリ規模に依存します。

## 結論

- 一定のパフォーマンス効果はある
- おとなしく設定したほうがいい

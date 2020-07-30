---
title: XcodeGenでBuild ConfigurationとSchemeの設定をする
description: XcodeGenを使う実務で上で必ず必要になってくるBuild Configurationの設定や各ビルドパラメータの調整方法やCIで使えるための設定に関して説明します。
categories: ios xcodegen
tags: ios swift xcodegen
image:
  path: /assets/images/2020-07-28-ios-xcodegen-build-configuration-scheme/0.png
---
XcodeGenでDebugやReleaseなどBuild Configuration自体を追加したり、Build Configuration毎にビルドパラメータを変えたりする方法について説明します。

## 新しいBuild Configurationの登録
デフォルトはDebugとReleaseですが、新しく追加する場合は`configs`プロパティで追加します。

```yml
configs:
  Debug: debug
  Beta: release
  AppStore: release
  CI: debug
```
例えば `Beta: release`とは、Build Configuration名を`Beta`と名付け、ベースをReleaseにしてあります。  
値の部分がdebugまたはrelease以外だとデフォルト値が適用されなくなります。

## Build Configuration毎にビルドパラメータを変更
デフォルトのDebugとReleaseとは違いをつけたいから新しくBuild Configurationを追加したのに  
そのままでは意味がありません。Build Configuration毎にビルドパラメータを変更します。

### CIではAssertionを無効にしてみる
例えばCI時のみ動かないassertを作ろうと思います。
`assert(_:)`メソッド自体は適当です。何でもいいので説明省きます。

```swift
#if DISABLE_ASSERTION
func assert(_ string: String) {}
#else
func assert(_ string: String) {
    Swift.assertionFailure(string)
}
#endif
```
コード側で重要なのはプリプロセッサの条件式に入ってる`DISABLE_ASSERTION`です。  
これをXcodeGenで定義するには、`settings.configs.CI.SWIFT_ACTIVE_COMPILATION_CONDITIONS`に値を追加します。

```yml
targets:
  CustomBuildConfig: # ← ターゲット名
    # 〜 略 〜
    settings:
      configs:
        CI:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: [DEBUG, DISABLE_ASSERTION]
```

これを実行するとXcodeに反映されます。

{% page_image 2.png 100% XcodeBuildConfiguration %}

`settings`はプロジェクト仕様のルートに置くことでターゲット毎でなく全体適用させることもできます。


## プロパティ名の見つけ方
例えばXcodeのBuild Settings > Development Teamを用意する場合は`DEVELOPMENT_TEAM`プロパティをセットします。

{% page_image 1.png 50% XcodeBuildSettingsDevelopmentTeam %}

```yml
settings:
  DEVELOPMENT_TEAM: hogehoge    
```

ではどうやってXcodeのBuild Settingsとプロジェクト仕様のプロパティを一致させてるのか？  
それはxcconfigと同じ値を使っています。

詳しくは「{% post_link_text 2020-07-30-ios-xcode-xcconfig-how-to-search-build-config %}」にまとめてあります。

## XcodeGenでテスト時のBuild ConfigurationをCIにする

前述した方法を実施することでCI用のBuild Configurationとビルドパラメータを定義することができます。  
しかし生成したXcodeではBuild ConfigurationがDebugのままです。  
これだとCIでXcode生成して実行する場合では意図したBuild Configurationになりません。  
デフォルトをDebugではなくCIにする必要があります。

デフォルトにするには`Scheme`を使うことで定義できます。

```yml
schemes:
  CustomBuildConfig: # ← スキーム名
    build:
      targets:
        CustomBuildConfig: all # ← ビルド対象ターゲットと対応Actionの設定
        CustomBuildConfigTests: [test]
    test:
      config: CI
```

こうすることで下図のようになります。

{% page_image 3.png 100% XcodeSchemes %}

これを追加することで生成されたXcodeプロジェクトを開くと初めからTestのBuild ConfigurationはCIになります。

### テストターゲットやカバレッジ指定をする
前述した設定でTest時のデフォルトBuild ConfigurationをCIにすることができました。  
しかし、いざテストを実行しても動きません。  
それはテストターゲットが設定されていないためです。


```yml
schemes:
  CustomBuildConfig:
    build:
      targets:
        CustomBuildConfig: all
        CustomBuildConfigTests: [test]
    test:
      targets:
        - CustomBuildConfigTests # ← テストターゲット名
      config: CI
      gatherCoverageData: true
```

先程のymlのtestプロパティを変更しました。こうすることでテストターゲットが選ばれた状態でXcodeプロジェクトが作成されます。

{% page_image 4.png 100% XcodeSchemes %}

今回の使ったコードは[GitHub](https://github.com/mothule/research_xcodegen/tree/master/custom_build_config)にアップしてありますので、全体像を掴みたい場合はご確認ください。

## XcodeGenでEmbedded frameworkを登録する

XcodeGenでBuild Configuration別のビルドチューニングについて説明しました。  
もしまだSettings周りで不明点がある場合は、「{% post_link_text 2020-07-29-ios-xcodegen-settings %}」をおすすめします。

次はEmbedded frameworkを「{% post_link_text 2020-07-29-ios-embedded-framework %}」で説明します。

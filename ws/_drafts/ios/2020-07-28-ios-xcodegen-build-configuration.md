---
title: XcodeGenでBuild Configurationの設定をする
categories: ios xcodegen
tags: ios swift xcodegen
---

- 署名情報
- ビルド環境を増やす

ビルド設定は、`settings`プロパティ下に記載します。
`settings`プロパティは全体とターゲットの2箇所で設定できます。

## プロパティ名の見つけ方
例えばXcodeのBuild Settings > Development Teamを用意する場合は`DEVELOPMENT_TEAM`プロパティをセットします。

{% page_image 1.png 50% XcodeBuildSettingsDevelopmentTeam %}

```yml
settings:
  DEVELOPMENT_TEAM: hogehoge    
```

ではどうやってXcodeのBuild Settingsとプロジェクト仕様のプロパティを一致させてるのか？  
それはxcconfigと同じ値を使っています。

実はxcconfigで使う値は、XcodeのBuild Settingsの各項目を選択してコピーするとxcconfigの値が取れます。
しかも下記のように設定がされている項目とBuild Configuration毎に分けてくれます。
未設定(デフォルト値)の部分は「//:completeSettings = some」以降になります。

```
//:configuration = Debug
SDKROOT = iphoneos
TARGETED_DEVICE_FAMILY = 1,2
LD_RUNPATH_SEARCH_PATHS = $(inherited) @executable_path/Frameworks
INFOPLIST_FILE = iOSWithCarthageProj/Info.plist
PRODUCT_BUNDLE_IDENTIFIER = com.mothule.iOSWithCarthageProj
FRAMEWORK_SEARCH_PATHS = $(inherited) $(PROJECT_DIR)/Carthage/Build/iOS
CODE_SIGN_IDENTITY = iPhone Developer
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon


//:configuration = Release
SDKROOT = iphoneos
TARGETED_DEVICE_FAMILY = 1,2
LD_RUNPATH_SEARCH_PATHS = $(inherited) @executable_path/Frameworks
INFOPLIST_FILE = iOSWithCarthageProj/Info.plist
PRODUCT_BUNDLE_IDENTIFIER = com.mothule.iOSWithCarthageProj
FRAMEWORK_SEARCH_PATHS = $(inherited) $(PROJECT_DIR)/Carthage/Build/iOS
CODE_SIGN_IDENTITY = iPhone Developer
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon


//:completeSettings = some
ADDITIONAL_SDKS
ARCHS
SDKROOT
// 〜 略 〜
```

## Build Configuration毎の設定

例えば`iOSWithCarthageProj`ターゲットの`settings`でBuild ConfigurationがDebug時の`CODE_SIGN_IDENTITY`を変更する場合は下記のようになります。

`configs`を使うことで各Build Configuration毎に値を設定できることができます。

```yml
targets:
  iOSWithCarthageProj:
    settings:
      configs:
        Debug:
          CODE_SIGN_IDENTITY: iPhone Developer
```


## 新しいBuild Configurationの登録

デフォルトはDebugとReleaseですが、新しく追加する場合は`configs`プロパティで追加します。

```yml
configs:
  Debug: debug
  Beta: release
  AppStore: release
```

値の部分がdebugまたはrelease以外だとデフォルト値が適用されなくなります。

## XcodeGenでEmbedded frameworkを登録する

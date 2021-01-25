---
title: XcodeGenのSettings周りを整理する
description: XcodeGenは便利ですが、settingsやconfigsやbase,settingGroupsや重複時の未指定時の挙動など不透明な部分が多い点を整理して説明した記事です。
categories: ios xcodegen
tags: ios xcodegen xcode xcconfig
image:
  path: /assets/images/2020-07-29-ios-xcodegen-settings/0.png
---
XcodeGenは便利ですが、プロジェクト仕様ファイル(project.yml)のSettingsに関して自分の中で不透明なので整理しました。

## Settingsとは？
XcodeGenのプロジェクト仕様ファイル内で使えるビルド設定を定義するプロパティと総称。

- `settings`はプロジェクトとターゲットの2箇所で使える
- ビルド設定の値の解決はレベル順となっている
- Build Configuration(DebugやReleaseなど)別でビルドパラメータを設定できる
- Build Configurationにも適用される`base`プロパティがある
- `settingGroups`でビルド設定を共通化できる
- Xcode同様に自動で適用されるプリセットビルド設定がある
- ビルド設定群を別ファイル(xcconfig)として抜き出せる

## ビルド設定はプロジェクトとターゲットで出来る

例えば次のプロジェクト仕様はプロジェクトとMyAppターゲットそれぞれでビルド設定をセットしています。

```yml
settings:
  SWIFT_ACTIVE_COMPILATION_CONDITIONS: [project_value]
targets:
  MyApp:
    settings:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: [target_value]
```

## ビルド設定の値の解決方法
ビルド設定の値はレベル順に見ていってる。

1. Target
1. Target xcconfig file
1. Project
1. Project xcconfig file
1. SDK defaults

Targetの設定が一番強く、下に行くほど範囲は広いが上書きされる。

検証するために次のプロジェクト仕様で確認する。

```yml
name: Settings
options:
  bundleIdPrefix: com.mothule
settings:
  SWIFT_ACTIVE_COMPILATION_CONDITIONS: [DEBUG, project_value]


targets:
  Settings:
    type: application
    platform: iOS
    sources: Settings
    settings:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: [DEBUG, target_value]
```

これを実際にXcodeで確認するとこうなる。

{% page_image 1.png 100% XcodeBuildSettings %}

想定通り、`Settings`ターゲットでは値は`target_value`で解決されてる。  
この挙動に関しては理解は容易と言える。


## Build Configuration別でビルドパラメータを設定できる

DebugやReleaseなどBuild Configuration別でビルド設定を変えることができます。  
例えば下記はDebug時は`DEBUG`が定義され、Release時は`RELEASE`が定義されます。

```yml
targets:
  MyApp:
    settings:
      configs:
        Debug:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: [DEBUG]
        Release:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: [RELEASE]
```


## Build Configurationにも適用される`base`プロパティがある
Build Configurationに依存せず設定したビルドパラメータを入れたい場合は、`base`を使います。

```yml
configs:
  Debug: debug
  CI: debug
  Release: release
settings:
  base:
    DEVELOPMENT_TEAM: HogeHoge
  configs:
    Debug:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: [DEBUG]
    CI:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: [DEBUG, CI]
    Release:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: [RELEASE]
```

この場合はどのBuild Configurationであっても`DEVELOPMENT_TEAM`は`HogeHoge`となります。


## `settingGroups`でビルド設定を共通化できる

例えばターゲットが5個あって、そのうち3つには同じビルド設定群がある場合、`settingGroups`を使うことで設定箇所を1箇所にまとめることができます。

下記は`settingGroups`を使わなかったケースです。

```yml
targets:
  App1:
    settings:
      DEVELOPMENT_TEAM: HogeHoge
  App2:
    settings:
      DEVELOPMENT_TEAM: HogeHoge
  App3:
    settings:
      DEVELOPMENT_TEAM: HogeHoge
  DebugApp:
    settings:
      DEBUG_MODE: YES
  StgApp:
    settings:
      DEBUG_MODE: NO
```

これだと1箇所ずつ更新する必要があり、更新し忘れなどが発生します。  
下記のように`settingGroups`を使うことで情報を1箇所に集約することができます。

```yml
settingGroups:
  app: # ← 任意のグループ名
    settings:
      DEVELOPMENT_TEAM: HogeHoge
target:
  App1:
    settings:
      groups: [app]
  App2:
    settings:
      groups: [app]
  App3:
    settings:
      groups: [app]
  DebugApp:
    settings:
      DEBUG_MODE: YES
  StgApp:
    settings:
      DEBUG_MODE: NO
```

## Xcode同様に自動で適用されるプリセットビルド設定がある
Xcodeがプロジェクトやターゲット追加時に自動で設定が設定されるのと同様に、XcodeGenにもプロジェクトとターゲットにデフォルト設定を設定する。  
プロジェクトにはDebugとReleaseの設定が、ターゲットにはプラットフォームとプロダクトタイプに応じた設定が適用される。

これらのプリセットを変更・無効するには`options.settingPresets`プロパティを使います。  
デフォルトでは`all`となっておりプロジェクトとターゲット両方に対して適用されています。  
もしターゲットだけ、プロジェクトだけとしたい場合は、`options.settingPresets: project`や`targets`とすることで部分適用されます。  
もし両方とも自動適用を無効にする場合は`none`になります。

## ビルド設定群を別ファイル(xcconfig)として抜き出せる
ビルド設定のボリュームが大きくなると、プロジェクト仕様全体として見通しの悪いファイルとなってしまいます。  
その場合は`configFiles`を使って`xcconfig`ファイルをインポートしてビルド構成を別ファイルに抽出できます。

```yml
configFiles:
  Debug: debug.xcconfig
  Release: release.xcconfig
targets:
  MyApp:
    configFiles:
      Debug: MyApp/debug.xcconfig
      Release: MyApp/release.xcconfig
```

`configFiles`でもプロジェクト単位とターゲット単位で設定できます。  
`xcconfig`について分からない方は「{% post_link_text 2020-07-30-ios-xcode-xcconfig-how-to-use %}」にまとめた記事をお読みください。

## 結論
この記事を書くにあたって、xcconfigの仕様を調べましたが、settings周りの仕様はxcconfigの仕様を把握すると理解が一気に深まりました。  
xcconfigについては「{% post_link_text 2020-07-30-ios-xcode-xcconfig-how-to-use %}」にまとめてあります。

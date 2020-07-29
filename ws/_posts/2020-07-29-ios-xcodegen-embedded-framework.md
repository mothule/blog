---
title: XcodeGenでEmbedded Frameworkを設定する
description: XcodeGenはXcodeによるアプリ開発において非常に有能なパッケージです。そんなXcodeGenでEmbedded Frameworkを設定する方法について説明します。
categories: ios xcodegen
tags: ios xcodegen
image:
  path: /assets/images/2020-07-29-ios-xcodegen-embedded-framework/0.png
---
XcodeGenを使ってEmbedded frameworkを設定する方法について説明します。

XcodeGenの基本的な使い方を理解していたら非常に簡単です。  
基本的な使い方が知りたい場合は下記記事をご覧ください。

- {% post_link_text 2020-07-28-ios-xcodegen-basic %}
- {% post_link_text 2020-07-28-ios-xcodegen-basic-usage %}
- {% post_link_text 2020-07-28-ios-xcodegen-carthage-cocoapods %}

## Embedded Frameworkとは？

Embedded Frameworkについて詳細を知りたい場合は、「{% post_link_text 2020-07-29-ios-embedded-framework %}」をご覧ください。

## XcodeGenでEmbedded Frameworkを作成する

まずは単純なiOSアプリターゲットを持つXcodeプロジェクトを用意します。

```yml
name: EmbeddedFramework
options:
  bundleIdPrefix: com.mothule
targets:
  EmbeddedFramework:
    type: application
    platform: iOS
    sources: EmbeddedFramework
```


ここからframeworkターゲットを追加し、アプリターゲットにリンクするまでが大まかな流れです。  
これをXcodeGenで表現すると、下記のようになります。


```yml
name: EmbeddedFramework
options:
  bundleIdPrefix: com.mothule
targets:
  EmbeddedFramework:
    type: application
    platform: iOS
    sources: EmbeddedFramework
    dependencies:
      - target: Logic
  Logic:
    type: framework
    platform: iOS
    sources:
      - path: Logic
```

実は`dependencies.target`で対象ターゲットを選ぶだけです。これだけでframeworkがリンクされます。

### 事前にフォルダ用意は必要
他ターゲットと変わらず、ターゲット追加時にはデフォルトでフォルダやファイルを作成してくれるので、
まずはXcode上でターゲットを追加してフォルダ作成後にプロジェクト仕様を追記する流れをおすすめします。

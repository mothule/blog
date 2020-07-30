---
title: xcconfigで使うパラメータ名の見つけ方
categories: ios xcode
tags: ios xcode xcconfig
image:
  path: /assets/images/2020-07-30-ios-xcode-xcconfig-how-to-search-build-config/0.png
---
TODO: リード文

xcconfigについて分からない方は「{% post_link_text 2020-07-30-ios-xcode-xcconfig-how-to-use %}」に詳細を説明してます。


## xcconfigへの変換はXcodeがサポートしてる
xcconfigの書き方が分かって実際に使おうにも、ビルドパラメータ名が分からないと設定しようがありません。  
XcodeのBuild Settingsでカスタマイズされた項目をxcconfigだとどうやって書けばいいか分からないと思います。  
実は**XcodeのBuild Settingsからxcconfigへのフォーマット変換はXcodeがサポートしてます。**

確認する方法は2つあります。

- XcodeのBuild Settingsの表示方法をパラメータ名に変更する
- XcodeのBuild Settingsの各パラメータをxcconfig形式でコピーする


## XcodeのBuild Settingsの表示方法をパラメータ名に変更

`Build Settings`を開いた後に`Editor > Show Setting Names`を選ぶと、表示されてるパラメータ名が表示用からコマンド用に変わります。

<video playsinline muted autoplay loop width="100%" height="400px">
    <source type="video/mp4" src="/assets/videos/2020-07-30-ios-xcode-xcconfig-how-to-search-build-config/0.mp4">
</video>

例えば、 `Architectures > Build Active Architecture Only`であれば、`ONLY_ACTIVE_ARCH`になります。  
これをxcconfigで使うなら`ONLY_ACTIVE_ARCH = YES`となります。

## XcodeのBuild Settingsの各パラメータをxcconfig形式でコピー

パラメータ名を確認するだけなら`Show Setting Names`で確認できますが、Xcodeはそれよりも強力な変換機能を備えています。  
実は`Build Settings`はコピー＆ペーストをサポートしており、対象ビルドパラメータをコピーしてテキストにペーストすると、xcconfig形式で貼り付けします。

{% page_image 1.png 100% XcodeBuildSettings %}

例えば`Build Active Architecture Only`の項目を選択し、コピー(⌘+C)してテキストエディタでペースト(⌘+V)すると、下記のように貼り付けされます。

```
//:configuration = Debug
ONLY_ACTIVE_ARCH = YES

//:configuration = Release

//:completeSettings = some
ONLY_ACTIVE_ARCH
```

`//:configuration = Debug`や`Release`とはBuild Configuration毎に分けられてます。
`Release`に何も表示されていないのは、カスタマイズ値ではなくデフォルト値なので空になります。

`some`はコピーしたビルドパラメータの明確ビルドパラメータ名が列挙されます。ここはxcconfigでは不要なので削除します。

もう一つ例として`Build Options > Debug Information Format`を見るとこうなります。
```
//:configuration = Debug
DEBUG_INFORMATION_FORMAT = dwarf

//:configuration = Release
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym

//:completeSettings = some
DEBUG_INFORMATION_FORMAT
```

これを使えばXcodeからxcconfigを作りたい場合に`Build Settings`の項目全部を選択してコピーすれば、簡単に現在のビルド構成を表現したxcconfigが作成できます。

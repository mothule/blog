---
title: XcodeをApp Storeからダウンロードせず旧バージョンと共存させる
categories: ios xcode
tags: ios xcode mac
image:
  path: /assets/images/2020-05-20-ios-xcode-dl-old-version/0.png
---
プログラマーにとって最新版のみを最短で追従するのはリスキーです。

## 旧バージョンのXcodeが必要な理由
Xcodeはバージョン毎にSwiftの最低バージョンやiOSの最低バージョンが決まっており、
最新のバージョンだけだと、hotfix版のために古いSwiftバージョンなど直したいときにビルドが通らなくなるためです。

### 例

|リリース日|App ver|Xcode ver|Swift ver|
|---|---|---|---|
|1ヶ月前|1.0|10.3|4.3|
|開発中|1.1|11.0|5.0|

アプリリース後にXcodeのバージョンを上げて、Swiftのバージョンアップ対応をしていたら、  
最新リリース版で緊急のクラッシュバグが発生しました。  
緊急のため開発中ブランチは一旦止めて、リリース版のrevisionから新しいブランチを切ってhotfix版としてリリースします。  
しかしリリース版は、Xcode/Swiftバージョンが今より古いバージョンでリリースしたものです。  
そのため、新しいバージョンではAPIが変わってたり、言語構文が変わったりしてビルドが通りません。

このように最新版のXcodeだけだと、開発環境を再現ができないリスクがあります。

## App Storeからダウンロードしないほうがいい理由

Xcode.appを一つしか使えなくなるためです。

バージョンアップは手軽ですが、古いバージョンと最新バージョンをApplicationフォルダに共存させれなくなります。

## 古いXcodeバージョンをダウンロードする

[More Downloads for Apple Developers](https://developer.apple.com/download/more/)(要ログイン)から過去バージョンをダウンロードできます。
また過去だけでなく最新バージョンやGM Seed版もダウンロードできます。

xipファイルを解凍後はXcode.appをApplicationフォルダに移動する前に、既存のXcode.appをリネームさせます。  
リネーム先は何でもいいですが、自分はバージョン番号をつけてます。

既存バージョンが11.2.1だったら `Xcode.app` → `Xcode11.2.1.app`にリネームする。

その後最新版Xcode.appをApplicationフォルダに移動させることで、最新版と旧版を共存させることができます。

何世代まで残しておくかは自分が取り掛かっている案件特性に応じて計画してください。  
私の今の環境では、1つ前のバージョンしか保持していません。  
前の環境では、3つほど保持していました。

## まとめ

- App Storeではなく[More Downloads for Apple Developers](https://developer.apple.com/download/more/)からダウンロードする
- 古いXcode.appはリネームして何世代か持っておく

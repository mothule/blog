---
title: Embedded frameworkの理解と作成方法
description: iOSアプリ開発ではiOSだけでなくwatchOSやtvOS,AppExtensionなどiOS以外でもコード流用性が高まっています。この記事ではそんな課題を解決するEmbedded frameworkの理解と作成方法について説明します。
categories: ios
tags: ios
image:
  path: /assets/images/2020-07-29-ios-embedded-framework/0.png
---
開発中のビルド時間の短縮やレイヤードアーキテクチャをより疎結合にする設計や、Extensionや他Platformなどでコード共有したい場合は、Embedded frameworkで解決できます。


## Embedded Frameworkとは？
事前に組み込まれたフレームワークです。static libraryみたいな扱いです。

### 例を使って説明
例えばiOSアプリターゲットにA,B,Cというソースコードが含まれてたとします。  
このうちCファイルを別のframeworkターゲットとして抜き出して、  
それを元のiOSアプリターゲットのフレームワークとして組み込む方法です。


## Embedded Frameworkのメリット

一見助長に感じる制御フローですが、次のケースでその恩恵を得られます。

### ケース1: 他プラットフォームのコード共有
最近のアプリケーションではiPhone(iOS)に留まらず、watchOSやtvOSなど複数端末で一つのサービスを横断して使うことでサービス体験を向上させてます。  
またAPIのバージョンアップによりアプリ外のサービスにも機能拡張できるApp Extensionによりアプリ外にもサービスロジックが必要になるなど、**現状のアプリは、複数プラットフォーム展開によるコード流用のニーズが高いです。**

|watchOS|AppExtension|
|---|---|
|{% page_image 1.png 100% watchOSTempl %}|{% page_image 2.png 100% AppExtension %}|

Embedded frameworkは、iOSアプリターゲットからコードを抽出し別ターゲットで管理することでiOSアプリターゲット以外でもframeworkとして使うことができることで、コード共有を実現しています。

### ケース2: ビルド時間の短縮
Xcodeで使われているビルダーではインクリメンタルビルドをサポートしており、開発中では主にこのビルド方式が多く使われます。
このインクリメンタルビルドは変更があった箇所と変更に影響ある箇所だけをビルドすることでビルド時間短縮します。

これをコードをframeworkで分離することでコード改修した箇所でframework先まではビルドされることはないので、より少ない時間でビルドが終わります。

同じ理論でビルド時間短縮してるのがCocoaPodsからのCarthageになります。

### ケース3: レイヤードアーキテクチャの疎結合を強化
Embedded frameworkといってもframeworkと同じ扱いになり、framework内の機能を使うには`import`しないとコンパイルエラーとなります。  
つまり言語レベルでレイヤー間のアクセス違反を検知してくれるようになります。  
（検知といっても検知した後はエンジニアが気づく必要があるので完璧とはいえないですが）

## Embedded Frameworkを作る

仕組みがシンプルですが、実装方法もシンプルです。

1. Frameworkターゲット追加
1. 作成されたフォルダ内にコード実装
1. アプリターゲット > Generalからフレームワークを追加
1. アプリ側コードからimportして呼び出し

では実際にLogicというEmbedded frameworkを用意し、中にはCalculatorという構造体を用意してみます。

### Frameworkターゲット追加

プロジェクトのGeneralからターゲット追加します。↓

{% page_image 3.png 100% XcodeTargetGeneral %}

Frameworkを選択します。↓  
注意点としてXcodeは定期的にUIを変更するため、時期によってはこの画面や名称とは違うケースがあります。

{% page_image 4.png 100% XcodeAddTarget %}


### 作成されたフォルダ内にコード実装

Frameworkターゲットを追加するとターゲットと一緒にフォルダも作成されます。

{% page_image 5.png 50% XcodeAddedFrameworkTarget %}

コードは何でもいいですが、今回は下記コードをFrameworkの管理するフォルダに追加します。

```swift
public struct Calculator {
    public static func plus(vals: Int...) -> Int {
        vals.reduce(0, +)
    }
}
```

#### アクセススコープに注意
framework全般の常識として外部から使われることを想定しているクラスやメソッドのスコープをpublicにして呼び出し元から見えるようにします。  
スコープ未指定だとframework外だと見えないので注意です。

### アプリターゲット > Generalからフレームワークを追加
作成したframeworkをiOSアプリターゲットから使えるようにするために関連付けする必要があります。  
アプリターゲットのGeneralからframework追加を行います。

{% page_image 6.png 100% XcodeAddFramework %}

`＋`を選ぶことで選択ダイアログが出てきますが、内部ターゲットになるのですぐ見つけれます。

{% page_image 7.png 80% XcodeAddFrameworkDialog %}

### アプリ側コードからimportして呼び出し

あとは使いたい場所でimportして呼び出すだけです。

```swift
import UIKit
import logic

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Calculator.plus(vals: 0, 1, 2))
    }
}
```

今回のコードは[GitHub](https://github.com/mothule/research_embedded_framework)にあげてあります。実際にXcode立ち上げて確認したい方はどうぞ。

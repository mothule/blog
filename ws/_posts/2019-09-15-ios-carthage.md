---
title: 今さらCarthage入門
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2019-09-15-ios-carthage/2019-09-15-ios-carthage.png
---

ライブラリ管理ツールとして市民権を得て暫く経つCarthageですが、iOS/Swiftに入門したばかりの人や使う機会がなかった人などもいると思います。

そんな人たち向けに改めてCarthageとは何か？どう便利なのか？どう使うのか？についてまとめてみました。  
なお、iOSアプリに主軸を置いて説明しています。


## CarthageとはSwift製ライブラリ管理ツール

Carthageとは、Swift製のライブラリ管理ツールです。

CocoaPodsと同様の立ち位置で、ライブラリ管理に便利なツールとなります。

## CarthageとCocoaPodsの違い

### CocoaPods

CocoaPodsは`$ pod install`でライブラリをインストールすると、対象プロジェクトに対してワークスペース(.xcworkspace)を作成をしたり、
プロジェクトに対してオプション更新をしたりと、導入が楽になっているかわりに高機能となっています。

作成されたワークスペースには、対象プロジェクトとは別に Podsプロジェクト(Pods.xcodeproj)が作成されており、
その中にライブラリとなるソースコードが含まれています。
ビルドすることでPodsプロジェクト内のソースコードも一緒にビルドされて、対象プロジェクトにはフレームワークとしてリンクされます。

リンク処理も全てCocoaPodsが自動で行ってくれます。

### Carthage

Carthageは最低限のライブラリからフレームワークの作成・更新のみとなります。
ワークスペースを作成したり、フレームワークをプロジェクトにリンクしたりはしません。
つまり、リンク処理は自分で行う必要があります。

## Carthageの利点

### ビルド時間の短縮
フレームワークのリンク構築を自分で行う必要がある、Carthageの利点は**ビルド時間の短縮**になります。

Carthageはコマンド実行するとライブラリをインストールしてフレームワークを作成します。
その作成されたフレームワークを、プロジェクトにリンクすることになるため、
つまり事前にフレームワークを作っておくことで、プロジェクトに対してのビルド時間が短くできます。

#### 速度差を測定してみる
ここでそれぞれのビルド時間を測定してみました。

- 測定は最初の5回は慣らし、5回目から数回測定。
- 測定ではRebuild(Clean+Build)で測定する。
- インストールライブラリはSwiftJSON。

|環境|min|max|avg|
|---|---|---|---|
|CocoaPods|3.208s|3.492s|3.308s|
|Carthage|1.478s|1.765s|1.60725s|
|vanilla|0.932s|1.143s|1.04967s|

効果としては期待どおりで、ビルド時間短縮を目的とするには、十分効果があると見てよいと思います。

### Xcodeの仕様変更に影響しにくい

Xcode内部の設定や仕様変更が行われるとCocoaPodsの場合は、ワークスペースや設定などを作成・更新をするため
ときとして動かないケースに出くわします。この場合、CocoaPodsが対応してくれるまで待ったあとにバージョンを上げる必要があります。

その点、Carthageはフレームワークを作成するだけなので、フレームワークの仕様が破壊変更されるなど、Xcodeの変更の影響を受けにくいので
開発安定性はCocoaPodsより勝っているとも言えます。

## Carthageの欠点

旨味の多いCarthageですが、欠点としては、

- 対応ライブラリがCocoaPodsより少ない
- 初期導入が少々面倒
- フレームワークの削除が少々面倒

の２つを上げておきます。

フレームワークの削除は、リンクを外す処理が必要になるため、その手間分面倒ということになります。
CocoaPodsの場合、Podfileから削除してインストールするだけで自動でリンクを外してくれます。

そして、対応ライブラリが少ないというのは、今の所一番痛い課題かと思います。
これに関しては今後時間による量が増えるのを期待するしかなさそうです。

## Carthageを導入する

ではCarthageの概要や利点について説明したので、実際に導入する手順について説明します。

1. Carghageをインストール
1. Cartfileにインストールしたいライブラリを記入
1. コマンド実行
1. リンク設定

になります。

### Carghageをインストール

最も手軽なHomebrewでインストールします。

```sh
$ brew install carthage
```
インストールされない場合は `$ brew update` 実行後の再実行してみてください。

### Cartfileを用意してライブラリを記入

- Cartfileファイルの用意
- Cartfileの編集

の順番でCartfileを作成します。

#### Cartfile作成

対象プロジェクトがあるディレクトリ上に `Cartfile` を作成してください。
```sh
$ cd <your xcode project>
$ touch Cartfile
```

※ touch: Cartfileという名前のファイルを作るだけのコマンドです。中身は空です。

#### Cartfile編集

テキストエディタでインストールしたいライブラリを追記します。
例えば SwiftyJSON であれば次のようにします。
これは githubのSwiftyJSONユーザーのSwiftyJSONレポジトリーを指しています。 [SwifthJSON](https://github.com/SwiftyJSON/SwiftyJSON)
```sh
$ cat Cartfile
github "SwiftyJSON/SwiftyJSON"
```

#### コマンドでインストールする

記入が終わったら保存して下記コマンドを実行します。
```sh
$ carthage update --platform iOS
```
`--platfrom iOS`というオプションは作成するフレームワークをiOSのみに指定するオプションです。
これがない場合、ライブラリによっては、OSXやwatchOS用もビルドが走ります。今回は使わないのでiOS指定をしています。

下記は、自分の環境で実行したときの結果です。

```sh
$ carthage update --platform iOS
*** Cloning SwiftyJSON
*** Checking out SwiftyJSON at "5.0.0"
*** xcodebuild output can be found in /var/folders/45/7f_wlrcs3xv6rmstcz2l5_000000gn/T/carthage-xcodebuild.MQ3JFo.log
*** Building scheme "SwiftyJSON iOS" in SwiftyJSON.xcworkspace
```

### プロジェクトにフレームワークをリンクする

コマンドによってフレームワークが作成されますが、まだプロジェクトにはリンクされていません。
プロジェクトに対してフレームワーク使うよう設定する必要があります。

### フレームワークをリンクする

プロジェクトのターゲットのGeneralを開いて、 `Linked frameworks and Libraries` を ＋ ボタンを押してください。
{% page_image -1.png %}

フレームワーク／ライブラリの選択画面が出るので、`Add Other...` ボタンを押してください。
{% page_image -2.png %}

ここで先程作成したフレームワークを指定します。

{% page_image -3.png %}

なおフレームワークは
```sh
$ ls -l Carthage/Build/iOS
total 288
-rw-------  1 mothule  staff  73046  9 15 14:31 11B6ADD2-B8F8-3816-830A-C3C0B53B18B2.bcsymbolmap
-rw-------  1 mothule  staff  70266  9 15 14:31 36F8ED49-B83F-3A70-B0D4-DED92A0D89E2.bcsymbolmap
drwxr-xr-x  6 mothule  staff    192  9 15 14:31 SwiftyJSON.framework
drwxr-xr-x  3 mothule  staff     96  9 15 14:31 SwiftyJSON.framework.dSYM
```
に作成されています。
次の図のように追加されていればOKです。

{% page_image -4.png %}


次に `Build Phases`上の ＋ ボタンを押して `New Run Script Phase` を選んでください。

{% page_image -5.png %}

`Run Script`フェイズが作成されるので、中にコマンドと、コマンドに渡す引数としてフレームワークのパスを指定します。

{% page_image -6.png %}

ちなみにこの `carthage copy-frameworks` を実行しなかった場合、ビルドは通りますが、実行すると次のエラーが起きます。
```
dyld: Library not loaded: @rpath/SwiftyJSON.framework/SwiftyJSON
  Referenced from: /Users/mothule/Library/Developer/CoreSimulator/Devices/1DB7E7C4-D7CD-44BA-B3F9-F66DC4E5EC51/data/Containers/Bundle/Application/6B0FDFCC-9D12-47D5-9B74-B837BE8FC983/UseCarthage.app/UseCarthage
  Reason: image not found
```

### まとめて指定も可能

Inputfilesに各フレームワーク毎にパス追記せずとも、xcfilelistという拡張子で指定することで一律管理も可能です。
手順は[公式](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)に記載されています。
番号5~9になります。英語ですが、英語読めなくとも手順は読み取れると思います。


## デバッグについて

事前に構築されたフレームワークは、フレームワークが構築されたPC以外でのステップ実行などはできません。
その場合は、
```sh
$ carthage update --platform iOS --no-use-binaries <library name>
```
で解決することができます。

## Cartfileの記法について

### ライブラリのバージョン指定

```
github "SwiftyJSON" ~> 4.2.0
github "Hoge" >= 4.2.0
github "Fuga" == 4.2.0
github "Nuga" "ブランチ or タグ or revision"
```

のように指定が可能です。
[参考](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement)

### GitHub以外からライブラリインストール

```
github "https://enterprise.local/hoge/fuga/perfect-library" # GitHub Enterprise
git "https://enterprise.local/hoge/fuga/perfect-me.git" # Other Git repositories
```


## テスト環境限定のライブラリインストール
テストでしか使用しないフレームワークは通常のCartfileではなく`Cartfile.private`ファイルを用意して、インストールします。

```
$ touch Cartfile.private
```

中身の書き方は通常のCartfileと変わりません。

注意点としては、プロジェクトへのリンク設定で、ターゲットをテストに対して行うことを忘れずに。

## git管理について
作成されたフレームワークやその他データに関して全てのgit管理する必要はありません。
使うのはフレームワーク成果物だけで、それ以外の途中データは、再現可能なデータであるため.gitignoreに追加しても大丈夫です。

私の環境では次のようにしています。
```
# Carthage
Carthage/Checkouts
!Carthage/Build
```

## Carthage管理のライブラリ更新

ライブラリが更新されたらCarthageにはライブラリを更新するコマンドが用意されています。

例えば次のシェルはこのような意味になります。

- `SwiftJSON`と`APIKit`を更新
- GitHubなどにアップロード済みのzipなどを使わず、コードから
- iOSプラットフォームだけを対象

```sh
$ carthage update SwiftyJSON APIKit --platform iOS --no-use-binaries
```

`--platform iOS`はiOSアプリでしか使わないのであれば他プラットフォーム用ビルドをしても意味ないので、その場合はこのオプションをつけます。  
`--no-use-binaries`はGitHubなどにビルド済みがzipなどでアップロードされてる場合はそれを使おうとするので、それを使わずコードからビルドしたい場合はこのオプションをつけます。
バイナリ使ったほうが更新処理は早いのですが、もしアップロードされてるSwiftバージョンが異なったりするとエラーとなるので、そこが気になるならこのオプションをつけといたほうがいいです。
少し時間がかかるぐらいなので。


## まとめ

以上がCarthageの入門記事になります。

他にも色々な機能や仕様を含んでおりますが、全部を紹介すると、入門として知っても慣れず、腹落ちしにくいかと思うので省きました。

当然ながら、[公式](https://github.com/Carthage/Carthage)には記載がされているので暇があったら少しずつ追うのもいいかもしれません。
README.mdだけでなく[Documentation](https://github.com/Carthage/Carthage/tree/master/Documentation)もあるので見落とさず。

`Carthage`シンプルなまま対応ライブラリが増えるといいですね。

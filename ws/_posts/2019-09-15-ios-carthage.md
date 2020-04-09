---
title: Carthageの実務での使い方
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2019-09-15-ios-carthage/2019-09-15-ios-carthage.png
---

ライブラリ管理ツールとして市民権を得て暫く経つCarthageですが、iOS/Swiftに入門したばかりの人や使う機会がなかった人などもいると思います。

また個人では使ったことあるけど会社などチームとして使ったことがない人もいるかと思います。

そんな人たち向けに改めてCarthageとは何か？どう便利なのか？どう使うのか？についてまとめてみました。  
なお、iOSアプリに主軸を置いて説明しています。

この記事は実際に実務において私が運用から得た知見を元にまとめた記事となります。

## Carthageの読み方
`カーセージ`と`カルタゴ`の２つに大きく分かれています。
[Wikipedia](https://ja.wikipedia.org/wiki/%E3%82%AB%E3%83%BC%E3%82%BB%E3%83%83%E3%82%B8)見た感じだと、
`カーセッジ`が正解な気もします。  
が、私としてはどれでもいいのです。


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

## Carthageのメリットは早くて安定

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

## Carthageのデメリットは初期導入と対応ライブラリ数とライブラリ削除

旨味の多いCarthageですが、欠点としては、

- 対応ライブラリがCocoaPodsより少ない
- 初期導入が少々面倒
- フレームワークの削除が少々面倒

の3つを上げておきます。

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


## Carthage成果物のgit管理について
作成されたフレームワークやその他データに関して全てのgit管理する必要はありません。
使うのはフレームワーク成果物だけで、それ以外の途中データは、再現可能なデータであるため.gitignoreに追加しても大丈夫です。

私の環境では次のようにしています。
```
# Carthage
Carthage/Checkouts
!Carthage/Build
```

### Carthage BuildはGitに必要
Carthage update などを実行することでライブラリとなるソースコードがダウンロードされてローカルでビルドされたり、サイト上に配置されたバイナリをダウンロードして解凍されることで、成果物をBuildディレクトリに展開されます。
この中にXcodeに指定するフレームワークが格納されています。

そのためここをGitにあげないと他環境からビルドした場合にフレームワークが見つからずビルドエラーとなります。


## Carthage --no-use-binariesでデバッグ可能にする
ライブラリによってはGitHubなどに既にビルド済みのフレームワークが用意されており、Carthageは特に指定がなければそれを使ってインストールして時間短縮を行っています。

しかし、事前に構築されたフレームワークは、フレームワークが構築されたPC以外でのステップ実行などはできません。
その場合は、
```sh
$ carthage update --platform iOS --no-use-binaries <library name>
```
というふうに **--no-use-binaries** オプションんを使うことで解決することができます。

## CarthageのCartfileでライブラリのバージョン指定する方法
Carthageでライブラリのバージョンを指定するには、Cartfileに決まった書き方をすることでライブラリのバージョンを制御することができます。

例えば次のようなCartfileが

```
github "SwiftyJSON" ~> 4.2.0
github "Hoge" >= 4.2.0
github "Fuga" == 4.2.0
github "Nuga" "develop"
github "Moga" "ab12c3ef4"
```

それぞれ順に説明していきます。

### ~>で範囲指定する
最も多く使われてるであろう書き方です。
例えばバージョン履歴が下記だった場合で説明します。

- 4.2.0
- 4.2.1
- 4.3.0
- 5.0.0

このときにCartfileで`github "Hoge" ~> 4.2.0`が記入された状態で`update`を実行したら`4.2.1`までアップデートします。  
もし`github "Hoge" ~> 4.2`が記入されてたら`4.3.0`までアップデートします。

なかなか範囲が覚えにくいと思いますが、最後の数字が`x`に置き換えて見れば分かりやすくなります。  
例えば `github "Hoge" ~> 4.2.0`であれば`4.2.x`系です。  
`4.2`なら`4.x`系です。つまり4系バージョンですね。

### >= で指定バージョン以上

指定バージョン値以上のバージョンを指定します。
Cartfileに`github "Hoge" >= 4.2.1`と記入された状態で
バージョン履歴が下記だった場合は、`5.0.0`がインストールされます。

- 4.2.0
- 4.2.1
- 4.3.0
- 5.0.0

この書き方は少し破壊変更リスクが伴うため使う側としてはオススメしないです。  
こっちよりも前述した範囲指定のほうが安全性をそれなりに維持できます。

### == で指定バージョンのみ

もっとも安全なバージョン指定方法です。
Cartfileに`github "Hoge" == 4.2.1`と記入されていたら
他にバージョンが出ていても `4.2.1`しかインストールされません。

丁寧にバージョンアップをしたいライブラリや開発運用に適した方法です。

### revisionでコミット指定

GitHub上のコミットを名指しでインストールします。コミットで発行されているrevisionを使います。  
またrevisionだけでなくブランチ名でも使えます。

使っていたライブラリに不具合や脆弱性、iOS最新版が出たけどライブラリ側がバージョンを切っていない状態など
緊急時で使うことがあるので覚えておいたほうがいいです。

[Carthage公式のVersion requirement](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement)でも英語ですが説明セクションはあります。

## CarthageでGitHub以外のライブラリを使う方法

大半のライブラリはGitHubにあるとは思いますが、全てのライブラリではありません。
例えば社内限定であれば自社内にOSSのGitレポジトリがありますし、GitLabやGitBucketもあります。
その場合はCartfileに次の書き方でそれぞれのライブラリをインストールできるようになります。

```
github "https://enterprise.local/hoge/fuga/perfect-library" # GitHub Enterprise
git "https://enterprise.local/hoge/fuga/perfect-me.git" # Other Git repositories
```


## Carthageにテスト用ライブラリをインストールする方法
テストでしか使用しないフレームワークは通常のCartfileではなく`Cartfile.private`ファイルを用意して、インストールします。

```
$ touch Cartfile.private
```

中身の書き方は通常のCartfileと変わりません。

注意点としては、プロジェクトへのリンク設定で、ターゲットをテストに対して行うことを忘れずに。



## Carthage updateでライブラリ更新する方法

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

## Carthage bootstrapで非更新でビルドする

Carthageにはフレームワークをビルドする方法として `update` ともう一つ `bootstrap`があります。

この２つの違いをざっくり表すと

- update: 最新版あればそれ使う
- bootstrap: 環境を再現する

になります。

### Carthage updateで最新版あればそれ使う
`$ carthage udpate`はCartfileに記載されたライブラリやバージョンからライブラリをビルドしてフレームワークを作成します。
そのため、実行時に新しいバージョンが公開されていて、かつCartfileにそのバージョンを取り入れる書き方をしていたら新しいバージョンを取り込んでフレームワークを作成します。

### Carthage bootstrapで環境を再現する
`$ carthage bootstrap`はCartfileではなく、Cartfile.resolvedに指定されているバージョンを使ってフレームワークを作成します。新しいバージョンが出ていても、Cartfile.resolved更新当時のバージョンが使われます。

### ライブラリ更新者はupdateでCIや環境構築はbootstrapを使う
これら２つの使い分けに関しては、次のルールにそうといいでしょう

- `update`
  - ライブラリ更新者が実施する
- `bootstrap`
  - CIでcarthageを使う場合
  - Buildディレクトリをgitにあげない運用で他環境で環境構築する場合

面倒であれば前述したようにBuildディレクトリをgit管理下にすることで`update`に絞ることができると思います。

## まとめ

他にも色々な機能や仕様を含んでおりますが、全部紹介せずとも実際に実務で使う分には十分なボリュームになっているかと思います。

当然ながら、[公式](https://github.com/Carthage/Carthage)には記載がされているので暇があったら少しずつ追うのもいいかもしれません。
README.mdだけでなく[Documentation](https://github.com/Carthage/Carthage/tree/master/Documentation)もあるので見落とさず。

今後も`Carthage`自体がシンプルなままで、対応ライブラリが増えるといいですね。

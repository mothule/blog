---
title: iOS開発環境には重要エコシステムとなるMintの理解と利用
description: iOS開発ではXcodeだけでなくSwiftLintやXcodeGenなどエコシステムが開発体験を向上させます。Mintではそれらツールのバージョン管理を可能にするパッケージマネージャーであり従来のHomebrewの課題を解決する重要なツールです。この記事ではMintの理解と利用について説明します。
categories: ios mint
tags: ios mint swift
image:
  path: /assets/images/2020-07-31-ios-mint-basic-usage/0.png
---
HomebrewでSwiftLintのバージョンを上げたら、別プロジェクトにも影響与えてコントロール失う経験ありますよね。Mintはそれを解決します。

## Mintとは？
[Mint](https://github.com/yonaskolb/Mint)は、**Swift製コマンドラインツールのパッケージマネージャーです。**
ツールのインストールと実行ができます。

同じパッケージマネージャーにHomebrewがあり、そちらのほうが遥かにメジャーです。  
Swift製ツールもHomebrewからインストールできますし、  
パッケージマネージャーとして使いやすく安定しています。

では「何故Mintがいいのか？Homebrewじゃ駄目なのか？」について説明します。

## iOS開発におけるHomebrewが抱える課題
通常はMac1台に複数のiOSアプリやSwiftアプリを開発するはずです。  
各プロジェクトでは開発環境に差異あれど、同じツールを使うことは当然ありえます。  
同様にそれぞれ使ってるバージョンが異なることも起きます。

しかし、**Homebrewは異なるバージョンのツールをバージョン別管理ができません。**  
そのためツールをバージョンアップすると、各プロジェクトに影響を与え動作しなくなるリスクがあります。

## Mintが解決する課題
Mintは、バージョン別管理を可能とし、管轄外のバージョン変更課題を解決します。

Mintでは、`Mintfile`によりプロジェクト毎にバージョンを管理できます。  
これにより**PC内の複数プロジェクト間のSwiftツールの疎結合を実現します。**

## Mintのパッケージ管理方法について

- バージョン別でパッケージを管理します
- バージョン指定でパッケージを実行できます
- パッケージはシンボリックリンクでパスを通してどこからでも実行できます
- パッケージとバージョンの一覧をMintfileというプレーンテキストで管理できます。

## Mintのインストール方法

Homebrewでインストールできます。
```sh
$ brew install mint
```

他にも[Make](https://github.com/yonaskolb/Mint#make), [Mintコード](https://github.com/yonaskolb/Mint#using-mint-itself), [Swift Package Manager](https://github.com/yonaskolb/Mint#swift-package-manager)からもインストールできます。

## Mintでパッケージをインストールする方法

Mintでパッケージをインストールするには`mint install`コマンドを使います。  
例えば[XcodeGen](https://github.com/yonaskolb/XcodeGen)の最新版をインストールするなら下記になります。
```sh
$ mint install yonaskolb/XcodeGen
```

### バージョン指定でインストール
バージョンを指定してインストールするならパッケージ情報の末尾に`@x.x.x`形式でバージョン情報を渡します。

```sh
$ mint install yonaskolb/XcodeGen@1.2.4
```

### パスを通さずインストール
デフォルトではインストールすると`/usr/local/bin`にシンボリックリンクを作成します。  
これによりどこからでもアクセスできるようになります。  
もしインストールするパッケージをリンクしたくない場合は`--no-link`をつけます。

```sh
$ mint install yonaskolb/XcodeGen@1.2.4 --no-link
```

### 再インストール
`--force`オプションをつけることで再インストールできます。
```sh
$ mint install yonaskolb/XcodeGen@1.2.4 --force
```

## Mintでパッケージを実行する方法
Mintでインストールしたパッケージを実行するには、`mint run`コマンドを使います。  
例えば最新版の`XcodeGen`で`generate`を実行したい場合は下記になります。
```sh
$ mint run XcodeGen generate
```

ちなみに小文字でも動きます。

```sh
$ mint run xcodegen generate
```

### バージョン指定で実行
Mintにインストールしてるパッケージが複数バージョンある中で、  
リンクしてない古いバージョンを実行する場合は、  
バージョン情報をつけることで指定実行できます。

```sh
$ mint run xcodegen@1.2.4 generate
```

## Mintfileでパッケージ管理する方法
Mintでは指定のパッケージとバージョンを列挙して一度にインストールしたりアップデートできます。  
例えばiOSアプリ開発のGit管理下にMintfileを置くことで、そのレポジトリで使うツールやバージョンを制御することができます。  

このMintfileを利用することでプロジェクト間のバージョン差異における干渉を解決します。

### Mintfileの書き方
至って簡単です。コマンドラインでインストールや実行するときに指定してる方法と同じです。

*Mintfile*
```
yonaskolb/XcodeGen@2.16.0
realm/SwiftLint@0.39.2
```

## Mintfile内のパッケージを使う
そのまま`mint run xcodegen`と実行すれば、インストールされてなければインストールして実行してくれます。
まとめて指定バージョンを予め全部インストールしておきたい場合は、`mint bootstrap`コマンドを実行します。
`mint bootstrap`ではデフォルトはリンク処理を行いません。  
もしリンク処理したい場合は`mint bootstrap --link`で実行してください。

### 注意: Mintfileの有効範囲について
rbenvや.gitignoreなどと異なり、カレントディレクトリ上にMintfileが見つからない場合はバージョン解決はMintfileで行いません。
例えば次のツリー構造のとき、Bディレクトリで`mint run xcodege`を実行すると`Mintfile`内のバージョンではなくMintがインストールしてる最新で実行します。

- Aディレクトリ
  - Mintfile
  - Bディレクトリ

Mintfileのないディレクトリ上でmintコマンドを実行する場合は注意してください。

## その他オプション

### mintからの出力を止める

`--silent`オプションを使います。

*--silentなし*
```sh
$ mint run xcodegen version
🌱 Finding latest version of XcodeGen
🌱 Running xcodegen 2.16.0...
Version: 2.16.0
```

*--silentあり*
```sh
$ mint run --silent xcodegen version
Version: 2.16.0
```

### mintのキャッシュパスとリンク先を変える

`MINT_PATH`を変更することでインストールしたパッケージの保存場所を変更できます。  
デフォルトは`/user/local/lib/mint`です。  

`MINT_LINK_PATH`を変更するとシンボリックリンクの作成場所を変更できます。  
デフォルトは`/usr/local/bin`です。

## 実際にXcodeプロジェクトに組み込む

SwiftLintを実際に組み込んでみます。  
小さいですが一応[GitHub](https://github.com/mothule/research_mint)にも上げてあります。  
git cloneして`mint bootstrap`を試してみるのもいいかもしれないです。

HomebrewではBuild Scriptでは
```sh
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```
ですが、

Mint経由でインストールした場合は、

```sh
if [[ -f ./Mintfile ]] ; then
  mint run swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```
と、実行条件とシェルコマンドを変える必要があります。

### 実行条件はMintfileを見たほうがいい
ネットで見かけた記事では↓のようにmintコマンドの有無でシェルコマンドを実行していましたが、  
MintはMintfileがなくても、`mint run swiftlint`と実行すれば勝手に最新版を取ってきて実行するので、  
mintコマンドの有無ではなく、Mintfileの有無のほうが「知らぬ間に最新版で実行してた」を防げると思います。

```sh
if which mint >/dev/null; then
  mint run swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

---
title: Carthage bootstrapとGit管理をチーム運用観点で整理
categories: ios carthage
tags: ios carthage
image:
  path: /assets/images/2020-05-15-ios-carthage-team-collaboration/0.png
---

この記事ではcarthage bootstrapとは何か？Git管理はどうするか？をチーム運用観点でこれら関係性を整理します。

## carthage updateとbootstrapの違い
carthage bootstrapについて説明します。

説明には、carthage bootstrapと比較するコマンドや関係するファイルを用いて説明します。

1. carthage updateは`Cartfile`を見てframeworkと`Cartfile.resolved`を作成する
1. `Cartfile.resolved`は実際に作成したframeworkの`ライブラリ`と`バージョン`が記載されてる
1. `carthage bootstrap`は`Cartfile.resolved`を見てframeworkを作成する
1. carthage updateは`Cartfile`を見て**なるべく最新**のライブラリバージョンを選ぶ

1、2、3をイメージで説明します。

{% page_image 1.png , 100% , Carthageのupdateとbootstrapの違い %}

- carthage updateはCartfileを使ってCartfile.resolvedとフレームワークを更新します。
- carthage bootstrapはCartfile.resolvedを使ってフレームワークを更新します。

そして最も大きな違いは、**carthage updateには冪等性がなく、carthage bootstrapには冪等性がある点です。**

### carthage updateの動き
例えば、carthage updateを5月1日に実行して、SwiftyJSON ver4のframeworkが作成されます。  
半月後にSwiftyJSONが新しいバージョンver5をリリースします。  
更に**半月後にもう一度carthage updateを実行すると、SwiftyJSON ver5のframeworkが作成されます。**

{% page_image 2.png , 100% , Carthage updateの動き %}

つまり、**carthage updateはライブラリ更新をします。**


### carthage bootstrapの動き
updateではなくbootstrapですると、  
1ヶ月後でもframeworkのバージョンは変わりません。

{% page_image 3.png , 100% , Carthage updateの動き %}

つまり、**carthage updateは環境を再現します。**


### carthage updateとbootstrapの使い分け

ライブラリの新規・更新はupdate、環境構築はbootstrapとして使います。

- updateを使うケース
  - ライブラリを追加する
  - ライブラリのバージョンを上げる
- bootstrapを使うケース
  - 新しくチームメンバーが入ってきて、開発環境を構築する
  - 別メンバーがライブラリのバージョンを更新した

## CarthageとGit管理

`carthage update`で`Carghage`ディレクトリと`Carthage.resolved`ファイルが生成されますが、  
これらはGit管理下に加えるべきでしょうか？除外すべきでしょうか？

方法は2つあります。

`Cartfile.resolved`だけをGit管理下において、`carthage bootstrap`で`Carthage`ディレクトリを再現する方法と、  
`Cartfile.resolved`と`Carthage`ディレクトリの両方をGit管理下においてgit cloneだけで再現環境を実現する方法です。

### Cartfile.resolvedのみをGit管理下にする
`Cartfile.resolved`はライブラリ名とそれらのバージョンが記載されたファイルであることは説明しました。  
しかし`framework`はないので、`carthge bootstrap`コマンドを使って必要なframeworkを構築します。

### Cartfile.resolvedとCarthageディレクトリ
`Cartfile.resolved`は他環境で再現をする上で必要です。  
そこに加えて、`Carthage`ディレクトリがあることで、frameworkの生成が不要になります。

#### Buildのみにする
`Carthage`ディレクトリ全てをGit管理下不要です。  
必要なのは生成済みframeworkなのため、`Carthage/Build`ディレクトリのみで問題ありません。

そのため`.gitignore`に追記が必要です。

```
Carthage/Checkouts
!Carthage/Build
```

### どちらがいいのか？
これは議論されているので、どちらがいいのか確定的なものはありません。  
答えとしては案件によります。  
なのでネットで「こちらがいい」と書いてあっても鵜呑みは危険です。  
理由を見てそれが自分が適用しようとしてる条件に一致しているか判断することを進めます。

ここではそれぞれのメリット・デメリットを部分的に抜粋します。  
公平にするため、私情は入れず事実のみを載せます。

- Cartfile.resolvedのみ
  - CIで毎回bootstrapでframework作成が必要
  - bootstrapが失敗するリスクがある
  - ライブラリ更新済みと未更新ブランチをまたぐとbootstrapが必要

- Cartfile.resolvedとCarthage
  - Swift versionを変更すると再生成が必要
  - Pull Requestでdiffが増える
  - git cloneが遅くなる
  - 1ファイル100MBがあるとプッシュできない

#### Swift versionを変更すると再生成が必要
`Module Stability`の有効になっていないライブラリでは、Swiftのバージョンを上げるたびにframeworkの再生成が必要です。

### ライブラリ更新後はbootstrapが必要
別メンバーがライブラリを更新したブランチをマージさせたら、  
bootstrapでframework再生成が必要です。

#### Pull Requestでdiffが増える
frameworkは1つのファイルではなくディレクトリになっており、中にファイルやディレクトリがあります。  
そのファイル数だけGit管理となるため、frameworkを追加や変更したときのdiffは量が増えます。

#### CIで毎回bootstrapでframework作成が必要
CIなど新規環境下で環境構築をする場合は、bootstrapを実行してframeworkを生成する必要があります。  
当然ですが、その分CI時間はかかります。

#### bootstrapが失敗するリスクがある
Carthageはxcodebuildでframeworkを生成しています。  
可能性は低いのですが、私の環境でも何度か起きており、xcodebuildのバージョン差異や他要因で失敗することがあります。

つまりそれは最悪Git管理下の情報だけでは環境再現が不可能となります。

#### git cloneが遅くなる
frameworkに関するファイル数が増える分、ファイル数やデータ数は増えるのでそれだけclone時やpull/fecthでのダウンロード時間は増えます。

#### 1ファイル100MBがあるとプッシュできない
GitHubでは1ファイル100MB以上のファイルコミットはできない制限が設けられており、LFSの設定が必要になります。

## 私のチーム運用観点

私が過去に経験してきたチームでのCarthage運用は次の通りです。

- `Carthage/Build`ディレクトリはコミットしない
- Swiftバージョン更新時は、別ブランチからPull Request通す
- Cartfileではバージョン指定してる

そして下記はそれぞれのメリット・デメリットに対する考えです。

- Swift versionを変更すると再生成が必要
  - バージョン上がる度毎回変更してます
- ライブラリ更新後はbootstrapが必要
  - 不要です。しかしGitからの取得量は増えます。
- Pull Requestでdiffが増える
  - バージョンを上げるだけのブランチなのでそもそもそのdiffを殆ど見ないです
- CIで毎回bootstrapでframework作成が必要
  - これはコミットしてるので不要です
- bootstrapが失敗するリスクがある
  - バージョン固定してるので`bootstrap`を使ってないです
- git cloneが遅くなる
  - 使っているfrmaeworkは10個ですが、それぞれのサイズは大きくはないので気になるほどになってないです
- 1ファイル100MBがあると運用不可能
  - 使ってるframeworkに1ファイル100MBを超えるものはありません。


バージョン上がるたびに全てのframework生成は時間がかかります。  
それ以上に回数的にCIにかかる時間が増えます。  
CIにキャッシュ仕込むのもありますが、CIが限定されますし、そのために開発環境が多少複雑にはなります。  
git cloneが時間かかるとありますが、git cloneよりbootstrapの方が遥かに時間がかかります。  
そして昔のCocoaPodsのように再現性がなくなることのリスクも気になります。

なおこれは私の経験した案件にフィットした運用ですので鵜呑みにせず参考にしてください。

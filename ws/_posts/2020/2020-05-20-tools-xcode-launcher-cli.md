---
title: コマンドラインからいい感じにXcodeプロジェクトを開くスクリプト作った
description: iOSで使うXcodeをターミナルなどコマンドラインからプロジェクトを開くときにxcodeprojかxcworkspaceなのか判断をいい感じにしてくれるスクリプトを作ったので紹介する記事です。
categories: tools
tags: tools xcode ruby
image:
  path: /assets/images/2020-05-20-tools-xcode-launcher-cli/eyecatch.png
---
キータイプ数「open hoge.xcworkspace」を「**xc**」にまで減らします。  
`xcodeproj`か`xcworkspace`かいちいち確認不要になります。

iOSエンジニアでもターミナルを使う頻度は非常に高いです。  
そのためターミナル上からXcodeプロジェクトを開くことも多いです。

## ターミナルからXcodeプロジェクトを開く
ターミナルからXcodeプロジェクトを開く場合は次のコマンドになります。

```sh
$ open hoge.xcodeproj
```

しかしCocoaPodsを入れたりすると、xcodeprojではなく`xcworkspace`を開く必要があります。  
そのためターミナルでは次のコマンドになります。

```sh
$ open hoge.xcworkspace
```

プロジェクト毎にxcodeprojなのかxcworkspaceなのかlsコマンドで確認するのは面倒です。  
それが毎日来る日も来る日も、色々なプロジェクトをターミナルで開いているとますます面倒です。

## ターミナルからいい感じにXcodeプロジェクトを開くスクリプト
ターミナルからXcodeプロジェクトを開く上でチリツモで面倒な作業なので勝手に判断して開くスクリプトを作りました。

[mothule/xc_launcher](https://github.com/mothule/xc_launcher)

{% page_image 1.gif , 100% , xcコマンドの動作 %}

### xcコマンドの使い方
使い方は簡単です。`xc`コマンドを叩くことでカレントディレクトリからXcodeプロジェクトを見つけて起動します。  

```sh
$ cd your/xcode/proj/path
$ xc
```

ディレクトリパスを指定すれば別ディレクトリ内のXcodeプロジェクトを開こうとします。

```sh
$ xc your/xcode/proj/path
```

### xcコマンドの特徴
このコマンドは次の特徴を持ってます。

- xcodeprojとxcworkspaceがあればxcworkspaceを開く
- Xcodeプロジェクトが複数あればAZ順の最初のXcodeプロジェクトを開く

### インストール方法

1. 1ファイルになっているのでファイルをGitHubから直接ダウンロード
1. chmod 711で実行権限付与
1. PATHの通った適当な場所にシンボリックリンクを引く

詳しくはGitHubページにも書いてあります。
[mothule/xc_launcher](https://github.com/mothule/xc_launcher)

## iOSエンジニアもスクリプトを書こう

今回スクリプトはRubyで書きました。  
iOSエンジニアにとってRubyは身近な言語です。  
fastlaneやCocoaPodsはRubyで書かれています。

あなたもiOSエンジニアならRubyを覚えて、  
身近な面倒くさいをスクリプトで解決して開発体験を向上させましょう。  
なおRubyでスクリプトを書く場合は「{% post_link_text 2020-02-08-ruby-script-basic %}」の記事を参考にしてみてください。

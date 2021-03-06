---
title: iOSでMVVMする前に基本を整理する
description: iOSでMVVM(View-Model-ViewModel)アーキテクチャを採用するにあたりMVVMを知ることで、メリットを活かしデメリットを抑えるために基本を説明します。
categories: ios swift
tags: notebook program-design ios
image:
  path: /assets/images/2020-08-08-ios-swift-mvvm/0.png
---
MVVMを知らなかったり曖昧知識で採用すると、MVCとは異なる部分で問題がおきるだけです。  

## MVVMとは？
アーキテクチャパターンの一つ。
MVCの派生パターンでModel-View-ViewModel
プレゼンテーションとドメインを分離することで保守性と生産性を貢献する。

### Model
アプリのドメイン（問題領域）を担当する。
ここで、このアプリが解決するドメイン(問題領域)のデータと手続き処理（ビジネスロジック）を表現する。  
その他にも永続化ロジック、通信ロジックも含める。

#### 表示寄りデータの扱い
アプリが背景色や文字色や余白のサイズなど表示カスタマイズ機能をもつ場合は、  
それら表示に関する情報を保持するのはModelになる。  
もちろんModelの情報はViewModelを経由してバインドされる。

#### 注意点
一般的にドメインを担当すると決めつけると混乱が生じる。
例えばサーバの存在するクライアント・サーバモデルだとドメイン(問題領域)はサーバ側にあたるため、
クライアント側はアプリケーションとしてみたときにドメインではなくプレゼンテーションに該当する。

ModelはViewとViewModelの役割以外の部分を担うのが妥当。

### View
UIへの入出力を担当。

- アプリが扱うデータをユーザーに向けて表示
- ユーザーからの入力を受け取る

MVVMにおけるViewはViewModelが持つデータを`データバインディング`機構を通じて自身の担当領域を全うする。
Viewは複雑なロジックと状態を持たないのがMVVMのViewの特徴。

#### データバインディング
RxSwiftやReactiveSwiftやCombineなどを使って、予めデータとイベントと振る舞いの関係性を宣言しておくことで、  
実際のイベント発生時には宣言した処理フローに従って振る舞いが行われる。

### ViewModel
Viewが状態やロジックを待たない分ここで解決する。
Viewの見た目に影響する状態の保持、Viewから受け取った入力を適切な形に変換しModelに伝達する役目。
つまりViewとModel間の情報伝達とView用状態保持の役割を持つ。

### ViewModelとModel間のバインディング
MVVMではView-ViewModel間はデータバインディング機構を使うことでメッセージフローを実現している。  
では、ViewModel-Model間も同様にデータバインディングを行ってはいけないのか？というと、それは別に構わないと思っている。  
MVVMはアーキテクチャパターンであり、そこから肉付けするのは自由だから。
メッセージフローを統一する観点においてデータバインディングやオブザーバーパターンによるメッセージフローの仕組み化を行うことは問題ないと見れる。

## iOSでMVVMを実現するには
MVVMは特性上`データバインディング`が重要な機能となる。  
iOSではViewとViewModel間の情報伝達を手動で同期が必要となるため、そのままでは実現コストが高くMVVMメリットへのコスパが悪い。
そのためiOSでMVVMアーキテクチャを実現するためには、データバインディング機構を何らかの方法で取り込む必要があります。

### データバインディング機構を提供するライブラリ
一般的に認知度の高いデータバインディング機構を提供してるライブラリ下記になります。

- RxSwift
- ReactiveSwift
- Combine

この中でCombineはiOS13からApple公式frameworkとして提供されています。  
近い将来公式のCombineがデファクトスタンダードとなるかもしれませんが、登場して間もないためまだまだ他のライブラリの利用率が高いです。

## iOSでMVVM採用するメリットとデメリット

ここまでで得た情報からiOSでMVVMを採用することで得られるメリットとデメリットについて並べました。

- Viewロジックのテスタビリティが向上
- Viewロジックとドメインロジックを分離できる
- データバインディング機構を提供するライブラリのメンテナンスが必要
- データバインディング機構を提供するライブラリの理解が必要

### Fat ViewModelになるリスク
ドメイン(アプリの問題領域)を理解できていないと、

- 「ModelではないのでViewModel」
- 「この画面で扱うデータはドメインではなく画面依存だからViewModel」

など、データやロジックがドメインなのか判断できないことが起因してViewModelへと責務が委任されていきます。

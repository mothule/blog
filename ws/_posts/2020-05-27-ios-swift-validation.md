---
title: iOSアプリのバリデーションについて考えてみた
categories: ios swift
tags: ios swift
image:
  path: /assets/images/2020-05-27-ios-swift-validation/0.png
---
アプリの入力フォームで無効なデータを登録しないようバリデーションを挟むことがあります。
大抵はAPI側で検証して問題があればバリデーションエラーとしてレスポンスを返し、
受け取ったクライアント側は結果をユーザーに伝えます。

この方法だと通信処理が走ってしまうのでサーバー負荷に加えて、結果が分かるのに時間もかかります。
そのため、クライアント側でバリデーションできたほうがUXとしては良いです。

しかしクライアント側のバリデーションロジックとサーバ側の検証ロジックが完全一致していなければバグの温床となるため
クライアント側でバリデーションをするにしても最低限にとどまることが多いと思います。

そのためあまり使うことが少ないのですが、少し考えてみました。

## ValidatorとValidationResult protocolの用意

まずは執行役のValidator protocolとその結果を受け取るValidationResult protocolを用意します。

Validatorには実行メソッドとなる`validate() -> ResultType`を用意して、
Validator protocolの採用クラスはこのメソッドに検証処理をまとめます。

そして、検証処理の結果としてValidationResult protocolを採用したクラスを返します。

ValidationResultにはバリデーションが合格したか分かるようにisOkプロパティを用意します。


<script src="https://gist.github.com/mothule/498c37e2f78bc9a527d25df8c0dc615d.js?file=Validator.swift"></script>


## 名前バリデーションを作ってみる

先程定義したValidatorとValidationResult protocolを使って名前用バリデーションを作ってみます。

<script src="https://gist.github.com/mothule/498c37e2f78bc9a527d25df8c0dc615d.js?file=NameValidator.swift"></script>

ValidationResultをネストしても動かせるので型名をシンプルにできます。  
ValidationResultの採用クラスをenumにしたことでバリデーションエラーの一覧が分かります

また`tooLong(Int)`のように内部パラメータを結果に渡すことでバリデーションエラーのハンドリング時に具体的な情報を構築することもできます。


## メールアドレスバリデーションを作ってみる

今度はメールアドレス用バリデーションを作ってみます。

<script src="https://gist.github.com/mothule/498c37e2f78bc9a527d25df8c0dc615d.js?file=EmailValidator.swift"></script>

`errorMessage: String`のように起きたバリデーションエラーのメッセージテキストを**デフォルト値**として使うこともできます。

### 注意：バリデーションのエラーメッセージをそのまま使うリスク
バリデーションは画面に結びついたものではなく検証対象に結びついたロジックです。  
そのため1画面とは限りません。また表示する文言も1つとは限りません。  
例えば男性と女声で文言を変える可能性もあれば、エラーした回数におうじて文言を変える可能性もあります。

バリデーションのエラーメッセージを使う場合は、あくまでもデフォルト値として扱うようにしておき、  
呼び出し元で上書き可能にしておくことで、デフォルトで良い部分はコード量を減らし、  
必要に応じて上書きするコードを書けるといった仕組みにしておくことで柔軟性を維持しつつ楽できるようになります。


## バリデーションを使う

{% page_image 1.png , 100% , ViewControllerWithValidation %}

次は用意した2つのバリデーションをViewController側で使うコードです。  
UIButtonの押下イベント内(`onTouchedRegister(_:)`)で2つのUITextFieldからバリデーション処理を入れてます。

`errorMessage`に文言が入ることで画面内にバリデーションエラーをユーザー通知します。

{% page_image 2.png , 50% , ValidationError %}

<script src="https://gist.github.com/mothule/498c37e2f78bc9a527d25df8c0dc615d.js?file=ViewController.swift"></script>

## RNMoValiライブラリ
実は昔モデル用バリデーションを作っています。
[mothule/RNMoVali](https://github.com/mothule/RNMoVali)

これは1つのプロパティに、名前と用意してあるバリデーターを登録しておくことで、  
バリデーション実行後に名前に紐づくバリデーション結果を受け取る仕組みです。

しかし、記事冒頭に書いたようにあまりニーズがありません。  
クライアント側で「しっかり」バリデーションを必要とするのは、サーバーのない登録系アプリぐらいで、  
それらは大抵が個人が練習で作るToDoアプリぐらいでしょう。

ちなみに作ったのが古いのでSwiftバージョンが古いですが、コンパイルエラーを直せば動くと思います。

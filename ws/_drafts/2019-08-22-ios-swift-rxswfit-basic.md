---
title: RxSwiftの基本を動かして理解する
description: TODO
date: 2019-08-22
categories: ios swift rxswift
tags: ios swift rxswift
draft: true
---

TODO:リード文

マーブルダイアグラム

基礎的な

## Basic

- BehaviorSubject
- BehaviorRelay
- PublishSubject
- PublishRelay
- Signal
- Driver
- Binder
- DisposeBag
- Observable#replay
- Observable#observeOn
- Observable#subscribeOn
- Cold-Hot変換
- BehaviorSubject<String>とObservable<String>の違い

クラスは多いけど、基本に対して特性をつけたり削ったりして名前付けしたものが多い。この特性を型として用意することをTraitsと呼ぶ.

### Driver
Observableに以下の特性を持たせたもの。

UIレイヤーのリアクティブプログラミング用部品。
Observableの代わりにDriverに変換すると
- メインスレッド通知
- shareReplayLatestWhileConnected を使ったCold-Hot変換
- エラー処理
をやってくれます。

呼び出し側でdriveを使うことで呼び出し先にDriverを強制できます。
それはつまり
- メインスレッドで通知
- shareReplayLatestWhileConnectedを使ったCold-Hot変換
- onError通知しない

を強制します。

#### Observable to Driver変換
```swift
// エラー無視
observable.asDriver(onErrorDriveWith: Driver.empty())
// エラーなら空配列
observable.asDriver(onErrorJustReturn: [])
// エラー内容に応じて処理
observable.asDriver(onErrorRecover: { error in
  if error is CustomError { return Driver.empty }
  return Driver.just([])
})
```

### Signal
Driverの特性にreplayされない特性を加えたもの。
Driverは購読開始時にイベントがあれば流します。
しかし、Signalは流しません。
そのため UIButton などのタップイベントに向いています。

## subscribeとbindとdriveの違い

Observable.subscribe(onNext:) は購読
bind は

Driver.drive(onNext:)


### shareReplayLatestWhileConnected


#### BehaviorRelayとPublishRelayの違い

BehaviorRelayは状態を保持し参照します。保持しているのでsubscribeしたらその状態も通知します。


一方でPublishRelayは状態を保持しないため初期値もなく、保持もしていないのでsubscribeしても通知はされません。


| |初期値|valueプロパティ|subscribeした時|
|---|---|---|---|
|BehaviorRelay|◯|◯|通知する|
|PublishRelay|✕|✕|通知しない|



## Index

• basic
• scheduler
• async


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

##

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

とは
---
title: RxSwiftメモ
categories: ios swift 
tags: ios swift rxswift
---

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

## bindとは？
あるデータとBinder<データ型>を結びつける機能です。

いまいち分からないので、実際の動きで確認してみる。
サンプルとして次のような仕様を実装する。

- 「UITextField」の内容が5文字超になれば「UIButton」が押せるようになる
- 「UIButton」が押されたら「UITextField」の内容を「UILabel」に反映する

これを`subscribe`で実装すると次のコードになる。

```swift
textField.rx.text.orEmpty
    .subscribe(onNext: { [weak self] text in
        self?.button.isEnabled = text.count > 5
    })
    .disposed(by: disposeBag)

button.rx.tap.asSignal()
    .emit(onNext: { [weak self] in
        self?.label.text = self?.textField.text
    })
    .disposed(by: disposeBag)
```

これをBinderで実装すると次のコードになる。

```swift
textField.rx.text.orEmpty
    .map { $0.count > 5 }
    .bind(to: button.rx.isEnabled)
    .disposed(by: disposeBag)

button.rx.tap
    .map { [weak self] _ in self?.textField.text }
    .bind(to: self.label.rx.text)
    .disposed(by: disposeBag)
```

渡された値をそのままバインド先に反映させる。  
当然なら型は同じでなければならないため、mapでバインド先の型に合わせている。

`bind` と `subscribe` はほとんど同じ動作をする。
`bind` のほうがシンプルなため、紐付け情報が分かりやすくなる。

## subscribeとbindとdriveの違い

どれもほとんど同じで講読処理。
bindは直感的なシンプル差を持つ。
driveはエラーで終了しないし、UIスレッド保証。

## 逆引き: ボタン押されたらテキストをObservableにわたす

outputText = buttonTap.withLatestFrom(textField.rx.text.orEmpty.asDriver())


### shareReplayLatestWhileConnected

## Observable<Element>.using(:observableFactory:) とは？

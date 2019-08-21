---
title: RxSwift Schedulerの一覧と使い方
description:
date: 2019-08-22
categories: ios swift rxswift
tags: ios swift rxswift
---

# RxSwift Scheduler(スケジューラ)の一覧と使い方

RxSwiftを使っていると必ず出てくるScheduler(スケジューラー)ですが、どんな種類があるのか把握できずに使っていました。

このままだと実装の自由度が変わらずでもったいないので、一覧と使い方を少し調べてみることにしました。

なおここで提案している使い方が答えと思わず参考程度にすることをオススメします。

使い方は１つではないですもんね。

## Scheduler(スケジューラ)とは？
そもそも分からない人に超絶ざっくり説明すると、Schedulerとはスレッド制御とまずは覚えておいて、のちのち慣れてきてから詳しく知る順番でいいと思います。


## Scheduler(スケジューラ)一覧

- MainScheduler
- ConcurrentMainScheduler
- SerialDispatchQueueScheduler
- ConcurrentDispatchQueueScheduler
- OperationQueueScheduler
- CurrentThreadScheduler
- ImmediateScheduler
- HistoricalSchedulerTimeConverter
- VirtualTimeScheduler

### MainScheduler
メインスレッドで実行するSchedulerです。
`observeOn`に最適化されておりメインスレッドを指定します。
`MainScheduler.instance` を渡して使います。
スケジュールするメソッドがメインスレッド上であれば即時実行されます。
`MainScheduler.asyncInstance`は後述する`SerialDispatchQueueScheduler`を参照ください。

### ConcurrentMainScheduler
メインスレッドで実行するSchedulerです。
`subscribeOn`に最適化されておりメインスレッドを指定します。
スケジュールするメソッドがメインスレッド上であれば即時実行されます。

### SerialDispatchQueueScheduler
バックグラウンドで処理を順次実行するのに使います。
内部でシリアルキューを保持しており、並列キューを渡してもシリアル実行されます。

### ConcurrentDispatchQueueScheduler
バックグラウンドで処理を並列実行するのに使います。
GCD の`dispatch_queue_t`か QOSで指定します。

### OperationQueueScheduler
`NSOperationQueue`を使った非同期実行をします。
同時実行数を制御できるのが便利なところ.

### CurrentThreadScheduler
現在のスレッドを指定します。
処理を一度キューイングしてから実行します。

### ImmediateScheduler
現在のスレッドを指定します。
処理をキューイングせず即時実行します。

### HistoricalSchedulerTimeConverter
時間経過を制御できるSchedulerです。
n秒後に実行などのテストで便利かと思います。

### VirtualTimeScheduler
時間経過をプログラムで制御するSchedulerです。
受け取った時間を何軸の時間に扱うかなどを制御を実装して使います。
テストとして使えますが、`HistoricalScheduler`を使ったり、ライブラリ側がテストスケジューラを提供したりと、あまり使う機会はないかと思います。

## まとめ
通常であれば`MainScheduler`,`ConcurrentDispatchQueueScheduler`をよく使いますが、 `CurrentThreadScheduler`と`ImmediateScheduler`を理解できていると実装が楽になるケースとかありそうですね。

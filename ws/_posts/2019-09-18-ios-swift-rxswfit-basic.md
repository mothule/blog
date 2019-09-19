---
title: RxSwiftの基本を動かして理解する
categories: ios swift rxswift
tags: ios swift rxswift
image:
  path: /assets/images/2019-09-18-ios-swift-rxswfit-basic.png
---

RxSwiftの理解ハードルが高くて苦労してる人やネットにある記事では理解できない人っていませんか？  
私もその一人でした。ネットで見かける記事を読み解いても

- 公式の英文をそのまま直訳しただけの説明
- 公式の順序通りの説明順番
- 正しい言葉に拘り過ぎて「パルスのファルシのルシがパージでコクーン」みたいな用語だけが独り歩き
- マーブルダイアグラムという慣れないし、慣れてもやっぱり直感で理解できないグラフに説明を丸投げ

などなど読み手に負担がかかった記事が多く「なんでこんなに分かりにくいのだろう？なぜか腹落ちしない」と何度も思いました。

なので自分が学習を通して「これを最初に腹落ちしないとダメじゃん」と思うアプローチで、RxSwiftを説明する記事を書きました。

## 背景

ざっくりとRxSwiftの立ち位置やこの記事で得られる知識について簡単に説明します。

### 最近のiOS開発事情
iOSはSwiftに加え、RxSwift、MVVM、そしてSwiftUI。
iOSはAndroidと異なり明確なアーキテクチャを提示やサポートをしません。
そのため実装が群雄割拠になり、案件や会社によってバラバラでどんどん覚える量が増えています。

スクール上がりの経験1年ちょいでもiOSアプリは作れますが、
メンテナンス、チーム、大規模、テスタビリティ、バグ抑制、レビューなど求められる要件に対して、適切なデザインを提示できるには相応のスキルを必要とされます。

つまりiOSアプリはSDKと言語仕様の上に明確なフレームワークが存在しないため、上記で上げた項目の品質がブレやすく、そしてエンジニアによって依存します。

{% page_image -1.png %}
*iOSにはアーキテクチャ指針が明確ではない*

### RxSwiftはちょっとした課題のちょっとした提案

RxSwiftは解決策をある程度強制します。  
アーキテクチャもMVVMが最適解として選択されます。  
RxSwiftが提示するレールにチームが従うことで、無数にある実装においてルールを強制することができます。

RxSwiftは従来の処理フローの繋がりが集約・視覚化されない問題を解決する１つのアプローチです。  
そのアプローチ方法について理解することがRxSwiftを使用する上で必須となっています。

しかし、この知識に正面からぶつかると難解な動きや構造をするモデルに心を折られてしまいます。

### この記事ではとっかかりを掴む

この記事を通して、コードを動かして理解することで、体系的な知識の点、そしてそれを繋ぐ線を少しずつ構築し、難解なモデルに対して戦える密度の薄い体系知識を得られればなと思います。

ネットで拾えるRxSwiftの記事はどれもオリジナルでもあるのかと、思うような似たような解説記事ばかりなので、私なりに噛み砕いて説明します。

まず巨大なモデルを理解するには、大きさを知るために **ざっくりイメージできる** ことが大事です。

粒度は少しずつ細かくして、少しずつ詳細を把握していくべきです。

## 前提

- RxSwift 5.x
- Swift 5.x

### この記事の読み方

この記事だけでRxSwiftについて理解する記事ではありません。  
この記事だけで完結するほど精巧に作られていませんし、RxSwiftはそんなに単純ではないです。

タイトルの通り実際にまたRxSwiftを使ったプロジェクトを用意し、動かしながら読むことを推奨します。  
RxSwiftのコード自体もあるとなお良いと思います。

### 注意点

この記事では全てについて説明は**していません。**

目的は**ざっくりイメージできる**ことを重視しています。

RxSwiftとはなにか？を知ったときに得るイメージを崩さないように記事を書いてあるので、専門用語や実践的なノウハウについては記載していません。
また説明順序に関しても、私が学習を通して、このセクションをこの順序でやったほうが分かりやすいはず。という判断で記事を書いてあります。

## RxSwiftはオブザーバーパターンとパイプライン

デザインパターンの１つであるオブザーバーパターンと、シェルでよく使うパイプ(`|`)を使って、  
**イベントにリアクションを連結するイメージです。**

他のサイトなどでRxSwiftについてざっくり概要を知った人たちが考えるRxSwiftとは  
**「イベントを監視し、動きがあれば逐一報告し、報告を受けたものが何らかの反応をする」**  
という説明で大体が納得できるのではないでしょうか？

つまり「RxSwiftとはオブザーバーパターンを使っている」というイメージが強くあることで、  
読み手側はオブザーバーの**イベントを報告する者**と**イベントを受け取る者**はどれか？をキーに文章を読むのではないでしょうか？

しかしそれが返って邪魔となり道に迷っているのではないかと私は思います。

## イベントを報告する者とイベントを受け取る者
たくさんあるクラスのなかでまず覚えるべきは`Observable`です。  
そして採用している`ObservableType` プロトコルです。

`ObservableType.subscribe` がイベントを受け取るための講読手続きになります。  
なので `ObservableType` を採用しているクラスは全て、 **イベントを受け取る者** となります。  
つまり`Observable`は **イベントを受け取る者** です。


では、**イベントを報告する者** は誰でしょうか。

それは `ObservableType.subscribe`の引数が採用している`ObserverType`です。  
`ObservableType`と`ObserverType`かなり似てるので、注意して読んでください。

`ObserverType`プロトコルは `on` メソッドを持っており、これを使って報告をしています。  
つまり `ObserverType`を採用しているクラスは全て、 **イベントを報告する者** となります。


### 整理

- `ObservableType` が **イベントを受け取る者**
- `ObserverType` が **イベントを報告する者**
- つまり `Observable`は **イベントを受け取る者**

## イベントを報告してイベントを受け取る

イベントを報告する者と受け取る者の２つがあることは分かりました。  
イベントを受け取る者のクラスは`Observable`でした。  
ではイベントを報告する者のクラスは何でしょう？

`ObserverType`を採用しているクラスを探すと出てきます。

今回はその中からよく使う `PublishSubject` を使います。

```swift
let subject = PublishSubject<String>()
subject.onNext("A")
subject.onCompleted()
```

`onNext`と`onCompleted`は `on` メソッドに `next`状態と`completed`状態をそれぞれ報告しています。
ただのラッパーメソッドです。

これだけでは **イベントを報告する者** だけで **イベントを受け取る者** がいません。  
しかも、イベントを受け取る者が報告する者に対し、講読する手続きも必要になります。

`PublishSubject`の定義へジャンプすると次のような定義になっています。

```swift
public final class PublishSubject<Element>
    : Observable<Element>
    , SubjectType
    , Cancelable
    , ObserverType
    , SynchronizedUnsubscribeType {
}
```
なんと、`PublishSubject`は、 `Observable` を採用しています。
つまり **イベントを受け取る者** でもあったのです。

そのため`PublishSubject`1つで、次のような **報告** と **受け取り** ができます。

次のコードは、`next` `completed` `disposed` それぞれの状態に対してハンドリングしています。
```swift
subject.subscribe(onNext: { (text: String) in
    print("onNext:  \(text)")
}, onError: {
    print("onError: ", $0.localizedDescription)
}, onCompleted: {
    print("onCompleted")
}, onDisposed: {
    print("onDisposed")
})

subject.onNext("A")
subject.onNext("B")
subject.onNext("C")
subject.onCompleted()
```

*Output*
```
onNext:  A
onNext:  B
onNext:  C
onCompleted
onDisposed
```

ちなみに途中でエラーイベントを報告した場合、講読は終了します。
例えば先程のコードの一部を次のように `onError` を挟むと結果が変わります。

```swift
subject.onNext("A")
subject.onNext("B")
subject.onError(NSError(domain: "domain", code: -1, userInfo: nil))
subject.onNext("C")
subject.onCompleted()
```

*Output*
```
onNext:  A
onNext:  B
onError:  The operation couldn’t be completed. (domain error -1.)
onDisposed
```

このように`C`イベントは報告されず、`completed`も報告されません。  
そして`disposed`が報告され講読終了となります。


### 整理

- `PublishSubject` は **報告する者** でもあり **受け取る者**
- エラーが起きたら講読は終了する

## 他のObserverTypeの採用クラス

PublishSubject以外に`ObserverType`を採用してるクラスについて簡単に説明します。

### PublishRelay

PublishSubjectのラッパーです。
PublishSubjectの`onNext`, `onCompleted`, `onError`はなく、`accept`のみになります。
この`accept`の中身は`onNext`となります。
結果的にエラーや完了のイベントを流せないので、実質エラーや完了で終了できなくなります。

### BehaviorSubject

PublishSubjectに状態を持たせたようなクラスです。
BehaviorSubjectは最後に報告した値を保持しています。
保持しているのでsubscribeしたらその状態も通知します。


```swift
let sub = BehaviorSubject<String>(value: "ABC")

sub.subscribe(onNext: {
    print("onNext: ", $0)
}, onError: {
    print("onError: ", $0.localizedDescription)
}, onCompleted: {
    print("onCompleted")
}, onDisposed: {
    print("onDisposed")
})

sub.onNext("D")
print(try! sub.value())
sub.onNext("E")
sub.onCompleted()
```

*Output*
```
onNext:  ABC
onNext:  D
D
onNext:  E
onCompleted
onDisposed
```

## イベントの報告に経路に手を加える

RxSwiftでは、報告する者がイベントを受け取る者に通知する経路を加工することができます。

### filter: 条件満たすイベントのみ連絡する

`filter`を通すことで、イベントを受け取る者への連絡を制限することができます。  
次のコードは、3文字以下のみを連絡しています。

```swift
let source = PublishRelay<String>()

source
    .filter({ $0.count <= 3 })
    .subscribe(onNext: {
        print("onNext: ", $0)
    })

source.accept("A")
source.accept("12")
source.accept("!$#")
source.accept("1234")
source.accept("ABCDE")
source.accept("ABC")
```

*Output*
```
onNext:  A
onNext:  12
onNext:  !$#
onNext:  ABC
```

### map: イベント情報を変換して連絡する

`map`を通すことで、イベントを連絡する者が持つデータを加工して、受け取る者へ通知できます。
次のコードは整数から文字列に変換して連絡しています。

```swift
let source = PublishRelay<Int>()
source
    .map({ "\($0)" })
    .subscribe(onNext: {
        print("onNext: ", $0)
    })

source.accept(1)
source.accept(2)
source.accept(3)
```

*Output*
```
onNext:  1
onNext:  2
onNext:  3
```

## 講読を解除する
受け取る者が報告する者から、データを受け取る講読手続きがあるように、反対に講読を解除する処理もあります。

次のコードでは、途中で`dispose`を読んだことで、それ以降のイベントが届いていません。

```swift
let subject = PublishSubject<String>()
subject.subscribe(onNext: { (text: String) in
    print("onNext:  \(text)")
}, onCompleted: {
    print("onCompleted")
}, onDisposed: {
    print("Disposed")
})
subject.onNext("A")
subject.onNext("B")
subject.dispose()
subject.onNext("C")
subject.onNext("D")
subject.onCompleted()
```

*Output*
```
onNext:  A
onNext:  B
```

この講読の解除は、明示的に呼び出して解除する方法ですが、エラーや完了イベントを受け取った場合も講読を解除します。

### DisposeBag

他の購読解除のタイミングとして、データの連絡する者が開放されるケースがあります。
このようなケースで自身の開放タイミングで保持するdisposableをまとめて解除してくれるのがこのクラスです。

次のコードでは、`DisposeBag`に講読先のdisposableを入れておき、講読途中でnilを渡してメモリ解放をすることで  
「DisposeBagの開放タイミングでバッグ内のdisposableを全て開放する」特性を再現しています。

```swift
let source = PublishRelay<String>()
let disposable = source.subscribe(onNext: {
    print("onNext: ", $0)
}, onError: {
    print("onError: ", $0.localizedDescription)
}, onCompleted: {
    print("onCompleted")
}, onDisposed: {
    print("onDisposed")
})


var bag: DisposeBag? = DisposeBag()
bag?.insert(disposable)

source.accept("A")
bag = nil
source.accept("B")
```

*Output*
```
onNext:  A
onDisposed
```

通常であれば、上記コードのようにnilを渡すといった意識した開放はせずとも、`DisposeBag`インスタンスのスコープアウトや親クラスの開放で、意識をせずとも開放をしてくれます。

## まとめ
以上がRxSwiftの基礎を動かして理解する説明です。

記事の内容に加え、手を動かしながらやったことで、RxSwiftに抱くオブサーバーのイメージを崩さずRxSwiftの基礎中の基礎を理解できたのではないかと思います。

まだ `Driver`, `Scheduler`, `Cold/Hot` など山程あるのですが、それは別記事として投稿したら、ここにリンクを貼ろうと思います。

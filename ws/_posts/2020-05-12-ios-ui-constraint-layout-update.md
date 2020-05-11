---
title: setNeedsLayoutやlayoutSubviewsなどの役割を整理する
categories: ios
tags: ios
image:
  path: /assets/images/2020-05-12-ios-ui-constraint-layout-update/0.png
---
`layoutIfNeeded`はビュー位置すぐ分かって便利。`layoutSubviews`は呼んだらいけない。`setNeedsLayout`はパフォーマンス良し。

ビュー周りをコーディング中にUIが反映されない不具合に遭遇したら、  
「ビューが反映されていない。とりあえず可能性を潰すために`Constraint`や`Layout`を更新」  
って思って、Xcode上で`constraint`とか`layout`って打ったら候補に上がるたくさんのメソッド。
「とりあえずそれぞれ何個か呼べば反映処理は走るだろう・・・」  
なんてことないですか？

この記事では、`setNeedsLayout`,`layoutIfNeeded`,`layoutSubviews`,`updateConstraints`,`setNeedsUpdateConstraints`,`updateConstraintsIfNeeded`について調べて、詳細は省いて噛み砕いて説明します。


## iOSのレイアウト更新をメソッド整理する

- 制約系
  - `updateConstraints`
  - `setNeedsUpdateConstraints`
  - `updateConstraintsIfNeeded`
- レイアウト系
  - `layoutSubviews`
  - `setNeedsLayout`
  - `layoutIfNeeded`

### updateConstraints
システムが制約更新に呼ぶ
自分らが直接呼ばない。

使う用途は、オーバーライドして制約更新の最適化。
そもそも、これをオーバーライドしてまでパフォーマンスを求められる複雑な画面はつくらないほうがいい。

### setNeedsUpdateConstraints
事前に更新予約することで複数ビュー更新時の無駄な再計算の抑制。
フラグセット処理なので処理は軽い。その場で処理はされない。

### updateConstraintsIfNeeded
システムがレイアウト更新時に呼ぶ。最新の制約を得たい場合は手動で呼ぶことも可能。
`setNeedsUpdateConstraints`の後にこれを呼ぶと制約更新が走る。

### layoutSubviews
制約を使いサブビューのサイズと位置を決定する。  
このメソッドは直接呼んではならない、代わりに`setNeedsLayout`使うこと。  
もし、ビューのレイアウトをすぐ欲しい場合は、`layoutIfNeeded`を呼ぶこと。

### setNeedsLayout
サブビューのレイアウトを無効化する＝次回レイアウト更新時に更新を必須とする。  
全てのレイアウト更新を1回の更新サイクルで済ませられるのでパフォーマンス良い。

### layoutIfNeeded
サブビューが保留中ならすぐさま更新する。更新不要なら何もしない。  
呼んだビューをルートとして、サブビューのレイアウト更新する。  
内部では制約の変更も更新する。  
`setNeedsLayout`を呼んだビューで呼ぶとその場でレイアウト更新処理が走る。


## 制約変更してすぐにレイアウトが欲しい場合
制約を変更した直後に、影響を受けた後のビュー状態が欲しい場合は、  
影響を受けるビューの親ビューの`layoutIfNeeded`を呼ぶ。  
これにより無効化されたビューのレイアウト更新が実行されます。  
レイアウト更新は内部で`updateConstraints`が呼ばれてから、`layoutSubviews`が呼ばれてます。  

### コードで表す

あるUIViewControllerにUILabelが配置されてるとする。  
UILabelは左右と上にsuperviewとConstraintを引いている。  
左右のConstraintsはそれぞれ`16`になっている。

左右のConstraints(`labelRightConstraint`と`labelLeftConstraint`)の値を変更。  
ラベルの中身も変更する。

この状態で制約変更後のラベルの座標が欲しい場合は、`layoutIfNeeded`を呼ぶ。  
`setNeedsLayout`は呼ばなくてもラベルの変更によりレイアウトが無効化（更新必須化）されている。

```swift
self.labelRightConstraint.constant = 30.0
self.labelLeftConstraint.constant = 40.0
self.label.text = "asdfasdfasdfasdf"
self.view.layoutIfNeeded()
print("ラベルX:", self.label.frame.origin.x)
```

*コンソール*  
```
ラベルX: 40.0
```

### 親ビューを更新しないといけない

`layoutIfNeeded`をラベルの親ビューではなく、ラベル自身で呼んでも変更されない。

```swift
self.labelRightConstraint.constant = 30.0
self.labelLeftConstraint.constant = 40.0
self.label.text = "asdfasdfasdfasdf"
self.label.layoutIfNeeded()
print("ラベルX:", self.label.frame.origin.x)
```

*コンソール*  
```
ラベルX: 16.0
```

### setNeedsLayoutは無効化するだけ

`setNeedsLayout`を呼ぶと次回更新時に更新されるが、その場で更新はされない。

```swift
self.labelRightConstraint.constant = 30.0
self.labelLeftConstraint.constant = 40.0
self.label.text = "asdfasdfasdfasdf"
self.view.setNeedsLayout()
print("ラベルX:", self.label.frame.origin.x)
```

*コンソール*  
```
ラベルX: 16.0
```

### Constraint更新してもフレーム位置は変わらない

`setNeedsUpdateConstraints`と`updateConstraintsIfNeeded`で制約更新しても  
レイアウト更新はされないので、ラベルの位置は更新されない。

```swift
self.labelRightConstraint.constant = 30.0
self.labelLeftConstraint.constant = 40.0
self.label.text = "asdfasdfasdfasdf"
self.label.setNeedsUpdateConstraints()
self.label.updateConstraintsIfNeeded()
print("ラベルX:", self.label.frame.origin.x)
```

*コンソール*  
```
ラベルX: 16.0
```


## あまり使うケース少ない
`setNeedsLayout`と`setNeedsUpdateConstraints`はパフォーマンス良いと説明されている。  
だけど呼ばなくても最近のiPhoneでは動く。  
そしてUIベースのアプリは、これが必要なほど凝ったUIは作るべきではないと私は思う。

かろうじて使うのは`layoutIfNeeded`だろうか。

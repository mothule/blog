---
title: 画面外へスライドアニメすると表示が消えてからスライドするのはSafeAreaが原因
date: 2019-01-05
categories: ios uiview
tags: ios swift uiview ios-safearea
---

## 問題の症状
下のアニメのように外へスライドしようとすると最初に白くなってから上へスライドします。

<a href="/assets/images/2019-01-05-disapper-cause-safe-area-when-fade-out-anim-1.gif"><img src="/assets/images/2019-01-05-disapper-cause-safe-area-when-fade-out-anim-1.gif" width="50%" alt="スライド前に非表示になるバグ"></a>

コードは下記のように至ってシンプル。

```swift
UIView.animate(withDuration: 0.3, animations: { [weak self] in
    guard let self = self else { return }
    self.frame.origin.y = self.parentFrame.origin.y - self.frame.size.height
}) { [weak self] (_) in
    guard let self = self else { return }
    self.removeFromSuperview()
    completion()
}
```

View階層も次の通り
```
UIViewController.view
  |
  +-- MKMapView
  |
  +-- Button
  |
  +-- SearchPopupView (これをスライドさせてる)
```

Auto Layoutが効いてる場合は、 `animations` クロージャ内に `self.updateConstraints()` が抜けてるとかありますが、今回は対象View自体にはAuto Layoutは使わず単純に UIViewController.view に addSubview してるだけです。

## 原因

スライド対象Viewの内部ViewのAuto LayoutでTopをSafe Areaに繋いでいることが原因でした。

|対象View|制約|
|---|---|
|<a href="/assets/images/2019-01-05-disapper-cause-safe-area-when-fade-out-anim-2.png"><img src="/assets/images/2019-01-05-disapper-cause-safe-area-when-fade-out-anim-2.png" width="100%" alt="対象View"></a>|<a href="/assets/images/2019-01-05-disapper-cause-safe-area-when-fade-out-anim-3.png"><img src="/assets/images/2019-01-05-disapper-cause-safe-area-when-fade-out-anim-3.png" width="100%" alt="成約"></a>|

今回のようなパーツxibのような Safe Area を使わなくても良い場合はSafe Areaを無効にすることで
画面外へスライドアニメしても表示が消えずにスライドできるように解決できました。

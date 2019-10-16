---
title: UIの更新順序について調べてみた
categories: ios
tags: ios
---
`updateConstraints` `layoutIfNeeded` などいくつかレイアウト更新に関するメソッドがあるが、どの順序で更新されており各メソッドはどのようなときに呼べばいいのかを理解する。

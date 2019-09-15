---
title: Railsのloggerでテストがうまく動かないときに
categories: ruby rails rspec
tags: ruby rails rspec
---
仕事でRailsのloggerがちゃんと出力されているかrspecでテストしたいなと思い調べたのですが、
ネットで見つかる方法だと想定した通りに動かず、同僚に教えてもらった方法で今回はことを得たので、
他にも同様に困っている人向けに書いてます。


## やりたいこと

controller で呼ばれているログを取りたい。

## ネットで見かける方法

```ruby
expect(Rails.logger).to receive(:debug).with("test")
```

しかしこれだと想定した挙動を示してくれず... 😭

## 今回の方法

```ruby
expect_any_instance_of(HogeController).to receive(:log_for_hoge)
```

テスト対象controllerは次のようになっている必要があります。
```ruby
class HogeController < ApplicationController
  private

  def log_for_hoge
    logger.debug("ほげほげ〜")
  end
end
```
監視対象メソッドは private メソッドでも問題ありません。

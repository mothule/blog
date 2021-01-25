---
title: Railsを5.0.0から5.2.3に変更した
categories: ruby rails
tags: ruby rails
image:
  path: /assets/images/2019-11-14-ruby-rails-rails-5_2_3-update.png
---
個人アプリのRailsバージョンが結構古いことに気づいたので、バージョンを上げたときに躓いたポイントをまとめた記事です。

Gemfileのrailsを`5.0.0` から `5.2.3` に変更後、`bundle update rails`を実行

gemインストールは成功したが末尾にメッセージが表示。

### 原文
```
HEADS UP! i18n 1.1 changed fallbacks to exclude default locale.
But that may break your application.

Please check your Rails app for 'config.i18n.fallbacks = true'.
If you're using I18n (>= 1.1.0) and Rails (< 5.2.2), this should be
'config.i18n.fallbacks = [I18n.default_locale]'.
If not, fallbacks will be broken in your app by I18n 1.1.x.

For more info see:
https://github.com/svenfuchs/i18n/releases/tag/v1.1.0
```

i18n の 1.1 では、デフォルトロケールが除外されました。
```ruby
config.i18n.fallbacks = true
```
を確認して i18n が >= 1.1.0 および Rails < 5.2.2 の場合はこれを

```ruby
config.i18n.fallbacks = [I18n.default_locale]
```
に変更すべきです。

そうしないとこれのせいでアプリが異常動作します。

## 親が保存されないと子はcreateを呼び出せない

ActiveRecordでは、親子関係のあるモデルで親より先に子を保存しようとするとエラーになるようになりました。

### 原文
```
ActiveRecord::RecordNotSaved:
You cannot call create unless the parent is saved
```

### 説明
例えば 著者(Author) と 記事(Article) なら関連は次のようになります。

```ruby
class Author < ApplicationRecord
  has_many :articles
  # カラムとして name: string がある
end

class Article < ApplicationRecord
  belongs_to :author
  # カラムとして title: string がある
end
```

このとき Author を保存せずにArticleを保存しようとするとエラーになります。

```ruby
author = Author.create(name: '')
author.name = 'hoge'
author.articles.create!(title: 'ほげ') # エラー
author.save!
```

### 対応策
子を保存しないか先に親を保存させる必要があります。

```ruby
author = Author.create(name: '')
author.name = 'hoge'
author.articles.build(title: 'ほげ')
author.save!
```

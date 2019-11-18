---
title: Rails4.1からRails5.0.0.1に変更した
categories: ruby rails
tags: ruby rails
image:
  path: /assets/images/2019-11-13-ruby-rails-rails5_0_0-update.png
---
個人アプリのRailsバージョンが結構古いことに気づいたので、バージョンを上げたときに躓いたポイントをまとめた記事です。

## Request spec では キーワード引数が必要になりました。

下記コードだと
```ruby
subject { post path, params, headers }
```

次のような警告が出る

### 原文

```
DEPRECATION WARNING: ActionDispatch::IntegrationTest HTTP request methods will accept only
the following keyword arguments in future Rails versions:
params, headers, env, xhr, as

Examples:

get '/profile',
  params: { id: 1 },
  headers: { 'X-Extra-Header' => '123' },
  env: { 'action_dispatch.custom' => 'custom' },
  xhr: true,
  as: :json
 (called from block (3 levels) in <top (required)> at /Users/mothule/workspace/organ/spec/requests/rooms_spec.rb:185)
```

params, headers などキーワード指定が必要になりました。

```ruby
subject { post path, params: params, headers: headers }
```

にすると警告が出なくなります。

## ActionController::Parametersからmerge!メソッドが5.1から使えなくなります

セキュリティ観点によるメソッド廃止です。

使い続けると潜在的なセキュリティ問題が顕在化しアプリの脆弱性が作成され悪性される可能性があります。
特に理由がなければ別メソッドで差し替えたほうがいいでしょう。
代用は非推奨ではないメソッドを[こちら](http://api.rubyonrails.org/v5.0.0.1/classes/ActionController/Parameters.html)から使うと確実です。

### 原文

```
DEPRECATION WARNING: Method merge! is deprecated and will be removed in Rails 5.1, as `ActionController::Parameters` no longer inherits from hash. Using this deprecated behavior exposes potential security problems. If you continue to use this method you may be creating a security vulnerability in your app that can be exploited. Instead, consider using one of these documented methods which are not deprecated: http://api.rubyonrails.org/v5.0.0.1/classes/ActionController/Parameters.html (called from reposition_location_param at your/rails/controller/path.rb:67)
```

---
title: rails updateでgemバージョン依存を解決してみる
categories: ruby rails
tags: ruby rails
image:
  path: /assets/images/2019-11-13-ruby-rails-update-rails-version.png
---
他愛もないネタですが、 `gem`のバージョン依存の解決って最初見方を分からないと萎えるのでどう読み解くか1ケースとして記事にします。

題材としてRailsのバージョンを4系から5系にアップデートします。

## バージョン衝突を再現する
`bundle update rails` を実行すると

```sh
$ bundle update rails
Fetching gem metadata from https://rubygems.org/.........
Fetching gem metadata from https://rubygems.org/.
Resolving dependencies....
Bundler could not find compatible versions for gem "activesupport":
  In Gemfile:
    bullet was resolved to 5.9.0, which depends on
      activesupport (>= 3.0.0)

    haml-rails was resolved to 1.0.0, which depends on
      activesupport (>= 4.0.1)

    jbuilder (~> 2.0) was resolved to 2.8.0, which depends on
      activesupport (>= 4.2.0)

    rails (= 5.0.0) was resolved to 5.0.0, which depends on
      activesupport (= 5.0.0)

    rspec-rails was resolved to 3.8.1, which depends on
      activesupport (>= 3.0)

    spring was resolved to 2.0.2, which depends on
      activesupport (>= 4.2)

Bundler could not find compatible versions for gem "rails":
  In Gemfile:
    rails (= 5.0.0)

    rails-flog was resolved to 1.5.0, which depends on
      rails (>= 4.2.0)

Bundler could not find compatible versions for gem "railties":
  In Gemfile:
    devise was resolved to 4.5.0, which depends on
      railties (< 6.0, >= 4.1.0)

    factory_bot_rails was resolved to 4.11.1, which depends on
      railties (>= 3.0.0)

    haml-rails was resolved to 1.0.0, which depends on
      railties (>= 4.0.1)

    jquery-rails was resolved to 4.3.3, which depends on
      railties (>= 4.2.0)

    rails (= 5.0.0) was resolved to 5.0.0, which depends on
      railties (= 5.0.0)

    devise was resolved to 4.5.0, which depends on
      responders was resolved to 2.4.0, which depends on
        railties (< 5.3, >= 4.2.0)

    rspec-rails was resolved to 3.8.1, which depends on
      railties (>= 3.0)

    sass-rails (~> 4.0.3) was resolved to 4.0.5, which depends on
      railties (< 5.0, >= 4.0.0)
```

とgem依存エラーが表示される。

赤く大量に表示されてこの時点でやる気なくすが、何がをどう解決すればいいかを読み解いてみる。

## ログはgemの依存関係を表している

このログはどの gem が どの gem に依存しているかを表してます。
一部抜粋します。

```sh
Bundler could not find compatible versions for gem "activesupport":
  In Gemfile:
    bullet was resolved to 5.9.0, which depends on
      activesupport (>= 3.0.0)
```

この場合 `bullet` gem が `activesupport` gem に依存してることを表します。  
`activesupport` のバージョンが `3.0.0以上` であれば問題ありません。  
つまり問題ないライブラリ組み合わせです。

他のライブラリもバージョン上問題ない組み合わせばかりです。

つまり問題のない組み合わせもログとして出力されます。

## 地道に見ていく

最後まで見ると `sass-rails` が怪しいです。

```sh
sass-rails (~> 4.0.3) was resolved to 4.0.5, which depends on
  railties (< 5.0, >= 4.0.0)
```

`railties` は 5.0未満でなければいけませんが、 `rails` は `5.0.0` なので
`railties` は `5.0.0` になります。
これは [rubygems.org](https://rubygems.org/gems/rails/versions/5.0.0) で確認できます。

`sass-rails` について調べてみると次のような記事を見つけます。
https://techracho.bpsinc.jp/hachi8833/2018_04_06/54793#2-1

どうやら`sass`は非推奨になるようです。つまり `rails` では `sass-rails` から `sassc-rails` に乗り換えないといけないようです。
Gemfile を次のように書き換えます。

```diff
-gem 'sass-rails', '~> 4.0.3'
+gem 'sassc-rails', '~> 2.1.2'
```

これで再度 `bundle update rails` を実行すると成功しました。

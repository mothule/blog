---
title: RailsのController内におけるエラーハンドリングのベストプラクティスについて調べてみた
date: 2018-10-21
categories: ruby rails
tags: rails rails-controller ruby
---
## 概要

- 各APIControllerでエラー検知とエラーレスポンスを書くのDRY違反してる
- エラーレスポンスは構造が統一できていないとクライアント側が死んでしまう
- Applicationで一律例外検知してエラー内容をハンドリングしたほうが楽

C#のASP.NET MVC5ではController毎に例外キャッチなどはせずApplicationで一律ハンドリングするので、
Railsにも同様の機能は提供されていると思う。

その方法を調べると同時にRailsにおけるベストプラクティスを知っておこうって思った。

## Applicationで一律例外検知してハンドリングする方法

- ApplicationController で `rescue_from` メソッドを使う
- 404や500は 専用Controller用意とroutes.rb更新して`config.exceptions_app = routes`でカスタマイズする

## ベストプラクティス

- ExceptionではなくStandardErrorをキャッチする
- 各ControllerではなくApplicationControllerでハンドリングする
- エラーハンドリング処理はApplicationControllerから分離する
- Custom Errorでエラー情報の詳細化を助ける
- アプリケーションエラーとシステムエラーは分けるハンドリングする
- アプリケーションエラーはユーザーフレンドリーを目指す
- システムエラーはデベロッパーフレンドリーを目指す


- [参考サイトA](https://medium.com/rails-ember-beyond/error-handling-in-rails-the-modular-way-9afcddd2fe1b)
- [参考サイトB](https://qiita.com/jnchito/items/3ef95ea144ed15df3637)

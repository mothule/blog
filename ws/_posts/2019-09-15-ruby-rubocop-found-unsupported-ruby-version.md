---
title: "原因と対応「Error: RuboCop found unsupported Ruby version 2.1」"
categories: ruby rubocop
tags: ruby rubocop
image:
  path: /assets/images/2019-09-15-ruby-rubocop-found-unsupported-ruby-version.png
---

先日コマンドラインツールを作ろうと bunlder や activesupport, rubocop など環境構築をしていたときに、ちょっとした勘違いでRuboCopがエラーを吐いて躓いたので、調査して分かった原因と対応方法についてまとめました。

## RuboCopでエラーが発生

`$ bundle exec rubocop` を実行したら次のようなエラーが発生しました。

```sh
$ bundle exec rubocop
Error: RuboCop found unsupported Ruby version 2.1 in `TargetRubyVersion` parameter (in vendor/bundle/ruby/2.6.0/gems/rainbow-3.0.0/.rubocop.yml). 2.1-compatible analysis was dropped after version 0.58.
Supported versions: 2.3, 2.4, 2.5, 2.6, 2.7
```

2.1？ 自分の環境では rbenv で .ruby-version を使っており、 2.6.2 を使っていました。
```sh
$ cat .ruby-version
2.6.2
```

### TargetRubyVersion を指定し忘れ
TargetRubyVersion指定するのを忘れてたので .rubocop.yml に追記しました。
```yml
AllCops:
  TargetRubyVersion : 2.6.2
```

しかし問題は解決せず...

## エラーをちゃんと読むと分かる
一行目の半分あたりを読んだ後に1行目終わりから2行目初めにパスが記載されていたので、それ以外の箇所をきちんと読んでいませんでした。
問題が起きてる場所が `vendor/bundle/ruby/2.6.0/gems/rainbow-3.0.0/.rubocop.yml` と書いており自分の場所ではない。
しかも 何やら .rubocop.yml が配置されている。
中身を見ると次のような指定がされています。
```sh
$ cat vendor/bundle/ruby/2.6.0/gems/rainbow-3.0.0/.rubocop.yml
inherit_from: .rubocop_todo.yml

AllCops:
  DisplayCopNames: true
  DisplayStyleGuide: true
  TargetRubyVersion: "2.1"
  Exclude:
    - "spec/**/*"
    - "vendor/**/*"
Documentation:
  Enabled: false

HashSyntax:
  Enabled: false

MethodName:
  Enabled: false

StringLiterals:
  Enabled: false
```

どうやら raibow gem では `TargetRubyVersion` が `2.1` を指定してあることで、互換性エラーが起きていました。
エラー文「2.1-compatible analysis was dropped after version 0.58.」と書いてあるように RubCop version 0.58 以降では 2.1互換性を破棄しています。

インストールした RubCop のバージョンは0.72.0でした。
```bash
$ bundle exec rubocop -v
0.72.0
```

## なぜエラーが起きたのか？
普段自分が作っている別のrailsアプリとかでは、このような問題は起きていません。
しかしRuboCopがgems内まで解析しようとしていることはエラーから判断できます。

`.rubocop.yml` でもgemは見ないように設定しています。

```yml
AllCops:
  TargetRubyVersion: 2.6.2
  Exclude:
    - vendor/
    - tmp/**/*
```

これ今見ると恥ずかしいミスです。。

### 指定方法を間違えている

実は gems内の解析を除外する指定方法が間違っており正しくははこうでした。

```yml
AllCops:
  TargetRubyVersion: 2.6.2
  Exclude:
    - vendor/**/*
    - tmp/**/*
```
`vendor/`でも下のtmp同様に除外されると勘違いしていました。
おそらく.gitignoreで指定フォルダを無視する設定をした後だったのか原因かもしれません。

## RuboCop found unsupported Ruby version 2.1 の原因と対応方法のまとめ

- 原因：gem内も解析対象となっている
- 対応：.rubocop.ymlで`vendor/**/*`のように除外指定をする
- まとめ：エラー文をちゃんと読む

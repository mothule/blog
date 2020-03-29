---
title: GitHub Page Custom domainメモ
categories: github
tags: github github-page 
---
# なるべく楽にはてなブログからJekyllに移行する方法



# 複数のGitHub Pagesにそれぞれサブドメインを割り振る

ドメインとgithub両方でドメイン設定が必要。
[GitHub Pagesで複数の独自ドメインのHTTPS(TLS,SSL)サイトを運用する - このすみろぐ](https://www.konosumi.net/entry/2018/07/01/190200)

[GitHub Pages でカスタムドメインを使用する - GitHub ヘルプ](https://help.github.com/ja/articles/using-a-custom-domain-with-github-pages)



静的生成による技術ブログ運営

# ドメイン取得

[ムームードメイン \| 欲しいドメインがすぐ見つかる。](https://muumuu-domain.com/)
mothule.com

# GitHub Pagesで静的Webページの作り方

- username/username.github.io
- private repository


# GitHub Pagesに独自ドメインのサブドメインを






# Railsエンジニアっぽい技術ブログ運営

- ホスティングサービスにはGithub.io
- ブログはJekyllで静的サイト
- 独自ドメインでサブドメインとして技術ブログ公開
- ドメインはムームードメインから取得
- ドメイン以外は無料

Github.ioにした理由は、記事コンテンツとホスティングを1つにできて余計なアカウントとか増えない.
エンジニアっぽい.

Jekyllにした理由は、最初Middlemanで考えていたけれど、メンテコストが意外と高く、更新も停まっているらしいので、同じRubyであるJekyllにした。
Rubyで書かれており、カスタマイズなどはRuby弄るので勉強になる。

ムームードメインにした理由は、たいした理由ないけど、whois代行が無料, 記事数, GMO傘下(長いものには巻かれろ)

1. ドメイン取得
1. GitHub Pages用意
1. ブログ運営にあたり必要なSEO対策
1. JekyllにおけるSEO対策の解決方法の調査
1. JekyllでベースとなるGitHub Pages作成
1. 必要な拡張機能を追加
1. はてなブログから記事をエクスポート
1. エクスポートした記事を記事コンテンツに流す
1. 不要記事のみをはてなブログに残す
1. GitHub Pagesに独自ドメイン適用

ブログ構築にあたって最低限必要なSEO対策

- ヘッダー
- フッター
- サイドバー
- TOC
- グロナビ
- パンくずリスト
- レスポンシブ
- SNSシェア
- コードシンタックスハイライト


## GitHub.io に独自ドメイン設定

- CNAME

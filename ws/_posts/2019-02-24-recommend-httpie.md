---
title: クライアントエンジニアにはcurlよりHTTPieがお薦め
description: クライアントエンジニアにはcurlよりHTTPieがお薦め. MacやLinuxで使うcurlですが、iOSやAndroid, フロントエンドWeb開発においてはcurlよりHTTPieを使ったほうが楽だったので紹介します。クライアントエンジニアはcurlの学習コストが割に合わないサーバーをよく弄るWebエンジニアはLinux上の操作が多いため既存パッケージのcurlを覚え使えたほうがフットワークが軽いと思います。しかしAPIを叩く側多いiOSやAndroid開発、フロントエンドWebの開発をするクライアントエンジニアにとって自分の開発機がそのまま開発環境になることがほとんどだと思います。curlのようなパッケージソフトはコマンドとそのオプションを覚えるコストがかかります。 自分はせっかく覚えてもすぐに忘れてまた調べ直すので開発スピードを阻害する要因の一つです。 しかし今回紹介するHTTPieはRESTful APIを叩きやすいコマンドになります。
date: 2019-02-24
categories: tools httpie
tags: tools httpie
image:
  path: /assets/images/2019-02-24-recommend-httpie.png
---

MacやLinuxで使うcurlですが、iOSやAndroid, フロントエンドWeb開発においてはcurlよりHTTPieを使ったほうが楽だったので紹介します。


## クライアントエンジニアはcurlの学習コストが割に合わない
サーバーをよく弄るWebエンジニアはLinux上の操作が多いため既存パッケージのcurlを覚え使えたほうがフットワークが軽いと思います。

しかしAPIを叩く側多いiOSやAndroid開発、フロントエンドWebの開発をするクライアントエンジニアにとって自分の開発機がそのまま開発環境になることがほとんどだと思います。

curlのようなパッケージソフトはコマンドとそのオプションを覚えるコストがかかります。
自分はせっかく覚えてもすぐに忘れてまた調べ直すので開発スピードを阻害する要因の一つです。
しかし今回紹介するHTTPieはRESTful APIを叩きやすいコマンドになります。

## サンプル

### あるサービスのタイムラインを取得
下のようにRESTful APIのように叩けます。

```sh
$ http get https://hogehoge.jp/timelines
```

### あるサービスの自分のプロフィールを取得
ヘッダーもすごく簡単です。

```sh
$ http get https://hogehoge.jp/users/me/profile "Authorization:bearer accesstoken"
```

### あるサービスの自分のプロフィールを変更
ボディパラメータも学習コストは低いです。

```sh
$ http patch https://hogehoge.jp/users/me/profile "Authorization:bearer accesstoken" name=hoge
```

## インストール方法
MacであればHomebrewを使えば一発です。
```sh
$ brew install httpie
```

## 比較的よく使うオプション

### フォーム(application/x-www-form-urlencoded)送信

`-f` または `--form` オプション追加

```sh
$ http --form POST api.example.org/person/1 name='hoge'
```

### JSONパラメータを送信
コマンドライン上だと数字も文字列として扱うので次の形式で入れると Boolean, Number, Object といったJSON型を指定できます。

```sh
$ http POST api.example.org/person/1 name=Jonh age:=29 male:=true hobbies:='["hobby1", "hobby2"]'
```

## 公式ドキュメントがかなり豊富で読みやすい

英語になりますが、難しい単語は少ないので読みやすいです。
[HTTPie documentation](https://httpie.org/doc)

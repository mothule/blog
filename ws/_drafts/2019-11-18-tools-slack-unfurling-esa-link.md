---
title: esa記事をslackで展開する
categories: tools slack
tags: tools slack
---
slackでURLを貼るとURL先をフェッチして一部内容を展開してくれてとても便利なのですが、
esaなど閉じたサイトでは展開されずURLが貼られて終わります。

展開になれると寂しいですし、展開されてるほうがすぐに何の情報なのか分かりやすいので情報疎通も円滑になりますね。

そんなわけでesa記事をslackに展開してみました。

## slack メッセージの展開とは

*展開前*
{% page_image 1.png %}
URLが貼られるだけになります。

*展開後*
{% page_image 2.png %}

このように展開されることでURL先を遷移せずともslack内でざっくりサマリー情報を得ることができます。



## メッセージフロー

下記は大まかなフローです。

{% page_image 4.png %}

1. esaのURLをslackに投稿
1. esa bot となるSlack Appが検知
1. Slack App が指定のURLにesaのURLをリクエスト
1. 指定URL先のサーバーがesaにアクセス
1. esaの情報を加工してesa botに返す
1. esa botがslackに書き込む

## ビルドフロー

メッセージフローを構築するフローです。

- Slack App作成
  - [slack api/Apps](https://api.slack.com/apps) で `Create New App` ボタン
  - アプリ名とワークスペースを入力
  - 下記手順でesa URLに反応する仕組みを作る
    - Event Subscriptions > App Unfurl Domains に展開したいドメインを指定
      - 例えばesaなら hogehoge.esa.io
    - Subscribe to Workspace Events で `link_shared` が表示されてることを確認
    - `Save Changes` ボタン押下
  - 下記手順でサーバーからURL展開用の情報を受け取る仕組みを作る
    - Features > OAuth & Permissions > Scopes > Select Permission Scopes に移動
    - そこで `links:read` と `links:write` を追加
    - `Install App to Workspace` ボタン押下
    - 表示される `OAuth Access Token` を保持しておく
- 外部からesaをアクセスできる準備
  - MyPage > Applications に移動
  - `Personal access tokens` を read only で作成
  - 表示される `Personal Access Token` を保持しておく
- サーバー準備
  - [FromAtom/Kujaku](https://github.com/FromAtom/Kujaku)を使う
  - Deploy to Heroku
  - Heroku URL 保持
- Slack App と サーバーの連携
  - Slack App > Event Subscriptions に移動
  - `Request URL`に Heroku URLを入力
  - Enable EventsをONにする
  - `Save Changes`ボタン押下

## Herokuの前にローカルで試す場合

いきなりHerokuで実行する前に疎通確認のためにローカルで動かしたい場合は

- ローカルにRedisサーバー起動
- Kujaku(Sinatra) Webサーバー起動
- ngrok 起動
- Event Subscriptions > Request URL に ngrok の一時URLを設定

という段取りになります。

### ローカルにRedisサーバー起動

`$ redis-server` で起動します。

### Kujaku(Sinatra) Webサーバー起動

KujakuはSinatraフレームワークを使っているので、実行時は
`$ bundle exec ruby main.rb`になります。

#### Kujakuはいくつか環境変数が必要
Kujakuは内部でいくつか環境変数を必要なので、用意しておく必要があります。

`.bash_profile`などで用意でもいいのですが、実行時のみであればコマンドの前にセットすることでコマンドは変数を参照できます。

*例*
`$ hoge=fuga bundle exec ruby main.rb`


#### 必要な環境変数

|環境変数|用途|
|---|---|
|ESA_ACCESS_TOKEN|esa アクセストークン|
|ESA_TEAM_NAME|esa チームネーム|
|REDISTOGO_URL|RedisサーバーURL|
|SLACK_OAUTH_ACCESS_TOKEN|slack OAuth アクセストーン|

ESA_ACCESS_TOKENとSLACK_OAUTH_ACCESS_TOKENは前述したビルドフローを遂行すれば得られます。

REDISTOGO_URLはローカル実行限定で、URLとあるがhttp://などではなく`redis://`スキーマ指定が必要。
ローカルであるなら `redis://127.0.0.1:6379` などになる。
ポート番号などは`$ redis-cli`で確認できる


ESA_TEAM_NAMEとは esa のドメイン部を指す。 (例: https://hoge.esa.io なら `hoge`)

### ngrok 起動

ngrok に関してはこちらの記事をご確認ください。

{% post_link 2019-08-05-how-to-use-ngrok %}

### Event Subscriptions > Request URL に ngrok の一時URLを設定

先のngrok起動で得られるURLを Request URL に設定します。保存忘れずに。

{% page_image 5.png %}

#### ローカル実行時の注意点

redisを既に別で使ってる場合`flushall`しないと既存データを使おうとしてエラーになるので、
`redis-cli` で接続後に `flushall` で中のデータを全部クリアする必要があります。

既存redisのクリア処理は自己責任です。

## 参考
https://inside.pixiv.blog/fromatom/5684

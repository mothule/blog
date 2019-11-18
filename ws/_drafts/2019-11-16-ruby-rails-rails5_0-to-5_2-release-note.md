今更ながらRailsのバージョンを5.0から5.2.3に上げるにあたってどのような機能が追加されたのか確認しました。
[Railsガイド](https://railsguides.jp/)


## Rails 5.0の注目ポイント

- Action Cable
  - WebSocket通信をサポートした
- Rails API
  - APIのみのRailsアプリが作れるようになった
- Active Record属性API
  - ActiveRecordのカラムに型情報を定義できるようになった
- テストランナー
  - bin/rails test で新しいテストランナーが使える
- Sprockets 3
- Turbolinks 5
- Ruby 2.2.2以上必須
- その他細かい変更
  - bin/rails restart 追加
    - 直接 tmp/restart.txt を touch しても再起動
  - bin/rails initializers 追加
    - initializersの起動順を出力
  - bin/rails dev:cache 追加
    - development限定でキャッシュのON/OFFを変更
  - bin/update 追加
    - development環境を自動アップデートする
  - RAILS_LOG_TO_STDOUT環境変数の追加
    - productionでSTDOUTへのログ出力ができる
  - HSTS(HTTP Strict Transport Security)がデフォルト有効(新規アプリ限定)
  - config/spring.rbファイルが作成される
    - Springの監視対象となる共通ファイルを追加できる

## Rails 5.1の注目ポイント

- Yarn サポート
- Webpackのサポート
- デフォルトでのjQuery廃止
- システムテスト
  - Capybaraでテストがかけるようになった
- 秘密情報の暗号化
  - rails secrets:setup で実行できる
- mailer のパラメータ化
- routesにresolveルーティング directルーティング追加
- form_for/form_tag → form_with

## Rails 5.2の注目ポイント

- Active Storage
  - S3/GCS/Azure Storageなどにファイルアップロードし、そのファイルをActiveRecordにアタッチできるようになった
- Redis Cache Store
- HTTP/2 Early Hints
- credential管理
  - prodの秘密情報をここに保存できるようになった
  - 暗号化済み秘密情報も最終的にこれによって置き換えられる
  - credentialを支えるAPIも用意
- Content Security Policy (CSP)
  - デフォルトポリシーやリソースベース、リクエスト毎のヘッダーに注入できる

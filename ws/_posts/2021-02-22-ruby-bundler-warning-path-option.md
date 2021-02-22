---
title: bundler(1.17.2)で--path=vendor/bundleつけたら警告出た話
categories: ruby bundler
tags: ruby gem bundler
image:
  path: /assets/images/2021-02-22-ruby-bundler-warning-path-option/eyecatch.png
---
Railsの空アプリを作りたくて、bundler(`1.17.2`)で`--path`をつけてインストール実行したら、警告が表示されるようになってた。

## `--path=vendor/bundle`で表示された警告

```sh
[DEPRECATED] The `--path` flag is deprecated because it relies on being remembered across bundler invocations, which bundler will no longer do in future versions. Instead please use `bundle config set --local path 'vendor/bundle'`, and stop using this flag
```

簡単に訳すと、

`--path`フラグは全体に依存してるため、非推奨となりました。将来的に無視します。
代わりに`bundle config set —-local path 'vendor/bundle'`でセットしてください。

とのこと。

今後は、`--path`オプションではなく、`bundle config`として設定してほしいということですね。
`bundle config set —-local path 'vendor/bundle'`を実行することで、`--path`と同様に`.bundle/config`に`BUNDLE_PATH`が追記されます。

## localとなってるがglobalでも設定される
警告文には`local`になっていますが、これはglobalで設定してしまえば、毎回初回実行時に`--path`フラグの指定が不要になるようです。

```sh
$ bundle config path "vendor/bundle"
```

ホームディレクトリの`.bundle/config`を見たところ`BUNDLE_PATH`が追加されていました。
```sh
$ cat ~/.bundle/config
---
BUNDLE_PATH: "vendor/bundle"
```

個人的には `-j4` フラグなどジョブ数指定も同様の扱いになってくれたほうが楽だったりする。

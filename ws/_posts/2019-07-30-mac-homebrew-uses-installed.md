---
title: Homebrewで使われているかを解決する
categories: mac homebrew
tags: mac homebrew
---
長いことHomebrewに色々とインストールしてると、たまにもう使っていないフォーミュラ（パッケージ）を削除したいなと思いませんか？
`$ brew list -l` で一覧出して眺めて、「もうこれは使っていないな」と分かるパッケージは消していきますが、
「これ何で入れたんだっけ？」と思うパッケージが結構います。

## 結論
その場合は次のコマンドでどのパッケージで使われているのか分かります。

`$ brew uses --installed <formula>`

## 使い方

例えば自分の環境で `python` だと

```sh
$ brew uses --installed python
awscli                                       cairo                                        glib                                         gobject-introspection                        harfbuzz                                     httpie                                       pango                                        vim
```

のようにpythonを使っている一覧が並びます。

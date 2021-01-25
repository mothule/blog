---
title: ターミナルからRubyMineを起動、比較、マージなどする
categories: tools rubymine
tags: tools rubymine
image:
  path: /assets/images/2020-05-18-tools-rubymine-launch-from-terminal/eyecatch.png
---
RubyMineは便利ですが、普段はターミナルを触ることが多いので、ターミナルからRubyMineを開く方法について調べたら、開く以外のことができることが分かったのでまとめます。


## ターミナルからRubyMineで開く

まずターミナルからRubyMine.appwを開くには`open`コマンドを使います。
最後のドットはそのフォルダをRubyMineで開くことを意味します。

```sh
$ open -na "RubyMine.app" .
```

- -a : アプリケーションを指定する
- -n : アプリが起動済みでも新しいインスタンスで開く


## シェルスクリプト化する

### シェルスクリプトを用意

```sh
#!/bin/sh
open -na "RubyMine.app" --args "$@"
```

これを`rubymine`という名前で保存します。

### 実行権限付与
さっき作ったシェルスクリプトの実行権限を変更します

```sh
$ chmod 711 rubymine
```

これでターミナルからrubymineスクリプトを実行できるようになります。

### パスが見えるようにする

このままだと配置した場所のパスが必要になるので、ターミナルが見えるようにパスが見える場所に配置します。

```sh
$ mv rubymine /usr/local/bin/
```

なおこの場所でなくとも`cat $PATH`で表示されるディレクトリ上にならどこでも構いません。


### RubyMineに渡せる引数一覧

- 引数なし : RubyMine起動
- ファイルまたはディレクトリのパス : RubyMineで指定パスを開きます
- diff : 渡された２つのファイルの差分を見ます
- merge : 渡されたファイル2~3つと出力パスでマージします
- format : 指定されたファイルにコードスタイルのフォーマットを適用します
- inspect : 指定プロジェクトでコード検査します


## RubyMineでファイル差分を見る
Syntax: `rubymine diff <path1> <path2>`

```sh
$ echo "Hoge" > hoge.txt
$ echo "Fuga" > fuga.txt
$ rubymine diff hoge.txt fuga.txt
```

{% page_image 1.png , 100% , RubyMine diff画面 %}

## RubyMineでファイルマージする
Syntax: `rubymine merge <path1> <path2> [<base>] <output>`

```sh
$ echo "Hoge" > hoge.txt
$ echo "Fuga" > fuga.txt
$ touch base.txt
$ touch out.txt
$ rubymine diff hoge.txt fuga.txt base.txt out.txt
```

{% page_image 2.png , 100% , RubyMine merge画面 %}

## RubyMineでファイルフォーマットを適用する
Syntax: `rubymine format [<options>] <path ...>`

```sh
$ cat ruby.rb
def main
puts "hogehogehoge"
end
$ rubymine ruby.rb
$ cat ruby.rb
def main
  puts "hogehogehoge"
end
```


どうやらrubocopが動くようではなく、RubyMine内の設定(Editor ｜ Code Style)に沿うようです。

### Options

- -h : ヘルプ表示
- -m or -mask : コンマ区切りでマスクファイルの一覧
  - 例 : -m *.xml,*.html
- -r or -R : 階層処理
- -s or -settings : ExportされたRubyMine内の設定

## RubyMineでコード検査する
Syntax: `rubymine inspect <project> <inspection-profile> <output> [<options>]`

RubyMineでコード書いていると警告されるアレです。  
ターミナル上からコード検査をして結果を外部ファイルに出力します。

`~/Downloads/sandbox`ディレクトリがあり、その中に`ruby.rb`ファイルがあった場合

```sh
$ rubymine inspect ~/Downloads/sandbox/ ~/Downloads/sandbox/.idea/inspectionProfiles/Project_Default.xml ~/Downloads/sandbox/InspectionResults -v2 -d ~/Downloads/sandbox/
```

### Options

- -d : 検査ディレクトリの指定.
- -format : 結果フォーマットの指定(xml/json/plan). デフォはxml
- v : 検査詳細レベル
  - -v0 : デフォルト(最も低い)
  - -v1 : ミディオム
  - -v2 : 最大


## まとめ

diffとmergeがあるのは知りませんでした。  
渡せる引数からしてgit mergetoolに登録できるかもしれません。  
もし渡せたら重いp4mergeとはオサラバです。

{% comment %} git mergetool に rubymine を渡す {% endcomment %}

[RubyMine - Command-line interface](https://www.jetbrains.com/help/ruby/working-with-the-ide-features-from-command-line.html)を参考にしてあります。
なお公式記事内では `inspect` が `rinspect` となっています。`rinspect`では動かなかったので多分タイポです。

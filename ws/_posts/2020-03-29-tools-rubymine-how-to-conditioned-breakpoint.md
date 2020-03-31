---
title: RubyMineで条件付きブレイクポイントを使いこなす方法
categories: tools rubymine
tags: tools rubymine ruby
image:
  path: /assets/images/2020-03-29-tools-rubymine-how-to-conditioned-breakpoint/0.png
---
みんな大好きRubyMineはRubyのIDEです。
IDEと言えばそのソフト一つで開発環境が整っている必要があります。
なんせ**Integrated Development Envrionment**ですもんね。

そんなIDEの重要機能としてデバッグがあります。
これが統合されていないIDEはIDEとは絶対に言えないです。

その中でもブレイクポイントはデバッグにおいて要と言える機能です。
ブレイクポイントができないデバッグは何ができるのか？と疑問なほどです。

## 条件付きブレイクポイントとは？

そんな便利なブレイクポイントですが、IDEとして用意されているブレイクポイントは一般的に単純なブレイクポイントだけでなく、一定の条件を満たした場合のみ止まってくれる**「条件付きブレイクポイント」** はIDEならではの機能です。

RubyMineにもきちんと用意されてます。今回はこれの使い方を説明します。

コードは何でもいいです、今回はこれを使います。

```ruby
(1..10).each do |i|
  puts i + 1
  puts i - 1
  puts i * i
end
```

## 無条件ブレイクポイントをかける

行の横をクリックすると赤丸がついたらその行にブレイクポイントをつけたことになります。

{% page_image 1.png 50% RubyMineのエディタ画面 %}

Debug実行するとこの行で止まります。

{% page_image 2.png 50% RubyMineでブレイクポイントで止まった画面 %}

これでもブレイクポイントがかかっているのでその時のコンテキストでRubyコードを実行したり変数評価したりできます。

{% page_image 3.png 50% RubyMineでブレイクポイントで止めた後のConsole画面 %}

### ループ内のブレイクポイントは何回も止まる

ただこの方法ではループや何回も呼ばれるメソッドなどではその都度止まります。
例えば決まったコンテキストだけデバッグしたい場合では何度も再開ボタンを連打して飛ばしてしまったりします。

## 条件付きブレイクポイントをかける

この無条件のブレイクポイントを右クリック押すとポップアップメニューが出ます。

{% page_image 4.png 100% RubyMineでブレイクポイントの編集ポップアップ %}

- Enabled: 有効状態の設定
- Suspend: 一時停止の設定
- Condition: 条件の設定

### Enabled: 有効状態の設定
一時的に有効／無効を設定します。ブレイクポイント自体の削除はしません。
無効にすると穴のあいた赤丸になります。

### Suspend: 一時停止の設定
一時停止とはつまるところ停止です。この行で止まります。
デフォルトではONになっており、これをOFFにするとオレンジ色になります。

{% page_image 5.png 100% RubyMineでブレイクポイントの編集でSuspendOFF %}

一時停止する代わりにログ出力のオプションが増えます。

#### "Breakpoint hit": 発火をログ出力で通知
止まる代わりにログを出力します。
例えば次のコードでブレイクポイントを貼り、
"Breakpoint hit"をONにします。

```ruby
(1..2).each do |i|
  puts i # ここでブレイクポイントを貼る
end
```

結果は次のようになります。
```sh
1
4

Process finished with exit code 0
Breakpoint reached: main.rb:4
Breakpoint reached: main.rb:4
```
「**"Breakpoint reached: main.rb:4"**」と通過したことをログ出力されてます。

#### Stack trace: 発火時のスタックトレース表示
ブレイクポイントを通過して発火するとコールスタックを出力します。

```
1
4

Process finished with exit code 0
Stack:
	main.rb:4
	main.rb:3
	debug_program [ruby-debug-ide.rb:100] (singleton class of Debugger)
	rdebug-ide:204
Stack:
	main.rb:4
	main.rb:3
	debug_program [ruby-debug-ide.rb:100] (singleton class of Debugger)
	rdebug-ide:204
```

どこからこのメソッドが呼ばれてるのか知りたい場合に便利ですね。

#### Evaluate and log: 発火時に独自ログを表示

ブレイクポイントを通過して発火すると記載しておいたRubyコードが評価され結果を出力します。
例えばブレイクポイントに次のコードを仕込んで実行すると
```ruby
"String #{i}"
```
ブレイクポイント発火時に次のようにRubyコードの評価結果が出力されます。
```sh
1
4

Process finished with exit code 0
String 1
String 2
```

#### Remove once hit: 一度だけ止まる

ブレイクポイントを一度発火するとそのブレイクポイントは削除されます。
**このブレイクポイントはSuspendがONのときしか機能しません。**


#### Disable until hitting the following breakpoint: 他のブレークポイント検知で有効化する
このブレイクポイントは他のブレークポイントが発火したらそれをトリガーにブレークポイントが有効化します。

ただシングルスレッドではこの機能は正しく動作していないように思えます。
対象のブレイクポイント発火時はたしかに有効化しているようなのですが、その後有効状態を継続してもブレイクポイントはヒットしません。
ここもし詳しく分かる方いたら教えてほしいです。

### Condition: 条件の設定

デフォルトはOFFになっておりONにすることで`Condition`内をRubyとして評価し`true`になったら止まります。
条件付きブレイクポイントの場合は赤丸の右下に？マークがつきます。
次の図では、変数`i`が`5`になったら止まります。

{% page_image 6.png 100% RubyMineの条件付きブレイクポイント %}

例では単純な等価判定ですが、戻り値として`Bool`を返せばいいだけなので
そのコンテキストで得られる情報を使った評価も可能です。
例えばActiveRecordがアクセスできるコンテキストであれば条件式に入れることも可能です。

```ruby
User.find_by(id: i).admin?
```
といったことも可能です。

## Moreでブレイクポイント管理画面を表示

画面左下の`More`ラベルをタップするとブレイクポイント一覧と詳細ができる管理画面が表示されます。

{% page_image 7.png 100% RubyMineブレイクポイント管理画面 %}

この画面でなくても指定したブレイクポイントの編集は可能です。

## RubyMineにも条件付きブレイクポイントはつけれる

他IDEと遜色ない条件付きブレイクポイント機能ですね。
ただ条件付きブレイクポイントのデメリットとしては、処理が重くなります。
通るたびに条件を満たしているか評価を行うためその分重くなります。

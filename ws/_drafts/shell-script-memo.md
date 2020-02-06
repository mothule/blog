# iOSエンジニアでも最低限知るべきシェルスクリプト

参考
https://qiita.com/zayarwinttun/items/0dae4cb66d8f4bd2a337
https://qiita.com/progrhyme/items/e99be732c2e62d4a7641
https://jehupc.exblog.jp/15729095/



## シェルスクリプトとは？
広義と狭義の意味を持っているのですが、ここではUnixシェルで使われるスクリプト言語です。  
つまりシェルのスクリプトです。

### ではシェルとは？
シェルとはOSとユーザーが対話するためのインターフェイスを提供するソフトウェアです。  
ユーザーがOSに対して命令するための窓口とも言えます。  
bashやzshなどもシェルでありコマンド言語でもあります。

### コマンドとは？

シェルが提供している対話手段みたいなものです。  
echo などがそれにあたります。

つまりシェルスクリプトとはechoなどのシェルコマンドにより構成されたスクリプト言語です。


スクリプト内でコマンド実行して結果を受け取る方法
[[ ]] の意味
>&2 の意味
exit 1 の意味
=~ の意味
[[ -z $hoge ]] の意味

## よく使うコマンド

- echo
- shift

### echo
### shift: 引数をN個ずらす

`shift [N]`
引数が1,2,3,4,5の場合、

```sh
echo $1 → 1
echo $2 → 2
shift
echo $1 → 2
echo $2 → 3
shift 2
echo $1 → 4
echo $2 → 5
```

case/inと組み合わせることで引数を一つずつハンドリングする処理が書くこともできます。


## 入出力リダイレクト

入力をコマンドに渡したり、コマンドの結果を別ストリームに渡したりすることをいいます。

- 上書きとファイル作成

### ファイル作成(上書き)

結果を指定パスに出力します。

```sh
$ echo "test" > ~/test.txt
$ cat ~/test.txt
test
```

出力先が存在する場合は上書きします。

```sh
$ cat ~/test.txt
test
$ echo "test2" > ~/test.txt
$ cat ~/test.txt
test2
```

## パイプ

## 外部シェルスクリプトの作成

### コメント

```sh
# これはコメント
```

### シェバング

`#!/usr/bin/bash`

### 実行権限

`$ chmod 711 shellscript.sh`


## 変数

- 変数の宣言
- 変数の参照
- 変数のエクスポート
- 特殊変数

### 変数の宣言
変数宣言は次のように書きます。
```sh
VARIABLE=1
```
**注意**
=の前後にスペースを空けるとエラーになります。

### 変数の参照
変数にアクセスして中の値を使うには変数名の前に$をつけて`$変数名`と書いて使います。
```sh
echo $VARIABLE
```

#### ${}でより厳密な参照
`$var`でも変数への参照はできるが、本来の正しい参照は`${var}`が正しい。  
この方法じゃないと変数名によっては間違った解釈で異なる変数参照をしようとする。
また後述する文字列演算子を使うときに必要となる。

### 文字列演算子
http://se.cite.ehime-u.ac.jp/~aman/memo/bash/shell_prog1.html
${1:-hogehoge}とか${hoge:-fuga}の意味



### 変数のエクスポート
変数を定義したシェルから起動したシェルや実行したコマンドから変数を参照できるようになります。
これを環境変数と呼びます。
```bash
export var2=cdn
```

### 特殊変数

[Linuxのシェルスクリプト変数の記号あれこれ - 気まぐれな備忘録(仮)](http://kajitiluna.hatenablog.com/entry/20111023/1319381392)


#### 引数
コマンドラインに渡された値が格納された変数です。

例えば**test.sh**の中身が下記コードだとして、
**test.sh**
```sh
echo $1
```
次のようなコマンドを実行すると、
```sh
$ sh test.sh hoge fuga nuga
```
```sh
hoge
```
とターミナルに出力されます。

`$1`


#### 直前のコマンドの終了ステータスを保持
`$?`

## 条件分岐

コマンドの結果によって次の処理を変えたい場合は、if文やswitch/case文を使います。

### if/else文

```sh
if 条件式 ; then
  # some process
elif 条件式 ; then
  # some process
else
  # some process
fi
```
閉じスコープが `if` の反対になってるのが特徴です。  
また `; then` の`;`はSwiftと同じ役割です。開始ブレースが頭についたほうが読みやすいようにシェルスクリプトでも`;`をつかって表現しています。

これは`;`使わずに書くと
```sh
if 条件式
then
  # some process
elif 条件式
then
  # some process
else
  # some process
fi
```
となり、さっきまであったレイアウトの法則性がなくなり、視線の運び方に乱れがおきて負荷がかかります。
つまりスラスラと読みにくいです。


例えば
```swift
if 1 > 0 {
  print("True")
}
```
を書く場合は
```sh
if [ 1 -gt 0 ] ; then
  echo True
fi
```
と書きます。

#### 注意！シェルのifは我々の知っているifではない

↓ `test`コマンドについて別途記事まとめる。

[[]]は[]の強化版

[test と [ と [[ コマンドの違い - 拡張 POSIX シェルスクリプト Advent Calendar 2013 - ダメ出し Blog](https://fumiyas.github.io/2013/12/15/test.sh-advent-calendar.html)

#### ifの評価式にtestや[]を使う理由
if文はlsやgrepなど**コマンドの終了ステータス**を評価しています。
そして、終了ステータスは**0なら真**となりそれ以外なら偽となります。
そのため `if $age > 5 ; then` みたいには書けません。

上記みたいな式を書きたい場合は、`test`コマンドを使います。
`test`コマンドは受け取った引数を評価し、真なら0、偽なら1の終了ステータスを返してくれます。
これをifの評価式に挟むことで、我々が本来そうていしているif文が使えるようになります。

`test 数値1 -eq 数値2`
```sh
$ test 1 -eq 1 ; echo $?
```

ちなみにこれのシュガーシンタックスが[]となります。
上のコードは次のように書けます。
```sh
$ [ 1 -eq 1 ] ; echo $?
```


しかし残念ながら、`test`コマンドは **==,<,>,<=,>=** は使えない。代わりに文字列で指定するしかない。

|引数|意味|いわゆる|
|---|---|---|
|-lt|Less than|<|
|-gt|Greater than|>|
|-le|Less than or equal|<=|
|-ge|Greater than or equal|>=|
|-eq|Equal|==|
|-ne|Not equal|!=|


ちなみに and と or は
and は`expression1 -a expression2`
or は`expression1 -o expression2`
となる。

否定は ! となる
`[ ! $hoge ]`

一般的に`if test hoge`と書かずに`if [[hoge]]`のように書かれる。 `[[]]`はtestの略式コマンドとなる

また文字列の比較であれば、 `=` と `!=` が使える


#### testコマンドでファイルやディレクトリの存在有無が分かる

ディレクトリは `-d` オプションを指定することで、その次に続くパスにディレクトリがあるか確認できる

```sh
if [ -d '/your/directory/path' ]; then
  echo "ある"
else
  echo "ない"
fi
```

ファイルは `-f` or `-e` オプションを指定することで、確認できる。


またファイルが読取可能, 書込可能, 実行可能の確認もできて、それぞれ
`-r` `-w` `-x`となる。

またファイルが空サイズかどうかの確認は `-s`で確認できる。

#### testコマンドで2つのファイルの新旧を比較できる

`[ $file1 -nt $file2 ]` は `$file1` が新しいと真となる
`[ $file1 -ot $file2 ]` は `$file1` が古いと真となる

それぞれ
`-nt` → newer than
`-ot` → older than
となる。


#### testコマンドで文字列の長さチェックができる

`[ -z $hoge]` は文字列の長さが0なら真
`[ -n $hoge]` は文字列の長さが1以上なら真
n


### switch/case文

shift

```sh
case 値 in
  ケース1 ) 処理 ;;
  ケース2 ) 処理 ;;
esac
```
`;;` セミコロン二つはコマンドの終わりを知らせます。


#### 評価値が文字列の場合は正規表現が使える

```sh
branch=
case "$1" in
  -b | --branch)
    echo $2
    branch=$2
    ;;
esac
```

## ループ

### for文

```sh
for var in one two three; do
  echo $var
done
```

### while文


```sh
while 評価式; do
  break
done
```

```sh
while read var; do
  echo $var
done < ~/Downloads/hoge.txt
```

## 関数

```sh
function my_func() {
  echo hello_world
}
```

### 引数あり関数
```sh
function hello() {
  echo "hello, $1"
}
hello "hoge"
```

## 特殊引数
### ダブル・ダッシュ
ハイフン二つ(--)のことをダブル・ダッシュ(Double Dash)と呼ばれており、これはコマンドフラグの終わりを示す記号となる。  
オプションのスキャン処理を明示的に終了させるときに使う。


## 展開
`$(コマンド)` でコマンド結果を出力します。  
同様の機能にバッククォートで囲む ``コマンド`` もあります。

## 正常終了と異常終了
`exit 終了ステータス`

正常： `exit 0`
以上： `exit 1`など0以外

## echo で色
16進数
```sh
echo -e "\033[1;31m This is red text \033[0m"
```

## 応用

### bash限定: local の意味
シェルスクリプトの変数はデフォルトはグローバル変数です。  
グローバル変数は、関数内で変数が使われていても、外でその変数にアクセスできるなど不具合の巣窟です。

```sh
function hoge() {
  var="test"
  echo $var
}
hoge
echo $var # "test" と出力される
```

関数で使った変数は関数から出たら消えてほしい場合には local を使います。

```sh
function hoge() {
  local var="test"
  echo $var
}
hoge
echo $var # 空出力
```

forなど内部で変数が使われるような場合は、事前に使う変数をlocal変数宣言しておきます。
```sh
local var
for var in `echo test1 test2 test3` ; do
  echo $var
done
echo $var # 空出力
```

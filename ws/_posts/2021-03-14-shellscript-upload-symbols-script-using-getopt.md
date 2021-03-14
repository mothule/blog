---
title: getoptによるオプション対応をiOSエンジニアでも分かるCrashlyticsへdSYMアップを使って説明する
description: getoptでのオプション対応をiOSエンジニアでも理解できるようFirebase Crashlyticsのコマンドを使ったスクリプトを用意して説明します。iOSエンジニアいえど、避けては通れないシェルスクリプト。でもちょっと凝ろうとするとその慣れない構文やスタイルにすぐ折れます。
categories: tools shellscript
tags: tools shellscript ios firebase crashlytics
image:
  path: /assets/images/2021-03-14-shellscript-upload-symbols-script-using-getopt/eyecathc.png
---
iOSエンジニアいえど、避けては通れないシェルスクリプト。でもちょっと凝ろうとするとその慣れない構文やスタイルにすぐ折れます。

今回はシェルスクリプトでgetoptを使ったオプション対応する方法について、実際に動くコードを使って説明します。
また、処理自体もiOSエンジニアには馴染みのあるFirebase Crashlyticsの`upload-symbols`コマンドを使うので読みやすいと思います。

## 概要

### 背景
今回スクリプト書いた経緯は、シェルスクリプトには必ずと言っていいほどオプション機能が備わっています。
Rubyではgemを使えばパースをいい感じにやってくれますが、シェルスクリプトではどのように実現しているのか仕組みを知っておこうと思いました。

### 読者対象
- iOSやAndroidエンジニアなどシェルスクリプトと正面から向かい合う機会が少ない人
- ちょっと凝ったシェルスクリプトを書きたい人
- 念の為シェルスクリプトの読むスキルを向上させときたい人

### この記事で得られる内容
- getoptの使い方やMacの標準搭載したgetoptの注意点
- getoptを使ったオプション対応
- シェルのcase文の使い方

## 作ったスクリプトの使い方
説明するスクリプトの動作について説明します。

Firebase Crashlyticsに入っている`upload-symbols`コマンドを使う機能のみです。
これにコマンドに必要な引数をオプションで変更可能にしてあります。

アップロードしたいdSYMを次の方法で指定できます。

- アーカイブされた`*.dSYM`ファイル
- `*.dSYM`ファイルの入ったディレクトリ
- 直接`*.dSYM`ファイル指定

```sh
$ ./dsyms-uploade.sh ~/Downloads/hogehoge-1.2.3.zip
$ ./dsyms-uploade.sh ~/Downloads/hogehoge-1.2.3/
$ ./dsyms-uploade.sh ~/Downloads/hogehoge-1.2.3/hogehoge.dSYM
```

オプションを渡して処理に使うパス先を変更できます。

```sh
$ ./dsyms-uploade.sh ~/Downloads/hogehoge-1.2.3.zip \
-c ~/workspace/hogehoge/Pods/FirebaseCrashlytics/upload-symbols \
-p ~/workspace/hogehoge/GoogleService-Info-release.plist
```

ロングオプションにも対応します。

```sh
$ ./dsyms-uploade.sh ~/Downloads/hogehoge-1.2.3.zip --dry-run
```

ヘルプを出すとそれっぽいヘルププリントが出力されます。
```
$ ./dsyms-uploade.sh --help
Usage: ./dsyms-uploade.sh <dSYM> [-c, --upload-symbols-command-path path] [-p, --google-service-plist-path path] [-d, --dry-run] [-h, --help]


  dSYM			dSYMファイルまたはアーカイブされた複数のdSYM、dSYMファイルが含まれたディレクトリを指定します。
			ディレクトリの場合は *.dSYM で一致するファイルが対象となります。

Options:
  --upload-symbols-command-path <path>
			upload-symbolsコマンドのパスを指定します。
  -c			--upload-symbols-command-pathのエイリアス
  --google-service-plist-path <path>
			GoogleService-Info.plistのパスを指定します。
  -p			--google-service-plist-pathのエイリアス
  --help		このヘルプ画面を表示します
  -h			--helpのエイリアス
  -d,--dry-run		実行の代わりに実行するコマンドラインを表示します。
```

## getoptとは
getoptの役割はとても単純で、コマンドオプションをパースするシェルコマンドです。

### getoptsとの違い
こちらも同様にコマンドオプションですが、bashのビルドインコマンドの一つとなります。
getoptsではロングオプションの対応が少し面倒そうだったためgetoptにしました。

### getoptにはGNU版とBSD版がある
getoptには出どころが複数あり、出どころによって挙動が異なります。
大きく分けるとGNU版とBSD版になります。

## GNU版getoptを使う理由
今回使うgetoptはGNU版を使います。理由は次の通りです。

- **ロングオプション**が使える
- **Bitrise**がgnu版をインストールしてた

ロングオプションを使いたい理由は、スクリプト利用時の可読性もありますが、単純によく見かけるよくできたオプションにはロングオプションが使われているからです。

また、このスクリプトの処理内容はFirebase CrashlyticsへdSYMをアップロードすることです。
アーカイブしてApp Store Connectでそのビルドを使うなら、そのビルドのdSYMをアップロードする必要があります。
そのためCIサービスからアーカイブするようなことも考慮します。

自分がよく使っているCIサービスはBitriseで、[BitriseのシステムレポートでGNU版getoptがインストールされていた](https://github.com/bitrise-io/bitrise.io/blob/master/system_reports/osx-xcode-12.5.x.log)という理由もあります。


### GNU版getoptをMacにインストール
MacでGNU版getoptを使うには、Homebrewからインストールします。

```sh
$ brew install gnu-getopt
```

インストールは`keg-only`となっていので、インストール後に`gnu-getopt`が優先して使われるようにパス変更します。
```sh
echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.zshrc
```

## コード全容
コードはGistに上げてあります。このコードから抜粋して説明します。

<script src="https://gist.github.com/mothule/391e64e936bfc9593a17e57803a74c12.js"></script>

### コードの流れ
スクリプトは1ファイルで構成されてます。
この1ファイルを上から見たとき次の順序で処理構成してます。

- 関数定義
- スクリプト前提条件の検証
- 引数で受け取る変数宣言
- getoptで引数からオプションへ変換
- オプション毎のハンドリング
- 受け取った変数の検証
- upload-symbolsコマンドの実行

## 関数定義
ヘルプ用表示関数(`usage()`)と引数を検証する関数(`validate_arg`)の2つが定義されてます。

### 引数を検証する関数

オプションには値も一緒に渡すタイプもあります。
その場合に値が正しいか検証する関数です。

渡された引数が「文字列としての長さが0」または「文字先頭がハイフン(`-`)から始まる場合は、ヘルプを表示します。
ヘルプは最後に`exit 1`を出しているのでそのままスクリプトは終了します。

```sh
validate_arg() {
  local value=$1
  # valueの長さが0 or valueがとマッチ
  if [[ -z $value ]] || [[ $value =~ ^-+ ]]; then
    usage
  fi
}
```

この関数は値やオプション値の検証時に呼ばれています。

## スクリプト前提条件の検証
先程までは関数でしたので処理としてはここが最初に実行されます。
`getopt`がBSD版ではなくGNU版を使っているかを検証します。
ここでBSD版だと後のgetoptの処理が正しくされず変な挙動となるためです。

なぜ、GNU版かどうかをこの方法で判断してるのかは、実際に双方のコマンドを見比べて決めました。

```sh
if [[ ! "`getopt --version | grep linux`" ]]; then
  echo "利用にはgnu-getoptが必要です。" >&2
  exit 1
elif [[ $# == 0 ]]; then
  usage
fi
```

## 引数で受け取る変数宣言

上から順番に次の役割を持っています。

- `upload_command`: `upload-symbols`コマンドのパス
- `google_service_plist`: Firebaseで受け取るplistのパス
- `dsym_path`: dSYMのパス
- `dry_run`: Dry実行するかどうか

```sh
upload_command=Pods/FirebaseCrashlytics/upload-symbols
google_service_plist=./GoogleService-Info.plist
dsym_path=
dry_run=false
```

## getoptで引数からオプションへ変換

getoptコマンドを使って渡された引数から有効なオプションを`opt`へ抜き出します。
`-o`でオプションで使う文字列で、値付きはコロンを文字後ろにつけます。
`-l`でロングオプションで使う文字列で値付きはコロンを文字列後ろにつけます。カンマで区切ります。
最後の `eval set`で位置パラメータを再構成します。

```sh
opt=$(getopt -o "c:p:hd" -l "upload-symbols-command-path:,google-service-plist-path:,help,dry-run" -- "$@")
if [[ $? != 0 ]]; then
  echo "getopt実行にエラーが発生しました。" >&2
  exit 1
fi
eval set -- "$opt"
```

## オプション毎のハンドリング

シェルスクリプトのオプションのハンドリングは、引数を先頭からキューのように取り出して破棄しながら進めます。
そのためオプションを1つハンドリングすると`shift`して次の引数を`$1`として取り出します。
オプションに値があるオプションの場合は、`$2`も値として使い、`shift 2`でオプション名とオプション値2つを履きします。

```sh
while true
do
  case "$1" in
  -c | --upload-symbols-command-path)
    validate_arg $2
    upload_command=$2
    shift 2 # 値付きなので2つ分ずらす
    ;;
  -p | --google-service-plist-path)
    validate_arg $2
    google_service_plist=$2
    shift 2
    ;;
  -h | --help) # -h または --help
    usage
    ;;
  -d | --dry-run)
    dry_run=true
    shift
    ;;
  --) # -- の場合何もしない
    shift
    break
    ;;
  *) # それ以外
    usage
    ;;
  esac
done
```

## 受け取った変数の検証
オプションのハンドリングが済んだら、
`upload-symbols`コマンドを使う前に関係する変数が有効か検証します。

```sh
if [[ ! -e $upload_command  ]]; then
  echo "upload_command_pathが有効なパスではありません。${upload_command}" >&2
  exit 1
fi

if [[ ! -e $google_service_plist ]]; then
  echo "google_service_plistが有効なパスではありません。${google_service_plist}" >&2
  exit 1
fi

if [[ ! -e $dsym_path ]]; then
  echo "dsym_pathが有効なパスではありません。${dsym_path}" >&2
  exit 1
fi
```

## upload-symbolsコマンドの実行

最後に`upload-symbols`コマンドを実行します。

`--dry-run`や`-d`でドライランが有効な場合は、`upload-symbols`コマンドは実行せずに
echoコマンドで実行予定のコマンドを文字列として表示して終了します。

```sh
if [[ -f $dsym_path ]]; then # path is file.
  if [[ $dry_run == true ]]; then
    echo "$upload_command -gsp $google_service_plist -p ios $dsym_path"
  else
    $upload_command -gsp $google_service_plist -p ios $dsym_path
  fi

elif [[ -d $dsym_path ]]; then # path is directory
  if [[ $dry_run == true ]]; then
    find $dsym_path -name "*.dSYM" | xargs -I FILE echo $upload_command -gsp $google_service_plist -p ios FILE
  else
    find $dsym_path -name "*.dSYM" | xargs -I FILE $upload_command -gsp $google_service_plist -p ios FILE
  fi

else
  echo "dsym_pathはファイルかディレクトリのみ有効です。${dsym_path}" >&2
  exit 1
fi
```

### ディレクトリ指定の動きについて
ファイル指定の場合は挙動はシンプルなため説明なく読み取れると思います。
ディレクトリ指定の場合は、指定ディレクトリ内を`*.dSYM`で検索し、一致するパス全部に対し、`upload-symbols`コマンドを実行します。

#### .dSYMをファイルを探す
コマンドライン前半の`find $dsym_path -name "*.dSYM"`では、指定ディレクトリ内から`*.dSYM`を探します。
`find`コマンドの結果を次の`xargs`コマンドへパイプで渡します。

コマンドライン後半の`xargs -I FILE $upload_command -gsp $google_service_plist -p ios FILE`では、
前半から受け取った文字列を指定位置に配置して、実行します。この場合`FILE`が前半から受け取った文字列、つまり`.dSYM`のパスになります。

## このスクリプトの使い所
今回はgetoptを使ってオプション対応する方法がメインですが、このスクリプト自体にも一応活用ケースはあります。

元々これを書こうと思った理由として、「使用頻度高いのに毎回ネットからアップロードシェルコマンド確認するのが面倒」が一番でした。他にもdSYMが必ずしも手元PCにあるとは限らない環境だったりです。

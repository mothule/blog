---
title: 【初心者向け】UITableViewのセル選択を制御する方法
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-18-ios-swift-rxswfit-basic.png
---

UITableViewのUITableViewCell(セル)をタップを検知する実装方法について説明します。

一部検知イベントは超基本的で超高頻度で使う機能ですが、難易度は簡単なのでささっと覚えてしまうほうが後々の実装効率は良くなります。

## セルの選択イベント一覧

- セルタップ制御: `func tableView(_:shouldHighlightRowAt:) -> Bool`
- セルハイライト直後: `func tableView(_:didHighlightRowAt:)`
- セルハイライト解除直後: `func tableView(_:didUnhighlightRowAt:)`
- セル選択直前: `func tableView(_:willSelectRowAt:) -> IndexPath?`
- セル選択解除直前: `func tableView(_:willDeselectRowAt:) -> IndexPath?`
- セル選択直後: `func tableView(_:didSelectRowAt:)`
- セル選択解除直後: `func tableView(_:didDeselectRowAt:)`

`セルタップ制御`では、falseを返したセルはタップしてもハイライトにもタップイベントも呼ばれません。  
ラベルセルとして実装する場合にここをfalseにしてタップできないようにします。

`セル選択直前`と`セル選択解除直前`の戻り値は返したセル位置が実際に選択状態を変更します。  
正直使うケースに出くわしたことはありません。

`セル選択直後`はセルがタップされたときにここにセルごとの処理を記述することで、セルのタップハンドリングができます。

## セルの選択/解除を検知する
- セル選択直前: `func tableView(_:willSelectRowAt:) -> IndexPath?`
- セル選択解除直前: `func tableView(_:willDeselectRowAt:) -> IndexPath?`
- セル選択直後: `func tableView(_:didSelectRowAt:)`
- セル選択解除直後: `func tableView(_:didDeselectRowAt:)`
- セルハイライト直後: `func tableView(_:didHighlightRowAt:)`
- セルハイライト解除直後: `func tableView(_:didUnhighlightRowAt:)`

この4つはセルの選択や解除の前後で呼ばれるコールバックメソッドです。

- セル選択直前: `func tableView(_:willSelectRowAt:) -> IndexPath?`
- セル選択解除直前: `func tableView(_:willDeselectRowAt:) -> IndexPath?`

直前に呼ばれるこの2つは、選択するセル／解除するセルを制御することも可能です。   
`nil`を返すと選択の拒否／解除の拒否する動作になります。

### イベント検知したら通知する実装
次のコードはセルをタップしたら、選択や解除の前後でコンソールにアウトプットするコードです。

```swift
// セル選択直前
func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    print(#function + "\(indexPath.row)")
    return indexPath
}

// セル選択解除直前
func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
    print(#function + "\(indexPath.row)")
    return indexPath
}

// セル選択直後
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(#function + "\(indexPath.row)")
}

// セル選択解除直後
func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    print(#function + "\(indexPath.row)")
}

// セルのハイライト直後
func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    print(#function + "\(indexPath.row)")
}

// セルのハイライト解除直後
func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    print(#function + "\(indexPath.row)")
}
```

### 動かした結果

{% page_image -1.gif 50% %}

上記動きをしたときの出力結果は次の通りです。

```
tableView(_:didHighlightRowAt:)0
tableView(_:didUnhighlightRowAt:)0
tableView(_:willSelectRowAt:)0
tableView(_:didSelectRowAt:)0
tableView(_:didHighlightRowAt:)1
tableView(_:didUnhighlightRowAt:)1
tableView(_:willSelectRowAt:)1
tableView(_:willDeselectRowAt:)0
tableView(_:willDeselectRowAt:)0
tableView(_:didDeselectRowAt:)0
tableView(_:didSelectRowAt:)1
tableView(_:didHighlightRowAt:)2
tableView(_:didUnhighlightRowAt:)2
tableView(_:willSelectRowAt:)2
tableView(_:willDeselectRowAt:)1
tableView(_:willDeselectRowAt:)1
tableView(_:didDeselectRowAt:)1
tableView(_:didSelectRowAt:)2
```

最初のセル選択以外は、

1. セルハイライト直後
1. セルハイライト解除直後
1. セル選択直前
1. セル選択解除直前
1. セル選択解除直後
1. セル選択直後

の順番で呼ばれています。(セル選択解除直前がなぜ2回呼ばれているのかは不明です)

#### ハイライトとは押下中の状態
ハイライトとは指でセルを押したままの状態を指します。

### セルのタップにより処理をするなら選択直後

セルをタップしたら別画面に遷移するなど、セルの押下で処理をしたい場合は

`tableView(_:didSelectRowAt:)`メソッドでやります。

## セル選択を拒否する
セルをタップしたさいにハイライト状態のち選択状態になります。  
選択状態とは次の状態です。

{% page_image -2.png %}

この選択状態を拒否するメソッドがあります。それが`func tableView(_:shouldHighlightRowAt:) -> Bool`になります。

このメソッドの戻り値で`false`を返すと、返されたセルはタップしても何も起こらなくなります。


次の動画は一番上のセル以外はタップ禁止にしたさいの動きになります。
動画では選択状態にもハイライトにもなっていません。  
またログも一番上のセル以外は拾わなくなりました。

<video autoplay loop muted playsinline src="/assets/videos/2019-09-30-ios-uitableview-uitableviewcell-cell-selection-1.mp4" width="100%" height="400px"></video>

```
tableView(_:willSelectRowAt:)0
tableView(_:didSelectRowAt:)0
```

コードは前述した選択／解除の前後コールバックに次のコードを追記したものです。

```swift
func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return indexPath.row == 0
}
```

セル自体のタップ禁止にするだけで、セル自体がボタンを持ってる場合などは通常通り反応します。  
その場合の実装方法や注意点に関してはこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-input-control %}

## セルの選択はUITableViewの重要機能の一つ

セルを表示するだけの画面はほぼなく、必ずといっていいほどセルの選択は必要になります。

全部のセル選択コールバックの覚える必要はなくともセルの選択により処理をするケースだけでも覚えといて損はないです。

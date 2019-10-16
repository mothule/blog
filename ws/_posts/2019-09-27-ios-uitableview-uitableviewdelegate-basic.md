---
title: 【初心者向け】UITableViewDelegateで出来ること
categories: ios uitableview
tags: ios uitableview uitableviewdelegate
image:
  path: /assets/images/2019-09-27-ios-uitableview-uitableviewdelegate-basic.png
---
`UITableViewDelegate`とは`UITableView`の操作イベントをハンドリングするプロトコルです。
単純なセルのタップイベントをはじめ、
今回はタップのみですが、それ以外にも様々なイベントフックや制御ができます。

この記事では `UITableViewDelegate`には何が用意されているのか？  
このprotocolを使ってどのようなことが出来るのか？についてとっかかりを掴むページを想定してます。

実際の詳細に関しては記事内の随所に詳細ページへの紹介をしているので、気になるページがあれば閲覧してください。


## 表示と非表示のイベント

セルやセクションの表示の直前直後を検知できます。

利用ケースはそこまで高くはありませんが、例えばユーザーの視界に入ったセル数を集計したいときなどにイベントマーキングなどが考えられます。

- セル表示直前: `func tableView(_:willDisplay:forRowAt:)`
- セクションヘッダー表示直前: `func tableView(_:willDisplayHeaderView:forSection:)`
- セクションフッター表示直前: `func tableView(_:willDisplayFooterView:forSection:)`
- セル非表示直後: `func tableView(_:didEndDisplaying:forRowAt:)`
- セクションヘッダー非表示直後: `func tableView(_:didEndDisplayingHeaderView:forSection:)`
- セクションフッター非表示直後: `func tableView(_:didEndDisplayingFooterView:forSection:)`

## セルやセクションの高さ制御

- セルの高さを返す: `func tableView(_:heightForRowAt:) -> CGFloat`
- セクションヘッダーの高さを返す: `func tableView(_:heightForHeaderInSection:) -> CGFloat`
- セクションフッターの高さを返す: `func tableView(_:heightForFooterInSection:) -> CGFloat`
- セルの推定高さを返す: `func tableView(_:estimatedHeightForRowAt:) -> CGFloat`
- セクションヘッダーの推定高さを返す: `func tableView(_:estimatedHeightForHeaderInSection:) -> CGFloat`
- セクションフッターの推定高さを返す: `func tableView(_:estimatedHeightForFooterInSection:) -> CGFloat`


セルやセクションヘッダー、セクションフッターの高さを調整するためのイベントになります。  
このイベントを使うことで、個別に高さ制御が可能になります。

### estimated は推定値
なお `estimated` とつくメソッドは推測値を返すイベントです。  
この値をなるべくなるであろう高さに返しておくことで、セル高さ調整差が狭まり表示完了までの速度が早まります。  
デフォルトは `automaticDimension` であり、これは自動で高さを推定します。  
`0`にすると推定が無効となり、セル毎の実際の高さを要求されます。  
Xcode9以降は`Self-Sizing`がデフォルトとなるため、`0`にすると正常に動きません。

### セル高さ可変制御する
なおセルの高さをAuto-Layoutによる算出で可変にする方法はこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-uitableviewcell-height-customize %}

### 一律制御もある

なお、これとは反対に全体で一律制御は次のプロパティでできます。

- `UITableView.rowHeight`
- `UITableView.estimatedRowHeight`
- `UITableView.sectionFooterHeight`
- `UITableView.estimatedSectionFooterHeight`
- `UITableView.sectionHeaderHeight`
- `UITableView.estimatedSectionFooterHeight`

## セクションヘッダーとセクションフッターのカスタマイズ

セクションヘッダーとフッターのカスタマイズに関するイベントメソッドです。

- `func tableView(_:viewForHeaderInSection:) -> UIView?`
- `func tableView(_:viewForFooterInSection:) -> UIView?`

カスタマイズする方法についてはこちらの記事をどうぞ。

{% post_link 2019-09-29-ios-uitableview-section-header-customize %}

## アクセサリーボタンのタップ検知

- `func tableView(_:accessoryButtonTappedForRowWith:)`

セル毎のアクセサリーボタンがタップされたときに呼ばれます。  
ボタンタップしたらハンドリングする処理などで使います。

アクセサリに関してはこちらの記事をどうぞ。

{% post_link 2019-09-30-ios-uitableview-uitableviewcell-accessory %}

## セルの選択イベント

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

詳細はこちらの記事をどうぞ。

{% post_link 2019-09-30-ios-uitableview-uitableviewcell-cell-selection %}

## 編集制御

セルを右や左にスワイプすることで横からアクションメニューを表示したり、ソートや削除するさいに使います。
メソッド一覧は量が多いので省きます。

実際にどういったことが出来るのか詳細はこちらの記事をどうぞ。

{% post_link 2019-09-30-ios-uitableview-uitableviewcell-edit-mode %}

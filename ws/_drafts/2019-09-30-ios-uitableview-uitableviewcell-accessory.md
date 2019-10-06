---
title: 【初心者向け】UITableViewCellのAccessory(アクセサリ)の使い方
categories: ios uitableview
tags: ios uitableview uitableviewcell
image:
  path: /assets/images/2019-09-30-ios-uitableview-uitableviewcell-accessory.png
---
UITableViewCellには予めAccessory(アクセサリ)が用意されており、全部で4種類あります。

種類の説明と実装方法について説明します。

使い方も簡単で利用用途も比較的高いので覚えておいて損はありません。

## Accessory(アクセサリ)を表示

`UITableViewCell.accessoryType` を設定すると表示されます。

## Accessory(アクセサリ)一覧

- AccessoryType.checkmark
- AccessoryType.detailButton
- AccessoryType.detailDisclosureButton
- AccessoryType.disclosureIndicator

{% page_image -1.png %}

## Accessory(アクセサリ)のタップを検知

アクセサリビューをタップするとイベントを検知することができます。  
またイベントを検知できるアクセサリは決まっていて次の２つになります。

- .detailButton
- .detailDisclosureButton

アクセサリの検知は `UITableViewDelegate` の `func tableView(_:accessoryButtonTappedForRowWith:)` で検知できます。

## Accessory(アクセサリ)のカスタマイズ

デフォルトで用意されたアクセサリではなく、独自にカスタマイズしたい場合は、  
`UITableViewCell.accessoryView` にビューを設定すると表示されます。

`AccessoryView`を使うと `func tableView(_:accessoryButtonTappedForRowWith:)`と`UITableViewCell.accessoryType`は無効になります。

## checkmarkとdisclosureIndicatorは非常によく使う

この２つのアクセサリは用途が明確でデザインに溶け込みやすいためデフォルトのままで使われる頻度も高いです。

特に`disclosureIndicator`に関してはデザイナーのチェビロンを使わずこれを使ってても気づかれなかったりします。

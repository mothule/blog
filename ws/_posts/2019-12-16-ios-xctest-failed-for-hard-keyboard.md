---
title: secureTextFieldsのNeither element nor any descendant has keyboard focusを対処する
categories: ios test
tags: ios test xcuitest
image:
  path: /assets/images/2019-12-16-ios-xctest-failed-for-hard-keyboard/0.png
---
1つのPCで複数のプロジェクトをいじることはよくあるありますよね。  
業務で複数プロジェクトだったり、ちょっとした調査プロジェクトだったり、プロジェクト自体は独立して他プロジェクトと疎結合であっても、開発環境はそうでない場合があります。

今回はXcodeのSimulatorがそれで、その影響で「何もコード弄ってないのに失敗する」って現象が起きたのでそれの対処方について簡単にまとめました。

## 何が起きているのか？

ローカル上にてXcodeのSimulator上でXCUITestを実行したところ、パスワード入力(secureTextFields)のタイピング(typeText)が反応せず失敗する。

## エラーメッセージ

抜粋ですが、残り部分はプロジェクト固有情報でノイズとなるため除去して最小限にしてあります。

```
Failed to synthesize event: Neither element nor any descendant has keyboard focus. Event dispatch snapshot: SecureTextField, identifier: 'password_textfield', placeholderValue: '半角英数8文字以上20文字以内', value: 半角英数8文字以上20文字以内
Element debug description:
Attributes: SecureTextField, { {151.0, 284.0}, {254.0, 40.0} }, identifier: 'password_textfield', placeholderValue: '半角英数8文字以上20文字以内'
```

## メッセージを読み解く

```
Neither element nor any descendant has keyboard focus.
```
Google翻訳にて「`要素も子孫もキーボードフォーカスを持ちません。`」と言われてるこれがエラーメッセージです。

コードでは下記のように一度タップしてフォーカスしたのち、キータイプを行っていますがあることが原因でフォーカスされていないようです。

```swift
app.secureTextFields["password_textfield"].tap()
app.secureTextFields["password_textfield"].typeText(password)
```

フォーカスされていないとは、つまりキーボードが出ていないことを意味します。  
本来ならフォーカスされればそれに対する入力としてキーボードが出現します。

何らかの原因でキーボードがでなくなっているようです。


また普段は成功しているし、CIでも問題なく動いています。しかしローカルでは失敗してしまいます。  
つまり自分のPCに原因があることが推測できます。

## 原因はConnect Hardware Keyboard

シミュレーターではある設定が有効だと、secureTextFields.typeTextが失敗する不具合があります。  
ここで不具合と言い切っているのは、通常のtextField.typeTextでは失敗しないためです。

キーボードが出てこなくなる設定、それは **Connect Hardware Keyboard** です。

{% page_image 1.png %}

これが有効だとキーボードウィンドウが表示されず、ハードキーボード（つまりmacなどのキー)を押すとシミュレーターのフォーカス中のテキストフィールドに入力されます。

どうやらこれがsecureTextFieldsだとフォーカスしていないと判断され失敗していたようでした。

## 追記：Connect Hardware KeyboardがOFFでも失敗する場合

シミュレーターのConnect Hardware KeyboardはOFFになっているが失敗するケースがあります。  
その場合は一度Connect Hardware KeyboardをONにしてからすぐにOFFにしてもう一度テストを試してみてください。

ショートカットは shift+cmd+k なので２回押せばOFF→ON→OFFとすぐできます。

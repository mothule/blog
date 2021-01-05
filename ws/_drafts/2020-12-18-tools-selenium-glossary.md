---
title: Webアプリの自動テストのcapybaraやSeleniumなど用語を整理した
description: capybara,WebKit,Selenium,WebDriver,selenium_chrome,ChromeDriver,capybara-webkitなど似たような用語が多く、しかも関係性が分からないので一つずつ整理しました。
categories: tools selenium
tags: tools selenium, capybara, webkit, web_driver, chrome_driver
---
Webアプリ画面のE2Eテスト（システムテスト）の自動化は、エンジニアの快眠に必要です。

ざっくりとした理解のまま使ってました。
しかし、改めてWebアプリで自動テストを再設計することになり、
他の人に説明できない状態だったので用語と関係性について整理しました。

## capybaraとは
gemの1つ。
rackベースのWebアプリ用統合テストツール。
Webサイト上のユーザー操作をシミュレートする。
https://rubygems.org/gems/capybara

## WebKitとは
HTMLレンダリングエンジンの1つ
Safariのレンダリングエンジンとして使われている
https://ja.wikipedia.org/wiki/WebKit

## Seleniumとは
Webアプリを自動テストするためのフレームワークまたはプロジェクト。
Selenium WebDriver, Selenium Grid, Selenium IDEなど複数ツールがある。

## WebDriverとは
Seleniumコンポーネントの1つ。
ブラウザ操作用のAPI群とプロトコル。
各ブラウザは特定のWebDriverの実装を持っている。（Driverと呼ぶ）
例えばChromeを使うなら、Chrome用WebDriver（ChromeDriver）となる。
DriverはSeleniumとブラウザ間の通信を処理する。
この事から、WebDriverが抽象クラスで、具象クラスは各ブラウザ毎のDriverという関係が言える。

## ChromeDriverとは
Chrome用WebDriverのツール名。
ChromeDriverはPC向けChromeとAndroid向けChromeで利用できます。
OSもMac, Linux, Windows, ChromeOSに対応してます。

## selenium_chromeとは
Capybaraのドライバー指定で、Chrome用WebDriver(ChromeDriver)を指定する文字列
下記コードのように使われる。

```ruby
Capybara.configure do |capybara_config|
  capybara_config.default_driver = :selenium_chrome
  capybara_config.default_max_wait_time = 10
end
```

## capybara-webkitとは
gemの1つ。
CapybaraのためのヘッドレスWebKit用WebDriverです。
https://github.com/thoughtbot/capybara-webkit
現在はQtWebKitが非推奨となってことで、アーカイブ状態となってます。
公式では、代わりにSeleniumかApparitionという別のドライバーを推薦してます。

## Safari用のWebDriverは？
あるようです。ただし、ヘッドレスモードはないようです。
https://stackoverflow.com/questions/58314263/how-to-set-ua-and-headless-for-selenium-of-safari/58314435#58314435

またiOS13からiOS版Safariでもできるようです。
https://www.publickey1.jp/blog/19/ios_13safariwebdriverseleniumui.html

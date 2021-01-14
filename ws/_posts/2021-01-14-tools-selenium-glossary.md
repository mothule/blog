---
title: Webアプリの自動テストのcapybaraやSeleniumなど用語を整理した
description: capybara,WebKit,Selenium,WebDriver,selenium_chrome,ChromeDriver,capybara-webkitなど似たような用語が多く、しかも関係性が分からないので一つずつ整理しました。
categories: tools selenium
tags: tools selenium capybara webkit web_driver chrome_driver
image:
  path: /assets/images/2021-01-14-tools-selenium-glossary/eyecatch.png
---
SeleniumやWebDriverは、Webアプリのシステムテストの自動化に関する用語です。  
これら用語は名前が似てたり関係性が曖昧で、ネット記事を見てもいまいちに腹落ちしません。  
それゆえ、これらの用語の意味や関係性を整理しました。

## 整理した用語一覧
今回整理した用語はSeleniumを使う上で、混乱の中心となる用語に絞ります。  
選定基準は、私が調べながら分かりにくいと感じた用語です。

- capybara
- WebKit
- Selenium
- WebDriver
- ChromeDriver
- Chrome用WebDriver
- selenium_chrome
- capybara-webkit

## capybaraとはライブラリ名
capybaraはRubyのライブラリ(gem)の1つで、RackベースのWebアプリ用統合テストツールです。  
Webサイト上のユーザー操作をシミュレートします。
[capybara](https://rubygems.org/gems/capybara)

## WebKitとはレンダリングエンジン
WebKitはHTMLレンダリングエンジンの1つで、Safariのレンダリングエンジンとして使われてます。

> WebKitは、元々アップルのmacOSに搭載されるSafariのレンダリングエンジンとして、LinuxやBSDといった、Unix系用のレンダリングエンジンであるKHTMLをフォークして開発された。現在はその他の多くのプラットフォームに移植されている。Wikipediaより抜粋

## Seleniumとはテストプロジェクト
SeleniumはWebアプリを自動テストするためのフレームワークまたはプロジェクトです。
「フレームワークまたはプロジェクト」と曖昧なのは、Seleniumの歴史によって用語の意味が変わってるためです。

現在であれば、プロジェクトです。
> Selenium is an umbrella project encapsulating a variety of tools and libraries enabling web browser automation.

SeleniumはWebブラウザの自動化に関する様々なツールやライブラリで構成されたプロジェクトです。  
Selenium WebDriver, Selenium Grid, Selenium IDEなど複数ツールがある。

## WebDriverとはコンポーネント
WebDriverはSeleniumコンポーネントの1つで、ブラウザ操作用のAPI群とプロトコルです。  
このプロトコルをブラウザで準拠させたものをDriverと呼ばれ、Seleniumとブラウザ間の通信を仲介します。  
つまり、実行ブラウザ(Driver)が変わっても操作は変えずに実行できます。

各ブラウザは特定のWebDriverの実装を持ってます。  
例えば、ChromeならChrome用WebDriver（ChromeDriver）がそれにあたります。

## ChromeDriverとはWebDriverの1つ
ChromeDirverはWebDriverをChrome用に実装したDriverであり、ツール名です。

ChromeDriverはPC向けChromeとAndroid向けChromeで利用できます。  
OSもMac, Linux, Windows, ChromeOSに対応してます。

## selenium_chromeとは識別用の文字列
Capybaraのドライバー指定で、Chrome用WebDriver(ChromeDriver)を指定する文字列です。
下記コードのように使います。

```ruby
Capybara.configure do |capybara_config|
  capybara_config.default_driver = :selenium_chrome
  capybara_config.default_max_wait_time = 10
end
```

## capybara-webkitとはライブラリ名
capybara-webkitはRubyのライブラリ(gem)の1つで、CapybaraのためのヘッドレスWebKit用WebDriverです。
[capybara-webkit](https://github.com/thoughtbot/capybara-webkit)

現在はQtWebKitが非推奨となってことで、アーカイブ状態となってます。  
公式では、代わりにSeleniumかApparitionという別のドライバーを推薦してます。

## Safari用のWebDriverは？
あるようですが、ヘッドレスモードはないようです。[GitHub/selenium](https://github.com/SeleniumHQ/selenium/issues/5985)

またiOS13からiOS版Safariでも、WebDriverを正式サポートされました。[URL](https://www.publickey1.jp/blog/19/ios_13safariwebdriverseleniumui.html)

## 最も重要な用語の関係性を表す
Seleniumを知る上で重要な用語が、SeleniumとWebDriverそして、ChromeDriverです。  
これらの関係性を文章にすると、  
**「SeleniumプロジェクトのWebDriverコンポーネントのプロトコルを採用したChromeウェブブラウザ用WebDriverは、ChromeDriverです」**

ツリー構造だと次の構造になります。
- Selenium
  - WebDriver
    - ChromeDriver(=Chrome用WebDriver)

---
title: Google Analyticsで自分のサイトを分析して分かったこと
categories: tools google-analytics
tags: tools google-analytics
image:
  path: /assets/images/2020-02-01-tools-google-analytics-my-site/0.png
---
Google Analytics(以下GA)を使ってサイト分析は一般的なサイト運営です。

普段アクセス数やアクセス数の多いページ一覧しか見てなかったのですが、  
今回ちょっと分析結果から仮説を立てるまでをまとめてみました。

GAを使った分析がいまいち分からない人向け。

## まずはグラフを見る

### DAUのチャート

{% page_image dau.png 50% %}

#### 変化を見る
チャートでは変化を見ましょう。
大きく変化してる部分や、全体としてのなだらかの変化率を見るの2つの観点で見てみましょう。

ちなみにこの図だと、
ガクンと落ちてる部分は全て **「土日」** です。

技術ブログなので、土日はみんな技術系の調べ物はせず、リフレッシュしてるのでしょうか。

### トラフィック

どうやってこのサイトに到達したのかが分かります。

{% page_image trafic.png %}

#### 流入元を調べる
どこからやってきたのかここで調べましょう。
SNSであればTwitterやFacebook、他サイトとしてQiitaなどの流入もあります。

このサイトは、ほぼ全部オーガニックつまりGoogle検索で辿り着いてます。

### 時間帯別ユーザーアクセス

ユーザーがこのサイトにアクセスしてくる時間帯が分かります。

{% page_image users-each-times.png 50% %}

#### 変化を見る
集合といった塊や変化してる部分を見ましょう。

ちなみにこの図だと、
平日9時から20時に主なアクセス時間帯のようです。

つまり社会人であれば業務中ですね。  
前述したDAUも考慮すると **業務中でしか使われていないサイト** のようです。

### アクセスランキングと直帰率と離脱率

2ヶ月間のアクセスランキングとそれらの直帰率と離脱率です。

{% page_image access-page-rank-bounce-rate.png %}

#### 記事の属性や数字を見る

- 初心者向け記事が目立ちます。
- 直帰率が非常に高いです。
- 離脱率も一部非常に高いです。
- ページ滞在時間が長いので欲しい情報に到達してると思って良さそう。

#### ここにはない情報がある

それは記事の構成と記事比率です。
「初心者向け」と「iOS」の記事が多く、それら記事内で構造化されていれば、SEO評価が上がります。

例えばCarthageに関する記事は1つしかないので、直帰率や離脱率が高いのでしょう。  
違う目線で見れば、これ1つでユーザーにとって有能な記事とも見れます。

#### 用語の意味

直帰率とは1セッションにおいてそのページ以外にアクセスせず離脱すること。  
離脱率とはそのページを最後にセッションを終了すること。  
セッション終了とは簡単な話ブラウザを閉じること。  

厳密には最後のアクセスから30分以上経過などあります。これはGAの定義の話なので他分析ツールでは異なってきます。  
GAについては[アナリティクスでのウェブ セッションの算出方法](https://support.google.com/analytics/answer/2731565?hl=ja)をどうぞ。


## 仮説を立てる

掲載したチャートや表、感想から考えて、
「ユーザーは業務中の初学者か？」と仮説が立ちます。  
おおむね「業務中で分からないことをググって解決して、分かったら閉じる。」がユーザーシナリオが想像できます。  
直帰率が高いのがそれを後押ししてます。
また次のリテンションも後押ししてます。

{% page_image retension.png 50% %}

## 仮説から課題を立てる

仮説が立ったら今度は課題です。仮説を事実だと捉えて考えてみます.

- このサイトは回遊率が低いです。 もっといろんな記事を見て直帰率とセッション時間をあげたいですね。
- 意図通りか別として、ユーザーの技術力が低いです。初学者以外にもアクセスされて欲しいですね。
- 業務中でしか使われていません。もっとプライベートな時間帯にもアクセスが欲しいですね。

## 課題に対する分析や対策を考える

課題が見えたら今度はそれらのいろんな角度から見たり、見えてきた原因の解決策を考えてみます。

### 直帰率が高いのはそれ以外に欲しい情報がない
ユーザーシナリオから鑑みて、直帰率が高すぎるのは、欲しい情報が手に入ったことで、ユーザーニーズが終了してるのも事実です。  
しかしユーザーは無意識でも「刺さる情報を提供できていない」とも言えます。

### 刺さる情報とはユーザー属性から出す
ユーザーが初学者であれば、初学者に刺さるような情報があればいいわけです。  
またiOS記事であれば、他の刺さるようなiOS記事があるといいかもしれません。
プライベートな時間帯を狙うなら、技術NEWS系の記事もあるとアンテナはってる人たちに見てもらえる可能性があります。

### 初学者以外のユーザー属性に刺さる記事がない
事実として初学者以外に向けた記事数は少ないですし、それらを構造化もあまり出来ていません。  
初学者以外を狙うとなると、大掛かりな行動となりそうです。

## アクションを立てる

対策から具体的な行動に移せる粒度に落とし込みます。

- ページ内の関連記事の精度を上げる
- 技術NEWSの考察した記事を蓄積する

## アクションを判断する

関連記事の精度を上げることで、閲覧中記事と同じ属性を持つ記事をユーザーに提供すれば、  
ユーザーは同様に興味を持つかも知れないですね。

技術NEWSの考察は、サイト方針とは異なる情報となるため、今回は却下となります。


## 分析してみて
優先順位の判断材料となります。

やることはたくさんある中で少ない時間の中で、何を選択し集中することでコスパよく効果を出さないといけません。
そんな状況下では、優先順位付けに悩みます。

これを繰り返すことでOODAをループさせます。
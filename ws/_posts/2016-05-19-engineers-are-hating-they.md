---
title: エンジニアは矛盾した行動でユーザーや自分を裏切る企画や営業に辟易しやすい。
description: エンジニアの心を折るのは容易いエンジニアって職業柄、仕様を曖昧にすることができず、全容を知る必要があります。そのためユーザーファーストとか謳っておきながら、己の目先の実績しか見えていない愚かな企画者に気づくことが多いです。上司の承認を得るような実現不可能な完璧なビジネスロジックをでっち上げ、細かい所は詰めもせず開発をスタートさせ、詰めの甘さや無知の領域のスケジュール感より遅いと、効率を上げろと迫り「一時的に」「次リリースまで」といいながらそのままにして別の案件に移り、永続的にユーザーを裏切る仕様にさせうまくことが回らないと、まず手を動かす人間でかつ成果の見えにくい、理解できないエンジニアを疑い、最後はチームもユーザーも嘘を付くそんなやつが、エンジニアって生き物はそういう奴は死ぬほど嫌いで、かつ敏感です。
date: 2016-05-19
categories: notebook
tags: notebook
draft: true
---

エンジニアって職業柄、仕様を曖昧にすることができず、全容を知る必要があります。
そのためユーザーファーストとか謳っておきながら、己の目先の実績しか見えていない愚かな企画者に気づくことが多いです。

- 上司の承認を得るような実現不可能な完璧なビジネスロジックをでっち上げ、
- 細かい所は詰めもせず開発をスタートさせ、
- 詰めの甘さや無知の領域のスケジュール感より遅いと、効率を上げろと迫り
- 「一時的に」「次リリースまで」といいながらそのままにして別の案件に移り、永続的にユーザーを裏切る仕様にさせ
- うまくことが回らないと、まず手を動かす人間でかつ成果の見えにくい、理解できないエンジニアを疑い、
- 最後はチームもユーザーも嘘を付く

そんなやつが、エンジニアって生き物はそういう奴は死ぬほど嫌いで、かつ敏感です。

## お金優先指向に待ち構えるリスク
現在都内の自社発Webサービスの会社にエンジニアとして勤めています。
最近「なんだかなぁ…」と思うことがあります。

半分が愚痴になってしまっていますが、自分の考えを少し書いてみました。
常にこの考えが正であるとは思ってはいないです。


## 金かねカネ
配属している部署でも、

* 「予算を削れないか？」
* 「もうちょっと納期を短くできないか？」
* 「品質はそこまで重要視する必要はあるのか？」

と対して理解できていなくてもとりあえず出しとけという軽さで、出てきます。

おそらくどこの会社にでもある身近な話題だと思います。
昔から言われていることなのですが、ここ最近それが表に出る傾向が強くなり、
新人から中堅手前のレイヤーにまで侵食してしまい、偏った考えをもって成長してしまった人材ができている状況です。

## 削る代償
見積もられた開発工数から何かを削るとなると、必要だと判断した作業を削ることになるため、必ずそれに対するリスクが発生します。
残業でカバーしても健康悪化や社員のモチベーション低下による社員定着率低下に繋がります。
そもそも重要な案件でもない限り、スケジュール見積もりの段階で残業な考慮されるのは、
ナンセンスでマネジメント陣営が管理できませんと宣言しているようなものです。

## 最小労働で最大成果
美学とされる安く・早く・質良くは、どの業界でも通じるものだと思います。

しかし何でもかんでも自分のモノサシで数字優先に走ると、
エンジニア業界では、「改修拡張コスト増大」「メンテナンス性ゼロ」といった技術負債が待ち構えています。

## アジャイルだから
アジャイル開発を誤解した企画やマネジメント層がいると、とても素晴らしい開発スタイルだと勘違いしてしまいます。

スパンを短くリリース頻度を上げ、重要な機能のみをどんどんリリースする。
ウォーターフォールと違い最初から全部詰めずに、必要になったところのみを用意・決定し、
スプリント毎に上がる成果物をレビューし、フットワークの軽い改修ができる。

そんなさわりのいい言葉部分のみを理解した夢物語を支える技術・プロセスを「必要なの？」と訪ねてくるたびに、毎回説明に疲れます。

## 分かんないけど
言葉はじめにジャブとして使います。
状況を理解しようとせず数字だけ見る人がよく使ってます。
とにかく他の数字と比べて大きい、なんとなくあまり見慣れない数字を見つけると、
なんとかしようとして「なんとかできない？」といったニュアンスを秘めて聞いてきます。


*それが自分で撒いた種にもかかわらず*


## 安く、早く、でもバグは出さない
最低限の実装、自動化ではなく人力テスト、技術負債は知らん顔
プロダクト優先でやった結果、数カ月後に負債の塊を片付けないと話が進まない状況を作り上げ、
しまいには、それをした本人が「その（負債片付け）作業は本当に今必要なものなのか？」と聞いてくる。

## プロジェクト品質を健康に
健康でないプロジェクトに、アジャイルのメリットは得られません。
むしろ開発速度は遅くなり、品質は悪化、使いにくい最低限の機能と負債だけが蓄積されます。

### 健康とは
プロセス・文化にカイゼンが組み込まれ、継続的にカイゼンできる「環境」が常に整っていることです。
ドキュメントが箇条書きで誤字脱字、置き場所が異なるは仕方ないです。
しかし、「優先度が低いから」それを放置する選択をし続けると、人依存になり、いなくなり、誰も知らないプロジェクトだけが残ります。
開発も同様に蓄積すると、「なぜ」の答えは残らず、担当者が「なぜ？」と頭をかしげることになります。

### 開発はレールにのっていれば強い

アーキテクチャ、API、SDK、エンジン、フレームワークと呼ばれるもののほとんどが、
課題に対して「普通に考えるなら実現／実装はこうだよね」という思考のもと作られています。
そのエンジニアにとって一般的な考えから外れない限り、開発速度は低下しません。

しかし負債が蓄積されるとそのレールから外れやすくなり、提供されている条件にマッチせず、結局自作することになり
一般的には考えられない組み合わせをすることになり、問題が起きても検索してもヒットせず、開発は最悪止まります。

## 転ばない杖より、起き上がる足腰
開発に負債、バグ、不備はスケジュールや予算や障害対応といった外部要因の都合上どうしても避けられません。
最小限に抑える努力、対策は必要です。
しかしそれと同様にプロジェクトが抱えている問題を解決する仕組みを案件といった粒度だけでなく
開発サイクルにも組み込むことが大事です。

## 聞かれるけど、聞いたら答えられない
開発者は企画者よりも機能を本当に必要最低限にできます。
それは作ってる作業を削っていけばいいし、要求分析、要件定義の際に実現したいことが分かれば、
満たしていればいいだけのシンプルな実現方法を提案できます。

しかしそれを提案しても企画者は納得せず、そこまではやらないといいます。
「削れ削れ」と言ってる割に、限界まで削ったらひきます。

結局企画者もやりたいことを言葉として文章化することができず、
開発側も伝わらないためニュアンスや空気を読むことしかできず、認識が噛み合わず谷が深まるばかりです。

アジャイルであればチーム内にて対話ベースにより共通認識を構築していくことで、何を目指しているのか見えてきます。
しかしマネジメント層はチーム外で、対話よりも数値、背景よりも数値な状態なので平行線です。

## QCDも大事、だけどそれを支える作業も大事
いつもなら「なんだかなぁ」と思う部分はあっても、お互い様なところもあるので気にしないようにしているのですが。
アジャイル開発なのに案件とチーム、そしてチーム構成をころっころっ変えて成熟度なにそれ？状態でして。。

利益優先しすぎた結果、運用費増加や利益低下になってしまい、
根本解決に走ると思いきや、さらに利益優先な決断をしていると流石に滑稽に思えます。

製品の開発には、ある程度の規模になると規模に適した計画が必要になり、計画を短くするためには熟練者が必要になります。
目の前のことしか決まっていない状態で走り出すと、プロジェクトは失敗します。
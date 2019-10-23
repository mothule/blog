---
title: Firebase Performance Monitoringの基本と概念と実装について整理した
categories: ios firebase
tags: ios firebase performance-monitoring
image:
  path: /assets/images/2019-10-23-firebase-performance-monitoring-basic/0.png
---

アプリを使用するユーザーの利用環境を明確に把握したニーズが強くなったので、前々から気になっていたFirebase Performance Monitoringについて調べることにしました。  
なお本記事はiOSを重点に調査しています。


## Firebase Performance Monitoringとは？

iOS,Android,Webアプリのパフォーマンス特性を知ることが出来ます。  
SDKをアプリに統合するだけで、プロファイルコード不要で各パフォーマンスデータを収集し、Firebaseコンソールから分析できます。

これによりアプリのパフォーマンス問題を解決できます。

なお Performance Monitoringが自動収集するデータには名前、メアド、電話番号などの個人情報は一切収集しません。  
またカスタム属性で個人を特定できる情報は使用しないでください。

[公式](https://firebase.google.com/docs/perf-mon?hl=ja)

## 主な機能

おもに３つの機能があります。

### パフォーマンスデータとして次の項目を自動収集

- アプリ起動時間
- HTTP/Sネットワーク上のリクエスト
- 画面ごとのレンダリングデータ
- フォアグラウンドでのアクティビティ
- バックグラウンドでのアクティビティ

### パフォーマンス課題を見つけやすくする

パフォーマンス指標として次の項目を確認できます。

- 国
- デバイス
- アプリのバージョン
- OS

### アプリ毎にPerformance Monitoringをカスタマイズ

自作や新しい画面やUIの表示などのパパフォーマンストレーサーを作成できます。  
またカスタム指標を用意し、トレース時に定義したイベント(キャッシュヒットなど)をカウントできます。

例えばアプリ独自にインメモリのキャッシュ機構を構築してる場合のキャッシュヒット率を収集することができます。

#### トレースとは？

トレースとは2つの時点の間で取得されたパフォーマンスデータのレポートです。

## Performance Monitoringの仕組み

大きくレポートタイミングとして、トレースと通信キャプチャに分かれており、その配下に指標があります。

## トレースには2種類ある

トレースには自動トレースとカスタムトレースの2種類のトレースがあります。

### 自動トレース

iOSやAndroidアプリで自動で組み込まれるデフォルトトレースです。

- アプリ起動トレース
  - ユーザーがアプリを起動してから、アプリが応答するまでの時間を測定
  - コンソールでは `_app_start` 報告指標は`期間`
  - 開始タイミングは、アプリが最初のObjectをロードすると開始します
  - 終了タイミングは、 `UIApplicationDidBecomeActiveNotification`通知受信後の最初の正常な実行ループ後に停止します。
- フォアグラウンドアプリのトレース
  - アプリがフォアグラウンドで実行されていてユーザーが利用できる時間を測定
  - コンソールでは `_app_in_foreground` 報告指標は`期間`
  - 開始タイミングは、`UIApplicationDidBecomeActiveNotification`を受け取ると開始
  - 終了タイミングは、`UIApplicationWillResignActiveNotification`を受け取ると停止
- バックグラウンドアプリのトレース
  - アプリがバックグラウンドで実行されている時間を測定
  - コンソールでは `_app_in_background` 報告指標は`期間`
  - 開始タイミングは、アプリが`UIApplicationWillResignActiveNotification`を受け取ると開始
  - 終了タイミングは、`UIApplicationDidBecomeActiveNotification`を受け取ると停止
- 画面トレース
  - 画面の存続期間を通じて低速なフレームとフリーズしたフレームを測定
  - 指標はレンダリングが遅いフレームとフリーズしたフレームのみ報告されます。
  - コンソールでは他トレースとは別テーブルに表示されます。
  - 開始タイミングは、 `viewDidAppear:`を呼び出すと `keyWindow`内のすべての`UIViewController`について開始
  - 終了タイミングは、`viewDidDisappear:`を呼び出すと停止
  - 正規のコンテナビューコントローラはキャプチャされません。(UINavigationViewControllerなど)



### 自動トレース情報

Firebase Performance Monitoringでは次の種類の情報がデフォルトで収集します。[URL](https://support.google.com/firebase/answer/6318039?hl=ja)

- 機種、OS、画面の向きなどの全般的な端末情報
- RAM とディスクのサイズ
- CPU 使用率
- 携帯通信会社（モバイルの国コードとネットワーク コードに基づく）
- 無線通信 / ネットワークの情報（例: Wi-Fi、LTE、3G）
- 国（IP アドレスに基づく）
- ロケール / 言語
- 電波強度
- デバイスのジェイルブレイクまたはルート権限取得
- 電池残量と充電状態
- アプリのバージョン
- アプリの状態（フォアグラウンドまたはバックグラウンド）
- アプリのパッケージ名
- 仮名のアプリ インスタンス識別子
- ネットワークの URL（URL パラメータやペイロードのコンテンツを含まない）と以下の対応する情報:
  - 応答コード（例: 403、200）
  - ペイロードのサイズ（バイト単位）
  - 応答時間
- 自動トレースの継続時間

### カスタムトレース

ユーザー独自のトレースです。SDKに用意されたAPIを使ってカスタムトレースの開始と終了を定義することできます。

またカスタムトレースを詳細に構成することで、該当する範囲内で発生したパフォーマンス関連イベントのカスタム指標の記録もできます。

これは前述したメモリキャッシュ機構でいう、キャッシュヒット数とミス数といった指標や、  
UIが一定期間反応しなかった回数などカスタム指標を作成できます。

## HTTP/Sネットワークリクエスト
アプリがリクエストを発行してレスポンスが返ってくるまでの時間をキャプチャするレポートです。  
次の指標を収集します。

- 応答時間
  - リクエスト発行からレスポンスの完全受信までの時間
- ペイロードサイズ
  - ダウンロード／アップロードされたネットワークペイロードのバイトサイズ
- 成功率
  - 全レスポンスに対する成功レスポンスの割合. これは通信障害やサーバー障害を測定することを目的としてる

## 属性

パフォーマンスデータはトレースとHTTP/Sネットワークリクエストの両レポートで次のように分類されています。(以下はiOS/Android)

- トレース
  - アプリバージョン
  - 国
  - OS レベル
  - デバイス
  - 無線通信
  - 携帯通信会社
- HTTP/Sネットワークリクエスト
  - アプリバージョン
  - 国
  - OS レベル
  - デバイス
  - 無線通信
  - 携帯通信会社
  - MIMEタイプ

またカスタム属性を設定することもできます。

これらは、コンソール上でパフォーマンスデータを属性でフィルタリング（セグメント化）することで、さまざまなシナリオにフォーカスした指標を得ることが出来ます。

## 組み込んでみる

1. Performance Monitoringをアプリに追加
1. Firebaseコンソールで結果を確認する

この2工程です。 なお Firebaseの追加自体はこちらの[公式サイト](https://firebase.google.com/docs/ios/setup?hl=ja)を参照してください。


### Performance Monitoringをアプリに追加

*Podfile*
```ruby
pod 'Firebase/Analytics'
pod 'Firebase/Performance'
```

後は `$ pod install` するだけです。

`UIApplicationDelegate`の`application:didFinishLaunchingWithOptions:`に `FirebaseApp.configure()` を追加する必要がありますが、  
すでにFirebaseを使っている場合はこのコードは既に組み込まれているかと思います。

これで `自動トレース` と `HTTP/Sネットワークリクエスト`を監視するようになります。

※ なお `Firebase/Performance` を追加すると依存関係として `Remote Config` が組み込まれます。

もし pod install で UUID重複警告が出た場合は、Firebase関連podを最新にupdateすることで回避できました。

### Firebaseコンソールで結果を確認する

[Firebase コンソール](https://console.firebase.google.com/?hl=ja) で結果が反映されることを確認します。結果は通常12時間以内で表示されます。

{% page_image 1.png 506px %}


## カスタムトレースとカスタム指標の実装

1つのトレースに複数の指標を追加できます。

カスタムトレースはIDが文字列になっており、いくつか制限があります。

- 先頭と末尾が空白ではないこと
- 先頭がアンダースコア`_`でないこと
- 32文字以下であること

### *カスタムトレースを追加する*
```swift
import FirebasePerformance

let trace = Performance.startTrace(name: "Hoge")
// トレースしたいコードを挟む
trace.stop()
```

### *カスタム指標を追加する*

次のコードのようにトレースの間にカスタム指標コードを追加します。

```swift
let trace = Performance.startTrace(name: "Hoge")
trace.incrementMetric(named: "cache-miss-count", by: 1)
// トレースしたいコードを挟む
trace.stop()
```

## HTTP/Sネットワークリクエストのモニタリング追加
基本的に自動収集されますが、一部収集されないケースがあります。  その場合はカスタムネットワークリクエストを次のように追加します。

```swift
guard let metric = HTTPMetric(url: "https://your.domain.com", httpMethod: .get) else { return }
metric.start()

let hogeRequest = HogeRequest()
HogeAPI.get(request: hogeRequest, completion: {
  metric.stop()
})
```
リクエストの発行前とレスポンスの受信完了直後に `start()` と `stop()` を呼んでください。

## カスタム属性の追加

Performance Monitoringでは属性を使用することでパフォーマンスデータをセグメント化し、シナリオ別にパフォーマンスを絞り込むことができます。

カスタム属性はトレースごとに設定出来ます。  
またカスタム属性にはいくつか制限があります。

- カスタム属性の数は、1トレース最大5個に制限
- 名前は、先頭と末尾に空白がない
- 先頭にアンダースコア`_`がない
- 32文字以下

にする必要があります。

```swift
var trace = Performance.sharedInstance().trace(name: "Hoge")
trace.setValue("Male", forAttribute: "Gender")

// 更新も可能
trace.setValue("Female", forAttribute: "Gender")

// 削除
trace.removeAttribute("Gender")

// 属性読み込み
let gender: String? = trace.valueForAttribute("Gender")

// トレースに紐づく全属性読み込み
let attributes: [String: String] = trace.attributes
```

## 注意事項

[公式](https://firebase.google.com/docs/perf-mon/get-started-ios?hl=ja#known_issues)ではいくつか注意事項があります。

- GTMSQLiteを使ってる場合は、互換性がないため、Performance Monitoringを使用しないほうがいいです。
- `FirebaseApp.configure()`の呼び出し後のメソッド入れ替えは影響する可能性があります。
- iOS8.0~8.2シミュレータでは正常に動作する保証がありません
- NSURLSessionのbackgroundSessionConfigurationは接続時間が予想より長くなります。


## Firebase Performance Monitoring を無効にする方法は3つある

大きく分けて`Info.plist`を設定する方法とコード上で設定する方法に分かれます。

またコード上での設定では自動とカスタムそれぞれの制御ができます。

### Info.plist を設定する方法

- ビルド時に無効にしておき、ランタイムで有効／無効を制御できる方法（`通常無効`）
- ビルド時に完全無効にしておき、ランタイムで有効に変更できない方法（`完全無効`）

#### 通常無効
`Info.plist` で `firebase_performance_collection_enabled` を `false` にすることで、無効にできます。

#### 完全無効
`Info.plist` で `firebase_performance_collection_deactivated` を `true` にすることで、完全無効にできます。

これは `通常無効`(`firebase_performance_collection_enabled`) の設定をオーバーライドします。

前者はつまりコード上で制御できて、後者は制御が不可能になります。

### コード上で設定する方法

`Performance.sharedInstance().isInstrumentationEnabled` で自動トレースとHTTP/Sネットワークリクエストを有効／無効制御できます。

`Performance.sharedInstance().isDataCollectionEnabled` でカスタムトレースを有効／無効制御できます。

コード上の変更では前述した`完全無効`では効果ありません。

### デバッグ版は無効にする
開発中ではパフォーマンス測定しないために無効にしておき、本番ではコード上で有効にする例があります。

デバッグ情報が入った開発版では本来の測定より重いレポートとなるため、あまりパフォーマンス測定の効果は得られません。

本番のみ有効にするという利用ケースもあります。

### Remote Config と組み合わせて無効制御する

コード上で無効制御ができることとRemote Configを組み合わせることで、デプロイ済みのアプリに対して無効／有効設定ができるようになります。

詳しくは[公式](https://firebase.google.com/docs/perf-mon/disable-sdk?hl=ja&platform=ios#disable-with-remote-config)の記事を確認ください。

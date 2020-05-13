---
title: インフラメモ
categories: no-category
tags: no-tag
---
# サーバーセキュリティ対策

- sshでのrootログインを無効化
- sshログインを公開鍵認証方式に変える
- yum-cron で 定期的な yum update
- firewalld で不要なポートを閉じる
- SSHのデフォルトポートを変更する

## CNAMEレコードとALIASレコードの違い

## 監視

### 種類
- アラート検知
- モニタリング

- 死活監視
  - 故障やトラブルにいち早く気づくための仕組み
- 性能監視
  - サーバリソースの時系列での推移を知る仕組み

### 人気なサービス

#### エラー監視系
- Bugsnag
  - gem入れてgenerator叩いてinitializer生成
- Honeybadger
- Airbrake

#### サーバ監視系
- Mackerel
  - 有料
- New Relic
  - パフォーマンス監視ツール
  - 無料プランは制限あり
- Datadog
  - 無料プランあり

- Nagios
- Zabbix
  - 死活監視
- Munin
  - 性能監視

## Zabbix

サーバー、ネットワーク、アプリケーションを集中監視するOSS総合監視ツール
監視、障害検知、通知機能を備えてる。
監視とグラフ作成の両方行えるツール

アクティブ監視
監視対象サーバにエージェントがインストールされ、各種リソースや性能を監視サーバに報告する機能.
監視対象サーバーが増えてもポーリングによるボトルネックは解決できる

## Mackerel

## New Relic

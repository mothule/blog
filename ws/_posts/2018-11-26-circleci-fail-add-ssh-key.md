---
title: CircleCIでSSH Key登録が失敗する場合の原因特定方法と自分が見つけた解決方法
categories: ci circleci
tags: circleci ci ssh
image:
  path: /assets/images/2018-11-26-circleci-fail-add-ssh-key.png
---
最近CircleCIを使って定期実行的なことをするために弄り始めました。

## CircleCIの簡単な説明
CircleCIはGitHubのレポジトリベースで管理されており、セットアップすると自動でread-onlyの鍵がGitHubの対象レポジトリに登録されてます。
これによりCircleCIがGitHubのレポジトリをgit pullして取得したコードのテストを実行できるようになります。


## 自分が試したかったのは少し違う
自分がやりたかったのはgit pull後にテストではなくバッヂスクリプトを走らせた後に
成果物を再度対象レポジトリにgit push することでした。

自動で登録される read-only な鍵では足りないので新たに鍵を追加する必要があります。
そのさいに何故か秘密鍵が登録できず失敗になって躓いたのでその時に調べたことを紹介しようと思います。

↓SSH Key 追加画面
{% page_image -1.png %}


## エラーはブラウザコンソールに出る
{% page_image -2.png 20% %}

エラーになると失敗しか表示されず一見まったく原因が分からないですが、
ここでエラーになったらブラウザコンソールでエラーログに失敗要因が表示されてます。
Chromeであれば`option+command+i`で呼び出せます。

## 自分が躓いたのはエラーログでは分からず
しかし自分が躓いたのはエラーログが単純に400が変えるだけで詳しい原因が分からなかったのですが、
次の方法で解決できました。

SSH Keyを登録する時に
```bash
$ ssh-keygen -t rsa -b 4096 -C "メールアドレスなど"
```

のようなコマンドだと思いますが、これに -m PEM をつけて強制的にPEM形式にすることで無事登録できました。

```bash
$ ssh-keygen -m PEM -t rsa -b 4096 -C "メールアドレスなど"
```


### 参考

- [Adding a new SSH Key fails](https://discuss.circleci.com/t/adding-a-new-ssh-key-fails/6862)
- [Adding SSH keys fails](https://discuss.circleci.com/t/adding-ssh-keys-fails/7747/23)

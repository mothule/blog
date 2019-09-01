---
title: CircleCIで別途SSHキーを追加して使う方法
date: 2018-11-27
categories: ci circleci
tags: circleci ssh ci
---
最近CircleCIを使って定期実行的なことをするために弄り始めました。

## CircleCI が自動で生成＆登録してる鍵は read-only

CircleCIを使ってサーバーにデプロイしたい場合やGitHubへpushしたい場合は、 自動生成＆登録されるSSH Keyでは権限が足りずエラーになります。

別途SSH Keyを登録して利用することで上記のような目的を達成できるようになります。

## 手順

1. `ssh-keygen -m PEM -t rsa` などで鍵生成
2. GitHubのrepository設定のdeploy keyに公開鍵を登録
3. repository毎の設定 \> PERMISSIONS \> SSH Permissions へ移動
4. Add SSH Key を押下
5. ホスト名を github.com
6. Private Keyに秘密鍵を登録
7. .circleci/config.yml の steps 内で `add_ssh_key` コマンドを記入

※ `add_ssh_key` に関しては[CircleCIのadd_ssh_keys](https://circleci.com/docs/2.0/configuration-reference/#add_ssh_keys)を参照。
記事中に出てくる Fingerprint は GitHubかCircleCIのrepository設定ページで確認可能。

## 関連

CircleCIにSSH Key登録が失敗する場合は[CircleCIでSSH Key登録が失敗する場合の原因特定方法と自分が見つけた解決方法]({% post_url 2018-11-26-circleci-fail-add-ssh-key %})を参考にしてみてください。

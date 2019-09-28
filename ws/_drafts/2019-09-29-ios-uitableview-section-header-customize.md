---
title: 【初心者向け】UITableViewのセクションヘッダを変更する
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-09-18-ios-swift-rxswfit-basic.png
---
TODO: リード文



セクションヘッダーの定義元には次のようなコメントがあります。

> fixed font style. use custom view (UILabel) if you want something different

つまり、この方法ではフォントは固定で、もしカスタマイズしたい場合は、UILabelを使います。
これを実装するには、`UITableViewDelegate` の `func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?` を実装します。  
なぜ急に`delegate`？ と多少違和感を感じますが、少なくとも`DataSource`ではないと思うと多少疑念が和らぎます。

---
title: 【初心者向け】UITableViewDataSourcePrefetchingで事前処理して最適スクローリングする
categories: ios uitableview
tags: ios uitableview
image:
  path: /assets/images/2019-10-06-ios-uitableview-uitableviewdatasourceprefetching-basic.png
---
UITableViewDataSourcePrefetchingで事前処理して最適スクローリングする方法についてまとめました。
UITableView(テーブル)には表示するUITableViewCell(セル)には様々な情報が乗せることが可能です。

テーブルの特性からしても大量のデータを表示することに適しておりユーザーもまたそれを望んでいます。

しかしセル表示処理に負荷がかかるとスクロールにカクツキやFPS低下がおき、快適なスクロールにストレスが生じます。

今回はそれを解決する一つのアプローチ法となる事前処理が可能となる `UITableViewDataSourcePrefetching` を実装します。

## 重いセルとは
実務で最もポピュラーな重いセルとは、セル内の情報がネットワーク先にあるセルです。

例えばセルに画像(UIImageView)と名前(UILabel)と説明(UILabel)があったとしたら、サーバーサイドから画像URL, 名前, 説明の情報を受信後に
画像URLに対して画像としてデータをダウンロードします。

画像ダウンロード後、それぞれのデータが揃うことでセルにデータが表示されます。

これでサーバーサイドへの通信負荷により遅延が起きるなどすると、セルはあっと言う間に重いセルとなります。

## 重いセルを再現する

では重いセルを再現するために擬似環境を実装します。

次のコードは記事の画像や`via.placehoder.com`のネットワーク画像を取得後200ms待機後にダウンロード完了させています。

`ImageLoader`は簡単な非同期画像取得と簡易キャッシュシステムです。

**記事向けに適当に作った物なので決して流用しないでください。**

```swift
struct User {
    let name: String
    let imageUrl: URL
}


let users: [User] = [
    "https://blog.mothule.com/assets/images/2019-09-18-ios-swift-rxswfit-basic.png",
    "https://blog.mothule.com/assets/images/2019-09-15-tools-training-support-tools-urcoach.jpg",
    "https://blog.mothule.com/assets/images/2019-09-15-ruby-rubocop-found-unsupported-ruby-version.png",
    "https://blog.mothule.com/assets/images/2019-09-15-notebook-remote-worker-need-thinkg-just-one.jpg",
    "https://blog.mothule.com/assets/images/2019-09-15-ios-carthage.png",
    "https://blog.mothule.com/assets/images/2019-09-10-necessary-continual-behavior-for-engineer.png",
    "https://blog.mothule.com/assets/images/2019-09-07-ios-scene-kit-abc.jpg",
    "https://blog.mothule.com/assets/images/2019-09-05-ios-iosdc-japan-2019-pro.png",
    "https://blog.mothule.com/assets/images/2019-09-02-git-merge-p4merge.png",
    "https://blog.mothule.com/assets/images/2019-08-30-migration-blog-to-github-pages-from-hatenablog.png",
    "https://blog.mothule.com/assets/images/2019-08-30-ios-cocoapods-managed-rbenv-bundler.png",
    "https://blog.mothule.com/assets/images/2019-08-05-how-to-use-ngrok.png",
    "https://blog.mothule.com/assets/images/2019-03-26-engineering-mind-and-behavior-for-team.png",
    "https://blog.mothule.com/assets/images/2019-02-24-recommend-httpie.png",
    "https://blog.mothule.com/assets/images/ios-apple-there-was-an-error-sending-data-to-the-itunes-store-scheduling-restart-shortly.png",
    "https://blog.mothule.com/assets/images/2017-12-24-ios-uitableview-change-cell-separate.jpg",
    "https://blog.mothule.com/assets/images/2017-12-10-ios-uitableview-dynamic-cell-height.png",
    "https://blog.mothule.com/assets/images/2017-12-10-ios-swift-uitableview-pull-to-refresh.png",
    "https://via.placeholder.com/550x50",
    "https://via.placeholder.com/450x22",
    "https://via.placeholder.com/350x23",
    "https://via.placeholder.com/250x23",
    "https://via.placeholder.com/150x23",
    "https://via.placeholder.com/503x24",
    "https://via.placeholder.com/650x24",
    "https://via.placeholder.com/750x24",
    "https://via.placeholder.com/850x24",
    "https://via.placeholder.com/950x25",
    "https://via.placeholder.com/500x35",
    "https://via.placeholder.com/400x35",
    "https://via.placeholder.com/300x36",
    "https://via.placeholder.com/200x36",
    "https://via.placeholder.com/100x46",
    "https://via.placeholder.com/600x47",
    "https://via.placeholder.com/700x47",
    "https://via.placeholder.com/800x42",
    "https://via.placeholder.com/1250x5",
    "https://via.placeholder.com/1150x33",
    "https://via.placeholder.com/150x44",
    "https://via.placeholder.com/1650x55",
    "https://via.placeholder.com/1750x66",
    "https://via.placeholder.com/1850x11",
    "https://via.placeholder.com/1950x12",
    "https://via.placeholder.com/1500x14",
    "https://via.placeholder.com/1400x55"

    ].enumerated().map { index, element in
        User(name: "mothule-\(index)", imageUrl: URL(string: element)!)
    }


class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

class ImageLoader {
    static var shared: ImageLoader = ImageLoader()

    typealias CompletionHandle = (Data?, Error?) -> Void

    var tasks: [String: URLSessionDataTask] = [:]
    var cache: [String: Data] = [:]

    func cancel(url: URL) {
        if let existingTask = tasks[url.absoluteString] {
            existingTask.cancel()
            tasks[url.absoluteString] = nil
        }
    }

    func load(url: URL, completionHandler: CompletionHandle?) {

        if let data = cache[url.absoluteString] {
            completionHandler?(data, nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, res, error) in
            let time = 0.2
            Thread.sleep(forTimeInterval: time)
            DispatchQueue.main.async { [weak self] in
                self?.cache[url.absoluteString] = data
                completionHandler?(data, error)
            }
            self?.tasks[url.absoluteString] = nil
        }
        task.resume()

        self.tasks[url.absoluteString] = task
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")

        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.imageView?.image = UIImage(named: "icon")
        ImageLoader.shared.load(url: user.imageUrl) { (data, error) in
            if let data = data {
                cell.imageView?.image = UIImage(data: data)
                cell.setNeedsLayout()
            }
            if let error = error {
                print(error.localizedDescription)
            }
        }

        return cell
    }
}
```

## UITableViewDataSourcePrefetchingを実装する

`UITableViewDataSourcePrefetching`を実装し、`UITableView.prefetchDataSource`にインスタンスを渡す。

```swift
tableView.prefetchDataSource = self
```

```swift
extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print(#function + " \(indexPaths)")
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print(#function + " \(indexPaths)")
    }
}
```

### 挙動を確認する

次のような動作をしたとき

{% page_image -1.gif %}

ログは下記のような出力をする。

```
tableView(_:prefetchRowsAt:) [[0, 9], [0, 10], [0, 11], [0, 12], [0, 13], [0, 14], [0, 15], [0, 16], [0, 17], [0, 18]]
tableView(_:prefetchRowsAt:) [[0, 19]]
tableView(_:prefetchRowsAt:) [[0, 20]]
tableView(_:prefetchRowsAt:) [[0, 21]]
tableView(_:prefetchRowsAt:) [[0, 22]]
tableView(_:prefetchRowsAt:) [[0, 23]]
tableView(_:prefetchRowsAt:) [[0, 24]]
tableView(_:prefetchRowsAt:) [[0, 25]]
tableView(_:prefetchRowsAt:) [[0, 26]]
tableView(_:prefetchRowsAt:) [[0, 27]]
tableView(_:prefetchRowsAt:) [[0, 28]]
tableView(_:prefetchRowsAt:) [[0, 29]]
tableView(_:prefetchRowsAt:) [[0, 30]]
tableView(_:prefetchRowsAt:) [[0, 31]]
tableView(_:prefetchRowsAt:) [[0, 32]]
tableView(_:prefetchRowsAt:) [[0, 33]]
tableView(_:prefetchRowsAt:) [[0, 34]]
tableView(_:prefetchRowsAt:) [[0, 35]]
tableView(_:prefetchRowsAt:) [[0, 36]]
tableView(_:prefetchRowsAt:) [[0, 37]]
tableView(_:prefetchRowsAt:) [[0, 38]]
tableView(_:prefetchRowsAt:) [[0, 39]]
tableView(_:prefetchRowsAt:) [[0, 40]]
tableView(_:prefetchRowsAt:) [[0, 41]]
tableView(_:prefetchRowsAt:) [[0, 42]]
tableView(_:prefetchRowsAt:) [[0, 43]]
tableView(_:prefetchRowsAt:) [[0, 44]]
tableView(_:prefetchRowsAt:) [[0, 35], [0, 34], [0, 33], [0, 32], [0, 31], [0, 30], [0, 29], [0, 28], [0, 27], [0, 26]]
tableView(_:prefetchRowsAt:) [[0, 36]]
```

- スクロール最上部にいると、同時表示可能セル数分を次ページに対して要求する
- それ以降は１セル移動すると１セル要求する、要求先は常に２ページ目先頭
- スクロール最下部にいると、同時表示可能セル数分を前ページに対して要求する

このことからプリフェッチは常に1ページ分を事前に取得しようと動いている。

### 事前処理を行ってみる

次のコードのように事前に画像のダウンロードを行うようにした。

```swift
extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print(#function + " \(indexPaths)")
        indexPaths
            .map { users[$0.row].imageUrl }
            .forEach({ url in
                ImageLoader.shared.load(url: url, completionHandler: nil)
            })

    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print(#function + " \(indexPaths)")
        indexPaths
            .map { users[$0.row].imageUrl }
            .forEach({ url in
                ImageLoader.shared.cancel(url: url)
            })
    }
}
```

### 結果: UITableViewDataSourcePrefetchingは必須で使うべきか？

**通信帯域と通信先の負荷に余裕があるなら使うと効果がある**

- 通信帯域やサーバーサイドに余裕があるのであればプリフェッチして利用帯域の拡大して事前に処理を終わらせることに効果はある。
- 反対に通信帯域に余裕がない場合やサーバーサイドのレスポンスが遅い場合、表示中セルの画像ダウンロードを圧迫することになるため逆効果となる。

## UITableViewDataSourcePrefetchingのリスク
下スクロールを突然上スクロールにすると、ロード不要なセルの事前情報に対して処理を行うので、無駄な処理をしてしまいます。

無駄な処理だと分かったタイミングで処理を中断(キャンセル)が必要になります。

`UITableViewDataSourcePrefetching` では `tableView(_:cancelPrefetchingForRowsAt:)` がキャンセル時に呼ばれるのでこのメソッドでキャンセル処理を行わないと、無駄な処理が完遂まで走り続けます。

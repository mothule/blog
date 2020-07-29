---
title: 実務に耐えうるSDWebImage運用
categories: ios swift
tags: ios swift sdwebimage
---



```swift
guard let cache = SDWebImageManager.shared().imageCache else { return }
let config = cache.config
config.maxCacheAge = 60 // 1 min
config.maxCacheSize = 100 * 1024 * 1024 // 100 MB
cache.maxMemoryCost = (600 * 500) * 300 // 商品画像300枚程度
```


```swift
class Image {

    let imageId: Int
    let largeUrl: String
    let productUrl: String
    let smallUrl: String
    let miniUrl: String
    private(set) var largeUIImage: UIImage?

    init(withJson json: JSON) {
        imageId = json["id"].intValue
        largeUrl = json["large_url"].stringValue
        productUrl = json["product_url"].stringValue
        smallUrl = json["small_url"].stringValue
        miniUrl = json["mini_url"].stringValue
        fetchLargeImage()
    }

    fileprivate func fetchLargeImage() {
        guard let url = URL(string: largeUrl) else { return }
        let downloader = SDWebImageDownloader.shared()
        _ = downloader.downloadImage(with: url, options: .highPriority, progress: nil, completed: { image, _, error, _ in
            DispatchQueue.main.async {
                self.largeUIImage = image
                error?.record()
            }
        })
    }
}
```

```swift
extension UIImageView {
    /**
     # SDWebImage のラッパーメソッド

     ## 次の条件を一つでも満たす場合は .image には nil が入る.
     - URL文字列が無効
     - URLが無効
     - エラー発生

     - parameter url: URL文字列
     */
    func sd_setImageWithFadeIn(url: String?) {
        guard let urlString = url else {
            image = nil
            return
        }
        guard let url = URL(string: urlString) else {
            image = nil
            return
        }


        let options: SDWebImageOptions = [.retryFailed, .lowPriority]
        sd_setImage(with: url, placeholderImage: nil, options: options) { [weak self] (_, error, cacheType, _) in
            guard let myself = self else { return }

            if error != nil {
                myself.image = nil
            }

            if cacheType != .memory {
                let options: UIView.AnimationOptions = [
                    .transitionCrossDissolve,
                    .curveLinear,
                    .allowUserInteraction
                ]
                UIView.transition(with: myself, duration: 0.28, options: options, animations: nil, completion: nil)
            }
        }
    }
}
```

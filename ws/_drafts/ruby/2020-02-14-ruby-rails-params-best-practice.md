---
title: Railsのparams型検証のベストプラクティス
categories: ruby rails
tags: ruby rails
---


## 配列を受け取る
```ruby
def index
  @cache_key = params[:ids].join(':')
end
```

```ruby
def index
  @cache_key = (params[:ids] || []).join(':')
end
```

```ruby
def index
  @cache_key = Array.wrap(params[:ids]).join(':')
end
```


ActiveRecordではids=1234(非配列)、ids[]=1234(配列)どちらも引数サポートしている。

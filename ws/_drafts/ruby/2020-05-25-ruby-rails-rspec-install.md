---
title: RailsにRSpecを導入する
categories: ruby rails rspec
tags: ruby rails rspec
---

```ruby
group :development, :test do
  gem 'rspec-rails'
end
```

`:development`に入れてる理由
rails genrate で生成されるように

初期化
`$ bin/rails g rspec:install`

- .rspec
- spec/spec_helper.rb
- spec/rails_helper.rb

https://github.com/rspec/rspec
https://github.com/rspec/rspec-rails

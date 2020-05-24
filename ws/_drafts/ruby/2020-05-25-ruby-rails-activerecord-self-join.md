---
title: RailsのActiveRecordテーブルで自身に関連(自己結合)させる
categories: ruby rails active-record
tags: ruby rails active-record
---


テーブル名: play_locations

|Name|Type|Options|
|---|---|---|
|id|bigint|not null, primary key|
|parent_id|integer||


```ruby
class PlayLocation < ApplicationRecord
  has_many :children, class_name: 'PlayLocation', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'PlayLocation', optional: true
end
```

## Primary Key以外で結合させる

|Name|Type|Options|
|---|---|---|
|id|bigint|not null, primary key|
|parent_id|integer||
|region_id|integer||


`id`ではなく`region_id`で結合したい場合

```ruby
class PlayLocation < ApplicationRecord
  has_many :children, class_name: 'PlayLocation', foreign_key: 'parent_id', primary_key: 'region_id'
  belongs_to :parent, class_name: 'PlayLocation', optional: true, primary_key: 'region_id'
end
```

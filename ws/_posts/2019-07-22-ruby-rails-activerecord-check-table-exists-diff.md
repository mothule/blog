---
title: ActiveRecordでテーブルの存在を確認する2つの方法とその違い
description: ActiveRecordでテーブルの存在を確認する2つの方法とその違い
date: 2019-07-22
categories: ruby rails active-record
tags: ruby rails active-record
---
あまり頻度は高くないので忘れることが多いメソッドです。

おそらく構造もシンプルだろうし、その推測も確かめたかったので、コード追いかけて分かったことをアウトプットしようかなと軽い気持ちでした。

しかし、調べてみたらどうやらテーブルの存在確認には２つ方法があり、明確な違いもありそうなので、まとめてみました。

```ruby
ActiveRecord::Base.connection.table_exists?(table_name)
ActiveRecord::Base.table_exists?
```

２つありますね。。

## 結論

- `ActiveRecord::Base.connection.table_exists?(table_name)` はキャッシュなしでDBにテーブル有無を問い合わせ。
- `ActiveRecord::Base.table_exists?` はキャッシュありで、初回 or ヒットしなければDBに問い合わせ。
- `ActiveRecord::Base.table_exists?` は削除テーブルに対して問い合わせると **テーブル有り** と返す。後述


## コードを追いかけてみる

ただただAPIの使い方が分かれば目的は達成できますが、中身は一体どうなっているのか？
少し気になったので追いかけてみました。

### `ActiveRecord::Base.table_exists?`

```ruby
module ActiveRecord
  module ModelSchema
      # Indicates whether the table associated with this class exists
      def table_exists?
        connection.schema_cache.data_source_exists?(table_name)
      end
  end
end
```
まず速度低下を防ぐためスキーマキャッシュからテーブル存在を確認しています。
対象メソッドは↓になります。

```ruby
module ActiveRecord
  module ConnectionAdapters
    class SchemaCache

      # A cached lookup for table existence.
      def data_source_exists?(name)
        prepare_data_sources if @data_sources.empty?
        return @data_sources[name] if @data_sources.key? name

        @data_sources[name] = connection.data_source_exists?(name)
      end

      private

        def prepare_data_sources
          connection.data_sources.each { |source| @data_sources[source] = true }
        end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      def data_sources
        query_values(data_source_sql, "SCHEMA")
      rescue NotImplementedError
        tables | views
      end
    end
  end
end
```

1. まずキャッシュデータから検索
1. 見つからなければ実際にアクセス

キャッシュデータ未作成なら準備処理が呼ばれる。
詳細は後述しますが、存在するテーブル一覧からキャッシュデータを作成しています。


キャッシュ作成やキャッシュでも見つからない場合で実際にアクセスしているメソッドは↓になります。
どちらも同じメソッドを呼んでいますが、引数の違いにより

- キャッシュデータ作成→全てのテーブル取得
- キャッシュにない場合のアクセス→指定したテーブル名のみ取得

の違いがあります。↓のコードはSQLite3とMySQLの2パターンの載せています。

```ruby
module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      # Checks to see if the data source +name+ exists on the database.
      #
      #   data_source_exists?(:ebooks)
      #
      def data_source_exists?(name)
        query_values(data_source_sql(name), "SCHEMA").any? if name.present?
      rescue NotImplementedError
        data_sources.include?(name.to_s)
      end
    end
  end
end

# DatabaseがSQLite3の場合
module ActiveRecord
  module ConnectionAdapters
    module SQLite3
      module SchemaStatements # :nodoc:
        private
          def data_source_sql(name = nil, type: nil)
            scope = quoted_scope(name, type: type)
            scope[:type] ||= "'table','view'"

            sql = "SELECT name FROM sqlite_master WHERE name <> 'sqlite_sequence'".dup
            sql << " AND name = #{scope[:name]}" if scope[:name]
            sql << " AND type IN (#{scope[:type]})"
            sql
          end
      end
    end
  end
end

# DatabaseがMySQLの場合
module ActiveRecord
  module ConnectionAdapters
    module MySQL
      module SchemaStatements # :nodoc:
        private
          def data_source_sql(name = nil, type: nil)
            scope = quoted_scope(name, type: type)

            sql = "SELECT table_name FROM information_schema.tables".dup
            sql << " WHERE table_schema = #{scope[:schema]}"
            sql << " AND table_name = #{scope[:name]}" if scope[:name]
            sql << " AND table_type = #{scope[:type]}" if scope[:type]
            sql
          end
      end
    end
  end
end
```

### `ActiveRecord::Base.connection.table_exists?(table_name)`

```ruby
module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      # Checks to see if the table +table_name+ exists on the database.
      #
      #   table_exists?(:developers)
      #
      def table_exists?(table_name)
        query_values(data_source_sql(table_name, type: "BASE TABLE"), "SCHEMA").any? if table_name.present?
      rescue NotImplementedError
        tables.include?(table_name.to_s)
      end
    end
  end
end
```

キャッシュ機構なしで管理テーブルに対して指定テーブルの有無を問い合わせています。

## まとめ

### `ActiveRecord::Base.table_exists?`
- 最初にキャッシュからテーブル有無の解決を試み
-「テーブル無し」ならDBからテーブル一覧を取得して、もう一度存在確認を行います。
- もし、キャッシュ未作成の場合は同様に管理テーブルからテーブル一覧を取得してキャッシュ作成します。

キャッシュを介している目的はパフォーマンスの維持だと思われます。
テーブル一覧は性質上コロコロとデータ状態が変わるような場所でもないので、キャッシュ効率が良い場面だと思います。

新たにテーブル追加して、ヒットミスが起きてもキャッシュ更新して正しい値を返します。

しかし、**テーブルを削除しても、まだキャッシュには残っている可能性がある**ため削除テーブルには誤った値を返すリスクがありそうです。

### `ActiveRecord::Base.connection.table_exists?(table_name)`
一方 こちらのメソッドはキャッシュしない分負荷や速度低下はありますが、毎回DBに対して問い合わせているので精度はこちらのほうが上になります。


テーブル削除が伴うコードでテーブル存在確認をしたい場合など、状況に応じて使い分ける必要がありそうです。

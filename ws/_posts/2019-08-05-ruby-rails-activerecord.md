---
title: ActiveRecordでpluckとselectしてpluckに変化はあるか？
description: ActiveRecordでpluckとselectしてpluckに変化はあるか？
date: 2019-08-05
categories: ruby rails active-record
tags: ruby rails active-record
---

ちょっとした疑問になりますが、明確な違いなどは生まれるのか気になるコードがあります。

```ruby
User.select(:name).pluck(:name)
```

と

```ruby
User.pluck(:name)
```

に速度差や消費メモリ差はあるのか？

## SQLは同じ

出力されるSQLはどちらも同じでした。

```sql
SELECT `users`.`name` FROM `users`
```

## 速度は微妙な変化

90万件に対して行った結果

| pluckのみ | select+pluck |
| --- | --- |
| 3228 | 3349 |
| 3152 | 2972 |
| 3126 | 3370 |
| 3101 | 3144 |
| 3271 | 2945 |
| 3454 | 3227 |
| 3120 | 3306 |
| 3488 | 3577 |
| 3046 | 3072 |
| 3228 | 3413 |

pluckのみ平均: 3210.0ms select+pluck平均: 3231.625ms

## しかしselectは確実に処理されてる

SQLは同じ、速度差も大きな違いはないが、トレースしたところ 確実はselectメソッドは処理されてからpluckを呼び出されている。 速度で微妙にpluckのみが勝っているのもこのselectメソッド処理が呼ばれているからではないかと予想。

## 結論

実践に影響を及ぼす変化は起こりにくいと考えてよいが、 確実に無駄な処理は起きていることは事実であり、表面上のコード量も増えるので、 **pluckを呼ぶのであれば,selectは呼ぶ必要はない。**

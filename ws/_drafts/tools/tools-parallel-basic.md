# ちょっとした負荷テストをする

```sh
parallel -j 10 --verbose ruby stress_tester.rb walk {} ::: "user0" "user1" "user2" "user3" "user4" "user5" "user6" "user7" "user8" "user9"
```

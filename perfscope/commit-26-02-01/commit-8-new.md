# PT- 3cdb8c6046ab8d661827239551554e4e27e3c179
## 第1次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 6.382205
Average (excluding the first number): 6.470383
Average (excluding the first number): 6.382205
新版本沿符号执行
6.382205303251051
新版本默认执行
6.382205303251051
旧版本
6.470382989793876
新旧版本比较（沿符号执行）
-0.013627892921008411
新旧版本比较（默认执行）
-0.013627892921008411
 
 
modified part:
Average end to end: 6.503718
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AT- fd4b5cb3fab63dae77ef62f0bea024a273819975
## 第1次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.890418
Average (excluding the first number): 6.594214
Average (excluding the first number): 6.508652
新版本沿符号执行
6.8904179978255415
新版本默认执行
6.508651669201825
旧版本
6.594213881079265
新旧版本比较（沿符号执行）
0.04491879124457468
新旧版本比较（默认执行）
-0.012975346784389795
 
 
modified part:
Average end to end: 9.466270
Average modified part: 1.980397
0.20920566021301623
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
不幂等
# AB- 5582a41bb647e71231a7c3a1b4bc35b16ed902b6
getFuncName.txt文件为空

# NT- ec31156b589a7a51c5a6fab800a34c5819e51cc9

# AB- eafc365040014d587df45d57467de3f86363111e
getFuncName.txt文件为空

# AB- 96a0cfdea27fa28f93b8071ec1b3c6ef8b315298
call_analyse.txt文件为空

# AB- 90fa80f372e42e140213aa01b5db777fde236754
getFuncName.txt文件为空

# AB- b33a405bf16cfa147f1736a6a3cd64c2fd2b3f7d
getFuncName.txt文件为空

# NT- c9be4fbd72257fee347a89e5092212c9aad85432

# AB- d3a0d95dabe05a9473454b28b3a4fbcf32c16f9d
getFuncName.txt文件为空

# AB- 725c71b87a019ef48d8ad78ff756c413e8ebc9c4
getFuncName.txt文件为空

# AB- 41ecf7323ee96b50effcc8d0ae7d6f8a631a5f25
call_analyse.txt文件为空

# AB- abf93902a535341109c9504ab111879287daffda
getFuncName.txt文件为空

# NT- a257b6b4ba9dc1c828258c922accab6fe74c60cd

# NT- a51918209cbfcb0a3c5f58a0d6d51115c14a56dd

# NT- 8468ded6679b2109ff926e5302d8db40ed42b4ee

# NT- 9f99dd5f6d96c9914e7effafd625eb90181f6a53

# AB- bd3c1e1bd7049a879c2a3902aaca8745f18c044f
getFuncName.txt文件为空

# AB- 2c66059cde27c3329907351b1df300b0c9679a3f
getFuncName.txt文件为空

# AB- d7e0d03b114450dca1990f1dc9dce704f11033ea
getFuncName.txt文件为空

# AB- 14dd59ab12836f71e7543cc82503db7d151572fe
getFuncName.txt文件为空

# AT- de16bee70a7533119f45c8f7b62a36861f1b2193
## 第1次符号执行
./redis/app/bin/redis-cli HSCAN test_HGET 0 MATCH HGET_HASH_FIELD*2* COUNT 1000

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 68.093712
Average (excluding the first number): 65.489769
Average (excluding the first number): 65.983520
新版本沿符号执行
68.09371189907942
新版本默认执行
65.98351989719426
旧版本
65.48976931370517
新旧版本比较（沿符号执行）
0.03976105905795768
新旧版本比较（默认执行）
0.007539354446706845
 
 
modified part:
Average end to end: 65.418317
Average modified part: 0.078925
0.001206461436209233
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题

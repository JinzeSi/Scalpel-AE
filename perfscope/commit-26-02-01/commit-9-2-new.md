# AB- c37a782153e99b88917ffa609ddf0887a8a3e544
getFuncName.txt文件为空

# AB- 47505c353305bfc25069001e75f54c5628bbcf62
getFuncName.txt文件为空

# AB- 26683565958f352e1afd86a7f247457db0d6578c
getFuncName.txt文件为空

# NT- 11954d925e41c3ca958a0fb1e1395f26d11625cc

# AB- 14578b3b8b80e8d6f03c34c972cf1eb4e2dd31fa
getFuncName.txt文件为空

# AB- a3f1d09a7dea6c0fa1b8fca5f68c4f486ebbbb98
getFuncName.txt文件为空

# AB- 57a5f51f2641736e607586d321e455b6ba6a87c2
getFuncName.txt文件为空

# NT- 97d7d2f865d801f26c460a87f488733c75be75e3

# PT- ac0bef15b5867b5bfa0039176649f14b9c95d1b0
## 第1次符号执行
./redis/app/bin/redis-cli INFO memory

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 19.787709
Average (excluding the first number): 19.837664
Average (excluding the first number): 19.787709
新版本沿符号执行
19.787709033569858
新版本默认执行
19.787709033569858
旧版本
19.83766408523019
新旧版本比较（沿符号执行）
-0.0025181922350185756
新旧版本比较（默认执行）
-0.0025181922350185756
 
 
modified part:
Average end to end: 19.851647
Average modified part: 0.130399
0.006568698357925044
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 6.659854
Average (excluding the first number): 6.968486
Average (excluding the first number): 6.659854
新版本沿符号执行
6.659853908266046
新版本默认执行
6.659853908266046
旧版本
6.968486339483705
新旧版本比较（沿符号执行）
-0.044289737567387535
新旧版本比较（默认执行）
-0.044289737567387535
 
 
modified part:
Average end to end: 6.461497
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-cli EXPIRE key:23 22

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2.282443
Average (excluding the first number): 2.358893
Average (excluding the first number): 2.282443
新版本沿符号执行
2.282443350542282
新版本默认执行
2.282443350542282
旧版本
2.3588926617772197
新旧版本比较（沿符号执行）
-0.032408982601751665
新旧版本比较（默认执行）
-0.032408982601751665
 
 
modified part:
Average end to end: 2.365547
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第4次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.651069
Average (excluding the first number): 7.833880
Average (excluding the first number): 7.687279
新版本沿符号执行
6.651068757841907
新版本默认执行
7.687278621834787
旧版本
7.833879662209712
新旧版本比较（沿符号执行）
-0.150986606301043
新旧版本比较（默认执行）
-0.018713721258972367
 
 
modified part:
Average end to end: 6.659280
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第5次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.765614
Average (excluding the first number): 6.955852
Average (excluding the first number): 6.757220
新版本沿符号执行
6.765614412826324
新版本默认执行
6.757220074438709
旧版本
6.955852383735493
新旧版本比较（沿符号执行）
-0.027349339867245206
新旧版本比较（默认执行）
-0.028556142128782967
 
 
modified part:
Average end to end: 6.570156
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第6次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.813711
Average (excluding the first number): 6.791917
Average (excluding the first number): 6.706279
新版本沿符号执行
6.813710757569447
新版本默认执行
6.706278596636911
旧版本
6.791917167107055
新旧版本比较（沿符号执行）
0.003208753865246909
新旧版本比较（默认执行）
-0.012608895009039278
 
 
modified part:
Average end to end: 6.668794
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AB- a46624e10e5b866d4154fb9bcc3fc7b45dd1aef8
call_analyse.txt文件为空

# PT- 6a436b6f723f9b089d0a8bf64ab0da5f37524847
## 第1次符号执行
./redis/app/bin/redis-cli REPLCONF rdb-filter-only ""

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.779530
Average (excluding the first number): 2.655602
Average (excluding the first number): 2.767929
新版本沿符号执行
2.779530339071886
新版本默认执行
2.767928662630257
旧版本
2.6556022699235133
新旧版本比较（沿符号执行）
0.04666665281617718
新旧版本比较（默认执行）
0.04229789753492669
 
 
modified part:
Average end to end: 2.996944
Average modified part: 2.078236
0.6934515389897236
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
# PT- 30d5f056372c914a50ca9975144016398e33657f
## 第1次符号执行
./redis/app/bin/redis-cli HMSET test_HMSET username alice age 30 location Paris HGET_HASH_FIELD1 weugfuwebgfiwebviu HGET_HASH_FIELD2 ewuvbgevhberihvneirn HGET_HASH_FIELD3 weufgewihiwer HGET_HASH_FIELD4 4tvnreiknveir HGET_HASH_FIELD5 23rgwnrighnkwn2 HGET_HASH_FIELD6 23jrb234jbg34ibgi3

新版本timeout
旧版本timeout
## 第2次符号执行
./redis/app/bin/redis-cli BLPOP key_list:1 key_list:999 key_list:23 key_list:98 key_list:1283 key_list:9999 key_list:123 key_list:8765 0

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 4.732619
Average (excluding the first number): 4.600410
Average (excluding the first number): 4.625321
新版本沿符号执行
4.732618650337005
新版本默认执行
4.62532141980862
旧版本
4.600410074305184
新旧版本比较（沿符号执行）
0.028738432856290252
新旧版本比较（默认执行）
0.005415027160855532
 
 
modified part:
Average end to end: 4.910074
Average modified part: 0.086241
0.017564007793336466
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第3次符号执行
./redis/app/bin/redis-cli HMSET test_HMSET username alice age 30 location Paris HGET_HASH_FIELD1 weugfuwebgfiwebviu HGET_HASH_FIELD2 ewuvbgevhberihvneirn HGET_HASH_FIELD3 weufgewihiwer HGET_HASH_FIELD4 4tvnreiknveir HGET_HASH_FIELD5 23rgwnrighnkwn2 HGET_HASH_FIELD6 23jrb234jbg34ibgi3

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 4.457611
Average (excluding the first number): 4.492280
Average (excluding the first number): 4.337944
新版本沿符号执行
4.4576110629514965
新版本默认执行
4.337943754384517
旧版本
4.492279509559435
新旧版本比较（沿符号执行）
-0.007717339612142278
新旧版本比较（默认执行）
-0.03435577747254952
 
 
modified part:
Average end to end: 4.599928
Average modified part: 0.109745
0.023857921539067777
 
 
icount diff
``` 
## 第4次符号执行
./redis/app/bin/redis-cli ZREMRANGEBYRANK key_SortSet:267 2 51

新版本timeout
旧版本timeout
## 第5次符号执行
./redis/app/bin/redis-cli DEBUG RELOAD NOSAVE NOFLUSH MERGE

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 1199871.204059
Average (excluding the first number): 1222391.592841
新版本沿符号执行
-0.0
新版本默认执行
1222391.5928411765
旧版本
1199871.204058824
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
0.018769005128360737
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
无占比
## 第6次符号执行
./redis/app/bin/redis-cli HDEL test_HGET HGET_HASH_FIELD157 HGET_HASH_FIELD3 HGET_HASH_FIELD55 HGET_HASH_FIELD98 HGET_HASH_FIELD2 erwbvirebre 3id23ifb2 23rb2j4bgfj24b HGET_HASH_FIELD34

新版本timeout
旧版本timeout
## 第7次符号执行
./redis/app/bin/redis-cli LTRIM key_list:1233 15 32

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.305172
Average (excluding the first number): 1.418684
Average (excluding the first number): 1.328452
新版本沿符号执行
1.305171692899195
新版本默认执行
1.3284521568470382
旧版本
1.418683763082969
新旧版本比较（沿符号执行）
-0.08001224313521338
新旧版本比较（默认执行）
-0.06360233942471204
 
 
modified part:
Average end to end: 1.324979
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第8次符号执行
./redis/app/bin/redis-cli SREM test_set value_set:159 value_set:1 value_set:91 value_set:72 value_set:134 value_set:13 value_set:93 value_set:3

新版本timeout
旧版本timeout
## 第9次符号执行
./redis/app/bin/redis-cli SMOVE test_set key_set:23 value_set:145

新版本timeout
旧版本timeout
## 第10次符号执行
./redis/app/bin/redis-cli ZREM test_zadd2 sortset156 sortset1 sortset32 sortset160 sortset97 sortset15 sortset134 sortset3 sortset72 sortset122

新版本timeout
旧版本timeout
## 第11次符号执行
./redis/app/bin/redis-cli PFADD key_HyperLogLog:999 gwuvgewubgvwe qiwghfdiqeghfiuwehbf qiwhfdiqwhfiqjehfieqhf qwifhqeifhewifhneiwhfewi qifhweihfbewikhfnvikewhfniwek qfheikfnewknfkqenfkqe qeifhqeifknewkfnewkqnfq ejfgbweijfbweknfwekqebfue qbfwjqebfewjbnvikwen qefbeiwnfiwkebnfwe

新版本timeout
旧版本timeout
## 第12次符号执行
./redis/app/bin/redis-cli SETRANGE key:3 34 uwvubwivbiebv34ewfgeiwghfbiew

新版本timeout
旧版本timeout
## 第13次符号执行
./redis/app/bin/redis-cli INFO clients

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 18.402501
Average (excluding the first number): 5.970238
Average (excluding the first number): 5.951150
新版本沿符号执行
18.402500845604916
新版本默认执行
5.951149705634987
旧版本
5.970237603909937
新旧版本比较（沿符号执行）
2.0823732766603844
新旧版本比较（默认执行）
-0.0031971756471550683
 
 
modified part:
Average end to end: 18.996253
Average modified part: 13.318152
0.7010936110377206
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第14次符号执行
./redis/app/bin/redis-cli GETSET key:2341 fwegbfueho2jofrh32i

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.330742
Average (excluding the first number): 2.414674
Average (excluding the first number): 2.621164
新版本沿符号执行
2.3307420974414588
新版本默认执行
2.6211639244363196
旧版本
2.4146739564243536
新旧版本比较（沿符号执行）
-0.034759085697508
新旧版本比较（默认执行）
0.08551463747831868
 
 
modified part:
Average end to end: 2.612601
Average modified part: 0.320787
0.12278458420170103
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
## 第15次符号执行
./redis/app/bin/redis-cli SPOP test_SPOP 7

新版本timeout
旧版本timeout
## 第16次符号执行
./redis/app/bin/redis-cli BRPOPLPUSH key_list:222 key_list:1234 0

新版本timeout
旧版本timeout
## 第17次符号执行
./redis/app/bin/redis-cli INCRBY test_INCR 10

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 1.687135
Average (excluding the first number): 1.700893
新版本沿符号执行
-0.0
新版本默认执行
1.700893453724605
旧版本
1.68713460366473
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
0.00815515847401188
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
无占比
## 第18次符号执行
./redis/app/bin/redis-cli HMSET test_HMSET username alice age 30 location Paris HGET_HASH_FIELD1 weugfuwebgfiwebviu HGET_HASH_FIELD2 ewuvbgevhberihvneirn HGET_HASH_FIELD3 weufgewihiwer HGET_HASH_FIELD4 4tvnreiknveir HGET_HASH_FIELD5 23rgwnrighnkwn2 HGET_HASH_FIELD6 23jrb234jbg34ibgi3

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 4.362923
Average (excluding the first number): 4.493802
Average (excluding the first number): 4.368149
新版本沿符号执行
4.362923327350891
新版本默认执行
4.368148932614781
旧版本
4.493802002409538
新旧版本比较（沿符号执行）
-0.029124263816801728
新旧版本比较（默认执行）
-0.02796141657495885
 
 
modified part:
Average end to end: 4.438846
Average modified part: 0.070344
0.015847375263121417
 
 
icount diff
``` 
## 第19次符号执行
./redis/app/bin/redis-cli APPEND test_APPEND 23ry342rh43ih34u9gu0qufe

新版本timeout
旧版本timeout
# AB- 98335e1237d082dee4176ac583e1d0df1a2f1eb6
getFuncName.txt文件为空

# AB- 714ea20fec4d0e258c83593433927f0fa29b12c9
getFuncName.txt文件为空

# AT- 191afb8903afd93149be99d436f00b574bd16798
## 第1次符号执行
./redis/app/bin/redis-cli BGREWRITEAOF

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.303714
Average (excluding the first number): 1.289068
Average (excluding the first number): 1.254973
新版本沿符号执行
1.3037141288433385
新版本默认执行
1.2549734567397863
旧版本
1.289068003096606
新旧版本比较（沿符号执行）
0.01136179449924249
新旧版本比较（默认执行）
-0.026448989715761723
 
 
modified part:
Average end to end: 16.254654
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AB- 538713e622ad400defa383c3b2c3ec032828e06b
getFuncName.txt文件为空

# AB- 8148e4116e984471c9934550bf557050fac226d4
getFuncName.txt文件为空


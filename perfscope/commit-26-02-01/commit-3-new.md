# AB- f5e046a730c7607579e414449d5bcb29c9771c86
getFuncName.txt文件为空

# NT- 2bfffe85e9e8fc2eb5a107f86d40f4bb7830382b

# AB- e3b9397dfe3e908d5576e7179a5a3d898501e7b8
getFuncName.txt文件为空

# NT- c688537d497f1edb70a0b52a9e9d7581de383baa

# PT- 870b6bd487ec4623af458d0a660b2854dee29d5a
## 第1次符号执行
./redis/app/bin/redis-cli DEBUG HTSTATS 0

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 17.598069
Average (excluding the first number): 4.771344
Average (excluding the first number): 4.690304
新版本沿符号执行
17.598068608549873
新版本默认执行
4.690304293611538
旧版本
4.771344264333983
新旧版本比较（沿符号执行）
2.6882831406855803
新旧版本比较（默认执行）
-0.016984725107392202
 
 
modified part:
Average end to end: 16.764374
Average modified part: 15.833289
0.9444604760599091
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
# PT- 09f8a2f37401347e860508df83189e94de1be6ce
## 第1次符号执行
./redis/app/bin/redis-cli INFO memory

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 19.501045
Average (excluding the first number): 19.325758
Average (excluding the first number): 19.501045
新版本沿符号执行
19.50104538162783
新版本默认执行
19.50104538162783
旧版本
19.325757853778416
新旧版本比较（沿符号执行）
0.009070150271759834
新旧版本比较（默认执行）
0.009070150271759834
 
 
modified part:
Average end to end: 19.400879
Average modified part: 17.135261
0.8832208505644622
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli INFO memory

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 19.631741
Average (excluding the first number): 19.898401
Average (excluding the first number): 19.435677
新版本沿符号执行
19.631741479099677
新版本默认执行
19.43567728493008
旧版本
19.89840091125873
新旧版本比较（沿符号执行）
-0.013401048322841537
新旧版本比较（默认执行）
-0.023254312162684178
 
 
modified part:
Average end to end: 19.539054
Average modified part: 0.639371
0.03272270301828947
 
 
icount diff
``` 
# PT- 04589f90d714c6a9594bb4026811bd7b3c1e0de0
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2476.555886
Average (excluding the first number): 2490.559129
Average (excluding the first number): 2476.555886
新版本沿符号执行
2476.5558857142864
新版本默认执行
2476.5558857142864
旧版本
2490.559128571428
新旧版本比较（沿符号执行）
-0.005622529775140843
新旧版本比较（默认执行）
-0.005622529775140843
 
 
modified part:
Average end to end: 2512.530343
Average modified part: 0.305071
0.00012141999774797317
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.311870
Average (excluding the first number): 6.457811
Average (excluding the first number): 6.363250
新版本沿符号执行
6.311869709576765
新版本默认执行
6.363250187546887
旧版本
6.4578114788437375
新旧版本比较（沿符号执行）
-0.02259926133568444
新旧版本比较（默认执行）
-0.01464293152666968
 
 
modified part:
Average end to end: 6.336434
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.440088
Average (excluding the first number): 6.333412
Average (excluding the first number): 6.392947
新版本沿符号执行
6.440088335692283
新版本默认执行
6.392946755199198
旧版本
6.333411651728554
新旧版本比较（沿符号执行）
0.016843478654133364
新旧版本比较（默认执行）
0.009400163252359454
 
 
modified part:
Average end to end: 6.333265
Average modified part: 0.282049
0.04453453720142263
 
 
icount diff
``` 
## 第4次符号执行
./redis/app/bin/redis-cli DEBUG HTSTATS 0

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 17.299119
Average (excluding the first number): 4.654859
Average (excluding the first number): 4.828621
新版本沿符号执行
17.29911932035941
新版本默认执行
4.828620512181962
旧版本
4.65485912110782
新旧版本比较（沿符号执行）
2.7163572237697187
新旧版本比较（默认执行）
0.03732903328614335
 
 
modified part:
Average end to end: 17.526189
Average modified part: 16.439017
0.9379687264120722
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第5次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本timeout
旧版本timeout
# PT- 8afb72a3263fbea0e229377e5450403f144e4d71
## 第1次符号执行
./redis/app/bin/redis-cli ZSCAN test_zadd 0 MATCH sortset*1* COUNT 100

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 85.936534
Average (excluding the first number): 89.215038
Average (excluding the first number): 85.936534
新版本沿符号执行
85.93653411531473
新版本默认执行
85.93653411531473
旧版本
89.215037538749
新旧版本比较（沿符号执行）
-0.0367483275676515
新旧版本比较（默认执行）
-0.0367483275676515
 
 
modified part:
Average end to end: 94.825537
Average modified part: 61.242618
0.6458452027627788
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli SCAN 0 MATCH key:* COUNT 100

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 18.786603
Average (excluding the first number): 17.683111
Average (excluding the first number): 17.816124
新版本沿符号执行
18.78660296712109
新版本默认执行
17.816124444088306
旧版本
17.68311096362052
新旧版本比较（沿符号执行）
0.06240372555320072
新旧版本比较（默认执行）
0.0075220633259291
 
 
modified part:
Average end to end: 20.199628
Average modified part: 4.596732
0.22756519826784638
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
# AT- 0aeb86d78d79810764af255721600a5cf13799f9
## 第1次符号执行
./redis/app/bin/redis-cli GETRANGE key:3242 8 33

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.472751
Average (excluding the first number): 1.530800
Average (excluding the first number): 1.574002
新版本沿符号执行
1.4727513730206452
新版本默认执行
1.5740018415452612
旧版本
1.5307996557521415
新旧版本比较（沿符号执行）
-0.037920235031000796
新旧版本比较（默认执行）
0.028221972503575474
 
 
modified part:
Average end to end: 1.638315
Average modified part: 0.181011
0.11048605143426433
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
# AB- 17eb33e0c3528d7f86462e4220853dfc0ad02022
getFuncName.txt文件为空

# AT- fd5c325886ca1308bb0a0813e054a880fe403120
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1099108.964457
Average (excluding the first number): 1095359.887871
Average (excluding the first number): 1103229.310586
新版本沿符号执行
1099108.9644571426
新版本默认执行
1103229.310585714
旧版本
1095359.8878714284
新旧版本比较（沿符号执行）
0.0034226893162937334
新旧版本比较（默认执行）
0.007184326175735635
 
 
modified part:
Average end to end: 1091669.223200
Average modified part: 1.886229
1.7278389198327742e-06
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 1102095.208014
Average (excluding the first number): 1105831.716671
新版本沿符号执行
-0.0
新版本默认执行
1105831.7166714284
旧版本
1102095.2080142857
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
0.003390368300280568
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 126.855088
Average (excluding the first number): 54.033608
Average (excluding the first number): 53.860925
新版本沿符号执行
126.85508847367973
新版本默认执行
53.86092451708767
旧版本
54.03360757581942
新旧版本比较（沿符号执行）
1.347707180122629
新旧版本比较（默认执行）
-0.0031958454465481
 
 
modified part:
Average end to end: 132.565353
Average modified part: 22.227545
0.16767235744601075
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
# AB- a0347734979e6a9288165c79b001aeee6c14a8ff
getFuncName.txt文件为空

# AB- f35ad82314e938bf2e19917edb9aef3522f43103
getFuncName.txt文件为空

# AB- a8850a8d3026e4eff3c9bc10748b504dad71b69c
getFuncName.txt文件为空

# AT- 192799539f798837b06ed540e3938b41ea5015d8
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2397.676800
Average (excluding the first number): 2504.480586
Average (excluding the first number): 2397.676800
新版本沿符号执行
2397.6768000000006
新版本默认执行
2397.6768000000006
旧版本
2504.4805857142856
新旧版本比较（沿符号执行）
-0.042645084303508045
新旧版本比较（默认执行）
-0.042645084303508045
 
 
modified part:
Average end to end: 2389.294486
Average modified part: 1.961657
0.000821019407438468
 
 
icount diff
``` 
# AB- 294492dbf2682e92e26c1c4f86ea326b391e83b9
getFuncName.txt文件为空

# AB- f7353db7ebbcacec876c34d881b82164a32d88aa
getFuncName.txt文件为空

# AT- 855ec46a6aaec7fe1360890a5aa24d60c7a20bde
## 第1次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 53.621025
Average (excluding the first number): 52.206032
Average (excluding the first number): 53.621025
新版本沿符号执行
53.621024873349384
新版本默认执行
53.621024873349384
旧版本
52.20603154771853
新旧版本比较（沿符号执行）
0.027104020046754346
新旧版本比较（默认执行）
0.027104020046754346
 
 
modified part:
Average end to end: 52.004166
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
不幂等
## 第2次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 127.134791
Average (excluding the first number): 52.798500
Average (excluding the first number): 52.108858
新版本沿符号执行
127.13479145226451
新版本默认执行
52.108858052658576
旧版本
52.798499743502056
新旧版本比较（沿符号执行）
1.4079243173554579
新旧版本比较（默认执行）
-0.013061766796287707
 
 
modified part:
Average end to end: 143.740359
Average modified part: 23.781299
0.1654462185294662
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
# NT- c88f9fe26f1c391e3b9637094d5c0f40840bf480

# AB- c2694fb696959fbad42e4ed711ff8a23e2bb0dbf
getFuncName.txt文件为空

# AB- 49455c43ae2eb5d460dd68b141d11a31c929e603
getFuncName.txt文件为空

# PT- de4e92ac39b8d405fe40ebedcf14442881fd1be4
## 第1次符号执行
./redis/app/bin/redis-cli CONFIG GET panda.numeric

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.782635
Average (excluding the first number): 2.647349
Average (excluding the first number): 2.651204
新版本沿符号执行
2.782635425694358
新版本默认执行
2.6512039718659492
旧版本
2.647349466368826
新旧版本比较（沿符号执行）
0.05110241811448255
新旧版本比较（默认执行）
0.0014559866561214662
 
 
modified part:
Average end to end: 2.669070
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
无占比
## 第2次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 52.211416
Average (excluding the first number): 53.066464
Average (excluding the first number): 53.957907
新版本沿符号执行
52.211416462064804
新版本默认执行
53.957907127155906
旧版本
53.066463824990606
新旧版本比较（沿符号执行）
-0.016112763151991567
新旧版本比较（默认执行）
0.01679861889997449
 
 
modified part:
Average end to end: 52.212797
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 137.241913
Average (excluding the first number): 53.068084
Average (excluding the first number): 53.313373
新版本沿符号执行
137.2419130508046
新版本默认执行
53.31337344913151
旧版本
53.06808439510534
新旧版本比较（沿符号执行）
1.5861478629792587
新旧版本比较（默认执行）
0.004622157683324957
 
 
modified part:
Average end to end: 137.482886
Average modified part: 5.509670
0.04007531291417548
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第4次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 129.342051
Average (excluding the first number): 52.018296
Average (excluding the first number): 53.449278
新版本沿符号执行
129.3420512123657
新版本默认执行
53.44927823920266
旧版本
52.018296058889206
新旧版本比较（沿符号执行）
1.4864722801750239
新旧版本比较（默认执行）
0.027509209042400416
 
 
modified part:
Average end to end: 129.347792
Average modified part: 21.790834
0.16846700045648608
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
# AB- 0f6e3a827356fd0c1d3b71f487ea9ce21eee0b51
getFuncName.txt文件为空

# AB- 98be450f1dd6c586fd83f1f9b5bec6484e188721
getFuncName.txt文件为空

# AB- f164012c191e711f4819f66611fccffe59391aa6
getFuncName.txt文件为空

# AB- 83c0348553248fde3283a85dc9b036197a06e66a
getFuncName.txt文件为空

# AB- b9361ad5fe7dabe80a37af457effb8c4009829b1
getFuncName.txt文件为空

# AB- 7a40fd630dd85711d6156d9be6f5dd2c10509f20
getFuncName.txt文件为空

# AB- d9134f8f9592a344592a9c6f1fa801e089dd2f98
getFuncName.txt文件为空

# AB- 1cd622bdcabf1bd80fd20a7c5722808108e324ff
getFuncName.txt文件为空

# NT- 1583d60cd62954338ca90f16f4d13afd96fcbf07

# AT- 87124a38b65e8f7c867e4dcb1f471355d50f7f74
## 第1次符号执行
./redis/app/bin/redis-cli BGREWRITEAOF

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.306254
Average (excluding the first number): 1.277475
Average (excluding the first number): 1.276395
新版本沿符号执行
1.306253556724145
新版本默认执行
1.2763945325269697
旧版本
1.2774747729771552
新旧版本比较（沿符号执行）
0.022527868538586293
新旧版本比较（默认执行）
-0.0008456060918275587
 
 
modified part:
Average end to end: 13.739287
Average modified part: 0.010996
0.0008003559357889043
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
不幂等
# PT- 662cb2fe75d747734d3ca4bfd062044315fb9dc9
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2352.348929
Average (excluding the first number): 2421.086800
Average (excluding the first number): 2352.348929
新版本沿符号执行
2352.348928571429
新版本默认执行
2352.348928571429
旧版本
2421.086800000001
新旧版本比较（沿符号执行）
-0.028391328815047804
新旧版本比较（默认执行）
-0.028391328815047804
 
 
modified part:
Average end to end: 2375.178843
Average modified part: 523.034457
0.22020845239329023
 
 
icount diff
``` 
# PT- 7f5f5882322d19ebba3ccbf933e1252c03116d55
## 第1次符号执行
./redis/app/bin/redis-cli BGREWRITEAOF

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1.307032
Average (excluding the first number): 1.199132
Average (excluding the first number): 1.307032
新版本沿符号执行
1.3070317615839966
新版本默认执行
1.3070317615839966
旧版本
1.1991317981381675
新旧版本比较（沿符号执行）
0.08998173813200518
新旧版本比较（默认执行）
0.08998173813200518
 
 
modified part:
Average end to end: 16.558033
Average modified part: 0.017666
0.001066926249191376
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
不幂等
## 第2次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1108670.064586
Average (excluding the first number): 2600.467186
Average (excluding the first number): 2493.454486
新版本沿符号执行
1108670.0645857141
新版本默认执行
2493.4544857142855
旧版本
2600.467185714286
新旧版本比较（沿符号执行）
425.3349565325082
新旧版本比较（默认执行）
-0.04115133641673192
 
 
modified part:
Average end to end: 1108787.882843
Average modified part: 1106739.731429
0.9981528014095585
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第3次符号执行
./redis/app/bin/redis-cli BGREWRITEAOF

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.265124
Average (excluding the first number): 1.202340
Average (excluding the first number): 1.303148
新版本沿符号执行
1.2651235205596454
新版本默认执行
1.3031475509954809
旧版本
1.2023400699414444
新旧版本比较（沿符号执行）
0.052217714594888824
新旧版本比较（默认执行）
0.08384273598978194
 
 
modified part:
Average end to end: 15.897711
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
## 第4次符号执行
./redis/app/bin/redis-cli BGREWRITEAOF

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.366372
Average (excluding the first number): 1.177806
Average (excluding the first number): 1.310373
新版本沿符号执行
1.3663718167765029
新版本默认执行
1.3103731538147694
旧版本
1.1778059658975295
新旧版本比较（沿符号执行）
0.16009924923013918
新旧版本比较（默认执行）
0.11255435254670239
 
 
modified part:
Average end to end: 13.283652
Average modified part: 0.030541
0.002299162952462102
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
不幂等
## 第5次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2613.910657
Average (excluding the first number): 2520.973671
Average (excluding the first number): 2448.448486
新版本沿符号执行
2613.9106571428592
新版本默认执行
2448.448485714286
旧版本
2520.973671428572
新旧版本比较（沿符号执行）
0.03686551222949598
新旧版本比较（默认执行）
-0.02876872001332229
 
 
modified part:
Average end to end: 2414.950429
Average modified part: 13.248229
0.00548592153888045
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第6次符号执行
./redis/app/bin/redis-cli BGREWRITEAOF

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.297818
Average (excluding the first number): 1.198579
Average (excluding the first number): 1.294949
新版本沿符号执行
1.2978175769450566
新版本默认执行
1.2949487430224504
旧版本
1.1985794206200668
新旧版本比较（沿符号执行）
0.08279647941364655
新旧版本比较（默认执行）
0.08040295098052694
 
 
modified part:
Average end to end: 13.326618
Average modified part: 6.509261
0.4884405872404762
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
不幂等
## 第7次符号执行
./redis/app/bin/redis-cli BGREWRITEAOF

新版本timeout
旧版本timeout
# NT- 57807cd33806116d2d65c2e037ffa35cdadfd801

# PT- e2608478b6a46998bb3196b9b3ef4a24cbbae8a7
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2429.158214
Average (excluding the first number): 2462.247757
Average (excluding the first number): 2429.158214
新版本沿符号执行
2429.1582142857137
新版本默认执行
2429.1582142857137
旧版本
2462.247757142858
新旧版本比较（沿符号执行）
-0.013438754390638893
新旧版本比较（默认执行）
-0.013438754390638893
 
 
modified part:
Average end to end: 2562.317429
Average modified part: 322.942671
0.12603538805440737
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli HMSET test_HMSET username alice age 30 location Paris HGET_HASH_FIELD1 weugfuwebgfiwebviu HGET_HASH_FIELD2 ewuvbgevhberihvneirn HGET_HASH_FIELD3 weufgewihiwer HGET_HASH_FIELD4 4tvnreiknveir HGET_HASH_FIELD5 23rgwnrighnkwn2 HGET_HASH_FIELD6 23jrb234jbg34ibgi3

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 4.505464
Average (excluding the first number): 4.399483
Average (excluding the first number): 4.552992
新版本沿符号执行
4.505464002984209
新版本默认执行
4.55299167741667
旧版本
4.399483146533831
新旧版本比较（沿符号执行）
0.024089387985012693
新旧版本比较（默认执行）
0.03489240116848305
 
 
modified part:
Average end to end: 4.618907
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
# AB- 6c202f495c6057fb571da1e3ab133773f4851e9d
getFuncName.txt文件为空

# AB- c5f91abaf70c4af035ec4cce13db86e3a584c28f
getFuncName.txt文件为空

# NT- b045fe4e174eb90e110d0cb1c34e0fdc61ed9cbf

# NT- 66df58f9616618fb519d6d74b7b643442051d43e

# PT- 725cd268e652cd3c9f0047c3cfe23a911e565d8a
## 第1次符号执行
./redis/app/bin/redis-cli BITOP AND tmp key:1789 key:8988 key:345 key:12 key:5467 key:998 key:7345 key:4 key:3098 key:9999

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 5.607286
Average (excluding the first number): 5.741384
Average (excluding the first number): 5.607286
新版本沿符号执行
5.607285991575122
新版本默认执行
5.607285991575122
旧版本
5.7413838047013295
新旧版本比较（沿符号执行）
-0.023356357576443835
新旧版本比较（默认执行）
-0.023356357576443835
 
 
modified part:
Average end to end: 5.664142
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第2次符号执行
./redis/app/bin/redis-cli DEBUG RELOAD NOSAVE NOFLUSH MERGE

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1160046.402182
Average (excluding the first number): 1194366.721188
Average (excluding the first number): 1160046.402182
新版本沿符号执行
1160046.4021823534
新版本默认执行
1160046.4021823534
旧版本
1194366.7211882344
新旧版本比较（沿符号执行）
-0.028735160145568074
新旧版本比较（默认执行）
-0.028735160145568074
 
 
modified part:
Average end to end: 1157090.416971
Average modified part: 17726.360818
0.015319771521448568
 
 
icount diff
``` 
# PT- 695126cccef67ddf4591da970b62b1efe175ac7c
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2506.140557
Average (excluding the first number): 2435.681829
Average (excluding the first number): 2506.140557
新版本沿符号执行
2506.140557142857
新版本默认执行
2506.140557142857
旧版本
2435.6818285714294
新旧版本比较（沿符号执行）
0.02892772272015212
新旧版本比较（默认执行）
0.02892772272015212
 
 
modified part:
Average end to end: 2434.700000
Average modified part: 6.171314
0.0025347329386430717
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第2次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 53.099360
Average (excluding the first number): 53.298960
Average (excluding the first number): 53.099360
新版本沿符号执行
53.09935965356991
新版本默认执行
53.09935965356991
旧版本
53.298960094891136
新旧版本比较（沿符号执行）
-0.003744921870255319
新旧版本比较（默认执行）
-0.003744921870255319
 
 
modified part:
Average end to end: 52.287400
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
# AT- 032357ec0f138454e9878c305b4fca71aaad8088
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2738.011886
Average (excluding the first number): 2568.954029
Average (excluding the first number): 2738.011886
新版本沿符号执行
2738.011885714287
新版本默认执行
2738.011885714287
旧版本
2568.9540285714284
新旧版本比较（沿符号执行）
0.06580805077188173
新旧版本比较（默认执行）
0.06580805077188173
 
 
modified part:
Average end to end: 2834.353100
Average modified part: 5.096629
0.0017981628934759658
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
# NT- ee933d9e2b787223effd5afc815897121b1c6575

# PT- 3f06ddfb7b1877daca3f4a7289be1f1be5266182
## 第1次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.253760
Average (excluding the first number): 6.390337
Average (excluding the first number): 6.584419
新版本沿符号执行
6.253759865524693
新版本默认执行
6.584418707497184
旧版本
6.390336635311746
新旧版本比较（沿符号执行）
-0.02137239046724959
新旧版本比较（默认执行）
0.03037118124778881
 
 
modified part:
Average end to end: 6.559534
Average modified part: 6.399646
0.9756251290120367
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
# AB- 658424fc8367186181123b6f3a770786afcefc15
getFuncName.txt文件为空

# PT- d7a448f9aebe9ac33997a433b06f14023bdd733a
## 第1次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.217772
Average (excluding the first number): 6.495607
Average (excluding the first number): 6.354357
新版本沿符号执行
6.217772481474063
新版本默认执行
6.354356659707725
旧版本
6.4956069341020095
新旧版本比较（沿符号执行）
-0.042772670120987795
新旧版本比较（默认执行）
-0.0217455082838709
 
 
modified part:
Average end to end: 6.389678
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AT- 1848809f669ea538eb283f496ad6d8d7983d503f
## 第1次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.890817
Average (excluding the first number): 6.287769
Average (excluding the first number): 8.034479
新版本沿符号执行
6.8908169519832985
新版本默认执行
8.034478616090038
旧版本
6.287769266208745
新旧版本比较（沿符号执行）
0.09590804945967198
新旧版本比较（默认执行）
0.2777947593065042
 
 
modified part:
Average end to end: 12.843880
Average modified part: 6.013524
0.4682015355739907
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
# PT- 0200e8ada63ddff5d5a7413ff481bf8f1d5465ba
## 第1次符号执行
./redis/app/bin/redis-cli GETSET key:2341 fwegbfueho2jofrh32i

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.509756
Average (excluding the first number): 2.434459
Average (excluding the first number): 2.403385
新版本沿符号执行
2.5097555942317253
新版本默认执行
2.4033847880999155
旧版本
2.434458957192128
新旧版本比较（沿符号执行）
0.03092951590625436
新旧版本比较（默认执行）
-0.01276430189977531
 
 
modified part:
Average end to end: 2.543562
Average modified part: 0.308762
0.1213896098639119
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第2次符号执行
./redis/app/bin/redis-cli MOVE key:267 8

新版本timeout
旧版本timeout
## 第3次符号执行
./redis/app/bin/redis-cli BLPOP key_list:1 key_list:999 key_list:23 key_list:98 key_list:1283 key_list:9999 key_list:123 key_list:8765 0

新版本timeout
旧版本timeout
## 第4次符号执行
./redis/app/bin/redis-cli --cluster check 127.0.0.1:6379

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 32.212082
Average (excluding the first number): 40.523333
Average (excluding the first number): 35.950686
新版本沿符号执行
32.21208171234276
新版本默认执行
35.950686444425855
旧版本
40.52333252438791
新旧版本比较（沿符号执行）
-0.20509791012482112
新旧版本比较（默认执行）
-0.11283983313095308
 
 
modified part:
Average end to end: 39.896634
Average modified part: 2.566503
0.0643288169585028
 
 
icount diff
``` 
不幂等
## 第5次符号执行
./redis/app/bin/redis-cli BLPOP key_list:1 key_list:999 key_list:23 key_list:98 key_list:1283 key_list:9999 key_list:123 key_list:8765 0

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 4.675268
Average (excluding the first number): 4.769368
Average (excluding the first number): 4.636322
新版本沿符号执行
4.675267743514439
新版本默认执行
4.636321520539546
旧版本
4.769367860958172
新旧版本比较（沿符号执行）
-0.01973010264400704
新旧版本比较（默认执行）
-0.027896011441628822
 
 
modified part:
Average end to end: 4.817132
Average modified part: 0.090618
0.018811546132926002
 
 
icount diff
``` 
## 第6次符号执行
./redis/app/bin/redis-cli PFADD key_HyperLogLog:9999999 gwuvgewubgvwe qiwghfdiqeghfiuwehbf qiwhfdiqwhfiqjehfieqhf qwifhqeifhewifhneiwhfewi qifhweihfbewikhfnvikewhfniwek qfheikfnewknfkqenfkqe qeifhqeifknewkfnewkqnfq ejfgbweijfbweknfwekqebfue qbfwjqebfewjbnvikwen qefbeiwnfiwkebnfwe

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.791497
Average (excluding the first number): 2.518678
Average (excluding the first number): 2.678745
新版本沿符号执行
2.7914966039599887
新版本默认执行
2.6787447679708825
旧版本
2.5186780908240842
新旧版本比较（沿符号执行）
0.10831813486996314
新旧版本比较（默认执行）
0.0635518598942615
 
 
modified part:
Average end to end: 3.060761
Average modified part: 2.071908
0.6769259077050886
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第7次符号执行
./redis/app/bin/redis-cli MOVE key:267 8

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1.367867
Average (excluding the first number): 1.248299
Average (excluding the first number): 1.346956
新版本沿符号执行
1.36786651719582
新版本默认执行
1.3469564190811592
旧版本
1.2482989985118451
新旧版本比较（沿符号执行）
0.09578435841614615
新旧版本比较（默认执行）
0.079033485316361
 
 
modified part:
Average end to end: 1.302308
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
不幂等
## 第8次符号执行
./redis/app/bin/redis-cli DEBUG RELOAD NOSAVE NOFLUSH MERGE

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1182480.543806
Average (excluding the first number): 1162259.520112
Average (excluding the first number): 1169855.257465
新版本沿符号执行
1182480.5438058819
新版本默认执行
1169855.2574647055
旧版本
1162259.5201117634
新旧版本比较（沿符号执行）
0.017398028017162656
新旧版本比较（默认执行）
0.006535319540520268
 
 
modified part:
Average end to end: 1153567.797076
Average modified part: 2074.905212
0.0017986851028810055
 
 
icount diff
``` 
## 第9次符号执行
./redis/app/bin/redis-cli PFMERGE key_HyperLogLog:888 key_HyperLogLog:12 key_HyperLogLog:9987 key_HyperLogLog:1 key_HyperLogLog:876 key_HyperLogLog:13 key_HyperLogLog:438 key_HyperLogLog:2355 key_HyperLogLog:3 key_HyperLogLog:5623

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2277.154852
Average (excluding the first number): 2577.803965
Average (excluding the first number): 2607.808383
新版本沿符号执行
2277.1548519646044
新版本默认执行
2607.8083831089352
旧版本
2577.8039652191637
新旧版本比较（沿符号执行）
-0.11662993668682571
新旧版本比较（默认执行）
0.011639526625997931
 
 
modified part:
Average end to end: 1554.182795
Average modified part: 1545.596639
0.9944754529043023
 
 
icount diff
``` 
# PT- 985bf68f3475e691bc50b340055a497715d57ad3
## 第1次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2.859036
Average (excluding the first number): 2.961807
Average (excluding the first number): 2.859036
新版本沿符号执行
2.8590361886745894
新版本默认执行
2.8590361886745894
旧版本
2.961806676223633
新旧版本比较（沿符号执行）
-0.03469858055694505
新旧版本比较（默认执行）
-0.03469858055694505
 
 
modified part:
Average end to end: 3.765696
Average modified part: 0.215634
0.05726275175238746
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --enable-debug-command yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1166876.961929
Average (excluding the first number): 1129144.134100
Average (excluding the first number): 1166876.961929
新版本沿符号执行
1166876.9619285713
新版本默认执行
1166876.9619285713
旧版本
1129144.1340999997
新旧版本比较（沿符号执行）
0.033417193331697334
新旧版本比较（默认执行）
0.033417193331697334
 
 
modified part:
Average end to end: 1126111.023743
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
## 第3次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 3.019350
Average (excluding the first number): 3.000889
Average (excluding the first number): 3.019350
新版本沿符号执行
3.019350305417136
新版本默认执行
3.019350305417136
旧版本
3.000889450867052
新旧版本比较（沿符号执行）
0.006151794277110009
新旧版本比较（默认执行）
0.006151794277110009
 
 
modified part:
Average end to end: 4.188364
Average modified part: 0.196046
0.04680725409773969
 
 
icount diff
``` 
## 第4次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.999529
Average (excluding the first number): 3.229970
Average (excluding the first number): 3.130569
新版本沿符号执行
2.9995287126335586
新版本默认执行
3.130568792635818
旧版本
3.229970154649528
新旧版本比较（沿符号执行）
-0.0713447589242427
新旧版本比较（默认执行）
-0.030774699843780954
 
 
modified part:
Average end to end: 3.667783
Average modified part: 0.216413
0.05900367555498593
 
 
icount diff
``` 
## 第5次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --enable-debug-command yes

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1127190.843214
Average (excluding the first number): 1114673.835071
Average (excluding the first number): 1125085.557971
新版本沿符号执行
1127190.8432142858
新版本默认执行
1125085.557971429
旧版本
1114673.8350714287
新旧版本比较（沿符号执行）
0.011229301118434362
新旧版本比较（默认执行）
0.009340600427149359
 
 
modified part:
Average end to end: 1128873.379971
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第6次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.637711
Average (excluding the first number): 3.124696
Average (excluding the first number): 3.043523
新版本沿符号执行
2.637710515647803
新版本默认执行
3.043522750983067
旧版本
3.1246961339571535
新旧版本比较（沿符号执行）
-0.15585055231998704
新旧版本比较（默认执行）
-0.02597800857880136
 
 
modified part:
Average end to end: 2.691984
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第7次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --enable-debug-command yes

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1121896.184886
Average (excluding the first number): 1116385.901657
Average (excluding the first number): 1122301.341200
新版本沿符号执行
1121896.1848857142
新版本默认执行
1122301.3412000004
旧版本
1116385.9016571427
新旧版本比较（沿符号执行）
0.004935823016389014
新旧版本比较（默认执行）
0.0052987408154088365
 
 
modified part:
Average end to end: 1123384.433071
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第8次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.716693
Average (excluding the first number): 6.869757
Average (excluding the first number): 6.659122
新版本沿符号执行
6.716693049383752
新版本默认执行
6.659122392601192
旧版本
6.869756734252051
新旧版本比较（沿符号执行）
-0.022280801313551063
新旧版本比较（默认执行）
-0.03066110632428259
 
 
modified part:
Average end to end: 8.535890
Average modified part: 2.574827
0.3016472100510137
 
 
icount diff
``` 
## 第9次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 3.004642
Average (excluding the first number): 2.998475
Average (excluding the first number): 3.033363
新版本沿符号执行
3.0046418826188748
新版本默认执行
3.0333628934868373
旧版本
2.998474596725533
新旧版本比较（沿符号执行）
0.002056807784890648
新旧版本比较（默认执行）
0.011635348453311566
 
 
modified part:
Average end to end: 2.851614
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# NT- 33f03f6fc8d9356d6fbab65fba9ce4e995d22511

# AB- f1d6542b1a38c45079b87264b35f054fc1f0e408
getFuncName.txt文件为空

# NT- 7939ba031de7bef64b1d6b3436b0179799061480

# NT- f364dcca2d8288dae95fffd3eba6f8b7ac6c01ee

# AB- 557e0b1c07a70af329626ff8f9ad7baf4c6f6e02
getFuncName.txt文件为空

# AB- b704179f158feef916cca9ba1907a1d0e817886c
getFuncName.txt文件为空

# AB- 752576ce4700465b304cbaff7749706e9d4c5a89
getFuncName.txt文件为空

# NT- a5a3afd923f5899c34d1a73053e61d5e1c6a1c0c

# NT- 26dcec4812ecddcf4111ac031f57f544b0ca6987

# PT- 3e012c9260cff54c1e0b910b02e067138b8140c0
## 第1次符号执行
./redis/app/bin/redis-cli ZADD key_SortSet:34 3 wegfuweb 5 wefbewifb 6 weihfiewhfiwe 3 wrugwirh 6 wefhweih 1 fwifghrwihf 3 weeifheiwrhi 4 ewufherwihvir 1 fewhfwiehve 6 wifhwrihi

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 5.629826
Average (excluding the first number): 3.965476
Average (excluding the first number): 3.987159
新版本沿符号执行
5.629825798925045
新版本默认执行
3.9871591696929687
旧版本
3.9654756198689776
新旧版本比较（沿符号执行）
0.4197101025452928
新旧版本比较（默认执行）
0.00546808300001793
 
 
modified part:
Average end to end: 6.635475
Average modified part: 2.569249
0.38719903879553763
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
# PT- 951ec796548311e0a460136c8729e38409b5df89
## 第1次符号执行
./redis/app/bin/redis-cli MOVE key:267 8

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1.313280
Average (excluding the first number): 1.338414
Average (excluding the first number): 1.313280
新版本沿符号执行
1.3132797155026923
新版本默认执行
1.3132797155026923
旧版本
1.3384143389572396
新旧版本比较（沿符号执行）
-0.018779403898294852
新旧版本比较（默认执行）
-0.018779403898294852
 
 
modified part:
Average end to end: 1.354637
Average modified part: 0.323650
0.23891977153590946
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 53.863693
Average (excluding the first number): 55.311722
Average (excluding the first number): 53.863693
新版本沿符号执行
53.86369327214619
新版本默认执行
53.86369327214619
旧版本
55.31172181279119
新旧版本比较（沿符号执行）
-0.0261794153786428
新旧版本比较（默认执行）
-0.0261794153786428
 
 
modified part:
Average end to end: 53.958538
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第3次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 6.721673
Average (excluding the first number): 6.692086
Average (excluding the first number): 6.721673
新版本沿符号执行
6.721673084166911
新版本默认执行
6.721673084166911
旧版本
6.692086142622359
新旧版本比较（沿符号执行）
0.004421183606127019
新旧版本比较（默认执行）
0.004421183606127019
 
 
modified part:
Average end to end: 6.641081
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第4次符号执行
./redis/app/bin/redis-cli CONFIG RESETSTAT

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 15.736906
Average (excluding the first number): 14.190508
Average (excluding the first number): 15.736906
新版本沿符号执行
15.736905816592417
新版本默认执行
15.736905816592417
旧版本
14.190507944514502
新旧版本比较（沿符号执行）
0.10897410283862966
新旧版本比较（默认执行）
0.10897410283862966
 
 
modified part:
Average end to end: 16.383844
Average modified part: 0.103884
0.006340619624422632
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第5次符号执行
./redis/app/bin/redis-cli EVAL "local function luaCallFunction(a, b) return a + b end return luaCallFunction(tonumber(ARGV[1]), tonumber(ARGV[2]))" 0 5 3

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 3.127754
Average (excluding the first number): 2.908193
Average (excluding the first number): 2.909423
新版本沿符号执行
3.1277541504914517
新版本默认执行
2.90942294428055
旧版本
2.9081933006807237
新旧版本比较（沿符号执行）
0.07549733704404558
新旧版本比较（默认执行）
0.0004228204499124672
 
 
modified part:
Average end to end: 3.155433
Average modified part: 1.031274
0.326825000639247
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第6次符号执行
./redis/app/bin/redis-cli INFO stats

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 14.236522
Average (excluding the first number): 14.174976
Average (excluding the first number): 14.298288
新版本沿符号执行
14.236521968440305
新版本默认执行
14.29828782583063
旧版本
14.17497647914646
新旧版本比较（沿符号执行）
0.004341840664384024
新旧版本比较（默认执行）
0.008699227604756884
 
 
modified part:
Average end to end: 14.230014
Average modified part: 11.555928
0.8120812706298798
 
 
icount diff
``` 
## 第7次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 53.702521
Average (excluding the first number): 54.469181
Average (excluding the first number): 54.093228
新版本沿符号执行
53.70252138640107
新版本默认执行
54.09322799633272
旧版本
54.46918063583816
新旧版本比较（沿符号执行）
-0.01407510156179336
新旧版本比较（默认执行）
-0.006902116667018046
 
 
modified part:
Average end to end: 53.642375
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
# AB- cb02bd190b64a683346111608b19e728477649f9
getFuncName.txt文件为空

# AT- 427c36888e1a0896dbbc830873ac6935a8019d41
## 第1次符号执行
./redis/app/bin/redis-cli RANDOMKEY

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 3.442595
Average (excluding the first number): 3.544745
Average (excluding the first number): 3.490762
新版本沿符号执行
3.4425945765818304
新版本默认执行
3.490762220346138
旧版本
3.5447445206343864
新旧版本比较（沿符号执行）
-0.028817293731023146
新旧版本比较（默认执行）
-0.015228826781171666
 
 
modified part:
Average end to end: 4.440519
Average modified part: 3.170851
0.7140721845249699
 
 
icount diff
``` 
# NT- 87b7c3ac1a661e7c23164659ce30dd1df29adf9d

# AT- 319bbcc1a780b836889a71b80313e039140b11d1
## 第1次符号执行
./redis/app/bin/redis-cli INFO stats

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 14.217238
Average (excluding the first number): 14.279141
Average (excluding the first number): 14.247247
新版本沿符号执行
14.217237764028162
新版本默认执行
14.24724672897196
旧版本
14.279140508157717
新旧版本比较（沿符号执行）
-0.00433518698791353
新旧版本比较（默认执行）
-0.0022335923627570635
 
 
modified part:
Average end to end: 14.250187
Average modified part: 11.663144
0.8184555322066884
 
 
icount diff
``` 
# AT- 2a189709e098139b3158575ee6cb6d7ff266ed45
## 第1次符号执行
./redis/app/bin/redis-cli DECRBY test_DECR 345

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1.671631
Average (excluding the first number): 1.697728
Average (excluding the first number): 1.671631
新版本沿符号执行
1.6716313194082508
新版本默认执行
1.6716313194082508
旧版本
1.6977281261282946
新旧版本比较（沿符号执行）
-0.015371605334452521
新旧版本比较（默认执行）
-0.015371605334452521
 
 
modified part:
Average end to end: 1.685156
Average modified part: 0.339206
0.20129051967949557
 
 
icount diff
``` 
# AB- 981aa5c12f60d5efd37cc1248a4c59834d552447
getFuncName.txt文件为空

# NT- a0da8390a28a92e7068fef7a00ebc9b767e70500

# NT- 87d8e717087293073b676565b2cd3c0a094543bb

# AB- 057f039c4b762b3721c2aa2beb95838bd529313e
getFuncName.txt文件为空

# NT- aa8e2d171232218364857ee8528f1af092b9e5b7

# PT- 366c6aff818a0f311e40f7f09d7f972b3c487e7c
## 第1次符号执行
./redis/app/bin/redis-cli INFO memory

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 19.505428
Average (excluding the first number): 19.725061
Average (excluding the first number): 19.505428
新版本沿符号执行
19.50542787013737
新版本默认执行
19.50542787013737
旧版本
19.72506086146288
新旧版本比较（沿符号执行）
-0.011134718055780892
新旧版本比较（默认执行）
-0.011134718055780892
 
 
modified part:
Average end to end: 19.277869
Average modified part: 17.085503
0.886275456834407
 
 
icount diff
``` 
# AB- 1c646662e9d131a65118885b155430d15d8d4e1f
getFuncName.txt文件为空

# AB- 8ea8f4220c393d496aa948b5ebe288f384392899
getFuncName.txt文件为空


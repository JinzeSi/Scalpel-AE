# PT- 701f06657d20ec42f0cf78de0ac9d7197e44c00c
## 第1次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 6.720175
Average (excluding the first number): 6.573125
Average (excluding the first number): 6.720175
新版本沿符号执行
6.720174849699399
新版本默认执行
6.720174849699399
旧版本
6.573124853703395
新旧版本比较（沿符号执行）
0.022371398576607554
新旧版本比较（默认执行）
0.022371398576607554
 
 
modified part:
Average end to end: 6.576516
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
## 第2次符号执行
./redis/app/bin/redis-cli DEBUG RELOAD NOSAVE NOFLUSH MERGE

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1212400.953871
Average (excluding the first number): 1210750.157853
Average (excluding the first number): 1212400.953871
新版本沿符号执行
1212400.953870588
新版本默认执行
1212400.953870588
旧版本
1210750.1578529412
新旧版本比较（沿符号执行）
0.0013634489386102535
新旧版本比较（默认执行）
0.0013634489386102535
 
 
modified part:
Average end to end: 1201645.910035
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.507819
Average (excluding the first number): 6.548096
Average (excluding the first number): 6.676736
新版本沿符号执行
6.507818546198488
新版本默认执行
6.676736448676188
旧版本
6.54809576427256
新旧版本比较（沿符号执行）
-0.006150981831058593
新旧版本比较（默认执行）
0.019645510547587234
 
 
modified part:
Average end to end: 6.384058
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第4次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 3.005129
Average (excluding the first number): 3.290108
Average (excluding the first number): 3.504072
新版本沿符号执行
3.0051288923126824
新版本默认执行
3.5040719977575785
旧版本
3.2901079804493367
新旧版本比较（沿符号执行）
-0.08661694079041568
新旧版本比较（默认执行）
0.06503252129707314
 
 
modified part:
Average end to end: 2.989099
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
无占比
## 第5次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.627023
Average (excluding the first number): 6.571110
Average (excluding the first number): 6.698810
新版本沿符号执行
6.627023128398159
新版本默认执行
6.6988103758204085
旧版本
6.571109910285834
新旧版本比较（沿符号执行）
0.008508945806065938
新旧版本比较（默认执行）
0.019433621911373506
 
 
modified part:
Average end to end: 6.472519
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# PT- 5b84dc967855eaecd90550584608145037d88ac6
## 第1次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 53.275182
Average (excluding the first number): 53.208601
Average (excluding the first number): 53.352895
新版本沿符号执行
53.27518160377359
新版本默认执行
53.35289538732248
旧版本
53.20860060022508
新旧版本比较（沿符号执行）
0.0012513203278686669
新旧版本比较（默认执行）
0.0027118696126126546
 
 
modified part:
Average end to end: 51.800891
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第2次符号执行
./redis/app/bin/redis-cli MODULE UNLOAD panda

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 11.643391
Average (excluding the first number): 11.606723
Average (excluding the first number): 11.706241
新版本沿符号执行
11.64339076571815
新版本默认执行
11.706241310267501
旧版本
11.606723174872668
新旧版本比较（沿符号执行）
0.00315916820734243
新旧版本比较（默认执行）
0.008574180145028285
 
 
modified part:
Average end to end: 12.565752
Average modified part: 9.880431
0.7862984024147784
 
 
icount diff
``` 
# PT- 79fd2558284df54b65b839c2edb5dcb875a5e00c
## 第1次符号执行
./redis/app/bin/redis-cli INFO memory

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 19.493691
Average (excluding the first number): 18.833368
Average (excluding the first number): 19.493691
新版本沿符号执行
19.493691468704814
新版本默认执行
19.493691468704814
旧版本
18.83336821038306
新旧版本比较（沿符号执行）
0.03506134701692442
新旧版本比较（默认执行）
0.03506134701692442
 
 
modified part:
Average end to end: 19.547834
Average modified part: 0.591320
0.03024991148230524
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第2次符号执行
./redis/app/bin/redis-cli INFO memory

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 19.629301
Average (excluding the first number): 19.250586
Average (excluding the first number): 19.493104
新版本沿符号执行
19.62930072099262
新版本默认执行
19.493103680619896
旧版本
19.25058625561978
新旧版本比较（沿符号执行）
0.019672879586318255
新旧版本比较（默认执行）
0.012597924124483156
 
 
modified part:
Average end to end: 19.374985
Average modified part: 16.976780
0.8762215586054991
 
 
icount diff
``` 
## 第3次符号执行
./redis/app/bin/redis-cli INFO memory

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 19.659467
Average (excluding the first number): 19.499034
Average (excluding the first number): 19.437406
新版本沿符号执行
19.659466623766626
新版本默认执行
19.43740603862766
旧版本
19.49903434861778
新旧版本比较（沿符号执行）
0.008227703602164205
新旧版本比较（默认执行）
-0.0031605826672379913
 
 
modified part:
Average end to end: 19.503980
Average modified part: 0.589685
0.030234070889796537
 
 
icount diff
``` 
# PT- 155634502d15adde8b55f1f6d1f93101f76986a7
## 第1次符号执行
./redis/app/bin/redis-cli MODULE UNLOAD panda

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 11.861454
Average (excluding the first number): 12.506241
Average (excluding the first number): 11.861454
新版本沿符号执行
11.861453675145203
新版本默认执行
11.861453675145203
旧版本
12.506241260561406
新旧版本比较（沿符号执行）
-0.05155726424769603
新旧版本比较（默认执行）
-0.05155726424769603
 
 
modified part:
Average end to end: 12.360724
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第2次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 53.487945
Average (excluding the first number): 52.095909
Average (excluding the first number): 53.487945
新版本沿符号执行
53.48794505447554
新版本默认执行
53.48794505447554
旧版本
52.09590894595502
新旧版本比较（沿符号执行）
0.026720641537604003
新旧版本比较（默认执行）
0.026720641537604003
 
 
modified part:
Average end to end: 50.254073
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
## 第3次符号执行
./redis/app/bin/redis-cli MODULE UNLOAD panda

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 12.419984
Average (excluding the first number): 11.998939
Average (excluding the first number): 12.419984
新版本沿符号执行
12.41998430053266
新版本默认执行
12.41998430053266
旧版本
11.998939467991347
新旧版本比较（沿符号执行）
0.03509017056586556
新旧版本比较（默认执行）
0.03509017056586556
 
 
modified part:
Average end to end: 12.182613
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
不幂等
## 第4次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1122502.432043
Average (excluding the first number): 1101083.100486
Average (excluding the first number): 1098681.935357
新版本沿符号执行
1122502.4320428576
新版本默认执行
1098681.9353571427
旧版本
1101083.1004857142
新旧版本比较（沿符号执行）
0.019452965491609943
新旧版本比较（默认执行）
-0.0021807301624302794
 
 
modified part:
Average end to end: 1108593.839014
Average modified part: 1.195371
1.0782771710460714e-06
 
 
icount diff
``` 
## 第5次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本timeout
旧版本timeout
## 第6次符号执行
./redis/app/bin/redis-cli MODULE UNLOAD panda

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 12.233218
Average (excluding the first number): 12.611929
Average (excluding the first number): 12.059606
新版本沿符号执行
12.23321829180354
新版本默认执行
12.05960564341334
旧版本
12.611928740236332
新旧版本比较（沿符号执行）
-0.03002795656659369
新旧版本比较（默认执行）
-0.04379370580019959
 
 
modified part:
Average end to end: 12.218880
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第7次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1094240.552900
Average (excluding the first number): 1102200.136600
Average (excluding the first number): 1094804.375929
新版本沿符号执行
1094240.5529000002
新版本默认执行
1094804.375928572
旧版本
1102200.1365999999
新旧版本比较（沿符号执行）
-0.0072215412026284545
新旧版本比较（默认执行）
-0.006709997963021429
 
 
modified part:
Average end to end: 1101580.951729
Average modified part: 1.042157
9.460558856086045e-07
 
 
icount diff
``` 
## 第8次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 52.641321
Average (excluding the first number): 52.304869
Average (excluding the first number): 50.988970
新版本沿符号执行
52.64132089145825
新版本默认执行
50.98897039362063
旧版本
52.304869441895384
新旧版本比较（沿符号执行）
0.006432507205407018
新旧版本比较（默认执行）
-0.02515825127403409
 
 
modified part:
Average end to end: 49.394432
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第9次符号执行
./redis/app/bin/redis-cli CONFIG GET panda.string

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.603672
Average (excluding the first number): 2.587923
Average (excluding the first number): 2.577164
新版本沿符号执行
2.603672148859544
新版本默认执行
2.5771644006939125
旧版本
2.5879225129145143
新旧版本比较（沿符号执行）
0.006085822070187227
新旧版本比较（默认执行）
-0.004157045725641135
 
 
modified part:
Average end to end: 2.580532
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第10次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 1103706.031171
Average (excluding the first number): 1099585.845729
新版本沿符号执行
-0.0
新版本默认执行
1099585.8457285718
旧版本
1103706.0311714283
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
-0.003733046052564846
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
无占比
## 第11次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1108847.373600
Average (excluding the first number): 1093517.864443
Average (excluding the first number): 1126172.842243
新版本沿符号执行
1108847.3735999998
新版本默认执行
1126172.8422428574
旧版本
1093517.8644428572
新旧版本比较（沿符号执行）
0.014018526496549668
新旧版本比较（默认执行）
0.02986231762810551
 
 
modified part:
Average end to end: 1098671.297086
Average modified part: 1.004357
9.141561680197308e-07
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
## 第12次符号执行
./redis/app/bin/redis-cli MODULE UNLOAD panda

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 12.196833
Average (excluding the first number): 12.420225
Average (excluding the first number): 12.279982
新版本沿符号执行
12.196832517847115
新版本默认执行
12.279981821821822
旧版本
12.420224683925346
新旧版本比较（沿符号执行）
-0.017986161423259282
新旧版本比较（默认执行）
-0.011291491552888755
 
 
modified part:
Average end to end: 12.296768
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第13次符号执行
./redis/app/bin/redis-cli CONFIG GET panda.string

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.599385
Average (excluding the first number): 2.597903
Average (excluding the first number): 2.566945
新版本沿符号执行
2.5993845845042154
新版本默认执行
2.566945184153386
旧版本
2.5979026335831965
新旧版本比较（沿符号执行）
0.0005704412866986007
新旧版本比较（默认执行）
-0.011916323972123648
 
 
modified part:
Average end to end: 2.716288
Average modified part: 0.131272
0.048327623523257625
 
 
icount diff
``` 
## 第14次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 52.671631
Average (excluding the first number): 53.201815
Average (excluding the first number): 53.386317
新版本沿符号执行
52.671630905965706
新版本默认执行
53.3863171129707
旧版本
53.20181493187545
新旧版本比较（沿符号执行）
-0.009965525172188905
新旧版本比较（默认执行）
0.0034679678001870475
 
 
modified part:
Average end to end: 51.216285
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第15次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 54.059877
Average (excluding the first number): 53.198965
Average (excluding the first number): 52.060375
新版本沿符号执行
54.05987710193066
新版本默认执行
52.060375036797176
旧版本
53.198965495423295
新旧版本比较（沿符号执行）
0.016182863679584693
新旧版本比较（默认执行）
-0.021402492473731882
 
 
modified part:
Average end to end: 51.109426
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第16次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 51.881065
Average (excluding the first number): 53.498021
Average (excluding the first number): 52.777324
新版本沿符号执行
51.88106484792479
新版本默认执行
52.77732400601403
旧版本
53.498021082692865
新旧版本比较（沿符号执行）
-0.030224599004675643
新旧版本比较（默认执行）
-0.013471471693594875
 
 
modified part:
Average end to end: 52.277259
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第17次符号执行
./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 1101652.973771
Average (excluding the first number): 1077784.769057
新版本沿符号执行
-0.0
新版本默认执行
1077784.769057143
旧版本
1101652.973771429
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
-0.021665810634155368
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
无占比
## 第18次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 53.880405
Average (excluding the first number): 52.898452
Average (excluding the first number): 52.861084
新版本沿符号执行
53.88040528995513
新版本默认执行
52.86108440812157
旧版本
52.898451876784115
新旧版本比较（沿符号执行）
0.018562989621289258
新旧版本比较（默认执行）
-0.0007064000426625836
 
 
modified part:
Average end to end: 53.136329
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第19次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 53.739411
Average (excluding the first number): 52.705297
Average (excluding the first number): 52.413452
新版本沿符号执行
53.73941088338033
新版本默认执行
52.41345152261999
旧版本
52.705297017294676
新旧版本比较（沿符号执行）
0.01962068187845182
新旧版本比较（默认执行）
-0.005537308604463858
 
 
modified part:
Average end to end: 52.439158
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第20次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 52.225096
Average (excluding the first number): 53.187642
Average (excluding the first number): 52.327330
新版本沿符号执行
52.22509648200566
新版本默认执行
52.32732990258366
旧版本
53.18764205457463
新旧版本比较（沿符号执行）
-0.01809716572096436
新旧版本比较（默认执行）
-0.016175038387831298
 
 
modified part:
Average end to end: 53.529474
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
# PT- 9ebf80a28c3ba12e9aedc7cee145637d1ed2ab5a
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2776.748457
Average (excluding the first number): 2902.786943
Average (excluding the first number): 2776.748457
新版本沿符号执行
2776.7484571428568
新版本默认执行
2776.7484571428568
旧版本
2902.786942857143
新旧版本比较（沿符号执行）
-0.043419819709616586
新旧版本比较（默认执行）
-0.043419819709616586
 
 
modified part:
Average end to end: 2864.557086
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第2次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2707.131257
Average (excluding the first number): 2978.378800
Average (excluding the first number): 2707.131257
新版本沿符号执行
2707.131257142857
新版本默认执行
2707.131257142857
旧版本
2978.3787999999995
新旧版本比较（沿符号执行）
-0.09107221111604155
新旧版本比较（默认执行）
-0.09107221111604155
 
 
modified part:
Average end to end: 3045.917843
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AB- 05b99c8f4cca9a5439c54888cf275f8447cd3c31
getFuncName.txt文件为空

# AT- a106198878f85b91de651dde74587768e81d4506
## 第1次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 3.090596
Average (excluding the first number): 3.076517
Average (excluding the first number): 3.019536
新版本沿符号执行
3.090596442331339
新版本默认执行
3.019536163900249
旧版本
3.0765165970101274
新旧版本比较（沿符号执行）
0.0045765543195491745
新旧版本比较（默认执行）
-0.018521087506972702
 
 
modified part:
Average end to end: 3.548854
Average modified part: 0.580497
0.16357318557913483
 
 
icount diff
``` 
# AB- db33b67d372c7d7b9977e9b1fef86730ac79ceb7
getFuncName.txt文件为空

# PT- 06b144aa097e968f579048800cd0e5c9336ea1c9
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2699.289600
Average (excluding the first number): 2529.009514
Average (excluding the first number): 2699.289600
新版本沿符号执行
2699.2895999999996
新版本默认执行
2699.2895999999996
旧版本
2529.0095142857135
新旧版本比较（沿符号执行）
0.06733074144340637
新旧版本比较（默认执行）
0.06733074144340637
 
 
modified part:
Average end to end: 2704.633943
Average modified part: 10.080757
0.0037272168270608736
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
# AT- 2af69a931ab45aad22204763bf93e1050629eede
## 第1次符号执行
./redis/app/bin/redis-cli SDIFF key_set:23 key_set:2345 key_set:9987 key_set:1 key_set:3

新版本timeout
旧版本timeout
# AT- ddafac4c6cef358441ce0ddb9a46a3a0378478d1
## 第1次符号执行
./redis/app/bin/redis-cli ACL genpass

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 11.204301
Average (excluding the first number): 10.828654
Average (excluding the first number): 10.883394
新版本沿符号执行
11.204300786535859
新版本默认执行
10.88339386113463
旧版本
10.828653716892056
新旧版本比较（沿符号执行）
0.03469009901552355
新旧版本比较（默认执行）
0.005055120024494157
 
 
modified part:
Average end to end: 11.570111
Average modified part: 0.659852
0.05703076102187557
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
# PT- 59953d2df62b0e3c4996b8068836591e96349720
## 第1次符号执行
./redis/app/bin/redis-cli ZUNIONSTORE tmp 10 key_SortSet:571 key_SortSet:8922 key_SortSet:23 key_SortSet:5678 key_SortSet:12 key_SortSet:4398 key_SortSet:456 key_SortSet:9546 key_SortSet:71 key_SortSet:897

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 491.224918
Average (excluding the first number): 494.743676
Average (excluding the first number): 496.184637
新版本沿符号执行
491.2249183631922
新版本默认执行
496.1846368373911
旧版本
494.7436761966733
新旧版本比较（沿符号执行）
-0.007112284608731946
新旧版本比较（默认执行）
0.002912539785844608
 
 
modified part:
Average end to end: 527.983419
Average modified part: 15.222716
0.02883180684053766
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli ZUNIONSTORE tmp 10 key_SortSet:571 key_SortSet:8922 key_SortSet:23 key_SortSet:5678 key_SortSet:12 key_SortSet:4398 key_SortSet:456 key_SortSet:9546 key_SortSet:71 key_SortSet:897

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 490.702401
Average (excluding the first number): 494.630317
Average (excluding the first number): 495.526070
新版本沿符号执行
490.70240064193723
新版本默认执行
495.52607045057493
旧版本
494.63031731043185
新旧版本比较（沿符号执行）
-0.007941115881963706
新旧版本比较（默认执行）
0.001810954785411804
 
 
modified part:
Average end to end: 528.835009
Average modified part: 16.937422
0.03202780024285588
 
 
icount diff
``` 
## 第3次符号执行
./redis/app/bin/redis-cli LRANGE test_LRANGE 0 99

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 16.268517
Average (excluding the first number): 16.688342
Average (excluding the first number): 16.024396
新版本沿符号执行
16.26851726761635
新版本默认执行
16.024395902524912
旧版本
16.68834209998797
新旧版本比较（沿符号执行）
-0.025156772905076254
新旧版本比较（默认执行）
-0.03978503038139044
 
 
modified part:
Average end to end: 15.675442
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第4次符号执行
./redis/app/bin/redis-cli LINSERT test_LINSERT AFTER value_list:147 12321423wvhbreijvbn

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.064731
Average (excluding the first number): 7.406156
Average (excluding the first number): 7.814322
新版本沿符号执行
6.064731303329429
新版本默认执行
7.814321842931937
旧版本
7.40615580677457
新旧版本比较（沿符号执行）
-0.18112291159444835
新旧版本比较（默认执行）
0.055111726893999326
 
 
modified part:
Average end to end: 6.632238
Average modified part: 0.273636
0.04125843417251108
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
## 第5次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --enable-debug-command yes

新版本Program terminated
旧版本timeout
## 第6次符号执行
./redis/app/bin/redis-cli HMSET test_HMSET username alice age 30 location Paris HGET_HASH_FIELD1 weugfuwebgfiwebviu HGET_HASH_FIELD2 ewuvbgevhberihvneirn HGET_HASH_FIELD3 weufgewihiwer HGET_HASH_FIELD4 4tvnreiknveir HGET_HASH_FIELD5 23rgwnrighnkwn2 HGET_HASH_FIELD6 23jrb234jbg34ibgi3

新版本timeout
旧版本bootstrap terminated
## 第7次符号执行
./redis/app/bin/redis-cli ZUNIONSTORE tmp 10 key_SortSet:571 key_SortSet:8922 key_SortSet:23 key_SortSet:5678 key_SortSet:12 key_SortSet:4398 key_SortSet:456 key_SortSet:9546 key_SortSet:71 key_SortSet:897

新版本timeout
旧版本bootstrap terminated
## 第8次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本timeout
旧版本bootstrap terminated
## 第9次符号执行
./redis/app/bin/redis-cli HMSET test_HMSET username alice age 30 location Paris HGET_HASH_FIELD1 weugfuwebgfiwebviu HGET_HASH_FIELD2 ewuvbgevhberihvneirn HGET_HASH_FIELD3 weufgewihiwer HGET_HASH_FIELD4 4tvnreiknveir HGET_HASH_FIELD5 23rgwnrighnkwn2 HGET_HASH_FIELD6 23jrb234jbg34ibgi3

新版本timeout
旧版本bootstrap terminated
## 第10次符号执行
./redis/app/bin/redis-cli HMSET test_HMSET username alice age 30 location Paris HGET_HASH_FIELD1 weugfuwebgfiwebviu HGET_HASH_FIELD2 ewuvbgevhberihvneirn HGET_HASH_FIELD3 weufgewihiwer HGET_HASH_FIELD4 4tvnreiknveir HGET_HASH_FIELD5 23rgwnrighnkwn2 HGET_HASH_FIELD6 23jrb234jbg34ibgi3

新版本timeout
旧版本bootstrap terminated
# PT- 0dd057222bd8b156b113e925745d7b2bf9486056
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2547.423343
Average (excluding the first number): 2540.905729
Average (excluding the first number): 2547.423343
新版本沿符号执行
2547.4233428571433
新版本默认执行
2547.4233428571433
旧版本
2540.9057285714275
新旧版本比较（沿符号执行）
0.002565075206225854
新旧版本比较（默认执行）
0.002565075206225854
 
 
modified part:
Average end to end: 2499.910557
Average modified part: 61.128000
0.024452074825374183
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli HSETNX key_hash:12 HGET_HASH_FIELD523432 "foo"

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 4.430310
Average (excluding the first number): 4.400987
Average (excluding the first number): 4.272145
新版本沿符号执行
4.43031006304961
新版本默认执行
4.27214530020704
旧版本
4.400987067706812
新旧版本比较（沿符号执行）
0.006662822428623298
新旧版本比较（默认执行）
-0.029275652374708562
 
 
modified part:
Average end to end: 4.408073
Average modified part: 2.816558
0.6389544361478235
 
 
icount diff
``` 
## 第3次符号执行
./redis/app/bin/redis-cli HMGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD123 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12313 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 89.288733
Average (excluding the first number): 82.028108
Average (excluding the first number): 86.141395
新版本沿符号执行
89.28873279946333
新版本默认执行
86.14139489293677
旧版本
82.02810814223453
新旧版本比较（沿符号执行）
0.08851386215855515
新旧版本比较（默认执行）
0.050144844783813806
 
 
modified part:
Average end to end: 82.382990
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
## 第4次符号执行
./redis/app/bin/redis-cli HMGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD123 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12313 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12

新版本timeout
旧版本timeout
## 第5次符号执行
./redis/app/bin/redis-cli HMGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD123 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12313 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12

新版本timeout
旧版本timeout
## 第6次符号执行
./redis/app/bin/redis-cli HMGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD123 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12313 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 82.044504
Average (excluding the first number): 83.714723
Average (excluding the first number): 86.182939
新版本沿符号执行
82.04450415183867
新版本默认执行
86.1829388938259
旧版本
83.71472282585897
新旧版本比较（沿符号执行）
-0.019951313432580393
新旧版本比较（默认执行）
0.029483655737608416
 
 
modified part:
Average end to end: 82.235385
Average modified part: 77.318437
0.9402088542378176
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
## 第7次符号执行
./redis/app/bin/redis-cli HINCRBYFLOAT key_hash:8765 name 43.132

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 9.408806
Average (excluding the first number): 9.237273
新版本沿符号执行
-0.0
新版本默认执行
9.23727330543933
旧版本
9.408805974538886
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
-0.01823107730818755
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
无占比
## 第8次符号执行
./redis/app/bin/redis-cli HINCRBY key_hash:4 name 1987

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 9.595822
Average (excluding the first number): 9.492596
新版本沿符号执行
-0.0
新版本默认执行
9.49259597998402
旧版本
9.595821757110306
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
-0.010757367085293873
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
无占比
# NT- c51c96656bf1f1801ae90a376f71890cbcdea4b4

# PT- f8942f93a6b156f2b05cd40940b9a23feb68de0c
## 第1次符号执行
./redis/app/bin/redis-cli ZUNIONSTORE tmp 10 key_SortSet:571 key_SortSet:8922 key_SortSet:23 key_SortSet:5678 key_SortSet:12 key_SortSet:4398 key_SortSet:456 key_SortSet:9546 key_SortSet:71 key_SortSet:897

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 497.066774
Average (excluding the first number): 498.871323
Average (excluding the first number): 492.295866
新版本沿符号执行
497.0667741554742
新版本默认执行
492.2958656837659
旧版本
498.87132323026844
新旧版本比较（沿符号执行）
-0.003617263592361865
新旧版本比较（默认执行）
-0.013180668521745148
 
 
modified part:
Average end to end: 550.193472
Average modified part: 97.881175
0.17790319226630863
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.864984
Average (excluding the first number): 6.554583
Average (excluding the first number): 6.659491
新版本沿符号执行
6.8649839690206536
新版本默认执行
6.659491421103663
旧版本
6.554583189528179
新旧版本比较（沿符号执行）
0.0473562956662723
新旧版本比较（默认执行）
0.01600532460143141
 
 
modified part:
Average end to end: 11.508068
Average modified part: 5.843548
0.5077783552237992
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第3次符号执行
./redis/app/bin/redis-cli ZUNIONSTORE tmp 10 key_SortSet:571 key_SortSet:8922 key_SortSet:23 key_SortSet:5678 key_SortSet:12 key_SortSet:4398 key_SortSet:456 key_SortSet:9546 key_SortSet:71 key_SortSet:897

新版本timeout
旧版本timeout
## 第4次符号执行
./redis/app/bin/redis-cli SREM test_set value_set:159 value_set:1 value_set:91 value_set:72 value_set:134 value_set:13 value_set:93 value_set:3

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.128531
Average (excluding the first number): 2.094940
Average (excluding the first number): 2.265829
新版本沿符号执行
2.1285309930035594
新版本默认执行
2.265829159822108
旧版本
2.094940482943035
新旧版本比较（沿符号执行）
0.016034111868102007
新旧版本比较（默认执行）
0.08157209155603476
 
 
modified part:
Average end to end: 3.387747
Average modified part: 0.932995
0.2754029721735458
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
# PT- 684077682e5826ab658da975c9536df1584b425f
## 第1次符号执行
./redis/app/bin/redis-cli PFMERGE key_HyperLogLog:888 key_HyperLogLog:12 key_HyperLogLog:9987 key_HyperLogLog:1 key_HyperLogLog:876 key_HyperLogLog:13 key_HyperLogLog:438 key_HyperLogLog:2355 key_HyperLogLog:3 key_HyperLogLog:5623

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2296.808508
Average (excluding the first number): 2287.278532
Average (excluding the first number): 2280.360742
新版本沿符号执行
2296.808508206712
新版本默认执行
2280.3607422637415
旧版本
2287.278531715344
新旧版本比较（沿符号执行）
0.004166513329804638
新旧版本比较（默认执行）
-0.0030244630707106793
 
 
modified part:
Average end to end: 1639.829449
Average modified part: 1632.034547
0.9952465168848941
 
 
icount diff
``` 
# AB- 1f09a55ebae402f4031d12e2c7c06fb64fdd7ed1
getFuncName.txt文件为空

# AT- 08c2b276fbf8ecb13692449ef9c2cb43aa82ba8e
## 第1次符号执行
./redis/app/bin/redis-cli SDIFF key_set:23 key_set:2345 key_set:9987 key_set:1 key_set:3

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): -0.000000
Average (excluding the first number): -0.000000
新版本沿符号执行
-0.0
新版本默认执行
-0.0
旧版本
-0.0
新旧版本比较（沿符号执行）
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
final-res.txt异常
## 第2次符号执行
./redis/app/bin/redis-cli SDIFF key_set:23 key_set:2345 key_set:9987 key_set:1 key_set:3

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): -0.000000
Average (excluding the first number): -0.000000
新版本沿符号执行
-0.0
新版本默认执行
-0.0
旧版本
-0.0
新旧版本比较（沿符号执行）
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
final-res.txt异常

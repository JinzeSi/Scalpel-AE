# PT- 7665bdc91aa6f98289eefdcbdb2def4467864b7a
## 第1次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 53.350209
Average (excluding the first number): 51.927402
Average (excluding the first number): 53.350209
新版本沿符号执行
53.350209073724
新版本默认执行
53.350209073724
旧版本
51.92740157247326
新旧版本比较（沿符号执行）
0.027399936414399282
新旧版本比较（默认执行）
0.027399936414399282
 
 
modified part:
Average end to end: 51.263524
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
无占比
不幂等
## 第2次符号执行
./redis/app/bin/redis-cli MODULE UNLOAD panda

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 12.470057
Average (excluding the first number): 12.265162
Average (excluding the first number): 12.470057
新版本沿符号执行
12.470056594607724
新版本默认执行
12.470056594607724
旧版本
12.2651623424438
新旧版本比较（沿符号执行）
0.016705384441173254
新旧版本比较（默认执行）
0.016705384441173254
 
 
modified part:
Average end to end: 12.860013
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第3次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 53.071339
Average (excluding the first number): 53.475331
Average (excluding the first number): 53.071339
新版本沿符号执行
53.071338689527416
新版本默认执行
53.071338689527416
旧版本
53.47533058949625
新旧版本比较（沿符号执行）
-0.007554734033718901
新旧版本比较（默认执行）
-0.007554734033718901
 
 
modified part:
Average end to end: 51.549888
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
不幂等
## 第4次符号执行
./redis/app/bin/redis-cli MODULE LOAD ./panda.so

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 52.819650
Average (excluding the first number): 52.905954
Average (excluding the first number): 52.819650
新版本沿符号执行
52.81965041398344
新版本默认执行
52.81965041398344
旧版本
52.90595364376697
新旧版本比较（沿符号执行）
-0.0016312574264257583
新旧版本比较（默认执行）
-0.0016312574264257583
 
 
modified part:
Average end to end: 52.367071
Average modified part: 0.067472
0.0012884524361910924
 
 
icount diff
``` 
## 第5次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.415845
Average (excluding the first number): 6.422739
Average (excluding the first number): 6.431517
新版本沿符号执行
6.415845114040595
新版本默认执行
6.43151691627383
旧版本
6.4227390888287905
新旧版本比较（沿符号执行）
-0.0010733698960598596
新旧版本比较（默认执行）
0.0013666797488796204
 
 
modified part:
Average end to end: 6.296668
Average modified part: 6.159030
0.978141201306586
 
 
icount diff
``` 
## 第6次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.458442
Average (excluding the first number): 6.470138
Average (excluding the first number): 6.403998
新版本沿符号执行
6.458441944606172
新版本默认执行
6.403997745490982
旧版本
6.470138139295811
新旧版本比较（沿符号执行）
-0.001807719470254186
新旧版本比较（默认执行）
-0.010222408298074935
 
 
modified part:
Average end to end: 6.351454
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第7次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.353756
Average (excluding the first number): 6.414401
Average (excluding the first number): 6.416052
新版本沿符号执行
6.353756475601605
新版本默认执行
6.416052199069221
旧版本
6.414400925694271
新旧版本比较（沿符号执行）
-0.009454421511094154
新旧版本比较（默认执行）
0.00025743220513946155
 
 
modified part:
Average end to end: 6.316193
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第8次符号执行
./redis/app/bin/redis-cli HSETNX key_hash:9722 HGET_HASH_FIELD2 "bar"

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 3.121020
Average (excluding the first number): 3.076678
Average (excluding the first number): 3.348082
新版本沿符号执行
3.1210197971602436
新版本默认执行
3.348082445316882
旧版本
3.076677966101695
新旧版本比较（沿符号执行）
0.014412243187977097
新旧版本比较（默认执行）
0.08821348292069374
 
 
modified part:
Average end to end: 3.188302
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
无占比
## 第9次符号执行
./redis/app/bin/redis-cli ZUNIONSTORE tmp 10 key_SortSet:571 key_SortSet:8922 key_SortSet:23 key_SortSet:5678 key_SortSet:12 key_SortSet:4398 key_SortSet:456 key_SortSet:9546 key_SortSet:71 key_SortSet:897

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 493.304754
Average (excluding the first number): 493.543969
Average (excluding the first number): 486.169683
新版本沿符号执行
493.3047538455343
新版本默认执行
486.1696831467912
旧版本
493.54396946349334
新旧版本比较（沿符号执行）
-0.0004846895773421322
新旧版本比较（默认执行）
-0.014941498170301501
 
 
modified part:
Average end to end: 493.410667
Average modified part: 51.734555
0.10485090539489254
 
 
icount diff
``` 
# PT- 8144019a13434717e22c44657064b2ea91863372
## 第1次符号执行
./redis/app/bin/redis-cli HSCAN test_HGET 0 MATCH HGET_HASH_FIELD*2* COUNT 1000

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 67.815895
Average (excluding the first number): 69.851371
Average (excluding the first number): 67.848460
新版本沿符号执行
67.8158947029533
新版本默认执行
67.84845983944271
旧版本
69.8513712316968
新旧版本比较（沿符号执行）
-0.029140108388020496
新旧版本比较（默认执行）
-0.02867390227187438
 
 
modified part:
Average end to end: 95.364300
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AT- dc57ee03b1c5b8f646718e362f3a809a7511ad36
## 第1次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本received segfault
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.273979
Average (excluding the first number): 6.460235
Average (excluding the first number): 6.335093
新版本沿符号执行
6.273978915536142
新版本默认执行
6.33509292146073
旧版本
6.460235375057333
新旧版本比较（沿符号执行）
-0.028831218788144868
新旧版本比较（默认执行）
-0.01937119103736863
 
 
modified part:
Average end to end: 6.402405
Average modified part: 6.217763
0.9711605612388716
 
 
icount diff
``` 
# AT- 04f63d4af74cb5aa0d1e12e05fa8f7f92cb2ef94
## 第1次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.865510
Average (excluding the first number): 2.831570
Average (excluding the first number): 2.941259
新版本沿符号执行
2.8655103821604593
新版本默认执行
2.9412586091046533
旧版本
2.831570005201873
新旧版本比较（沿符号执行）
0.011986416333071268
新旧版本比较（默认执行）
0.038737733378045286
 
 
modified part:
Average end to end: 3.411281
Average modified part: 0.517520
0.1517085269496933
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
# AT- 8e9f5146dd15eb8b934d4fe6c561639c034f78e8
## 第1次符号执行
./redis/app/bin/redis-cli CONFIG RESETSTAT

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 16.798152
Average (excluding the first number): 18.135942
Average (excluding the first number): 16.798152
新版本沿符号执行
16.798152242049397
新版本默认执行
16.798152242049397
旧版本
18.135942415505365
新旧版本比较（沿符号执行）
-0.0737645799047212
新旧版本比较（默认执行）
-0.0737645799047212
 
 
modified part:
Average end to end: 18.086434
Average modified part: 0.823598
0.04553680869355196
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 6.307562
Average (excluding the first number): 6.237073
Average (excluding the first number): 6.307562
新版本沿符号执行
6.307561971067662
新版本默认执行
6.307561971067662
旧版本
6.237073233905669
新旧版本比较（沿符号执行）
0.011301572791995692
新旧版本比较（默认执行）
0.011301572791995692
 
 
modified part:
Average end to end: 6.183114
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 6.398813
Average (excluding the first number): 8.024674
Average (excluding the first number): 6.398813
新版本沿符号执行
6.39881291266193
新版本默认执行
6.39881291266193
旧版本
8.02467366151039
新旧版本比较（沿符号执行）
-0.20260770935106695
新旧版本比较（默认执行）
-0.20260770935106695
 
 
modified part:
Average end to end: 6.234215
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第4次符号执行
./redis/app/bin/redis-cli INFO stats

新版本timeout
旧版本timeout
# PT- 4a12291765c215d8ab9263f533cb9b9c8135729e
## 第1次符号执行
./redis/app/bin/redis-cli PSETEX test_PSETEX 56698 weufgweiuvb23r32

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2.615958
Average (excluding the first number): 2.482511
Average (excluding the first number): 2.615958
新版本沿符号执行
2.6159577159230456
新版本默认执行
2.6159577159230456
旧版本
2.4825105575517785
新旧版本比较（沿符号执行）
0.053754920785864066
新旧版本比较（默认执行）
0.053754920785864066
 
 
modified part:
Average end to end: 2.713821
Average modified part: 1.558734
0.5743688647013944
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第2次符号执行
./redis/app/bin/redis-cli SETRANGE key:3 34 uwvubwivbiebv34ewfgeiwghfbiew

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1.592534
Average (excluding the first number): 1.536136
Average (excluding the first number): 1.592534
新版本沿符号执行
1.5925339347959813
新版本默认执行
1.5925339347959813
旧版本
1.5361363180487024
新旧版本比较（沿符号执行）
0.03671394008763405
新旧版本比较（默认执行）
0.03671394008763405
 
 
modified part:
Average end to end: 1.757040
Average modified part: 0.065939
0.03752832548308658
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第3次符号执行
./redis/app/bin/redis-cli LTRIM key_list:1233 15 32

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 1.290741
Average (excluding the first number): 1.555620
Average (excluding the first number): 1.290741
新版本沿符号执行
1.2907413067019613
新版本默认执行
1.2907413067019613
旧版本
1.5556203718544641
新旧版本比较（沿符号执行）
-0.17027230418481787
新旧版本比较（默认执行）
-0.17027230418481787
 
 
modified part:
Average end to end: 1.413784
Average modified part: 0.443896
0.3139773388901945
 
 
icount diff
``` 
# AT- 08d714d0e5d59f1c1ca37cff1724849220fb6daf
## 第1次符号执行
./redis/app/bin/redis-cli BLPOP key_list:1 key_list:999 key_list:23 key_list:98 key_list:1283 key_list:9999 key_list:123 key_list:8765 0

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 4.581361
Average (excluding the first number): 4.688336
Average (excluding the first number): 4.581361
新版本沿符号执行
4.581360984650095
新版本默认执行
4.581360984650095
旧版本
4.688336031726562
新旧版本比较（沿符号执行）
-0.02281727383714686
新旧版本比较（默认执行）
-0.02281727383714686
 
 
modified part:
Average end to end: 4.879632
Average modified part: 0.324763
0.06655471987079513
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 6.371411
Average (excluding the first number): 6.292912
Average (excluding the first number): 6.371411
新版本沿符号执行
6.371410551518461
新版本默认执行
6.371410551518461
旧版本
6.292912376505898
新旧版本比较（沿符号执行）
0.01247406134330269
新旧版本比较（默认执行）
0.01247406134330269
 
 
modified part:
Average end to end: 6.413847
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-cli ZUNIONSTORE tmp 10 key_SortSet:571 key_SortSet:8922 key_SortSet:23 key_SortSet:5678 key_SortSet:12 key_SortSet:4398 key_SortSet:456 key_SortSet:9546 key_SortSet:71 key_SortSet:897

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 494.248773
Average (excluding the first number): 491.553792
Average (excluding the first number): 488.680003
新版本沿符号执行
494.2487725732268
新版本默认执行
488.68000274215666
旧版本
491.5537921489275
新旧版本比较（沿符号执行）
0.005482574780915875
新旧版本比较（默认执行）
-0.005846337578248583
 
 
modified part:
Average end to end: 493.938332
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AT- 21aee83abdbfe8878d8b870b9783ce52ec8fe0f2
## 第1次符号执行
./redis/app/bin/redis-cli DEBUG RELOAD NOSAVE NOFLUSH MERGE

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 1196707.809024
Average (excluding the first number): 1181754.642171
Average (excluding the first number): 1199065.337576
新版本沿符号执行
1196707.80902353
新版本默认执行
1199065.3375764706
旧版本
1181754.642170588
新旧版本比较（沿符号执行）
0.012653359944054662
新旧版本比较（默认执行）
0.014648299053081888
 
 
modified part:
Average end to end: 1193480.190847
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第2次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.495323
Average (excluding the first number): 6.323319
Average (excluding the first number): 6.424431
新版本沿符号执行
6.4953229379189725
新版本默认执行
6.424431482488807
旧版本
6.323318502239178
新旧版本比较（沿符号执行）
0.02720160871524746
新旧版本比较（默认执行）
0.01599049300044336
 
 
modified part:
Average end to end: 6.559171
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
无占比
# PT- dc0ee51cb19403607991b060b9f1c71c71548404
## 第1次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2445.792629
Average (excluding the first number): 2404.519371
Average (excluding the first number): 2517.892729
新版本沿符号执行
2445.7926285714284
新版本默认执行
2517.8927285714285
旧版本
2404.519371428571
新旧版本比较（沿符号执行）
0.017164867804053546
新旧版本比较（默认执行）
0.04715011178117487
 
 
modified part:
Average end to end: 2852.747757
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
无占比
## 第2次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2394.449700
Average (excluding the first number): 2603.311214
Average (excluding the first number): 2475.134529
新版本沿符号执行
2394.4497
新版本默认执行
2475.1345285714287
旧版本
2603.3112142857144
新旧版本比较（沿符号执行）
-0.08022917626581992
新旧版本比较（默认执行）
-0.049236021037713025
 
 
modified part:
Average end to end: 2403.040014
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第3次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2579.246214
Average (excluding the first number): 2439.435343
Average (excluding the first number): 2419.944157
新版本沿符号执行
2579.2462142857134
新版本默认执行
2419.944157142857
旧版本
2439.435342857143
新旧版本比较（沿符号执行）
0.057312800619187365
新旧版本比较（默认执行）
-0.007990039896469398
 
 
modified part:
Average end to end: 2607.132329
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
无占比
## 第4次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2405.925600
Average (excluding the first number): 2588.954129
Average (excluding the first number): 2446.436243
新版本沿符号执行
2405.925600000001
新版本默认执行
2446.4362428571435
旧版本
2588.954128571429
新旧版本比较（沿符号执行）
-0.07069593336998296
新旧版本比较（默认执行）
-0.05504843988600374
 
 
modified part:
Average end to end: 2485.264114
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
Average (excluding the first number): 6.249780
Average (excluding the first number): 6.388591
Average (excluding the first number): 6.391252
新版本沿符号执行
6.249779560641832
新版本默认执行
6.391252331390508
旧版本
6.3885906115812725
新旧版本比较（沿符号执行）
-0.021727961514360183
新旧版本比较（默认执行）
0.00041663646507728166
 
 
modified part:
Average end to end: 8.059063
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
Average (excluding the first number): 2.881670
Average (excluding the first number): 3.082073
Average (excluding the first number): 2.912258
新版本沿符号执行
2.8816696051348716
新版本默认执行
2.912258279214231
旧版本
3.0820731026108077
新旧版本比较（沿符号执行）
-0.06502230505375599
新旧版本比较（默认执行）
-0.05509759754002188
 
 
modified part:
Average end to end: 3.871155
Average modified part: 0.654184
0.16898944262574125
 
 
icount diff
``` 
## 第7次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本Program terminated
旧版本timeout
``` sql 
end-to-end diff:
Average (excluding the first number): 6.208564
Average (excluding the first number): 6.414734
Average (excluding the first number): 6.453491
新版本沿符号执行
6.208563570856685
新版本默认执行
6.453490858539052
旧版本
6.414733577401506
新旧版本比较（沿符号执行）
-0.032140073170168454
新旧版本比较（默认执行）
0.006041915953311579
 
 
modified part:
Average end to end: 6.331023
Average modified part: 0.099827
0.01576789090776639
 
 
icount diff
``` 
## 第8次符号执行
./redis/app/bin/redis-cli CLUSTER SLOTS

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 118.345548
Average (excluding the first number): 122.200445
Average (excluding the first number): 124.677714
新版本沿符号执行
118.34554798573043
新版本默认执行
124.67771402505778
旧版本
122.20044523965322
新旧版本比较（沿符号执行）
-0.03154568910418256
新旧版本比较（默认执行）
0.020272174790740487
 
 
modified part:
Average end to end: 137.517777
Average modified part: 44.216635
0.32153395961960596
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
## 第9次符号执行
./redis/app/bin/redis-cli HMGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD123 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12313 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 84.716266
Average (excluding the first number): 83.889529
Average (excluding the first number): 83.363373
新版本沿符号执行
84.71626632163917
新版本默认执行
83.36337315646371
旧版本
83.88952925454166
新旧版本比较（沿符号执行）
0.009855068617550417
新旧版本比较（默认执行）
-0.006272011569899976
 
 
modified part:
Average end to end: 83.679747
Average modified part: 2.446916
0.02924143101762843
 
 
icount diff
``` 
## 第10次符号执行
./redis/app/bin/redis-cli SDIFF key_set:23 key_set:2345 key_set:9987 key_set:1 key_set:3

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 169.896081
Average (excluding the first number): 164.955810
Average (excluding the first number): 176.481683
新版本沿符号执行
169.89608098696223
新版本默认执行
176.4816833851792
旧版本
164.9558095781072
新旧版本比较（沿符号执行）
0.029949059820871617
新旧版本比较（默认执行）
0.06987249395186933
 
 
modified part:
Average end to end: 181.136349
Average modified part: 0.087558
0.00048338061536902147
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
## 第11次符号执行
./redis/app/bin/redis-cli HMGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD123 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12313 MGET test_HGET HGET_HASH_FIELD5 HGET_HASH_FIELD198 HGET_HASH_FIELD1 HGET_HASH_FIELD97 HGET_HASH_FIELD123 HGET_HASH_FIELD178 HGET_HASH_FIELD988 HGET_HASH_FIELD12

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 83.176557
Average (excluding the first number): 87.281399
Average (excluding the first number): 81.882800
新版本沿符号执行
83.17655674949631
新版本默认执行
81.88279976368317
旧版本
87.28139852095318
新旧版本比较（沿符号执行）
-0.047029972491463165
新旧版本比较（默认执行）
-0.06185279852011074
 
 
modified part:
Average end to end: 79.236864
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第12次符号执行
./redis/app/bin/redis-cli HSCAN test_HGET 0 MATCH HGET_HASH_FIELD*2* COUNT 1000

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 65.531190
Average (excluding the first number): 71.192558
Average (excluding the first number): 66.240028
新版本沿符号执行
65.53119029193
新版本默认执行
66.24002767668219
旧版本
71.19255843879161
新旧版本比较（沿符号执行）
-0.07952190890469281
新旧版本比较（默认执行）
-0.06956528702880369
 
 
modified part:
Average end to end: 67.626746
Average modified part: 0.139762
0.0020666744736336402
 
 
icount diff
``` 
## 第13次符号执行
./redis/app/bin/redis-cli MSET test_MSET1 weiuvweiuvb test_MSET2 4r4i3ih test_MSET3 f348yg3gbeb test_MSET4 23ry8342hfihbf test_MGET4 wevgbewihviwe test_MGET5 2f239fu439gfh4 test_MGET6 23hr23ibf3jghi test_MGET7 wbgvirhvorj test_MGET8 pkwpjvkwnkv test_MGET9 2qfnk23nfjb2gj4b test_MGET10 24ty4inkwev

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 6.445438
Average (excluding the first number): 6.356787
Average (excluding the first number): 6.521261
新版本沿符号执行
6.445437709170013
新版本默认执行
6.521261067490812
旧版本
6.356786866070682
新旧版本比较（沿符号执行）
0.01394585739101993
新旧版本比较（默认执行）
0.025873795187000826
 
 
modified part:
Average end to end: 6.381503
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
无占比
## 第14次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 2.984713
Average (excluding the first number): 2.793774
Average (excluding the first number): 2.771006
新版本沿符号执行
2.984712554182052
新版本默认执行
2.7710063451267017
旧版本
2.7937741663657154
新旧版本比较（沿符号执行）
0.06834424561406796
新旧版本比较（默认执行）
-0.008149485206469359
 
 
modified part:
Average end to end: 3.288544
Average modified part: 0.503952
0.153244602854431
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
## 第15次符号执行
./redis/app/bin/redis-cli HSCAN test_HGET 0 MATCH HGET_HASH_FIELD*2* COUNT 1000

新版本bootstrap terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 67.634247
Average (excluding the first number): 71.733356
Average (excluding the first number): 66.407858
新版本沿符号执行
67.63424689305458
新版本默认执行
66.40785832874508
旧版本
71.7333563555896
新旧版本比较（沿符号执行）
-0.05714370093343074
新旧版本比较（默认执行）
-0.07424019030206098
 
 
modified part:
Average end to end: 65.922055
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
## 第16次符号执行
./redis/app/bin/redis-cli MGET test_MGET1 23r23r23f test_MGET2 4tr43ign4i3gnopsdkv test_MGET3 dewugfewiugbv test_MGET10 test_MGET8 giurgb3i test_MGET5

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): 3.135939
Average (excluding the first number): 3.070046
Average (excluding the first number): 3.327294
新版本沿符号执行
3.1359385749385753
新版本默认执行
3.3272937068648667
旧版本
3.0700460715588154
新旧版本比较（沿符号执行）
0.021463034053525794
新旧版本比较（默认执行）
0.08379276053516482
 
 
modified part:
Average end to end: 3.292665
Average modified part: 0.146567
0.04451327087443688
 
 
icount diff
``` 
新旧版本沿符号执行end-to-end有性能问题
新旧版本默认执行end-to-end有性能问题
# NT- 73a9b916c9f42f2e07b9338a975f9a473ad0cd9b

# PT- 4a95b3005a140165bbb9df373ba61f775c936554
## 第1次符号执行
./redis/app/bin/redis-cli ACL setuser tom on >p1pp0 ~cached:* +get

新版本Program terminated
旧版本bootstrap terminated
``` sql 
end-to-end diff:
Average (excluding the first number): -0.000000
Average (excluding the first number): 11.458648
Average (excluding the first number): 12.376348
新版本沿符号执行
-0.0
新版本默认执行
12.376348238653064
旧版本
11.458648297737366
新旧版本比较（沿符号执行）
-1.0
新旧版本比较（默认执行）
0.0800879752192855
 
 
modified part:
Average end to end: -0.000000
Average modified part: -0.000000
 
 
icount diff
``` 
新旧版本默认执行end-to-end有性能问题
无占比
# NT- 342ee426ad0d0731b2272553bd4db2cd78e24772

# PT- 5b8b58e472fc567337429f63e93927f86db7f838
## 第1次符号执行
./redis/app/bin/redis-cli ACL setuser tom on >p1pp0 ~cached:* +get

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 11.518867
Average (excluding the first number): 11.728082
Average (excluding the first number): 11.518867
新版本沿符号执行
11.518866837549375
新版本默认执行
11.518866837549375
旧版本
11.72808194227613
新旧版本比较（沿符号执行）
-0.017838816761042528
新旧版本比较（默认执行）
-0.017838816761042528
 
 
modified part:
Average end to end: 11.916320
Average modified part: 0.239392
0.02008943850456158
 
 
icount diff
``` 
## 第2次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2399.728871
Average (excluding the first number): 2384.852600
Average (excluding the first number): 2399.728871
新版本沿符号执行
2399.728871428571
新版本默认执行
2399.728871428571
旧版本
2384.8526000000015
新旧版本比较（沿符号执行）
0.0062378158837026
新旧版本比较（默认执行）
0.0062378158837026
 
 
modified part:
Average end to end: 2616.467057
Average modified part: 0.047057
1.7984993439408535e-05
 
 
icount diff
``` 
## 第3次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2523.407871
Average (excluding the first number): 2583.067400
Average (excluding the first number): 2523.407871
新版本沿符号执行
2523.4078714285706
新版本默认执行
2523.4078714285706
旧版本
2583.0674000000004
新旧版本比较（沿符号执行）
-0.02309638864685828
新旧版本比较（默认执行）
-0.02309638864685828
 
 
modified part:
Average end to end: 2470.781171
Average modified part: 584.810057
0.23669034874696243
 
 
icount diff
``` 
## 第4次符号执行
./redis/app/bin/redis-cli HSCAN test_HGET 0 MATCH HGET_HASH_FIELD*2* COUNT 1000

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 64.299507
Average (excluding the first number): 66.836877
Average (excluding the first number): 64.299507
新版本沿符号执行
64.29950693052416
新版本默认执行
64.29950693052416
旧版本
66.83687737433777
新旧版本比较（沿符号执行）
-0.03796362941377997
新旧版本比较（默认执行）
-0.03796362941377997
 
 
modified part:
Average end to end: 67.246526
Average modified part: 65.738602
0.9775761722543836
 
 
icount diff
``` 
## 第5次符号执行
./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 2410.596100
Average (excluding the first number): 2389.422571
Average (excluding the first number): 2410.596100
新版本沿符号执行
2410.596100000001
新版本默认执行
2410.596100000001
旧版本
2389.422571428572
新旧版本比较（沿符号执行）
0.008861357896510482
新旧版本比较（默认执行）
0.008861357896510482
 
 
modified part:
Average end to end: 2572.632986
Average modified part: 0.187443
7.286031788588533e-05
 
 
icount diff
``` 
# AB- 0f65806b5b0f21b96e9c688ce7d2d00062203a51
getFuncName.txt文件为空

# AB- ee96a5a6f5161b57fcbbc23260e0f756258cb973
getFuncName.txt文件为空

# AB- 781ccc1beed4e89c28850c4d8bc5e3d53db437b1
getFuncName.txt文件为空

# AB- dcd0b3d02013edb9102ce5ec125dbb7562e29bad
getFuncName.txt文件为空

# PT- f86575f210a9fa450a2b1949786122ea6135046c
## 第1次符号执行
./redis/app/bin/redis-cli BITOP AND tmp key:1789 key:8988 key:345 key:12 key:5467 key:998 key:7345 key:4 key:3098 key:9999

无需符号执行
``` sql 
end-to-end diff:
Average (excluding the first number): 5.561965
Average (excluding the first number): 5.521305
Average (excluding the first number): 5.561965
新版本沿符号执行
5.561965429148296
新版本默认执行
5.561965429148296
旧版本
5.5213048654884025
新旧版本比较（沿符号执行）
0.007364303303381717
新旧版本比较（默认执行）
0.007364303303381717
 
 
modified part:
Average end to end: 5.518306
Average modified part: 0.000000
0.0
 
 
icount diff
``` 
无占比
# AB- eb50eb20a5e54b48cd2bbc271340b825b355b6e7
getFuncName.txt文件为空


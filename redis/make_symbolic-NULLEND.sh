#!/bin/bash

command=$1 #是command_old，注意，shell脚本变量名不能有-，所以这里用_代替
command_now=$2
redis_dir=$(pwd)
echo "commitId:$command"
# exit 0
# break
# 第0步：将工具拷贝过来，修改 Makefile 并构建 bc 文件
cp /data3/sjz/AE/redis/tools/.clang-format .
cp /data3/sjz/AE/redis/tools/new_function_analyzer.sh .
cp /data3/sjz/AE/redis/tools/commit_analyzer .
cp /data3/sjz/AE/redis/tools/call_analyzer .
cp /data3/sjz/AE/redis/tools/symbolic_analyzer .
cp /data3/sjz/AE/redis/tools/make_symbolizer-new .
cp /data3/sjz/AE/redis/tools/real_executor-new .
cp /data3/sjz/AE/redis/tools/jsonAnalyze .
cp /data3/sjz/AE/redis/tools/jsonAnalyze-icount .
cp /data3/sjz/AE/redis/tools/get_redis_1 . 
cp /data3/sjz/AE/redis/tools/get_redis_2 .
cp /data3/sjz/AE/redis/tools/redis-order.txt .

###### 编译新旧版本的redis-server二进制文件 ######
cp -r /data3/sjz/AE/redis/redis redis-tmp
cd redis-tmp
git reset --hard $command_now
make distclean
make noopt -j4
make install PREFIX=../app
cp app/bin/redis-server ../redis-server-new

git reset --hard $command
make distclean
make noopt -j4
make install PREFIX=../app
cp app/bin/redis-server ../redis-server-old

cd ..
rm -rf redis-tmp

./new_function_analyzer.sh redis-server-old redis-server-new
################################################

make distclean

# TODO:
# 用合理的方式修改 Makefile
# 提前构建好需要的Makefile，copy
cp ../Makefile1 ./src/Makefile

make bc -j4 CC=clang

# 第1步：分析commit修改，生成 getFuncName.txt
./commit_analyzer > getFuncName.txt

# 第2步：分析调用关系，生成 call_analyse.txt
./call_analyzer src/final_obj.bc getFuncName.txt > call_analyse.txt

# 第3步：分析若干次符号执行符号化插桩的位置，生成 symbolic_analyse.txt
cat call_analyse.txt | ./symbolic_analyzer 1
echo "symbolic_analyzer"

# TODO：
# 第4步：读取 symbolic_analyse.txt，结合之前的信息，利用preknowledge库寻找测试用例
# 生成 call_analyse2.txt

cp call_analyse.txt /data2/sjz/Pre-knowledge/demo-S2E-times-res-2.txt
cp symbolic_analyse.txt /data2/sjz/Pre-knowledge/demo-S2E-times-res-3-flag.txt

# 迁移到ds00后
# cp call_analyse.txt /data2/sjz/Pre-knowledge/demo-S2E-times-res-2.txt
# cp symbolic_analyse.txt /data2/sjz/Pre-knowledge/demo-S2E-times-res-3-flag.txt
file_path="/data/sjz/call_analyse2.txt"

# 检查文件是否存在
while [ ! -f "$file_path" ]
do
echo "Waiting for file to appear..."
sleep 3  # 等待5秒
done   

cp /data/sjz/call_analyse2.txt ./call_analyse2.txt

rm /data/sjz/call_analyse2.txt


# 第4.5步：读取 call_analyse2.txt，其中的内容用空行分隔，第i块(block)内容代表第i次符号执行的信息
# 读取输入文件
file_path="call_analyse2.txt"
# 读取文件内容并分割块
declare -a blocks    # 声明一个数组用于存储每个block
declare -a blocks_NULL    # 声明一个数组用于存储每个block
current_block=""    # 当前正在构建的block

flagEndNULL=0
while read line
do
    if [[ "$line" == "" ]]; then
        if [ "$flagEndNULL" -eq 1 ]; then
            if [[ "$current_block" == "End NULL"$'\n' ]]; then
                flagEndNULL=0
                current_block=""
                continue
            else
                blocks_NULL+=("$current_block")
                current_block=""
                continue
            fi
        else
            if [[ "$current_block" == "Begin NULL"$'\n' ]]; then
                flagEndNULL=1
                current_block=""
                continue
            else
                blocks+=("$current_block")
                current_block=""
                continue
            fi
        fi
    fi
    
    current_block+="$line"$'\n'
done < "$file_path"

# 确保最后一个block被添加，如果文件不以空行结束
if [[ -n "$current_block" ]]; then
    if [ "$flagEndNULL" -eq 0 ]; then
        blocks+=("$current_block")
    else
        if [[ "$current_block" == "END NULL"$'\n' ]]; then
            current_block=""
        else
            blocks_NULL+=("$current_block")
        fi
    fi
fi

# 遍历每个块
i=1
for block in "${blocks_NULL[@]}"; do
    if [[ "$block" == "" ]]; then
        continue
    fi
    echo "blocks_NULLblocks_NULL :$block"
    
    if [ ! -d "$i" ]; then
        mkdir "$i"
    fi
    git restore ./src/
    cp ../Makefile ./src/Makefile
    src_files=$(echo "$block" | grep [.]c | awk '{print $2}' | sort | uniq)

    last_line=$(echo "$block" | tail -n 2 | head -n 1)

    echo "last_line:$last_line"

    if [ "$last_line" = "testcase:no testcase" ]; then
        echo "testcase:no testcase"
        continue
    fi

    testcase_line=$last_line
    testcase_content=$(echo "$testcase_line" | sed 's/^testcase:.*redis-cli //')
    if [[ "$testcase_line" == *"redis-server"* ||
          "${testcase_content^^}" =~ ^[[:space:]]*DEBUG[[:space:]]+RELOAD([[:space:]]|$) ]]; then
        echo "Skipping performance analysis for testcase $i: $testcase_line"
        i=$((${i} + 1))
        continue
    fi

   
    # 由于block的最后一行是测试用例，没有源文件路径，所以需要去掉
    # src_files=$(echo "$src_files" | sed '$d')

    echo "src_files: $src_files"
    # 临时备份源文件，以便还原
    for src_file in $src_files; do
        if [ ! -f "${src_file}.brk" ]; then
            cp "$src_file" "${src_file}.brk"
        fi
    done

    

    for src_file in $src_files; do
        echo "src_files $src_file"
    done

    # testcase_line是否包含redis-server

    if [[ "$testcase_line" == *"redis-server"* ]]; then
        echo "testcase contains 'redis-server'"

        redis_dir=$(pwd)

        #替换成redis-server启动的插桩 & 保存redis-server启动的文件
        if [ ! -f "src/server.c.brk" ]; then
            cp "src/server.c" "src/server.c.brk"
        fi
        cp "src/ae.c" "src/ae.c.brk"

        echo "$(pwd)/src/server.c main start" > end_to_end.txt
        echo "$(pwd)/src/ae.c aeMain start" >> end_to_end.txt


        echo "$block" | ./real_executor-new --measure-modified-part=true --loop-boost=true 1

       
        # 第9步：正常编译、运行
        rm src/.make-settings
        make distclean
        make -j4
        make install PREFIX=$i
        cd src/$i/bin
        
        touch redis-server.log
        touch redis.pid
        # cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh
        cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh
        cp /data3/sjz/AE/redis/run-redis-2.sh ./run-redis-2.sh
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        ../../../get_redis_2 $testcase_line > get_redis_2.txt
        
        sh run-redis-2.sh > redis-server.log1

        sleep 2
        
        cp redis-server.log1 $redis_dir/$i/real-execute-modified-part-res.txt

        # 备份真实执行插桩后的源文件，还原源文件
        cd $redis_dir

        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            clang-format -i "$src_file"
            echo "cp ${src_file} ./$i/${src_file_basename}-modified-part.real"
            cp "${src_file}" "./$i/${src_file_basename}-modified-part.real"
            cp "${src_file}.brk" "$src_file"
            
        done

        # 替换成恢复redis-server启动时候的文件
        clang-format -i src/server.c
        echo "cp src/server.c ./$i/server.c.real-modified-part-1"
        cp src/server.c ./$i/server.c.real-modified-part-1
        cp src/server.c.brk src/server.c

        cp src/ae.c $redis_dir/$i/ae.c.real-modified-part-1
        cp src/ae.c.brk src/ae.c
        make distclean

        #不带占比插桩新版本
        git restore ./src/
        cp ../Makefile ./src/Makefile
        if [ ! -f "src/server.c.brk" ]; then
            cp "src/server.c" "src/server.c.brk"
        fi
        cp "src/ae.c" "src/ae.c.brk"

    
    
        echo "$block" | ./real_executor-new --measure-modified-part=false --loop-boost=false 1


       
        # 第9步：正常编译、运行
        rm src/.make-settings
        make distclean
        make -j4
        make install PREFIX=$i-1
        cd src/$i-1/bin
        
        touch redis-server.log
        touch redis.pid
        # cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh
        cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh
        cp /data3/sjz/AE/redis/run-redis-2.sh ./run-redis-2.sh
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        ../../../get_redis_2 $testcase_line > get_redis_2.txt
        
        sh run-redis-2.sh > redis-server.log1

        sleep 2
        
        cp redis-server.log1 $redis_dir/$i/real-execute-res.txt
        cp redis-server.log1 $redis_dir/$i/real-execute-res-pure.txt

        # 备份真实执行插桩后的源文件，还原源文件
        
        cd $redis_dir
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            clang-format -i "$src_file"
            echo "cp ${src_file} ./$i/${src_file_basename}.real"
            cp "${src_file}" "./$i/${src_file_basename}.real"
            cp "${src_file}.brk" "$src_file"
            
        done

        # 替换成恢复redis-server启动时候的文件
        clang-format -i src/server.c
        echo "cp src/server.c ./$i/server.c.real"
        cp src/server.c ./$i/server.c.real-1
        cp src/server.c.brk src/server.c

        cp src/ae.c $redis_dir/$i/ae.c.real-1
        cp src/ae.c.brk src/ae.c
        make distclean

        # 第10步：可能还需要插桩和运行旧版本
        # 旧版本只需要对end-to-end函数插桩，不需要对其他函数插桩，用以下命令
        
        # 进入
        cd /data3/sjz/AE/redis
        
        cd redis-$command-old
        #替换成保存redis-server启动的文件
        git restore ./src/
       
        if [ ! -f "src/server.c.brk" ]; then
            cp "src/server.c" "src/server.c.brk"
        fi
        cp "src/ae.c" "src/ae.c.brk"
        make distclean

        cp /data3/sjz/AE/redis/tools/.clang-format .
        cp /data3/sjz/AE/redis/tools/new_function_analyzer.sh .
        cp /data3/sjz/AE/redis/tools/commit_analyzer .
        cp /data3/sjz/AE/redis/tools/call_analyzer .
        cp /data3/sjz/AE/redis/tools/symbolic_analyzer .
        cp /data3/sjz/AE/redis/tools/make_symbolizer-new .
        cp /data3/sjz/AE/redis/tools/real_executor-new .
        cp /data3/sjz/AE/redis/tools/jsonAnalyze .
        cp /data3/sjz/AE/redis/tools/jsonAnalyze-icount .
        cp /data3/sjz/AE/redis/tools/get_redis_1 . 
        cp /data3/sjz/AE/redis/tools/get_redis_2 .
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        cp ../Makefile ./src/Makefile
        
        #替换成redis-server启动的插桩
        echo "$(pwd)/src/server.c main start" > end_to_end.txt
        echo "$(pwd)/src/ae.c aeMain start" >> end_to_end.txt
        
        echo "EOF" | ./real_executor-new --measure-modified-part=false --loop-boost=false 1
        make distclean
        make -j4
        make install PREFIX=$i

        cd src/$i/bin
        
        touch redis-server.log
        touch redis.pid
        cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
        cp /data3/sjz/AE/redis/run-redis-2.sh ./run-redis-2.sh 
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        ../../../get_redis_2 $testcase_line > get_redis_2.txt
     
        sh run-redis-2.sh > redis-server.log1

        sleep 2

        cp redis-server.log1 $redis_dir/$i/real-execute-res-old.txt

        cd /data3/sjz/AE/redis
        cd redis-$command-old
        # 替换成恢复redis-server启动时候的文件
        clang-format -i src/server.c
        echo "cp src/server.c $redis_dir/$i/server.c.real.old"
        cp src/server.c $redis_dir/$i/server.c.real.old
        cp src/server.c.brk src/server.c

        cp src/ae.c $redis_dir/$i/ae.c.real.old
        cp src/ae.c.brk src/ae.c

        make distclean
        

        #形成最终结果
        cd $redis_dir/$i
        cp /data3/sjz/AE/redis/run-getres.sh ./run-getres.sh
        cp /data3/sjz/AE/redis/run-getres.py ./run-getres.py
        cp /data3/sjz/AE/redis/run-getres-modify.py ./run-getres-modify.py
        cp /data3/sjz/AE/redis/run-getres-icount.py ./run-getres-icount.py
        sh run-getres.sh
        cd $redis_dir

        i=$((${i} + 1))

    else
        echo "testcase not contains 'redis-server'"
        if [ ! -f "src/server.c.brk" ]; then
            cp "src/server.c" "src/server.c.brk"
        fi
        redis_dir=$(pwd)

        echo "$(pwd)/src/server.c processCommand start" > end_to_end.txt
        echo "$(pwd)/src/server.c processCommand end" >> end_to_end.txt
        echo "$block" | ./real_executor-new --measure-modified-part=true --loop-boost=true 1
        

        # TODO：
        # 第9步：正常编译、运行
        rm src/.make-settings
        make distclean
        make -j4
        make install PREFIX=$i
        cd src/$i/bin
        
        touch redis-server.log
        touch redis.pid
        cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
        # ./redis-server redis.conf --pidfile redis.pid --dir /data3/sjz/AE/redis/dump.rdb --save "" > s2e—execute-res.txt
        # ./redis-server --dir /data3/sjz/AE/redis --save "" & > $(pwd)/redis-server.log
        
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        ../../../get_redis_2 $testcase_line > get_redis_2.txt
        echo "$testcase_content" > get_redis_3.txt
        bash run-redis.sh > redis-server.log1

        sleep 2
        
        cp redis-server.log1 $redis_dir/$i/real-execute-modified-part-res.txt

        # 备份真实执行插桩后的源文件，还原源文件
        cd $redis_dir
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            clang-format -i "$src_file"
            echo "cp ${src_file} ./$i/${src_file_basename}-modified-part.real"
            cp "${src_file}" "./$i/${src_file_basename}-modified-part.real"
            cp "${src_file}.brk" "$src_file"
            # 额外恢复server.c
            # cp src/server.c.brk src/server.c
        done

        clang-format -i src/server.c
        echo "cp src/server.c ./$i/server.c.real-modified-part-1"
        cp src/server.c ./$i/server.c.real-modified-part-1
        cp src/server.c.brk src/server.c

        make distclean


        # 新版本不带修改部分
        git restore ./src/
        cp ../Makefile ./src/Makefile
        
        if [ ! -f "src/server.c.brk" ]; then
            cp "src/server.c" "src/server.c.brk"
        fi
        
        echo "$block" | ./real_executor-new --measure-modified-part=false --loop-boost=false 1

        # TODO：
        # 第9步：正常编译、运行
        rm src/.make-settings
        make distclean
        make -j4
        make install PREFIX=$i-1
        cd src/$i-1/bin
        
        touch redis-server.log
        touch redis.pid
        cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
        
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        ../../../get_redis_2 $testcase_line > get_redis_2.txt
        echo "$testcase_content" > get_redis_3.txt
        bash run-redis.sh > redis-server.log1

        sleep 2
        
        cp redis-server.log1 $redis_dir/$i/real-execute-res.txt

        cp redis-server.log1 $redis_dir/$i/real-execute-res-pure.txt


        # 备份真实执行插桩后的源文件，还原源文件
        cd $redis_dir
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            clang-format -i "$src_file"
            echo "cp ${src_file} ./$i/${src_file_basename}.real"
            cp "${src_file}" "./$i/${src_file_basename}.real"
            cp "${src_file}.brk" "$src_file"
            # 额外恢复server.c
            # cp src/server.c.brk src/server.c
        done

        clang-format -i src/server.c
        echo "cp src/server.c ./$i/server.c.real-1"
        cp src/server.c ./$i/server.c.real-1
        cp src/server.c.brk src/server.c

        make distclean

        # 第10步：可能还需要插桩和运行旧版本
        # 旧版本只需要对end-to-end函数插桩，不需要对其他函数插桩，用以下命令
        
        # 进入
        cd /data3/sjz/AE/redis
        
        cd redis-$command-old
        git restore ./src/
       
        
        if [ ! -f "src/server.c.brk" ]; then
            cp "src/server.c" "src/server.c.brk"
        fi
        make distclean
        

        cp /data3/sjz/AE/redis/tools/.clang-format .
        cp /data3/sjz/AE/redis/tools/new_function_analyzer.sh .
        cp /data3/sjz/AE/redis/tools/commit_analyzer .
        cp /data3/sjz/AE/redis/tools/call_analyzer .
        cp /data3/sjz/AE/redis/tools/symbolic_analyzer .
        cp /data3/sjz/AE/redis/tools/make_symbolizer-new .
        cp /data3/sjz/AE/redis/tools/real_executor-new .
        cp /data3/sjz/AE/redis/tools/jsonAnalyze .
        cp /data3/sjz/AE/redis/tools/jsonAnalyze-icount .
        cp /data3/sjz/AE/redis/tools/get_redis_1 . 
        cp /data3/sjz/AE/redis/tools/get_redis_2 .
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        
        cp ../Makefile ./src/Makefile

        echo "$(pwd)/src/server.c processCommand start" > end_to_end.txt
        echo "$(pwd)/src/server.c processCommand end" >> end_to_end.txt
        

        echo "EOF" | ./real_executor-new --measure-modified-part=false --loop-boost=false 1
        make distclean
        make -j4
        make install PREFIX=$i

        cd src/$i/bin
        
        touch redis-server.log
        touch redis.pid
        cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
        
        cp /data3/sjz/AE/redis/tools/redis-order.txt .
        ../../../get_redis_2 $testcase_line > get_redis_2.txt
        echo "$testcase_content" > get_redis_3.txt
        bash run-redis.sh > redis-server.log1

        sleep 2

        cp redis-server.log1 $redis_dir/$i/real-execute-res-old.txt

        cd /data3/sjz/AE/redis
        cd redis-$command-old
        clang-format -i src/server.c
        echo "cp src/server.c $redis_dir/$i/server.c.real.old"
        cp src/server.c $redis_dir/$i/server.c.real.old
        cp src/server.c.brk src/server.c
        make distclean
        
        cd $redis_dir/$i
        cp /data3/sjz/AE/redis/run-getres.sh ./run-getres.sh
        cp /data3/sjz/AE/redis/run-getres.py ./run-getres.py
        cp /data3/sjz/AE/redis/run-getres-modify.py ./run-getres-modify.py
        cp /data3/sjz/AE/redis/run-getres-icount.py ./run-getres-icount.py
        sh run-getres.sh
        cd $redis_dir

        i=$((${i} + 1))
    fi
done

for block in "${blocks[@]}"; do
    if [[ "$block" == "" ]]; then
        continue
    fi
    echo "blocksblocks : $block"
   
    if [ ! -d "$i" ]; then
        mkdir "$i"
    fi
    git restore ./src/
    cp ../Makefile ./src/Makefile
    # 获取所有涉及的源文件，排除数字成员
    src_files=$(echo "$block" | grep [.]c | awk '{print $2}' | sort | uniq)

    #对最后一行内容进行判断
    # last_line=$(echo "$block" | tail -n 1)
    last_line=$(echo "$block" | tail -n 2 | head -n 1)
    # echo "last_line:$block"
    # echo "last_line:$last_line"

    echo "last_line:$last_line"

    if [ "$last_line" = "testcase:no testcase" ]; then
        echo "testcase:no testcase"
        continue
    fi

    testcase_line=$last_line
    testcase_content=$(echo "$testcase_line" | sed 's/^testcase:.*redis-cli //')
    if [[ "$testcase_line" == *"redis-server"* ||
          "${testcase_content^^}" =~ ^[[:space:]]*DEBUG[[:space:]]+RELOAD([[:space:]]|$) ]]; then
        echo "Skipping performance analysis for testcase $i: $testcase_line"
        i=$((${i} + 1))
        continue
    fi
    
    # 由于block的最后一行是测试用例，没有源文件路径，所以需要去掉
    # src_files=$(echo "$src_files" | sed '$d')

    echo "src_files: $src_files"
    # 临时备份源文件，以便还原
    for src_file in $src_files; do
        if [ ! -f "${src_file}.brk" ]; then
            cp "$src_file" "${src_file}.brk"
        fi
    done
    redisServerFlag=0
    if [[ "$last_line" == *"redis-server"* ]]; then
        redisServerFlag=1
    else
        redisServerFlag=0
    fi

    if [ ! -f "src/server.c.brk" ]; then
        cp "src/server.c" "src/server.c.brk"
    fi
    #redis-server启动过程，需要额外保存
    if [ "$redisServerFlag" -eq 1 ]; then
        cp "src/ae.c" "src/ae.c.brk"   
    fi

    for src_file in $src_files; do
        echo "src_files $src_file"
    done

    # 第5步：符号执行插桩，生成插桩后的源文件和存放testcase行的 testcase.txt
    # 将块信息传递给 make_symbolizer-new
    # block=$(echo "$block" | sed '$d')
    # echo "$block"
    
    if [ "$redisServerFlag" -eq 1 ]; then
        echo "$(pwd)/src/server.c main start" > end_to_end.txt
        echo "$(pwd)/src/ae.c aeMain start" >> end_to_end.txt
    else
        echo "$(pwd)/src/server.c processCommand start" > end_to_end.txt
        echo "$(pwd)/src/server.c processCommand end" >> end_to_end.txt
    fi
    echo "$block" | ./make_symbolizer-new --new-version=true 1

    cp ./modified_part_info.txt /data3/sjz/AE/redis/redis-$command-old/modified_part_info.txt

    # TODO：
    # 第6步：-O0编译、s2e运行（testcase行存放在 testcase.txt）、提取结果存放到 symbolic_testcase.txt
    make distclean
    make noopt -j4
    # 可执行文件被保存在./src/app/bin 目录下
    rm $(pwd)/src/app/bin/redis-server
    rm $(pwd)/src/app/bin/redis-cli

    make install PREFIX=app

    file_path_redis_server="$(pwd)/src/app/bin/redis-server"

    # 检查是否编译成功
    if [ ! -f "$file_path_redis_server" ]; then
        # 编译失败
        
        make distclean
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            clang-format -i "$src_file"
            echo "cp ${src_file} ./$i/${src_file_basename}.sym"
            cp "${src_file}" "./$i/${src_file_basename}.sym"
            cp "${src_file}.brk" "$src_file"
        done
        
        cp src/server.c ./$i/server.c.sym-1
        cp src/server.c.brk src/server.c
        
        #todo redis-serve启动过程需要额外恢复
        if [ "$redisServerFlag" -eq 1 ]; then
            cp src/ae.c ./$i/ae.c.sym-1
            cp src/ae.c.brk src/ae.c
        fi
        touch ./$i/compile.txt
        echo "fail compile" > ./$i/compile.txt
        i=$((${i} + 1))
        cd "$redis_dir"
        continue
    fi

    # 执行s2e 注意s2e-config.lua文件不需要修改，已经是固定格式
    # ln -s的对象是 redis-server redis-cli 
    # dump.rdb不需要修改
    rm /home/sjz/S2E/s2e/projects/redis-server/redis-server
    rm /home/sjz/S2E/s2e/projects/redis-server/redis-cli
    ln -s $(pwd)/src/app/bin/redis-server /home/sjz/S2E/s2e/projects/redis-server/redis-server
    ln -s $(pwd)/src/app/bin/redis-cli /home/sjz/S2E/s2e/projects/redis-server/redis-cli

    #!/bin/bash

    # 使用sed删除前缀
    ./get_redis_1 $testcase_line > get_redis_1.txt
    redis_inst=$(tail -n 1 get_redis_1.txt)
    # delete redis_inst last &
    redis_inst=$(echo "$redis_inst" | sed 's/ &//')
    # add --logfile /tmp/redis.log into redis_inst
    redis_inst="$redis_inst --logfile /tmp/redis.log &"
    #是否是redis-server启动过程
    if [ "$redisServerFlag" -eq 1 ]; then
        echo "Testcase Result: $redis_inst"
        bootstrap_path="/data3/sjz/AE/redis/bootstrap-1.sh"
        cp /data3/sjz/AE/redis/bootstrap.sh /data3/sjz/AE/redis/bootstrap-1.sh
        sed -i "232i$redis_inst" "$bootstrap_path"
    
    else
        testcase_result="./redis-cli $testcase_content"
        echo "Testcase Result: $testcase_result"
        bootstrap_path="/data3/sjz/AE/redis/bootstrap-1.sh"
        cp /data3/sjz/AE/redis/bootstrap.sh /data3/sjz/AE/redis/bootstrap-1.sh
        sed -i "244i$testcase_result" "$bootstrap_path"
        sed -i "232i$redis_inst" "$bootstrap_path"
    fi
   

    cp /data3/sjz/AE/redis/bootstrap-1.sh /home/sjz/S2E/s2e/projects/redis-server/bootstrap.sh

    #保存redis目录
    redis_dir=$(pwd)
    cd /home/sjz/S2E/s2e/projects/redis-server/
    # 设置launch-s2e.sh 超时时间为600秒（10分钟）,后续可能会调整
    timeout_time=600
    # 执行脚本并设置超时
    timeout $timeout_time ./launch-s2e.sh 
    # 检查命令的退出状态
    if [ $? -eq 124 ]; then
        echo "launch-s2e.sh 脚本执行超时，已被终止。"
        # /home/sjz/S2E/s2e/install/bin/qemu-system-x86_64 kill S2E
        pid=$(pgrep -f /home/sjz/S2E/s2e/install/bin/qemu-system-x86_64)
        if [ -z "$pid" ]; then
            echo "S2E 被杀死"
        else
            kill -9 "$pid"
        fi
        sleep 1
        
        cd $redis_dir
        make distclean
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            clang-format -i "$src_file"
            echo "cp ${src_file} ./$i/${src_file_basename}.sym"
            cp "${src_file}" "./$i/${src_file_basename}.sym"
            cp "${src_file}.brk" "$src_file"
        done
        
        cp src/server.c ./$i/server.c.sym-1
        cp src/server.c.brk src/server.c
        
        #todo redis-serve启动过程需要额外恢复
        if [ "$redisServerFlag" -eq 1 ]; then
            cp src/ae.c ./$i/ae.c.sym-1
            cp src/ae.c.brk src/ae.c
        fi
        i=$((${i} + 1))
        cd $redis_dir
        continue
    fi
    s2e execution_trace redis-server -pp
    
    cd $redis_dir
    cp /home/sjz/S2E/s2e/projects/redis-server/s2e-last/execution_trace.json ./$i/execution_trace.json
    cp /home/sjz/S2E/s2e/projects/redis-server/serial.txt ./$i/serial.txt
    mkdir -p ./$i/s2e_res
    cp -r /home/sjz/S2E/s2e/projects/redis-server/s2e-last/ ./$i/s2e_res/
    cp /home/sjz/S2E/s2e/projects/redis-server/s2e-last/debug.txt ./$i/s2e_res/debug.txt
    echo "$command" > ./$i/s2e_res/commitId.txt
   
    # 第7步：备份符号化插桩后的源文件，还原源文件
    for src_file in $src_files; do
        src_file_basename=$(basename "$src_file")
        clang-format -i "$src_file"
        echo "cp ${src_file} ./$i/${src_file_basename}.sym"
        cp "${src_file}" "./$i/${src_file_basename}.sym"
        cp "${src_file}.brk" "$src_file"
    done

    cp src/server.c "./$i/server.c.sym-1"
    cp src/server.c.brk src/server.c
    #redis-serve启动过程需要额外恢复
    if [ "$redisServerFlag" -eq 1 ]; then
        cp src/ae.c "./$i/ae.c.sym-1"
        cp src/ae.c.brk src/ae.c
    fi

    ./jsonAnalyze-icount ./$i/execution_trace.json > icount-new.txt
    cp icount-new.txt ./$i/icount-new.txt
    # 第8步：真实执行带修改部分占比
    # end_to_end.txt 指明 end-to-end 函数，例如 processCommand

    ./jsonAnalyze ./$i/execution_trace.json > symbolic_testcase.txt

    cp symbolic_testcase.txt ./$i/symbolic_testcase.txt
    git restore ./src/
    cp ../Makefile ./src/Makefile
    echo "$block" | ./real_executor-new --measure-modified-part=true --loop-boost=true 1
    # rm -rf symbolic_testcase.txt

    # TODO：
    # 第9步：正常编译、运行
    rm src/.make-settings
    
    
    make distclean
    make -j4
    make install PREFIX=$i
    cd src/$i/bin
    
    touch redis-server.log
    touch redis.pid
    cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
    cp /data3/sjz/AE/redis/run-redis-2.sh ./run-redis-2.sh 
       
    cp /data3/sjz/AE/redis/tools/redis-order.txt .
    ../../../get_redis_2 $testcase_line > get_redis_2.txt
    if [ "$redisServerFlag" -eq 1 ]; then
        sh run-redis-2.sh > redis-server.log1
    else
        echo "$testcase_content" > get_redis_3.txt
        bash run-redis.sh > redis-server.log1
    fi
    sleep 2
    
    cp redis-server.log1 $redis_dir/$i/real-execute-modified-part-res.txt

    # 第11步：备份真实执行插桩后的源文件，还原源文件
    cd $redis_dir
    for src_file in $src_files; do
        src_file_basename=$(basename "$src_file")
        clang-format -i "$src_file"
        echo "cp ${src_file} ./$i/${src_file_basename}.real-modified-part"
        cp "${src_file}" "./$i/${src_file_basename}.real-modified-part"
        cp "${src_file}.brk" "$src_file"
    done

    clang-format -i src/server.c
    echo "cp src/server.c ./$i/server.c.real-modified-part-1"
    cp src/server.c ./$i/server.c.real-modified-part-1
    cp src/server.c.brk src/server.c

    if [ "$redisServerFlag" -eq 1 ]; then
        cp src/ae.c $redis_dir/$i/ae.c.real-modified-part-1
        cp src/ae.c.brk src/ae.c
    fi


    make distclean
    # 真实执行不带修改部分占比
    git restore ./src/
    cp ../Makefile ./src/Makefile

    rm src/.make-settings
    make distclean
    echo "$block" | ./real_executor-new --measure-modified-part=false --loop-boost=false 1
    
    make -j4
    make install PREFIX=$i-1
    cd src/$i-1/bin

    touch redis-server.log
    touch redis.pid
    cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
    cp /data3/sjz/AE/redis/run-redis-2.sh ./run-redis-2.sh

    cp /data3/sjz/AE/redis/tools/redis-order.txt .
    ../../../get_redis_2 $testcase_line > get_redis_2.txt
    if [ "$redisServerFlag" -eq 1 ]; then
        sh run-redis-2.sh > redis-server.log1
    else
        echo "$testcase_content" > get_redis_3.txt
        bash run-redis.sh > redis-server.log1
    fi
    sleep 2
    
    cp redis-server.log1 $redis_dir/$i/real-execute-res.txt

    # 第11步：备份真实执行插桩后的源文件，还原源文件
    cd $redis_dir
    for src_file in $src_files; do
        src_file_basename=$(basename "$src_file")
        clang-format -i "$src_file"
        echo "cp ${src_file} ./$i/${src_file_basename}.real"
        cp "${src_file}" "./$i/${src_file_basename}.real"
        cp "${src_file}.brk" "$src_file"
    done

    clang-format -i src/server.c
    echo "cp src/server.c ./$i/server.c.real-1"
    cp src/server.c ./$i/server.c.real-1
    cp src/server.c.brk src/server.c

    if [ "$redisServerFlag" -eq 1 ]; then
        cp src/ae.c $redis_dir/$i/ae.c.real-1
        cp src/ae.c.brk src/ae.c
    fi


    make distclean

    # 新版本完全真实执行不沿着符号执行路径
    git restore ./src/
    cp ../Makefile ./src/Makefile

    rm src/.make-settings
    make distclean
    echo "EOF" | ./real_executor-new --measure-modified-part=false --loop-boost=false 1
    
    make -j4
    make install PREFIX=$i-2
    cd src/$i-2/bin

    touch redis-server.log
    touch redis.pid
    cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
    cp /data3/sjz/AE/redis/run-redis-2.sh ./run-redis-2.sh

    cp /data3/sjz/AE/redis/tools/redis-order.txt .
    ../../../get_redis_2 $testcase_line > get_redis_2.txt
    if [ "$redisServerFlag" -eq 1 ]; then
        sh run-redis-2.sh > redis-server.log1
    else
        echo "$testcase_content" > get_redis_3.txt
        bash run-redis.sh > redis-server.log1
    fi
    sleep 2
    
    cp redis-server.log1 $redis_dir/$i/real-execute-res-pure.txt

    # 第11步：备份真实执行插桩后的源文件，还原源文件
    cd $redis_dir
    for src_file in $src_files; do
        src_file_basename=$(basename "$src_file")
        clang-format -i "$src_file"
        echo "cp ${src_file} ./$i/${src_file_basename}.real-pure"
        cp "${src_file}" "./$i/${src_file_basename}.real-pure"
        cp "${src_file}.brk" "$src_file"
    done

    clang-format -i src/server.c
    echo "cp src/server.c ./$i/server.c.real-1-pure"
    cp src/server.c ./$i/server.c.real-1-pure
    cp src/server.c.brk src/server.c

    if [ "$redisServerFlag" -eq 1 ]; then
        cp src/ae.c $redis_dir/$i/ae.c.real-1-pure
        cp src/ae.c.brk src/ae.c
    fi

    #结束

    make distclean
    # TODO：
    # 第10步：可能还需要插桩和运行旧版本
    # 旧版本只需要对end-to-end函数插桩，不需要对其他函数插桩，用以下命令
    
    # 进入
    cd /data3/sjz/AE/redis
    
    cd redis-$command-old
    git restore ./src/
    

    mkdir "$i"
    
    for src_file in $src_files; do
        if [ ! -f "${src_file}.brk" ]; then
            cp "$src_file" "${src_file}.brk"
        fi
    done

    if [ ! -f "src/server.c.brk" ]; then
        cp "src/server.c" "src/server.c.brk"
    fi

    if [ "$redisServerFlag" -eq 1 ]; then
        cp src/ae.c src/ae.c.brk
    fi
    make distclean
    cp /data3/sjz/AE/redis/tools/.clang-format .
    cp /data3/sjz/AE/redis/tools/new_function_analyzer.sh .
    cp /data3/sjz/AE/redis/tools/commit_analyzer .
    cp /data3/sjz/AE/redis/tools/call_analyzer .
    cp /data3/sjz/AE/redis/tools/symbolic_analyzer .
    cp /data3/sjz/AE/redis/tools/make_symbolizer-new .
    cp /data3/sjz/AE/redis/tools/real_executor-new .
    cp /data3/sjz/AE/redis/tools/jsonAnalyze .
    cp /data3/sjz/AE/redis/tools/jsonAnalyze-icount .
    cp /data3/sjz/AE/redis/tools/get_redis_1 . 
    cp /data3/sjz/AE/redis/tools/get_redis_2 .
    cp /data3/sjz/AE/redis/tools/redis-order.txt .

    cp ../Makefile ./src/Makefile


    if [ "$redisServerFlag" -eq 1 ]; then
        echo "$(pwd)/src/server.c main start" > end_to_end.txt
        echo "$(pwd)/src/ae.c aeMain start" >> end_to_end.txt
    else
        echo "$(pwd)/src/server.c processCommand start" > end_to_end.txt
        echo "$(pwd)/src/server.c processCommand end" >> end_to_end.txt
    fi

    #旧版本符号执行

    echo "$block" | ./make_symbolizer-new --new-version=false 1
    make distclean
    make noopt -j4
    # 可执行文件被保存在./src/app/bin 目录下
    rm $(pwd)/src/app/bin/redis-server
    rm $(pwd)/src/app/bin/redis-cli

    make install PREFIX=app

    file_path_redis_server="$(pwd)/src/app/bin/redis-server"

    # 检查是否编译成功
    if [ ! -f "$file_path_redis_server" ]; then
        # 编译失败
        
        make distclean
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            clang-format -i "$src_file"
            echo "cp ${src_file} ./$i/${src_file_basename}.sym"
            cp "${src_file}" "./$i/${src_file_basename}.sym"
            cp "${src_file}.brk" "$src_file"
        done
        
        cp src/server.c ./$i/server.c.sym-1
        cp src/server.c.brk src/server.c
        
        #todo redis-serve启动过程需要额外恢复
        if [ "$redisServerFlag" -eq 1 ]; then
            cp src/ae.c ./$i/ae.c.sym-1
            cp src/ae.c.brk src/ae.c
        fi
        touch ./$i/compile.txt
        echo "fail compile" > ./$i/compile.txt
        # i=$((${i} + 1))
        # cd $redis_dir
        # continue
    else
        # 执行s2e 注意s2e-config.lua文件不需要修改，已经是固定格式
        # ln -s的对象是 redis-server redis-cli 
        # dump.rdb不需要修改
        rm /home/sjz/S2E/s2e/projects/redis-server/redis-server
        rm /home/sjz/S2E/s2e/projects/redis-server/redis-cli
        ln -s $(pwd)/src/app/bin/redis-server /home/sjz/S2E/s2e/projects/redis-server/redis-server
        ln -s $(pwd)/src/app/bin/redis-cli /home/sjz/S2E/s2e/projects/redis-server/redis-cli



        
        #是否是redis-server启动过程
        if [ "$redisServerFlag" -eq 1 ]; then
            echo "Testcase Result: $redis_inst"
            bootstrap_path="/data3/sjz/AE/redis/bootstrap-1.sh"
            cp /data3/sjz/AE/redis/bootstrap.sh /data3/sjz/AE/redis/bootstrap-1.sh
            sed -i "232i$redis_inst" "$bootstrap_path"
        
        else
            testcase_content=$(echo "$testcase_line" | sed 's/^testcase:.*redis-cli //')
            testcase_result="./redis-cli $testcase_content"
            echo "Testcase Result: $testcase_result"
            bootstrap_path="/data3/sjz/AE/redis/bootstrap-1.sh"
            cp /data3/sjz/AE/redis/bootstrap.sh /data3/sjz/AE/redis/bootstrap-1.sh
            sed -i "244i$testcase_result" "$bootstrap_path"
            sed -i "232i$redis_inst" "$bootstrap_path"
        fi
    

        cp /data3/sjz/AE/redis/bootstrap-1.sh /home/sjz/S2E/s2e/projects/redis-server/bootstrap.sh

        #保存redis_old目录
        redis_dir_old=$(pwd)
        cd /home/sjz/S2E/s2e/projects/redis-server/
        # 设置launch-s2e.sh 超时时间为600秒（10分钟）,后续可能会调整
        timeout_time=600
        # 执行脚本并设置超时
        timeout $timeout_time ./launch-s2e.sh 
        # 检查命令的退出状态
        if [ $? -eq 124 ]; then
            echo "launch-s2e.sh 脚本执行超时，已被终止。"
            # /home/sjz/S2E/s2e/install/bin/qemu-system-x86_64 kill S2E
            pid=$(pgrep -f /home/sjz/S2E/s2e/install/bin/qemu-system-x86_64)
            if [ -z "$pid" ]; then
                echo "S2E 被杀死"
            else
                kill -9 "$pid"
            fi
            sleep 1
            
            cd $redis_dir_old
            make distclean
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                clang-format -i "$src_file"
                echo "cp ${src_file} ./$i/${src_file_basename}.sym"
                cp "${src_file}" "./$i/${src_file_basename}.sym"
                cp "${src_file}.brk" "$src_file"
            done
            
            cp src/server.c ./$i/server.c.sym-1
            cp src/server.c.brk src/server.c
            
            #todo redis-serve启动过程需要额外恢复
            if [ "$redisServerFlag" -eq 1 ]; then
                cp src/ae.c ./$i/ae.c.sym-1
                cp src/ae.c.brk src/ae.c
            fi
            # i=$((${i} + 1))
            # cd $redis_dir
            # continue
        else
            s2e execution_trace redis-server -pp
            
            cd $redis_dir_old
            cp /home/sjz/S2E/s2e/projects/redis-server/s2e-last/execution_trace.json ./$i/execution_trace.json
            cp /home/sjz/S2E/s2e/projects/redis-server/serial.txt ./$i/serial.txt
            mkdir -p ./$i/s2e_res
            cp -r /home/sjz/S2E/s2e/projects/redis-server/s2e-last/ ./$i/s2e_res/
            cp /home/sjz/S2E/s2e/projects/redis-server/s2e-last/debug.txt ./$i/s2e_res/debug.txt
            echo "$command" > ./$i/s2e_res/commitId.txt
        
            # 第7步：备份符号化插桩后的源文件，还原源文件
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                clang-format -i "$src_file"
                echo "cp ${src_file} ./$i/${src_file_basename}.sym"
                cp "${src_file}" "./$i/${src_file_basename}.sym"
                cp "${src_file}.brk" "$src_file"
            done

            cp src/server.c "./$i/server.c.sym-1"
            cp src/server.c.brk src/server.c
            #redis-serve启动过程需要额外恢复
            if [ "$redisServerFlag" -eq 1 ]; then
                cp src/ae.c "./$i/ae.c.sym-1"
                cp src/ae.c.brk src/ae.c
            fi
            ./jsonAnalyze-icount ./$i/execution_trace.json > icount-old.txt
            cp icount-old.txt $redis_dir/$i/icount-old.txt
        fi
    fi
    

    #旧版本真实执行
    cd /data3/sjz/AE/redis
    
    cd redis-$command-old
    git restore ./src/
    cp ../Makefile ./src/Makefile
    make distclean

    echo "EOF" | ./real_executor-new --measure-modified-part=false --loop-boost=false 1

    
    make -j4
    make install PREFIX=$i

    cd src/$i/bin
    
    touch redis-server.log
    touch redis.pid
    cp /data3/sjz/AE/redis/run-redis.sh ./run-redis.sh 
    cp /data3/sjz/AE/redis/run-redis-2.sh ./run-redis-2.sh 
    
    cp /data3/sjz/AE/redis/tools/redis-order.txt .
    ../../../get_redis_2 $testcase_line > get_redis_2.txt

    if [ "$redisServerFlag" -eq 1 ]; then
        sh run-redis-2.sh > redis-server.log1
    else
        echo "$testcase_content" > get_redis_3.txt
        bash run-redis.sh > redis-server.log1
    fi

    sleep 2

    cp redis-server.log1 $redis_dir/$i/real-execute-res-old.txt

    cd /data3/sjz/AE/redis
    cd redis-$command-old
    clang-format -i src/server.c
    echo "cp src/server.c $redis_dir/$i/server.c.real.old"
    cp src/server.c $redis_dir/$i/server.c.real.old
    cp src/server.c.brk src/server.c
    if [ "$redisServerFlag" -eq 1 ]; then
        cp src/ae.c $redis_dir/$i/ae.c.real.old
        cp src/ae.c.brk src/ae.c
    fi

    make distclean
    
    cd $redis_dir/$i
    cp /data3/sjz/AE/redis/run-getres.sh ./run-getres.sh
    cp /data3/sjz/AE/redis/run-getres.py ./run-getres.py
    cp /data3/sjz/AE/redis/run-getres-modify.py ./run-getres-modify.py
    cp /data3/sjz/AE/redis/run-getres-icount.py ./run-getres-icount.py
    
    sh run-getres.sh
    cd $redis_dir

    i=$((${i} + 1))
done

# 删除临时备份文件
rm -f -- *.brk

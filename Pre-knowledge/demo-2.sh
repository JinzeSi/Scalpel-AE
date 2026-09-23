# !/bin/bash

command=$1
# #生成final_obj.ll
init_dir=$(pwd)

echo "$command"
echo "$init_dir"

cd redis || exit 1



make distclean || exit 1
make CC=/data2/sjz/llvm-sjz/llvm-project/build2/bin/clang -j8 || exit 1
echo "step1111"
make install CC=/data2/sjz/llvm-sjz/llvm-project/build2/bin/clang PREFIX=/data2/sjz/Pre-knowledge/redis/app2 || exit 1


cp /data2/sjz/Pre-knowledge/socket-26-02-01/socket.c ./src/socket.c || exit 1

make distclean || exit 1
make CC=/data2/sjz/llvm-sjz/llvm-project/build/bin/clang -j8 || exit 1
echo "step2222"
make install CC=/data2/sjz/llvm-sjz/llvm-project/build2/bin/clang PREFIX=/data2/sjz/Pre-knowledge/redis/app || exit 1



cd $init_dir


#备份
rm -rf re-build

mkdir -p re-build

FILENAME="redis-order-1.txt"
i=1
./build_KeyValue_hashTable &
while IFS= read -r line; do
    echo 111
    rm redis.conf
    touch redis.conf
    ASAN_OPTIONS=coverage=1 ./redis/app/bin/redis-server --pidfile redis.pid --save "" &

    sleep 10

    $line

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1
    
    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1


    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME"


FILENAME1="redis-order-2.txt"
while IFS= read -r line; do
    echo 111
    rm redis.conf
    touch redis.conf
    ASAN_OPTIONS=coverage=1 ./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local &

    sleep 10

    $line

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1

    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME1"

FILENAME2="redis-order-3.txt"
while IFS= read -r line; do
    rm redis.conf
    touch redis.conf
    ASAN_OPTIONS=coverage=1 ./redis/app/bin/redis-server --pidfile redis.pid --save "" --enable-module-command local --loadmodule /data2/sjz/Pre-knowledge/panda.so &

    sleep 10

    $line

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1

    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME2"

FILENAME3="redis-order-4.txt"
while IFS= read -r line; do
    rm redis.conf
    touch redis.conf
    ASAN_OPTIONS=coverage=1 ./redis/app/bin/redis-server --pidfile redis.pid --save "" --cluster-enabled yes &

    sleep 10

    $line

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1

    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME3"

FILENAME4="redis-order-5.txt"
while IFS= read -r line; do
    rm redis.conf
    touch redis.conf
    ASAN_OPTIONS=coverage=1 ./redis/app/bin/redis-server --pidfile redis.pid  --save "" --appendonly yes &

    sleep 10

    $line

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1

    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME4"


FILENAME5="redis-order-6.txt"
while IFS= read -r line; do
    rm redis.conf
    touch redis.conf
    ASAN_OPTIONS=coverage=1 ./redis/app/bin/redis-server --pidfile redis.pid  --save "" --enable-debug-command yes &

    sleep 10

    $line

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1

    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME5"


FILENAME6="redis-order-7.txt"
while IFS= read -r line; do
    rm redis.conf
    touch redis.conf
    ASAN_OPTIONS=coverage=1 ./redis/app/bin/redis-server /data2/sjz/Pre-knowledge/redis.conf --pidfile redis.pid  --save "" &

    sleep 10

    $line

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1

    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME6"



FILENAME7="redis-order-redis-server.txt"

while IFS= read -r line; do
    rm redis.conf
    touch redis.conf
    testcase_content=$(echo "$line" | sed 's|^./redis/app/bin/redis-server ||')
    echo "line:$line"
    echo "$testcase_content"
    ASAN_OPTIONS=coverage=1 ./redis/app2/bin/redis-server $testcase_content &

    sleep 10

    filename="redis.pid"

    pid=$(head -n 1 "$filename")

    kill -2 "$pid"
    sleep 1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 1

    rm res_BB.txt
    rm test.symcov

    sancov --print *.sancov > res_BB.txt
    sancov -symbolize *.sancov ./redis/app2/bin/redis-server > test.symcov

    rm *.sancov
    

    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data2/sjz/llvm-sjz/llvm-project/build2/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/Pre-knowledge/redis/app/bin/redis-server < res_BB.txt >> re-build/BB-info-$i.txt
    
    
    i=$((i + 1))
done < "$FILENAME7"


# 备份
file_path2="build_KeyValue_hashTable.txt"

# 检查文件是否存在 标志demo.sh是否完成
while [ ! -f "$file_path2" ]
do
echo "Waiting for file(build_KeyValue_hashTable.txt) to appear..."
sleep 3  
done 
rm -rf init_file_$command
rm -rf re-build-$command
mkdir -p init_file_$command

cp -r re-build re-build-$command
cp redis-BB.txt ./init_file_$command
cp redis-BB-res-1.txt ./init_file_$command
cp redis-BB-res-2.txt ./init_file_$command
cp redis-BB-res-3.txt ./init_file_$command
cp redis/src/final_obj.ll ./init_file_$command



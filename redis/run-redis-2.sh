# ./get_redis_2 $testcase_line > get_redis_2.txt
#     echo "$testcase_content" > get_redis_3.txt
#     sh run-redis.sh > redis-server.log1

redis_inst=$(tail -n 1 get_redis_2.txt)
pkill redis-server
touch redis.conf
cp /data3/sjz/AE/redis/panda.so ./
# print redis instruction
echo "Redis Instruction: $redis_inst"
filename="redis.pid"
for i in $(seq 1 100)
do
    taskset -c 30 $redis_inst & > ./redis-server.log2
    sleep 5
    pid=$(head -n 1 "$filename")
    kill -9 "$pid"
    sleep 0.1

    pkill redis-server
    sleep 0.1

    pid=$(pgrep -f redis-server)
    if [ -z "$pid" ]; then
        echo "redis-server被杀死"
    else
        kill -2 "$pid"
    fi
    sleep 0.1
done


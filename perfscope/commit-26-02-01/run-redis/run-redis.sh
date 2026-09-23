# ./get_redis_2 $testcase_line > get_redis_2.txt
#     echo "$testcase_content" > get_redis_3.txt
#     sh run-redis.sh > redis-server.log1

redis_inst=$(tail -n 1 get_redis_2.txt)
testcase_content=$(tail -n 1 get_redis_3.txt)
pkill redis-server
touch redis.conf
cp /data/sjz/commit-analysis/redis-run/panda.so ./
taskset -c 45 $redis_inst & > ./redis-server.log2
sleep 10

if [[ $testcase_content == "DEBUG RELOAD NOSAVE NOFLUSH MERGE" ]]; then
    for i in $(seq 1 300)
    do
      taskset -c 47 ./redis-cli $testcase_content > /dev/null
    done
else
    for i in $(seq 1 30000)
    do
      taskset -c 57 ./redis-cli $testcase_content > /dev/null
    done
fi


filename="redis.pid"

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

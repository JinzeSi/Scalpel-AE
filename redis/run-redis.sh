#!/bin/bash

# ./get_redis_2 $testcase_line > get_redis_2.txt
#     echo "$testcase_content" > get_redis_3.txt
#     sh run-redis.sh > redis-server.log1

redis_inst=$(tail -n 1 get_redis_2.txt)
testcase_content=$(tail -n 1 get_redis_3.txt)

# Parse quoted arguments without executing shell operators or expanding globs.
mapfile -d '' -t testcase_args < <(
    python3 -c '
import shlex
import sys

try:
    args = shlex.split(sys.argv[1])
except ValueError as error:
    print(f"Invalid testcase: {error}", file=sys.stderr)
    sys.exit(1)
sys.stdout.buffer.write(b"".join(arg.encode() + b"\0" for arg in args))
' "$testcase_content"
)
if [[ ${#testcase_args[@]} -eq 0 || -z "${testcase_args[0]}" ]]; then
    echo "No valid testcase command in get_redis_3.txt" >&2
    exit 1
fi

testcase_command=${testcase_args[0]^^}
testcase_subcommand=${testcase_args[1]:-}
use_benchmark=1
case "$testcase_command:${testcase_subcommand^^}" in
    DEBUG:RELOAD)
        echo "Skipping DEBUG RELOAD testcase"
        exit 0
        ;;
    -*|RENAME:*|RENAMENX:*|BGREWRITEAOF:*|BLPOP:*|BRPOP:*|BRPOPLPUSH:*|\
    REPLCONF:*|EVAL:*|EVALSHA:*|MODULE:LOAD|MODULE:LOADEX|MODULE:UNLOAD|\
    CLUSTER:ADDSLOTS|CLUSTER:ADDSLOTSRANGE|CLUSTER:DELSLOTS|CLUSTER:DELSLOTSRANGE)
        use_benchmark=0
        ;;
esac

pkill redis-server
touch redis.conf
cp /data3/sjz/AE/redis/panda.so ./
# print redis instruction
echo "Redis Instruction: $redis_inst"
taskset -c 45 $redis_inst & > ./redis-server.log2
sleep 10

if [[ "$use_benchmark" -eq 1 ]]; then
    taskset -c 57 ./redis-benchmark -n 300000 -c 1 "${testcase_args[@]}" > /dev/null
else
    for ((i = 0; i < 30000; i++)); do
        taskset -c 57 ./redis-cli "${testcase_args[@]}" > /dev/null
    done
fi


filename="/data/sjz/commit-analysis/redis-run/redis.pid"

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

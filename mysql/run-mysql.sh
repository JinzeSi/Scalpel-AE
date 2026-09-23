#!/bin/sh
mysql_inst=$(tail -n 1 get_mysql.txt)
query_count=$(python3 /data3/sjz/AE/mysql/get-sql-times.py --multiplier 1 -- "$mysql_inst") || exit 1
printf 'mysqlslap query count: %s (sql-times.txt x1)\n' "$query_count"
mysql_pid=
cleanup() {
    if [ -n "$mysql_pid" ]; then
        kill "$mysql_pid" 2>/dev/null || true
        sleep 0.1
        if kill -0 "$mysql_pid" 2>/dev/null; then
            kill -KILL "$mysql_pid" 2>/dev/null || true
        fi
        wait "$mysql_pid" 2>/dev/null || true
        sleep 0.1
    fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Only stop this instance; Pre-knowledge may be running another mysqld.
./bin/mysqld --datadir="$(pwd)/bin/data" --socket="$(pwd)/bin/mysql.sock" \
    --thread_stack=2097152 --log-error="$(pwd)/error.log" > mysql-server.log2 2>&1 &
mysql_pid=$!
# Preserve the original startup delay and uncapped benchmark duration.
sleep 10
/data/sjz/commit-analysis/mysql-8.4.4/build/bin/mysqlslap \
    --concurrency=1 --iterations=1 --create-schema=test --query="$mysql_inst" \
    -uroot -S "$(pwd)/bin/mysql.sock" --number-of-queries="$query_count" >> error.log

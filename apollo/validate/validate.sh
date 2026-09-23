#!/bin/bash

for i in 1 4 8 9 10 12 13 14 15
do
    mysql_inst_init=$(cat /home/sjz/apollo/data-3-else/$i.sql)

    mysql_inst=$(echo $mysql_inst_init)

    cd /home/sjz/apollo/opt/old
    rm -r data
    cp -r data.brk data
    bin/mysqld --defaults-file=/home/sjz/apollo/etc/my3307.cnf &
    sleep 3

    mysqlslap --concurrency=1 --iterations=1 --create-schema=test_bd --query="$mysql_inst" -uroot -S /tmp/mysql3307.sock --number-of-queries=40 >> /home/sjz/apollo/data-3-else/$i.log3

    sleep 0.5
    pkill mysqld 
    sleep 0.5
    pid=$(pgrep -f mysqld)
    if [ -z "$pid" ]; then
        echo "mysqld被杀死"
    else
        kill -9 "$pid"
    fi

    cd /home/sjz/apollo/opt/new
    rm -r data
    cp -r /home/sjz/apollo/opt/old/data.brk data
    mv data/mysql3307 data/mysql3308
    bin/mysqld --defaults-file=/home/sjz/apollo/etc/my3308.cnf &
    sleep 3

    mysqlslap --concurrency=1 --iterations=1 --create-schema=test_bd --query="$mysql_inst" -uroot -S /tmp/mysql3308.sock --number-of-queries=40 >> /home/sjz/apollo/data-3-else/$i.log3

    sleep 0.5
    pkill mysqld 
    sleep 0.5
    pid=$(pgrep -f mysqld)
    if [ -z "$pid" ]; then
        echo "mysqld被杀死"
    else
        kill -9 "$pid"
    fi

    # sleep 3
    # cd /data/sjz/fuzz/opt/fix
    # rm -r data
    # cp -r /data/sjz/fuzz/opt/old/data.brk data
    # mv data/mysql3307 data/mysql3308
    # bin/mysqld --defaults-file=/data/sjz/fuzz/etc/my3308.cnf &
    # sleep 3

    # mysqlslap --concurrency=1 --iterations=1 --create-schema=test_bd --query="$mysql_inst" -uroot -S /tmp/mysql3308.sock --number-of-queries=10000 >> /data/sjz/fuzz/data-4/$i.log

    # sleep 0.5
    # pkill mysqld 
    # sleep 0.5
    # pid=$(pgrep -f mysqld)
    # if [ -z "$pid" ]; then
    #     echo "mysqld被杀死"
    # else
    #     kill -9 "$pid"
    # fi
done

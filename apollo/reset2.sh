#!/bin/bash

kill -9 $(ps aux | grep 3307 | grep mysqld | head -n 1 | awk '{print $2}')
kill -9 $(ps aux | grep 3308 | grep mysqld | head -n 1 | awk '{print $2}')

cd /home/sjz/apollo/opt/old
rm -r data
cp -r /home/sjz/apollo/opt/old/data.brk data
bin/mysqld --defaults-file=/home/sjz/apollo/etc/my3307.cnf &
sleep 3

cd /home/sjz/apollo/opt/new
rm -r data
cp -r /home/sjz/apollo/opt/old/data.brk data
mv data/mysql3307 data/mysql3308
bin/mysqld --defaults-file=/home/sjz/apollo/etc/my3308.cnf &
sleep 3

netstat -tuln | grep 3307
netstat -tuln | grep 3308

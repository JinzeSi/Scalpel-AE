#!/bin/bash

kill -9 $(ps aux | grep 3307 | head -n 1 | awk '{print $2}')
kill -9 $(ps aux | grep 3308 | head -n 1 | awk '{print $2}')

cd /home/sjz/apollo/opt/old
rm -r data
mkdir -p data/mysql3307
bin/mysqld --initialize-insecure --user=sjz --basedir=/home/sjz/apollo/opt/old --datadir=/home/sjz/apollo/opt/old/data/mysql3307
bin/mysqld --defaults-file=/home/sjz/apollo/etc/my3307.cnf &
sleep 3
mysql -u root -S /tmp/mysql3307.sock -e "create database test_bd;"
cd ~/apollo
mysql -u root -S /tmp/mysql3307.sock -D test_bd -e "SOURCE init.sql;"
mysql -u root -S /tmp/mysql3307.sock -D test_bd -e "SOURCE insert.sql;"

cd /home/sjz/apollo/opt/new
rm -r data
mkdir -p data/mysql3308
bin/mysqld --initialize-insecure --user=sjz --basedir=/home/sjz/apollo/opt/new --datadir=/home/sjz/apollo/opt/new/data/mysql3308
bin/mysqld --defaults-file=/home/sjz/apollo/etc/my3308.cnf &
sleep 3
mysql -u root -S /tmp/mysql3308.sock -e "create database test_bd;"
cd ~/apollo
mysql -u root -S /tmp/mysql3308.sock -D test_bd -e "SOURCE init.sql;"
mysql -u root -S /tmp/mysql3308.sock -D test_bd -e "SOURCE insert.sql;"

netstat -tuln | grep 3307
netstat -tuln | grep 3308

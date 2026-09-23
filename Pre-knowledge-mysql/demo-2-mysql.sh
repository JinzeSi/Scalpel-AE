# !/bin/bash
command=$1
cd /data2/sjz/Pre-knowledge-mysql

./getBB-mysql /data2/sjz/mysql/mysql-server/build1/sql/mysqld.ll 2> mysql-BB.txt
./get_BB_hashTable-mysql mysql-BB.txt mysql-BB-res-1.txt
./build_BB_hashTable-mysql mysql-BB-res-1.txt mysql-BB-res-2.txt mysql-BB-res-3.txt


# #生成final_obj.ll
init_dir=$(pwd)




cd /data2/sjz/Pre-knowledge-mysql


#备份
rm -rf re-build

mkdir -p re-build

FILENAME="mysql-order.txt"
i=1
rm mysql-map.txt
./build_KeyValue_hashTable-mysql mysql-BB-res-2.txt mysql-BB-res-3.txt mysql-order.txt mysql-map.txt &
while IFS= read -r line; do

    
    cd /data2/sjz/Pre-knowledge-mysql/mysql-data
    /bin/rm -rf data
    tar -zxvf tables.tar.gz -C .

    /bin/rm -rf /data2/sjz/mysql/mysql-server/build4/bin/asan/*
    mkdir -p /data2/sjz/mysql/mysql-server/build4/bin/asan
    cd ..
    /bin/rm -rf mysqld.*.sancov
    ASAN_OPTIONS=coverage=1:coverage_dir=/data2/sjz/mysql/mysql-server/build4/bin/asan /data2/sjz/mysql/mysql-server/build4/bin/mysqld --datadir=/data2/sjz/Pre-knowledge-mysql/mysql-data/data --socket=/data2/sjz/mysql/mysql-server/mysql.sock --thread_stack=2097152 --skip-grant-tables &

    sleep 10
    cd /data2/sjz/Pre-knowledge-mysql
    echo $line >> sql-res.txt 
    /data2/sjz/mysql/mysql-server/build4/bin/mysql -u root -S /data2/sjz/mysql/mysql-server/mysql.sock -D test -e "$line" >> sql-res.txt 2>&1
    /data2/sjz/mysql/mysql-server/build4/bin/mysql -u root -S /data2/sjz/mysql/mysql-server/mysql.sock -D sys -e "shutdown"
    
    
    sleep 4

    cp /data2/sjz/mysql/mysql-server/build4/bin/asan/mysqld.*.sancov ./

    sancov --print mysqld.*.sancov > mysqld.res
    # sancov -symbolize mysqld.*.sancov ../mysqld  > test.symcov

    /bin/rm *.sancov
    
    echo "Instruction:$line" > re-build/BB-info-$i.txt
    /data/sjz/llvm-project/build2/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/mysql/mysql-server/build4/bin/mysqld < mysqld.res >> re-build/BB-info-$i.txt
    
    i=$((i + 1))
done < "$FILENAME"



# 备份
file_path2="build_KeyValue_hashTable.txt"

# 检查文件是否存在 标志demo.sh是否完成
while [ ! -f "$file_path2" ]
do
echo "Waiting for file(build_KeyValue_hashTable.txt) to appear..."
sleep 3  
done 

rm -rf mysql-BB/init_file_$command
rm -rf mysql-BB/re-build-$command
mkdir -p mysql-BB/init_file_$command

cp -r re-build mysql-BB/re-build-$command
cp mysql-BB.txt ./mysql-BB/init_file_$command
cp mysql-BB-res-1.txt ./mysql-BB/init_file_$command
cp mysql-BB-res-2.txt ./mysql-BB/init_file_$command
cp mysql-BB-res-3.txt ./mysql-BB/init_file_$command
# cp redis/src/final_obj.ll ./init_file_$command




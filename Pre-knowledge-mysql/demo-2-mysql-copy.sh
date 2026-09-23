# !/bin/bash


FILENAME="mysql-order.txt"
# i=1
# rm mysql-map.txt
# ./build_KeyValue_hashTable-mysql mysql-BB-res-2.txt mysql-BB-res-3.txt mysql-order.txt mysql-map.txt &
while IFS= read -r line; do

    
    
    echo $line >> tmptmptmp.txt 
    echo "$line" >> tmptmptmp.txt 
    # /data2/sjz/mysql/mysql-server/build4/bin/mysql -u root -S /data2/sjz/mysql/mysql-server/mysql.sock -D test -e "$line" >> sql-res.txt 2>&1
    # /data2/sjz/mysql/mysql-server/build4/bin/mysql -u root -S /data2/sjz/mysql/mysql-server/mysql.sock -D sys -e "shutdown"
    
    
    # sleep 4

    # cp /data2/sjz/mysql/mysql-server/build4/bin/asan/mysqld.*.sancov ./

    # sancov --print mysqld.*.sancov > mysqld.res
    # # sancov -symbolize mysqld.*.sancov ../mysqld  > test.symcov

    # /bin/rm *.sancov
    
    # echo "Instruction:$line" > re-build/BB-info-$i.txt
    # /data/sjz/llvm-project/build2/bin/llvm-symbolizer --inlining --print-address --pretty-print --obj=/data2/sjz/mysql/mysql-server/build4/bin/mysqld < mysqld.res >> re-build/BB-info-$i.txt
    
    # i=$((i + 1))
done < "$FILENAME"






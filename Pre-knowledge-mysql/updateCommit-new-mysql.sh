FILENAME=$1

while IFS= read -r line; do
    if [ "$line" = "e3c9955d236ac19bae4674fea46576aeb41e0d90" ]; then
        cp /data2/sjz/Pre-knowledge-mysql/sql_parse/sql_parse-e3c9955d236ac19bae4674fea46576aeb41e0d90.cc /data2/sjz/Pre-knowledge-mysql/sql_parse/sql_parse.cc  
    fi
    cp mysql-BB-res-2-new.txt mysql-BB-res-2.txt 
    cp mysql-BB-res-3-new.txt mysql-BB-res-3.txt 
    echo $line > gitshow.txt
    ./gitshow-mysql $line /data2/sjz/mysql/mysql-server-2>> gitshow.txt
    echo "end" >> gitshow.txt
    cd /data2/sjz/mysql/mysql-server-2
    git checkout $line

    cd build

    cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-project/build2/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-project/build2/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-project/build2/bin/llvm-link" -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DWITH_BOOST=/data/sjz/commit-analysis/mysql-run/mysql-server/boost_1_77_0 ..
    mv sql/CMakeFiles/mysqld.dir/link.txt sql/CMakeFiles/mysqld.dir/link.txt.brk
    cp /data2/sjz/Pre-knowledge-mysql/mysql-link/link.py ./link.py
    python3 link.py
    make mysqld -j24
    cd sql

    /data/sjz/llvm-project/build2/bin/llvm-dis mysqld.bc -o mysqld.ll
    cd /data2/sjz/Pre-knowledge-mysql/
    ./getBB-mysql /data2/sjz/mysql/mysql-server-2/build/sql/mysqld.ll 2> demo-mysql-BB.txt
    echo "Function:End" >> demo-mysql-BB.txt

    file_path="demo-S2E-times-res-3-flag.txt"

    # 检查文件是否存在
    while [ ! -f "$file_path" ]
    do
    echo "Waiting for file to appear..."
    sleep 3  # 等待5秒
    done    
    cp demo-S2E-times-res-3-flag.txt demo-S2E-times-res-3.txt
    rm demo-S2E-times-res-3-flag.txt

    line_count=$(wc -l < gitshow.txt)
    if [ "$line_count" -lt 3 ]; then
        rm -rf mysql-brk/$line
        mkdir mysql-brk/$line
        echo "The file gitshow.txt has less than 3 lines."
        echo > mysql-BB-res-4.txt
        cp mysql-BB-res-4.txt /data/sjz/call_analyse2.txt
        continue
    fi
    ./update_KeyValue_hashTable-mysql2 1 mysql-BB-res-2.txt mysql-BB-res-3.txt demo-mysql-BB.txt gitshow.txt mysql-BB-res-3-new.txt mysql-BB-res-2-new.txt mysql-map.txt

    #如果触发re-build
    last_line=$(tail -n 1 demo-S2E-times-res-1.txt)
    if [ "$last_line" = "need to re-build pre-knowledge" ]; then
        #要确定demo.sh执行完成，因为有函数在后台执行
        echo "begin rebuild pre-knowledege$line"
        sh demo-1-mysql.sh $line
        sh demo-2-mysql.sh $line


        #要确定demo.sh执行完成，因为有函数在后台执行
        #重新执行上面的逻辑，然后再进行下一轮
       
        file_path2="build_KeyValue_hashTable.txt"

        # 检查文件是否存在 标志demo.sh是否完成
        while [ ! -f "$file_path2" ]
        do
        echo "Waiting for file(build_KeyValue_hashTable.txt) to appear..."
        sleep 3  
        done  
        cp mysql-BB-res-2.txt mysql-BB-res-2-new.txt 
        cp mysql-BB-res-3.txt mysql-BB-res-3-new.txt 
        rm build_KeyValue_hashTable.txt
        ./update_KeyValue_hashTable-mysql2 0 mysql-BB-res-2.txt mysql-BB-res-3.txt demo-mysql-BB.txt gitshow.txt mysql-BB-res-3-new.txt mysql-BB-res-2-new.txt mysql-map.txt
        
        touch generate_S2E_case-1.txt
        ./generate_S2E_case-mysql2 mysql-BB-res-2-new.txt mysql-BB-res-3-new.txt mysql-order-priority.txt mysql-map.txt > generate_S2E_case-2.txt
        python3 dup_S2E_case-1.py 
        python3 dup_S2E_case.py 

        ./generate_S2E_case-2 > mysql-BB-res-4.txt

        rm generate_S2E_case-1.txt

    else
        
        touch generate_S2E_case-1.txt
        ./generate_S2E_case-mysql2 mysql-BB-res-2-new.txt mysql-BB-res-3-new.txt mysql-order-priority.txt mysql-map.txt> generate_S2E_case-2.txt
        python3 dup_S2E_case-1.py 
        python3 dup_S2E_case.py 

        ./generate_S2E_case-2 > mysql-BB-res-4.txt

        rm generate_S2E_case-1.txt
    fi
   

    # 备份
    rm -rf mysql-brk/$line
    mkdir mysql-brk/$line
    cp gitshow.txt ./mysql-brk/$line/gitshow.txt 
    # cp demo-mysql-BB.txt ./mysql-brk/$line/demo-mysql-BB.txt
    cp mysql-BB-res-4.txt ./mysql-brk/$line/mysql-BB-res-4.txt 
    cp demo-S2E-times-res-1.txt ./mysql-brk/$line/demo-S2E-times-res-1.txt
    cp demo-S2E-times-res-2.txt ./mysql-brk/$line/demo-S2E-times-res-2.txt
    cp demo-S2E-times-res-3.txt ./mysql-brk/$line/demo-S2E-times-res-3.txt
    cp mysql-BB-res-2-new.txt ./mysql-brk/$line/mysql-BB-res-2.txt 
    cp mysql-BB-res-3-new.txt ./mysql-brk/$line/mysql-BB-res-3.txt 
       
    #发送给ds00/data
    cp mysql-BB-res-4.txt /data/sjz/call_analyse2.txt
done < "$FILENAME"

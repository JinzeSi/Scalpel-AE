#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/run-common.sh" || exit 1
cd "$MYSQL_RUN_ROOT" || exit 1

# 检查 validate.txt 文件是否存在
if [[ ! -f "validate.txt" ]]; then
    echo "Error: validate.txt not found"
    exit 1
fi
prepare_build_dirs || exit 1

cd /data3/sjz/AE/mysql/mysql-server
cp /data3/sjz/AE/mysql/tool/.clang-format .
cp /data3/sjz/AE/mysql/tool/new_function_analyzer.sh .
cp /data3/sjz/AE/mysql/tool/new_function_combiner.py .
cp /data3/sjz/AE/mysql/tool/commit_analyzer++ .
cp /data3/sjz/AE/mysql/tool/call_analyzer++ .
cp /data3/sjz/AE/mysql/tool/symbolic_analyzer++ .
cp /data3/sjz/AE/mysql/tool/make_symbolizer++ .
cp /data3/sjz/AE/mysql/tool/real_executor++ .
cp /data3/sjz/AE/mysql/tool/jsonAnalyze .
cp /data3/sjz/AE/mysql/tool/jsonAnalyze-icount .
cp /data3/sjz/AE/mysql/tool/get_redis_1 . 
cp /data3/sjz/AE/mysql/tool/get_redis_2 .
cp /data3/sjz/AE/mysql/tool/redis-order.txt .

# 逐行读取 validate.txt 文件
while IFS=" " read -r command command_now target; do
    # 检查是否正确读取了三列
    if [[ -z "$command" || -z "$command_now" || -z "$target" ]]; then
        echo "Warning: Invalid line: $command $command_now $target"
        continue
    fi
    echo "commitId:$command"

    cd /data3/sjz/AE/mysql
    mkdir -p $command_now
    mkdir -p $command-old

    ###### 获取新版本的 compile_commands.json ######
    echo "$command_now: Get compile_commands.json for new version..."
    cd /data3/sjz/AE/mysql/mysql-server
    git restore .
    git checkout -f $command_now
    cd build-ae-new-tmp
    cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-18.1.8/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-18.1.8/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-18.1.8/bin/llvm-link" -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
    cd include
    make -j12 > /dev/null
    echo "$command_now: Get compile_commands.json for new version done."

    ###### 获取旧版本的 compile_commands.json ######
    echo "$command_now: Get compile_commands.json for old version..."
    cd /data3/sjz/AE/mysql/mysql-server
    git restore .
    git checkout -f $command
    cd build-ae-old-tmp
    cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-18.1.8/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-18.1.8/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-18.1.8/bin/llvm-link" -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
    cd include
    make -j12 > /dev/null
    echo "$command_now: Get compile_commands.json for old version done."

    ###### 读取分析结果 ######
    echo "$command_now: Read analysis result..."
    cd /data3/sjz/AE/mysql/mysql-server
    git restore .
    git checkout -f $command_now
    cp /data2/sjz/brk/mysql-run-3-26/$command_now/call_analyse2.txt ./call_analyse2.txt
    relocate_analysis_paths call_analyse2.txt || exit 1
    cp ./call_analyse2.txt ../$command_now/call_analyse2.txt
    # 第4.5步：读取 call_analyse2.txt，其中的内容用空行分隔，第i块(block)内容代表第i次符号执行的信息
    file_path="call_analyse2.txt"
    # 读取文件内容并分割块
    declare -a blocks    # 声明一个数组用于存储每个block
    declare -a blocks_NULL    # 声明一个数组用于存储每个block
    current_block=""    # 当前正在构建的block
    flagEndNULL=0
    while read line
    do
        if [[ "$line" == "" ]]; then
            if [ "$flagEndNULL" -eq 1 ]; then
                if [[ "$current_block" == "End NULL"$'\n' ]]; then
                    flagEndNULL=0
                    current_block=""
                    continue
                else
                    blocks_NULL+=("$current_block")
                    current_block=""
                    continue
                fi
            else
                if [[ "$current_block" == "Begin NULL"$'\n' ]]; then
                    flagEndNULL=1
                    current_block=""
                    continue
                else
                    blocks+=("$current_block")
                    current_block=""
                    continue
                fi
            fi
        fi
        current_block+="$line"$'\n'
    done < "$file_path"
    # 确保最后一个block被添加，如果文件不以空行结束
    if [[ -n "$current_block" ]]; then
        if [ "$flagEndNULL" -eq 0 ]; then
            blocks+=("$current_block")
        else
            if [[ "$current_block" == "END NULL"$'\n' ]]; then
                current_block=""
            else
                blocks_NULL+=("$current_block")
            fi
        fi
    fi
    echo "$command_now: Read analysis result done."

    ###### 循环执行仅需真实执行的 ######
    echo "$command_now: Loop execute real-execution only.."
    i=1
    for block in "${blocks_NULL[@]}"; do
        if [[ "$block" == "" ]]; then
            continue
        fi
        echo "info: $block"
        if [ ! -d "../$command_now/$i" ]; then
            mkdir -p "../$command_now/$i"
            mkdir -p "../$command-old/$i"
        fi

        ###### 新版本执行准备 ######
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        git checkout -f $command_now
        src_files=$(echo "$block" | grep "/data3/sjz/AE/mysql/mysql-server/" | awk '{print $2}' | sort | uniq)
        last_line=$(echo "$block" | tail -n 2 | head -n 1)
        echo "$last_line"
        if [ "$last_line" = "testcase:no testcase" ]; then
            continue
        fi
        if [[ "$i" -ne "$target" ]]; then
            i=$((${i} + 1))
            continue
        fi
        # 临时备份源文件，以便还原
        echo "src_files: $src_files"
        # for src_file in $src_files; do
        #     if [ ! -f "${src_file}.brk" ]; then
        #         cp "$src_file" "${src_file}.brk"
        #     fi
        # done
        # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
        rm end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state start" > end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state end" >> end_to_end.txt
        testcase_line=$(echo "$last_line" | sed 's/^testcase://')
        rm testcase.txt
        echo "$testcase_line" > testcase.txt
        cp testcase.txt /data3/sjz/AE/mysql/$command_now/$i/testcase.txt

        ###### 新版本测量修改部分真实执行插桩 ######
        echo "$command_now: $i: Real-execution only measure-modified-part instrument for new version.."
        cd /data3/sjz/AE/mysql/mysql-server
        mysql_dir=$(pwd)
        echo "$block" | ./real_executor++ --measure-modified-part=true --loop-boost=true --server-log=true ./build-ae-new-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution only measure-modified-part instrument for new version done."

        ###### 新版本测量修改部分编译 ######
        echo "$command_now: $i: Real-execution only measure-modified-part compile for new version.."
        cd build-ae-new
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Real-execution only measure-modified-part compile for new version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}-modified-part.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-modified-part.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-modified-part.real-1"
            

            touch ../$command_now/$i/compile.txt
            echo "新版本测量修改部分真实执行插桩后编译失败" >> ../$command_now/$i/compile.txt
            cp build-ae-new/compile.log /data3/sjz/AE/mysql/$command_now/$i/compile-modified-part.real.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-new/bin/mysqld /data3/sjz/AE/mysql/$command_now/$i/mysqld-modified-part
            echo "$command_now: $i: Real-execution only measure-modified-part compile for new version done."

            ###### 新版本测量修改部分运行 ######
            echo "$command_now: $i: Real-execution only measure-modified-part run for new version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-modified-part-res.txt
            echo "$command_now: $i: Real-execution only measure-modified-part run for new version done."

            # 备份真实执行插桩后的源文件，还原源文件
            cd $mysql_dir
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}-modified-part.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-modified-part.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-modified-part.real-1"
            
        fi

        ###### 新版本无占比真实执行插桩 ######
        echo "$command_now: $i: Real-execution only no-measure-modified-part instrument for new version.."
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
        echo "$block" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-ae-new-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution only no-measure-modified-part instrument for new version done."

        ###### 新版本无占比编译 ######
        echo "$command_now: $i: Real-execution only no-measure-modified-part compile for new version.."
        cd build-ae-new
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt    
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Real-execution only no-measure-modified-part compile for new version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real-1"
            

            touch ../$command_now/$i/compile.txt
            echo "新版本无占比真实执行插桩后编译失败" >> ../$command_now/$i/compile.txt
            cp build-ae-new/compile.log /data3/sjz/AE/mysql/$command_now/$i/compile.real.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-new/bin/mysqld /data3/sjz/AE/mysql/$command_now/$i/mysqld-real
            echo "$command_now: $i: Real-execution only no-measure-modified-part compile for new version done."
            
            ###### 新版本无占比运行 ######
            echo "$command_now: $i: Real-execution only no-measure-modified-part run for new version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh    
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-res.txt
            echo "$command_now: $i: Real-execution only no-measure-modified-part run for new version done."

            # 备份真实执行插桩后的源文件，还原源文件    
            cd $mysql_dir
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real-1"
            
        fi

        ###### 新版本完全真实执行插桩 ######
        echo "$command_now: $i: Real-execution completely instrument for new version.."
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
        echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-ae-new-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution completely instrument for new version done."

        ###### 新版本完全真实执行编译 ######
        echo "$command_now: $i: Real-execution completely compile for new version.."
        cd build-ae-new
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Real-execution completely compile for new version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-pure.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-pure.real-1"
            

            touch ../$command_now/$i/compile.txt
            echo "新版本完全真实执行插桩后编译失败" >> ../$command_now/$i/compile.txt
            cp build-ae-new/compile.log /data3/sjz/AE/mysql/$command_now/$i/compile-pure.real.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-new/bin/mysqld /data3/sjz/AE/mysql/$command_now/$i/mysqld-pure
            echo "$command_now: $i: Real-execution completely compile for new version done."

            ###### 新版本完全真实执行运行 ######
            echo "$command_now: $i: Real-execution completely run for new version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-res-pure.txt
            echo "$command_now: $i: Real-execution completely run for new version done."

            # 备份真实执行插桩后的源文件，还原源文件
            cd $mysql_dir
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-pure.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-pure.real-1"
            
        fi

        ###### 旧版本执行准备 ######
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        git checkout -f $command
        rm end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state start" > end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state end" >> end_to_end.txt

        ###### 旧版本无占比真实执行插桩 ######
        echo "$command_now: $i: Real-execution only no-measure-modified-part instrument for old version.."
        echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-ae-old-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution only no-measure-modified-part instrument for old version done."
            
        ###### 旧版本无占比编译 ######
        echo "$command_now: $i: Real-execution only no-measure-modified-part compile for old version.."
        cd build-ae-old
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Real-execution only no-measure-modified-part compile for old version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            # clang-format -i sql/sql_parse.cc
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # echo "cp ${src_file} ../$command-old/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command-old/$i/${src_file_basename}.real"
            done
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real.old-1"
            

            touch ../$command-old/$i/compile.txt
            echo "旧版本无占比真实执行插桩后编译失败" >> ../$command-old/$i/compile.txt
            cp build-ae-old/compile.log /data3/sjz/AE/mysql/$command-old/$i/compile.real.old.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-old/bin/mysqld /data3/sjz/AE/mysql/$command-old/$i/mysqld-real
            echo "$command_now: $i: Real-execution only no-measure-modified-part compile for old version done."

            ###### 旧版本无占比运行 ######
            echo "$command_now: $i: Real-execution only no-measure-modified-part run for old version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-res-old.txt
            echo "$command_now: $i: Real-execution only no-measure-modified-part run for old version done."

            # 备份真实执行插桩后的源文件，还原源文件
            cd $mysql_dir
            # clang-format -i sql/sql_parse.cc
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # echo "cp ${src_file} ../$command-old/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command-old/$i/${src_file_basename}.real"
            done
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real.old-1"
            

            ###### 真实执行比较 ######
            echo "$command_now: $i: Real-execution compare.."
            cd $mysql_dir
            cd ../$command_now/$i
            cp /data3/sjz/AE/mysql/run-getres.sh ./run-getres.sh
            cp /data3/sjz/AE/mysql/run-getres.py ./run-getres.py
            cp /data3/sjz/AE/mysql/run-getres-modify.py ./run-getres-modify.py
            cp /data3/sjz/AE/mysql/run-getres-icount.py ./run-getres-icount.py
            sh run-getres.sh
            cd $mysql_dir
            echo "$command_now: $i: Real-execution compare done."
        fi
        
        i=$((${i} + 1))
    done
    echo "$command_now: Loop execute real-execution only done."

    ###### 循环执行需要符号执行的 ######
    echo "$command_now: Loop execute symbolic-execution and real-execution.."
    for block in "${blocks[@]}"; do
        if [[ "$block" == "" ]]; then
            continue
        fi
        echo "info: $block"
        if [ ! -d "../$command_now/$i" ]; then
            mkdir -p "../$command_now/$i"
            mkdir -p "../$command-old/$i"
        fi

        ###### 新版本执行准备 ######
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        git checkout -f $command_now
        src_files=$(echo "$block" | grep "/data3/sjz/AE/mysql/mysql-server/" | awk '{print $2}' | sort | uniq)
        last_line=$(echo "$block" | tail -n 2 | head -n 1)
        echo "$last_line"
        if [ "$last_line" = "testcase:no testcase" ]; then
            continue
        fi
        if [[ "$i" -ne "$target" ]]; then
            i=$((${i} + 1))
            continue
        fi
        # 临时备份源文件，以便还原
        echo "src_files: $src_files"
        # for src_file in $src_files; do
        #     if [ ! -f "${src_file}.brk" ]; then
        #         cp "$src_file" "${src_file}.brk"
        #     fi
        # done
        # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
        rm end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state start" > end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state end" >> end_to_end.txt
        testcase_line=$(echo "$last_line" | sed 's/^testcase://')
        rm testcase.txt
        echo "$testcase_line" > testcase.txt
        cp testcase.txt /data3/sjz/AE/mysql/$command_now/$i/testcase.txt

        ###### 新版本符号执行插桩 ######
        echo "$command_now: $i: Symbolic-execution instrument for new version.."
        cd /data3/sjz/AE/mysql/mysql-server
        mysql_dir=$(pwd)
        rm modified_part_info.txt
        echo "$block" | ./make_symbolizer++ --new-version=true ./build-ae-new-tmp/compile_commands.json
        cp modified_part_info.txt /data3/sjz/AE/mysql/$command_now/$i/modified_part_info.txt
        echo "$command_now: $i: Symbolic-execution instrument for new version done."

        ###### 新版本符号执行编译 ######
        echo "$command_now: $i: Symbolic-execution compile for new version.."
        # 第6步：-O0编译、s2e运行（testcase行存放在 testcase.txt）、提取结果存放到 symbolic_testcase.txt
        cd build-ae-new
        /bin/rm bin/mysqld
        cmake -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Symbolic-execution compile for new version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.sym"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}.sym"
            done
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.sym-1"
            

            touch ../$command_now/$i/compile.txt
            echo "新版本符号执行插桩后编译失败" >> ../$command_now/$i/compile.txt
            cp build-ae-new/compile.log /data3/sjz/AE/mysql/$command_now/$i/compile.sym.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-new/bin/mysqld /data3/sjz/AE/mysql/$command_now/$i/mysqld-sym
            echo "$command_now: $i: Symbolic-execution compile for new version done."

            ###### 新版本符号执行运行 ######
            echo "$command_now: $i: Symbolic-execution run for new version.."
            ln -sf $(pwd)/bin/mysqld /home/sjz/S2E/s2e/projects/mysqld/mysqld
            ln -sf $(pwd)/bin/mysql /home/sjz/S2E/s2e/projects/mysqld/mysql
            tar -czvf output.tar.gz $(find ./library_output_directory -name "libabsl_*" -o -name "libprotobuf-lite.so.24.4.0") > /dev/null
            cp output.tar.gz /home/sjz/S2E/s2e/projects/mysqld/output.tar.gz
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz /home/sjz/S2E/s2e/projects/mysqld/tables.tar.gz
            mysql_inst="./mysql -u root -S \$(pwd)/mysql.sock -D test -e \"$testcase_line\" "
            echo "MySQL inst: $mysql_inst"
            bootstrap_path="/data3/sjz/AE/mysql/bootstrap-1.sh"
            cp /data3/sjz/AE/mysql/bootstrap.sh /data3/sjz/AE/mysql/bootstrap-1.sh
            sed -i "240i$mysql_inst" "$bootstrap_path"
            cp /data3/sjz/AE/mysql/bootstrap-1.sh /home/sjz/S2E/s2e/projects/mysqld/bootstrap.sh
            #保存mysql目录
            cd /data3/sjz/AE/mysql/mysql-server
            mysql_dir=$(pwd)
            cd /home/sjz/S2E/s2e/projects/mysqld
            # 设置launch-s2e.sh 超时时间为600秒（10分钟）,后续可能会调整
            timeout_time=600
            # 执行脚本并设置超时
            timeout $timeout_time ./launch-s2e.sh 
            # 检查命令的退出状态
            if [ $? -eq 124 ]; then
                echo "$command_now: $i: Symbolic-execution run for new version timeout in launch-s2e.sh."
                pid=$(pgrep -f /home/sjz/S2E/s2e/install/bin/qemu-system-x86_64)
                if [ -z "$pid" ]; then
                    echo "S2E 被杀死"
                else
                    kill -9 "$pid"
                fi
                sleep 1
                # 备份符号化插桩后的源文件，还原源文件
                cd $mysql_dir
                for src_file in $src_files; do
                    src_file_basename=$(basename "$src_file")
                    # clang-format -i "$src_file"
                    # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.sym"
                    cp "${src_file}" "../$command_now/$i/${src_file_basename}.sym"
                done
                cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.sym-1"
                
                # i=$((${i} + 1))
                # continue
            else
                echo "$command_now: $i: Symbolic-execution run for new version done."

                ###### 新版本符号执行获取结果 ######
                echo "$command_now: $i: Get symbolic-execution result for new version.."
                s2e execution_trace mysqld -pp
                cd $mysql_dir
                cp /home/sjz/S2E/s2e/projects/mysqld/s2e-last/execution_trace.json ../$command_now/$i/execution_trace.json
                cp /home/sjz/S2E/s2e/projects/mysqld/serial.txt ../$command_now/$i/serial.txt
                mkdir -p ../$command_now/$i/s2e_res
                cp -r /home/sjz/S2E/s2e/projects/mysqld/s2e-last/ ../$command_now/$i/s2e_res/
                cp /home/sjz/S2E/s2e/projects/mysqld/s2e-last/debug.txt ../$command_now/$i/s2e_res/debug.txt
                echo "$command_now" > ../$command_now/$i/s2e_res/commitId.txt
                # 备份符号化插桩后的源文件，还原源文件
                for src_file in $src_files; do
                    src_file_basename=$(basename "$src_file")
                    # clang-format -i "$src_file"
                    # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.sym"
                    cp "${src_file}" "../$command_now/$i/${src_file_basename}.sym"
                done
                cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.sym-1"
                
                ./jsonAnalyze-icount ../$command_now/$i/execution_trace.json > icount-new.txt
                cp icount-new.txt ../$command_now/$i/icount-new.txt
                rm symbolic_testcase.txt
                ./jsonAnalyze ../$command_now/$i/execution_trace.json > symbolic_testcase.txt
                cp symbolic_testcase.txt ../$command_now/$i/symbolic_testcase.txt
                echo "$command_now: $i: Get symbolic-execution result for new version done."
            fi
        fi

        ###### 新版本测量修改部分真实执行插桩 ######
        echo "$command_now: $i: Real-execution measure-modified-part instrument for new version.."
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
        echo "$block" | ./real_executor++ --measure-modified-part=true --loop-boost=true --server-log=true ./build-ae-new-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution measure-modified-part instrument for new version done."
        
        ###### 新版本测量修改部分编译 ######
        echo "$command_now: $i: Real-execution measure-modified-part compile for new version.."
        cd build-ae-new
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Symbolic-execution compile for new version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real-modified-part"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-modified-part.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-modified-part.real-1"
            

            touch ../$command_now/$i/compile.txt
            echo "新版本测量修改部分真实执行插桩后编译失败" >> ../$command_now/$i/compile.txt
            cp build-ae-new/compile.log /data3/sjz/AE/mysql/$command_now/$i/compile-modified-part.real.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-new/bin/mysqld /data3/sjz/AE/mysql/$command_now/$i/mysqld-modified-part
            echo "$command_now: $i: Real-execution measure-modified-part compile for new version done."

            ###### 新版本测量修改部分运行 ######
            echo "$command_now: $i: Real-execution measure-modified-part run for new version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-modified-part-res.txt
            echo "$command_now: $i: Real-execution measure-modified-part run for new version done."

            # 备份真实执行插桩后的源文件，还原源文件
            cd $mysql_dir
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real-modified-part"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-modified-part.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-modified-part.real-1"
            
        fi

        ###### 新版本无占比真实执行插桩 ######
        echo "$command_now: $i: Real-execution no-measure-modified-part instrument for new version.."
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
        echo "$block" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-ae-new-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution no-measure-modified-part instrument for new version done."

        ###### 新版本无占比编译 ######
        echo "$command_now: $i: Real-execution no-measure-modified-part compile for new version.."
        cd build-ae-new
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Real-execution no-measure-modified-part compile for new version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real-1"
            

            touch ../$command_now/$i/compile.txt
            echo "新版本无占比真实执行插桩后编译失败" >> ../$command_now/$i/compile.txt
            cp build-ae-new/compile.log /data3/sjz/AE/mysql/$command_now/$i/compile.real.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-new/bin/mysqld /data3/sjz/AE/mysql/$command_now/$i/mysqld-real
            echo "$command_now: $i: Real-execution no-measure-modified-part compile for new version done."

            ###### 新版本无占比运行 ######
            echo "$command_now: $i: Real-execution no-measure-modified-part run for new version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-res.txt
            echo "$command_now: $i: Real-execution no-measure-modified-part run for new version done."

            # 备份真实执行插桩后的源文件，还原源文件
            cd $mysql_dir
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real-1"
            
        fi

        ###### 新版本完全真实执行插桩 ######
        echo "$command_now: $i: Real-execution completely instrument for new version.."
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
        echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-ae-new-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution completely instrument for new version done."

        ###### 新版本完全真实执行编译 ######
        echo "$command_now: $i: Real-execution completely compile for new version.."
        cd build-ae-new
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Real-execution completely compile for new version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-pure.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-pure.real-1"
            

            touch ../$command_now/$i/compile.txt
            echo "新版本完全真实执行插桩后编译失败" >> ../$command_now/$i/compile.txt
            cp build-ae-new/compile.log /data3/sjz/AE/mysql/$command_now/$i/compile-pure.real.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-new/bin/mysqld /data3/sjz/AE/mysql/$command_now/$i/mysqld-pure
            echo "$command_now: $i: Real-execution completely compile for new version done."

            ###### 新版本完全真实执行运行 ######
            echo "$command_now: $i: Real-execution completely run for new version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-res-pure.txt
            echo "$command_now: $i: Real-execution completely run for new version done."

            # 备份真实执行插桩后的源文件，还原源文件
            cd $mysql_dir
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.real"
                cp "${src_file}" "../$command_now/$i/${src_file_basename}-pure.real"
            done
            # clang-format -i sql/sql_parse.cc
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc-pure.real-1"
            
        fi

        ###### 旧版本执行准备 ######
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        git checkout -f $command
        rm end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state start" > end_to_end.txt
        echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state end" >> end_to_end.txt

        ###### 旧版本符号执行插桩 ######
        echo "$command_now: $i: Symbolic-execution instrument for old version.."
        if [ ! -s "modified_part_info.txt" ]; then
            echo "$command_now: $i: modified_part_info.txt is empty."
        fi
        echo "$block" | ./make_symbolizer++ --new-version=false ./build-ae-old-tmp/compile_commands.json
        echo "$command_now: $i: Symbolic-execution instrument for old version done."

        ###### 旧版本符号执行编译 ######
        echo "$command_now: $i: Symbolic-execution compile for old version.."
        cd build-ae-old
        /bin/rm bin/mysqld
        cmake -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Symbolic-execution compile for old version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                cp "${src_file}" "../$command-old/$i/${src_file_basename}.sym.old"
            done
            cp "sql/sql_parse.cc" "../$command-old/$i/sql_parse.cc.sym.old-1"
            

            touch ../$command-old/$i/compile.txt
            echo "旧版本符号执行插桩后编译失败" >> ../$command-old/$i/compile.txt
            cp build-ae-old/compile.log /data3/sjz/AE/mysql/$command-old/$i/compile.sym.old.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-old/bin/mysqld /data3/sjz/AE/mysql/$command-old/$i/mysqld-sym
            echo "$command_now: $i: Symbolic-execution compile for old version done."

            ###### 旧版本符号执行运行 ######
            echo "$command_now: $i: Symbolic-execution run for old version.."
            ln -sf $(pwd)/bin/mysqld /home/sjz/S2E/s2e/projects/mysqld/mysqld
            ln -sf $(pwd)/bin/mysql /home/sjz/S2E/s2e/projects/mysqld/mysql
            tar -czvf output.tar.gz $(find ./library_output_directory -name "libabsl_*" -o -name "libprotobuf-lite.so.24.4.0") > /dev/null
            cp output.tar.gz /home/sjz/S2E/s2e/projects/mysqld/output.tar.gz
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz /home/sjz/S2E/s2e/projects/mysqld/tables.tar.gz
            mysql_inst="./mysql -u root -S \$(pwd)/mysql.sock -D test -e \"$testcase_line\" "
            echo "MySQL inst: $mysql_inst"
            bootstrap_path="/data3/sjz/AE/mysql/bootstrap-1.sh"
            cp /data3/sjz/AE/mysql/bootstrap.sh /data3/sjz/AE/mysql/bootstrap-1.sh
            sed -i "240i$mysql_inst" "$bootstrap_path"
            cp /data3/sjz/AE/mysql/bootstrap-1.sh /home/sjz/S2E/s2e/projects/mysqld/bootstrap.sh
            #保存mysql目录
            cd /data3/sjz/AE/mysql/mysql-server
            mysql_dir=$(pwd)
            cd /home/sjz/S2E/s2e/projects/mysqld
            # 设置launch-s2e.sh 超时时间为600秒（10分钟）,后续可能会调整
            timeout_time=600
            # 执行脚本并设置超时
            timeout $timeout_time ./launch-s2e.sh 
            # 检查命令的退出状态
            if [ $? -eq 124 ]; then
                echo "$command_now: $i: Symbolic-execution run for old version timeout in launch-s2e.sh."
                pid=$(pgrep -f /home/sjz/S2E/s2e/install/bin/qemu-system-x86_64)
                if [ -z "$pid" ]; then
                    echo "S2E 被杀死"
                else
                    kill -9 "$pid"
                fi
                sleep 1
                # 备份符号化插桩后的源文件，还原源文件
                cd $mysql_dir
                for src_file in $src_files; do
                    src_file_basename=$(basename "$src_file")
                    # clang-format -i "$src_file"
                    cp "${src_file}" "../$command-old/$i/${src_file_basename}.sym.old"
                done
                cp "sql/sql_parse.cc" "../$command-old/$i/sql_parse.cc.sym.old-1"
                
                # i=$((${i} + 1))
                # continue
            else
                echo "$command_now: $i: Symbolic-execution run for old version done."

                ###### 旧版本符号执行获取结果 ######
                echo "$command_now: $i: Get symbolic-execution result for old version.."
                s2e execution_trace mysqld -pp
                cd $mysql_dir
                cp /home/sjz/S2E/s2e/projects/mysqld/s2e-last/execution_trace.json ../$command-old/$i/execution_trace.json
                cp /home/sjz/S2E/s2e/projects/mysqld/serial.txt ../$command-old/$i/serial.txt
                mkdir -p ../$command-old/$i/s2e_res
                cp -r /home/sjz/S2E/s2e/projects/mysqld/s2e-last/ ../$command-old/$i/s2e_res/
                cp /home/sjz/S2E/s2e/projects/mysqld/s2e-last/debug.txt ../$command-old/$i/s2e_res/debug.txt
                echo "$command" > ../$command-old/$i/s2e_res/commitId.txt
                # 备份符号化插桩后的源文件，还原源文件
                for src_file in $src_files; do
                    src_file_basename=$(basename "$src_file")
                    # clang-format -i "$src_file"
                    cp "${src_file}" "../$command-old/$i/${src_file_basename}.sym.old"
                done
                cp "sql/sql_parse.cc" "../$command-old/$i/sql_parse.cc.sym.old-1"
                
                ./jsonAnalyze-icount ../$command-old/$i/execution_trace.json > icount-old.txt
                cp icount-old.txt $mysql_dir/../$command_now/$i/icount-old.txt
                echo "$command_now: $i: Get symbolic-execution result for old version done."
            fi
        fi

        ###### 旧版本无占比真实执行插桩 ######
        echo "$command_now: $i: Real-execution no-measure-modified-part instrument for old version.."
        cd /data3/sjz/AE/mysql/mysql-server
        git restore .
        echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-ae-old-tmp/compile_commands.json
        echo "$command_now: $i: Real-execution no-measure-modified-part instrument for old version done."

        ###### 旧版本无占比编译 ######
        echo "$command_now: $i: Real-execution no-measure-modified-part compile for old version.."
        cd build-ae-old
        /bin/rm bin/mysqld
        cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
        sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
        make mysqld -j24 > compile.log 2>&1
        make mysql -j24 > /dev/null
        file_path_mysql_server="$(pwd)/bin/mysqld"
        # 检查是否编译成功
        if [ ! -f "$file_path_mysql_server" ]; then
            echo "$command_now: $i: Real-execution no-measure-modified-part compile for old version failed."
            # 编译失败
            cd /data3/sjz/AE/mysql/mysql-server
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                cp "${src_file}" "../$command_old/$i/${src_file_basename}.real.old"
            done
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real.old-1"
            

            touch ../$command-old/$i/compile.txt
            echo "旧版本无占比真实执行插桩后编译失败" >> ../$command-old/$i/compile.txt
            cp build-ae-old/compile.log /data3/sjz/AE/mysql/$command-old/$i/compile.real.old.log
            # i=$((${i} + 1))
            # continue
        else
            cp /data3/sjz/AE/mysql/mysql-server/build-ae-old/bin/mysqld /data3/sjz/AE/mysql/$command_old/$i/mysqld-real
            echo "$command_now: $i: Real-execution no-measure-modified-part compile for old version done."

            ###### 旧版本无占比运行 ######
            echo "$command_now: $i: Real-execution no-measure-modified-part run for old version.."
            cd bin
            /bin/rm tables.tar.gz
            /bin/rm -rf data
            cp /data/sjz/commit-analysis/mysql-8.4.4/testcases/tables.tar.gz ./
            tar -zxvf tables.tar.gz -C . > /dev/null
            cd ..
            cp /data3/sjz/AE/mysql/run-mysql.sh ./run-mysql.sh
            echo "$testcase_line" > get_mysql.txt
            rm error.log
            sh run-mysql.sh > mysql-server.log1
            sleep 1.5
            cp error.log $mysql_dir/../$command_now/$i/real-execute-res-old.txt
            echo "$command_now: $i: Real-execution no-measure-modified-part run for old version done."

            # 备份真实执行插桩后的源文件，还原源文件
            cd $mysql_dir
            # clang-format -i sql/sql_parse.cc
            for src_file in $src_files; do
                src_file_basename=$(basename "$src_file")
                # clang-format -i "$src_file"
                cp "${src_file}" "../$command_old/$i/${src_file_basename}.real.old"
            done
            cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real.old-1"
            

            ###### 真实执行比较 ######
            echo "$command_now: $i: Real-execution compare.."
            cd $mysql_dir/../$command_now/$i
            cp /data3/sjz/AE/mysql/run-getres.sh ./run-getres.sh
            cp /data3/sjz/AE/mysql/run-getres.py ./run-getres.py
            cp /data3/sjz/AE/mysql/run-getres-modify.py ./run-getres-modify.py
            cp /data3/sjz/AE/mysql/run-getres-icount.py ./run-getres-icount.py
            sh run-getres.sh
            cd $mysql_dir
            echo "$command_now: $i: Real-execution compare done."
        fi

        i=$((${i} + 1))
    done
    echo "$command_now: Loop execute symbolic-execution and real-execution done."

done < /data3/sjz/AE/mysql/validate.txt

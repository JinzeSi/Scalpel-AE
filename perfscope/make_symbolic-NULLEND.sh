#!/bin/bash

command=$1 #是command_old，注意，shell脚本变量名不能有-，所以这里用_代替
command_now=$2
echo "commitId:$command"
# exit 0
# break

# 第0步：将工具拷贝过来，编译新旧版本 mysqld 和 mysqld.bc
cd /data/sjz/commit-analysis/mysql-run/mysql-server
cp /data/sjz/commit-analysis/llvm-analysis/tools/.clang-format .
cp /data/sjz/commit-analysis/llvm-analysis/tools/new_function_analyzer.sh .
cp /data/sjz/commit-analysis/llvm-analysis/tools/new_function_combiner.py .
cp /data/sjz/commit-analysis/llvm-analysis/tools/commit_analyzer++ .
cp /data/sjz/commit-analysis/llvm-analysis/tools/call_analyzer++ .
cp /data/sjz/commit-analysis/llvm-analysis/tools/symbolic_analyzer++ .
cp /data/sjz/commit-analysis/llvm-analysis/tools/make_symbolizer++ .
cp /data/sjz/commit-analysis/llvm-analysis/tools/real_executor++ .
cp /data/sjz/commit-analysis/llvm-analysis/tools/jsonAnalyze .
cp /data/sjz/commit-analysis/llvm-analysis/tools/jsonAnalyze-icount .
cp /data/sjz/commit-analysis/llvm-analysis/tools/get_redis_1 . 
cp /data/sjz/commit-analysis/llvm-analysis/tools/get_redis_2 .
cp /data/sjz/commit-analysis/llvm-analysis/tools/redis-order.txt .

cd /data/sjz/commit-analysis/mysql-run
/bin/rm -rf $command_now
/bin/rm -rf $command-old
mkdir -p $command_now
mkdir -p $command-old

###### 获取新版本的 compile_commands.json ######
echo "$command_now: Get compile_commands.json for new version..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server
git restore .
git checkout -f $command_now
git restore .
cd build-new-tmp
cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-18.1.8/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-18.1.8/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-18.1.8/bin/llvm-link" -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
cd include
make -j12 > /dev/null
echo "$command_now: Get compile_commands.json for new version done."

###### 优化：此处已经得到 compile_commands.json，先进行 commit-analysis，如果 getFuncName-ini.txt 为空，则直接跳过后续步骤 ######
# 原先的第1步：分析commit修改，生成 getFuncName-ini.txt，之后我们还要将其与 new_function.txt 结合
echo "$command_now: Analyze commit modification..." 
cd /data/sjz/commit-analysis/mysql-run/mysql-server
rm new_function.txt
rm getFuncName-ini.txt
./commit_analyzer++ ./build-new-tmp $command $command_now > getFuncName-ini.txt
echo "$command_now: Analyze commit modification done."
if [ ! -s "getFuncName-ini.txt" ]; then
    # getFuncName-ini.txt 为空，直接跳过后续步骤
    echo "$command_now: have no c/c++ modification on source code."

    # 让 Pre-knowledge 库知晓
    rm call_analyse.txt
    rm symbolic_analyse.txt
    touch call_analyse.txt
    touch symbolic_analyse.txt
    cp call_analyse.txt /data2/sjz/Pre-knowledge-mysql/demo-S2E-times-res-2.txt
    cp symbolic_analyse.txt /data2/sjz/Pre-knowledge-mysql/demo-S2E-times-res-3-flag.txt
    
    /bin/rm call_analyse2.txt
    file_path="/data/sjz/call_analyse2.txt"
    # 检查文件是否存在
    while [ ! -f "$file_path" ]
    do
        echo "Waiting for file to appear..."
        sleep 3  # 等待5秒
    done
    cp /data/sjz/call_analyse2.txt ./call_analyse2.txt
    rm /data/sjz/call_analyse2.txt
    exit 0
fi

###### 获取旧版本的 compile_commands.json ######
echo "$command_now: Get compile_commands.json for old version..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server
git restore .
git checkout -f $command
git restore .
cd build-old-tmp
cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-18.1.8/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-18.1.8/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-18.1.8/bin/llvm-link" -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
cd include
make -j12 > /dev/null
echo "$command_now: Get compile_commands.json for old version done."

###### 编译新版本的 mysqld ######
echo "$command_now: Compile new version mysqld..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server-2
git checkout -f $command_now
cd build-tmp
cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
make mysqld -j24 > /dev/null
cp ./bin/mysqld /data/sjz/commit-analysis/mysql-run/mysql-server/mysqld-new
echo "$command_now: Compile new version mysqld done."

###### 编译旧版本的 mysqld ######
echo "$command_now: Compile old version mysqld..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server-2
git checkout -f $command
cd build-tmp
cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
make mysqld -j24 > /dev/null
cp ./bin/mysqld /data/sjz/commit-analysis/mysql-run/mysql-server/mysqld-old
echo "$command_now: Compile old version mysqld done."

################################################

# 第0.5步：比较新旧版本的 mysqld，获取完全新增的函数，生成 new_function.txt
echo "$command_now: Compare new and old mysqld..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server
./new_function_analyzer.sh mysqld-old mysqld-new
/bin/rm mysqld-old
/bin/rm mysqld-new
# 第1步：分析commit修改，生成 getFuncName.txt，剩余步骤
rm getFuncName.txt
python3 new_function_combiner.py
echo "$command_now: Compare new and old mysqld done."

################################################

###### 编译旧版本的 mysqld.bc ######
echo "$command_now: Compile old version mysqld.bc..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server-2
git checkout -f $command
cd build-bc-old
cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-18.1.8/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-18.1.8/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-18.1.8/bin/llvm-link" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
mv sql/CMakeFiles/mysqld.dir/link.txt sql/CMakeFiles/mysqld.dir/link.txt.brk
cp /data2/sjz/Pre-knowledge-mysql/mysql-link/link.py ./link.py
python3 link.py
make mysqld -j24 > /dev/null
echo "$command_now: Compile old version mysqld.bc done."

###### 编译新版本的 mysqld.bc ######
echo "$command_now: Compile new version mysqld.bc..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server-2
git checkout -f $command_now
cd build-bc-new
cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-18.1.8/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-18.1.8/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-18.1.8/bin/llvm-link" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
mv sql/CMakeFiles/mysqld.dir/link.txt sql/CMakeFiles/mysqld.dir/link.txt.brk
cp /data2/sjz/Pre-knowledge-mysql/mysql-link/link.py ./link.py
python3 link.py
make mysqld -j24 > /dev/null
echo "$command_now: Compile new version mysqld.bc done."

###### 保存 compile_commands.json & new.bc ######
cd /data/sjz/commit-analysis/mysql-run/mysql-server-2
cp ./build-bc-new/sql/mysqld.bc ../$command_now/mysqld.bc
cd /data/sjz/commit-analysis/mysql-run/mysql-server
cp ./build-new-tmp/compile_commands.json ../$command_now/compile_commands.json.new
cp ./build-old-tmp/compile_commands.json ../$command_now/compile_commands.json.old

###### 分析调用关系和符号化位置，寻找测试用例 ######
cd /data/sjz/commit-analysis/mysql-run/mysql-server
git restore .
git checkout -f $command_now
git restore .
# 第2步：分析调用关系，生成 call_analyse.txt
echo "$command_now: Analyze call relationship..."
rm call_analyse.txt
./call_analyzer++ /data/sjz/commit-analysis/mysql-run/mysql-server-2/build-bc-new/sql/mysqld.bc getFuncName.txt > call_analyse.txt
echo "$command_now: Analyze call relationship done."
# 第3步：分析若干次符号执行符号化插桩的位置，生成 symbolic_analyse.txt
echo "$command_now: Analyze symbolic execution..."
rm symbolic_analyse.txt
cat call_analyse.txt | ./symbolic_analyzer++ ./build-new-tmp/compile_commands.json
echo "$command_now: Analyze symbolic execution done."
# 第4步：读取 symbolic_analyse.txt，结合之前的信息，利用preknowledge库寻找测试用例，生成 call_analyse2.txt
echo "$command_now: Get testcase..."
rm /data/sjz/call_analyse2.txt
cp call_analyse.txt /data2/sjz/Pre-knowledge-mysql/demo-S2E-times-res-2.txt
cp symbolic_analyse.txt /data2/sjz/Pre-knowledge-mysql/demo-S2E-times-res-3-flag.txt
rm call_analyse2.txt
file_path="/data/sjz/call_analyse2.txt"
# 检查文件是否存在
while [ ! -f "$file_path" ]
do
    echo "Waiting for file to appear..."
    sleep 3  # 等待5秒
done
cp /data/sjz/call_analyse2.txt ./call_analyse2.txt
rm /data/sjz/call_analyse2.txt
echo "$command_now: Get testcase done."

###### 保存分析结果 ######
cd /data/sjz/commit-analysis/mysql-run/mysql-server
cp ./getFuncName-ini.txt ../$command_now/getFuncName-ini.txt
cp ./new_function.txt ../$command_now/new_function.txt
cp ./getFuncName.txt ../$command_now/getFuncName.txt
cp ./call_analyse.txt ../$command_now/call_analyse.txt
cp ./symbolic_analyse.txt ../$command_now/symbolic_analyse.txt
cp ./call_analyse2.txt ../$command_now/call_analyse2.txt

###### 读取分析结果 ######
echo "$command_now: Read analysis result..."
cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    git checkout -f $command_now
    git restore .
    src_files=$(echo "$block" | grep "/data/sjz/commit-analysis" | awk '{print $2}' | sort | uniq)
    last_line=$(echo "$block" | tail -n 2 | head -n 1)
    echo "$last_line"
    if [ "$last_line" = "testcase:no testcase" ]; then
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
    cp testcase.txt /data/sjz/commit-analysis/mysql-run/$command_now/$i/testcase.txt

    ###### 新版本测量修改部分真实执行插桩 ######
    echo "$command_now: $i: Real-execution only measure-modified-part instrument for new version.."
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    mysql_dir=$(pwd)
    echo "$block" | ./real_executor++ --measure-modified-part=true --loop-boost=true --server-log=true ./build-new-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution only measure-modified-part instrument for new version done."

    ###### 新版本测量修改部分编译 ######
    echo "$command_now: $i: Real-execution only measure-modified-part compile for new version.."
    cd build-new
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
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
        cp build-new/compile.log /data/sjz/commit-analysis/mysql-run/$command_now/$i/compile-modified-part.real.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution only measure-modified-part compile for new version done."

        ###### 新版本测量修改部分运行 ######
        echo "$command_now: $i: Real-execution only measure-modified-part run for new version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
    echo "$block" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-new-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution only no-measure-modified-part instrument for new version done."

    ###### 新版本无占比编译 ######
    echo "$command_now: $i: Real-execution only no-measure-modified-part compile for new version.."
    cd build-new
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
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
        cp build-new/compile.log /data/sjz/commit-analysis/mysql-run/$command_now/$i/compile.real.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution only no-measure-modified-part compile for new version done."
        
        ###### 新版本无占比运行 ######
        echo "$command_now: $i: Real-execution only no-measure-modified-part run for new version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh    
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
    # echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-new-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution completely instrument for new version done."

    ###### 新版本完全真实执行编译 ######
    echo "$command_now: $i: Real-execution completely compile for new version.."
    cd build-new
    /bin/rm bin/mysqld
    cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
    # sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
    make mysqld -j24 > compile.log 2>&1
    make mysql -j24 > /dev/null
    file_path_mysql_server="$(pwd)/bin/mysqld"
    # 检查是否编译成功
    if [ ! -f "$file_path_mysql_server" ]; then
        echo "$command_now: $i: Real-execution completely compile for new version failed."
        # 编译失败
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
        cp build-new/compile.log /data/sjz/commit-analysis/mysql-run/$command_now/$i/compile-pure.real.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution completely compile for new version done."

        ###### 新版本完全真实执行运行 ######
        echo "$command_now: $i: Real-execution completely run for new version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    git checkout -f $command
    git restore .
    rm end_to_end.txt
    echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state start" > end_to_end.txt
    echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state end" >> end_to_end.txt

    ###### 旧版本无占比真实执行插桩 ######
    echo "$command_now: $i: Real-execution only no-measure-modified-part instrument for old version.."
    # echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-old-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution only no-measure-modified-part instrument for old version done."
        
    ###### 旧版本无占比编译 ######
    echo "$command_now: $i: Real-execution only no-measure-modified-part compile for old version.."
    cd build-old
    /bin/rm bin/mysqld
    cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
    # sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
    make mysqld -j24 > compile.log 2>&1
    make mysql -j24 > /dev/null
    file_path_mysql_server="$(pwd)/bin/mysqld"
    # 检查是否编译成功
    if [ ! -f "$file_path_mysql_server" ]; then
        echo "$command_now: $i: Real-execution only no-measure-modified-part compile for old version failed."
        # 编译失败
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
        # clang-format -i sql/sql_parse.cc
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            # echo "cp ${src_file} ../$command-old/$i/${src_file_basename}.real"
            cp "${src_file}" "../$command-old/$i/${src_file_basename}.real"
        done
        cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real.old-1"
        

        touch ../$command-old/$i/compile.txt
        echo "旧版本无占比真实执行插桩后编译失败" >> ../$command-old/$i/compile.txt
        cp build-old/compile.log /data/sjz/commit-analysis/mysql-run/$command-old/$i/compile.real.old.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution only no-measure-modified-part compile for old version done."

        ###### 旧版本无占比运行 ######
        echo "$command_now: $i: Real-execution only no-measure-modified-part run for old version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh
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
        cp /data/sjz/commit-analysis/mysql-run/run-getres.sh ./run-getres.sh
        cp /data/sjz/commit-analysis/mysql-run/run-getres.py ./run-getres.py
        cp /data/sjz/commit-analysis/mysql-run/run-getres-modify.py ./run-getres-modify.py
        cp /data/sjz/commit-analysis/mysql-run/run-getres-icount.py ./run-getres-icount.py
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    git checkout -f $command_now
    git restore .
    src_files=$(echo "$block" | grep "/data/sjz/commit-analysis" | awk '{print $2}' | sort | uniq)
    last_line=$(echo "$block" | tail -n 2 | head -n 1)
    echo "$last_line"
    if [ "$last_line" = "testcase:no testcase" ]; then
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
    cp testcase.txt /data/sjz/commit-analysis/mysql-run/$command_now/$i/testcase.txt

    ###### 新版本符号执行插桩 ######
    echo "$command_now: $i: Symbolic-execution instrument for new version.."
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    mysql_dir=$(pwd)
    rm modified_part_info.txt
    echo "$block" | ./make_symbolizer++ --new-version=true ./build-new-tmp/compile_commands.json
    cp modified_part_info.txt /data/sjz/commit-analysis/mysql-run/$command_now/$i/modified_part_info.txt
    echo "$command_now: $i: Symbolic-execution instrument for new version done."

    ###### 新版本符号执行编译 ######
    echo "$command_now: $i: Symbolic-execution compile for new version.."
    # 第6步：-O0编译、s2e运行（testcase行存放在 testcase.txt）、提取结果存放到 symbolic_testcase.txt
    cd build-new
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
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            # clang-format -i "$src_file"
            # echo "cp ${src_file} ../$command_now/$i/${src_file_basename}.sym"
            cp "${src_file}" "../$command_now/$i/${src_file_basename}.sym"
        done
        cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.sym-1"
        

        touch ../$command_now/$i/compile.txt
        echo "新版本符号执行插桩后编译失败" >> ../$command_now/$i/compile.txt
        cp build-new/compile.log /data/sjz/commit-analysis/mysql-run/$command_now/$i/compile.sym.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Symbolic-execution compile for new version done."

        ###### 新版本符号执行运行 ######
        echo "$command_now: $i: Symbolic-execution run for new version.."
        ln -sf $(pwd)/bin/mysqld /home/sjz/S2E/s2e/projects/mysqld/mysqld
        ln -sf $(pwd)/bin/mysql /home/sjz/S2E/s2e/projects/mysqld/mysql
        tar -czvf output.tar.gz $(find ./library_output_directory -name "libabsl_*" -o -name "libprotobuf-lite.so.24.4.0") > /dev/null
        cp output.tar.gz /home/sjz/S2E/s2e/projects/mysqld/output.tar.gz
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz /home/sjz/S2E/s2e/projects/mysqld/tables.tar.gz
        mysql_inst="./mysql -u root -S \$(pwd)/mysql.sock -D test -e \"$testcase_line\" "
        echo "MySQL inst: $mysql_inst"
        bootstrap_path="/data/sjz/commit-analysis/mysql-run/bootstrap-1.sh"
        cp /data/sjz/commit-analysis/mysql-run/bootstrap.sh /data/sjz/commit-analysis/mysql-run/bootstrap-1.sh
        sed -i "240i$mysql_inst" "$bootstrap_path"
        cp /data/sjz/commit-analysis/mysql-run/bootstrap-1.sh /home/sjz/S2E/s2e/projects/mysqld/bootstrap.sh
        #保存mysql目录
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
    echo "$block" | ./real_executor++ --measure-modified-part=true --loop-boost=true --server-log=true ./build-new-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution measure-modified-part instrument for new version done."
    
    ###### 新版本测量修改部分编译 ######
    echo "$command_now: $i: Real-execution measure-modified-part compile for new version.."
    cd build-new
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
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
        cp build-new/compile.log /data/sjz/commit-analysis/mysql-run/$command_now/$i/compile-modified-part.real.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution measure-modified-part compile for new version done."

        ###### 新版本测量修改部分运行 ######
        echo "$command_now: $i: Real-execution measure-modified-part run for new version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
    echo "$block" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-new-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution no-measure-modified-part instrument for new version done."

    ###### 新版本无占比编译 ######
    echo "$command_now: $i: Real-execution no-measure-modified-part compile for new version.."
    cd build-new
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
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
        cp build-new/compile.log /data/sjz/commit-analysis/mysql-run/$command_now/$i/compile.real.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution no-measure-modified-part compile for new version done."

        ###### 新版本无占比运行 ######
        echo "$command_now: $i: Real-execution no-measure-modified-part run for new version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    # cp "sql/sql_parse.cc" "sql/sql_parse.cc.brk"
    # echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-new-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution completely instrument for new version done."

    ###### 新版本完全真实执行编译 ######
    echo "$command_now: $i: Real-execution completely compile for new version.."
    cd build-new
    /bin/rm bin/mysqld
    cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
    # sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
    make mysqld -j24 > compile.log 2>&1
    make mysql -j24 > /dev/null
    file_path_mysql_server="$(pwd)/bin/mysqld"
    # 检查是否编译成功
    if [ ! -f "$file_path_mysql_server" ]; then
        echo "$command_now: $i: Real-execution completely compile for new version failed."
        # 编译失败
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
        cp build-new/compile.log /data/sjz/commit-analysis/mysql-run/$command_now/$i/compile-pure.real.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution completely compile for new version done."

        ###### 新版本完全真实执行运行 ######
        echo "$command_now: $i: Real-execution completely run for new version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    git checkout -f $command
    git restore .

    rm end_to_end.txt
    echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state start" > end_to_end.txt
    echo "$(pwd)/sql/sql_parse.cc _Z20dispatch_sql_commandP3THDP12Parser_state end" >> end_to_end.txt

    ###### 旧版本符号执行插桩 ######
    echo "$command_now: $i: Symbolic-execution instrument for old version.."
    if [ ! -s "modified_part_info.txt" ]; then
        echo "$command_now: $i: modified_part_info.txt is empty."
    fi
    echo "$block" | ./make_symbolizer++ --new-version=false ./build-old-tmp/compile_commands.json
    echo "$command_now: $i: Symbolic-execution instrument for old version done."

    ###### 旧版本符号执行编译 ######
    echo "$command_now: $i: Symbolic-execution compile for old version.."
    cd build-old
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
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            # clang-format -i "$src_file"
            cp "${src_file}" "../$command-old/$i/${src_file_basename}.sym.old"
        done
        cp "sql/sql_parse.cc" "../$command-old/$i/sql_parse.cc.sym.old-1"
        

        touch ../$command-old/$i/compile.txt
        echo "旧版本符号执行插桩后编译失败" >> ../$command-old/$i/compile.txt
        cp build-old/compile.log /data/sjz/commit-analysis/mysql-run/$command-old/$i/compile.sym.old.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Symbolic-execution compile for old version done."

        ###### 旧版本符号执行运行 ######
        echo "$command_now: $i: Symbolic-execution run for old version.."
        ln -sf $(pwd)/bin/mysqld /home/sjz/S2E/s2e/projects/mysqld/mysqld
        ln -sf $(pwd)/bin/mysql /home/sjz/S2E/s2e/projects/mysqld/mysql
        tar -czvf output.tar.gz $(find ./library_output_directory -name "libabsl_*" -o -name "libprotobuf-lite.so.24.4.0") > /dev/null
        cp output.tar.gz /home/sjz/S2E/s2e/projects/mysqld/output.tar.gz
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz /home/sjz/S2E/s2e/projects/mysqld/tables.tar.gz
        mysql_inst="./mysql -u root -S \$(pwd)/mysql.sock -D test -e \"$testcase_line\" "
        echo "MySQL inst: $mysql_inst"
        bootstrap_path="/data/sjz/commit-analysis/mysql-run/bootstrap-1.sh"
        cp /data/sjz/commit-analysis/mysql-run/bootstrap.sh /data/sjz/commit-analysis/mysql-run/bootstrap-1.sh
        sed -i "240i$mysql_inst" "$bootstrap_path"
        cp /data/sjz/commit-analysis/mysql-run/bootstrap-1.sh /home/sjz/S2E/s2e/projects/mysqld/bootstrap.sh
        #保存mysql目录
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
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
    cd /data/sjz/commit-analysis/mysql-run/mysql-server
    git restore .
    # echo "EOF" | ./real_executor++ --measure-modified-part=false --loop-boost=false --server-log=false ./build-old-tmp/compile_commands.json
    echo "$command_now: $i: Real-execution no-measure-modified-part instrument for old version done."

    ###### 旧版本无占比编译 ######
    echo "$command_now: $i: Real-execution no-measure-modified-part compile for old version.."
    cd build-old
    /bin/rm bin/mysqld
    cmake -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUG" -DCMAKE_C_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DCMAKE_CXX_FLAGS="-I/data/sjz/commit-analysis/llvm-analysis/tools/include" -DWITH_BOOST=../boost_1_77_0 .. > /dev/null
    # sed -i '1s#$#-lsymbolic -L/data/sjz/commit-analysis/llvm-analysis/tools/lib#' sql/CMakeFiles/mysqld.dir/link.txt
    make mysqld -j24 > compile.log 2>&1
    make mysql -j24 > /dev/null
    file_path_mysql_server="$(pwd)/bin/mysqld"
    # 检查是否编译成功
    if [ ! -f "$file_path_mysql_server" ]; then
        echo "$command_now: $i: Real-execution no-measure-modified-part compile for old version failed."
        # 编译失败
        cd /data/sjz/commit-analysis/mysql-run/mysql-server
        for src_file in $src_files; do
            src_file_basename=$(basename "$src_file")
            # clang-format -i "$src_file"
            cp "${src_file}" "../$command_old/$i/${src_file_basename}.real.old"
        done
        cp "sql/sql_parse.cc" "../$command_now/$i/sql_parse.cc.real.old-1"
        

        touch ../$command-old/$i/compile.txt
        echo "旧版本无占比真实执行插桩后编译失败" >> ../$command-old/$i/compile.txt
        cp build-old/compile.log /data/sjz/commit-analysis/mysql-run/$command-old/$i/compile.real.old.log
        # i=$((${i} + 1))
        # continue
    else
        echo "$command_now: $i: Real-execution no-measure-modified-part compile for old version done."

        ###### 旧版本无占比运行 ######
        echo "$command_now: $i: Real-execution no-measure-modified-part run for old version.."
        cd bin
        /bin/rm tables.tar.gz
        /bin/rm -rf data
        cp /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz ./
        tar -zxvf tables.tar.gz -C . > /dev/null
        cd ..
        cp /data/sjz/commit-analysis/mysql-run/run-mysql.sh ./run-mysql.sh
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
        cp /data/sjz/commit-analysis/mysql-run/run-getres.sh ./run-getres.sh
        cp /data/sjz/commit-analysis/mysql-run/run-getres.py ./run-getres.py
        cp /data/sjz/commit-analysis/mysql-run/run-getres-modify.py ./run-getres-modify.py
        cp /data/sjz/commit-analysis/mysql-run/run-getres-icount.py ./run-getres-icount.py
        sh run-getres.sh
        cd $mysql_dir
        echo "$command_now: $i: Real-execution compare done."
    fi

    i=$((${i} + 1))
done
echo "$command_now: Loop execute symbolic-execution and real-execution done."

# 删除临时备份文件
# rm *.brk

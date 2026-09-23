# !/bin/bash

command=$1
# #生成final_obj.ll
init_dir=$(pwd)

echo "$command"
echo "$init_dir"

# exit 0

cd /data2/sjz/mysql/mysql-server
git reset --hard
git checkout $command

# // 编译.bc
cd build1
cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-project/build2/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-project/build2/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-project/build2/bin/llvm-link" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DWITH_BOOST=/data/sjz/commit-analysis/mysql-run/mysql-server/boost_1_77_0 ..
mv sql/CMakeFiles/mysqld.dir/link.txt sql/CMakeFiles/mysqld.dir/link.txt.brk
cp /data2/sjz/Pre-knowledge-mysql/mysql-link/link.py ./link.py
python3 link.py
make mysqld -j12
cd sql

/data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-dis mysqld.bc -o mysqld.ll

# // 编译可执行文件
cd /data2/sjz/mysql/mysql-server/build4

cp /data2/sjz/Pre-knowledge-mysql/sql_parse/sql_parse.cc /data2/sjz/mysql/mysql-server/sql/sql_parse.cc
cmake -DCMAKE_C_COMPILER="/data/sjz/llvm-project/build2/bin/clang" -DCMAKE_CXX_COMPILER="/data/sjz/llvm-project/build2/bin/clang++" -DCMAKE_LINKER="/data/sjz/llvm-project/build2/bin/llvm-link" -DCMAKE_C_FLAGS="-flto" -DCMAKE_CXX_FLAGS="-flto" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O0 -g -DNDEBUG" -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DCMAKE_C_FLAGS="-fsanitize=address -fsanitize-coverage=bb,no-prune,trace-pc-guard" -DCMAKE_CXX_FLAGS="-fsanitize=address -fsanitize-coverage=bb,no-prune,trace-pc-guard" -DWITH_BOOST=/data/sjz/commit-analysis/mysql-run/mysql-server/boost_1_77_0 ..
make mysqld -j12
make mysql -j12
cp /data2/sjz/mysql/mysql-server/build4/runtime_output_directory/mysqld /data2/sjz/mysql/mysql-server/build4/bin/mysqld
cp /data2/sjz/mysql/mysql-server/build4/runtime_output_directory/mysql /data2/sjz/mysql/mysql-server/build4/bin/mysql

cd $init_dir

# ../llvm-sjz/llvm-project/build/bin/clang++ -o getBB getBB.cpp `/data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-config --cxxflags --ldflags --s
# ystem-libs --libs core irreader analysis passes support`



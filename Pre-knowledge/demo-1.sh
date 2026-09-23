# !/bin/bash

command=$1
# #生成final_obj.ll
init_dir=$(pwd)

echo "$command"
echo "$init_dir"

# exit 0

cd redis
git reset --hard
git checkout $command
# 第一轮 Makefile-1 第二轮Makefile-2，依次类推
cp /data2/sjz/Pre-knowledge/Makefile ./src/Makefile
make distclean
make bc CC=/data2/sjz/llvm-sjz/llvm-project/build/bin/clang -j8


cd src
/data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-dis final_obj.bc -o final_obj.ll

cd $init_dir

# ../llvm-sjz/llvm-project/build/bin/clang++ -o getBB getBB.cpp `/data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-config --cxxflags --ldflags --s
# ystem-libs --libs core irreader analysis passes support`

./getBB redis/src/final_obj.ll 2> redis-BB.txt
./get_BB_hashTable
./build_BB_hashTable

clang++ -o getBB getBB.cpp `llvm-config --cxxflags --ldflags --system-libs --libs core irreader analysis passes support`
# clang -O0 -g -emit-llvm -c demo.c -o demo.bc
llvm-dis final_obj.bc -o final_obj.ll

./getBB redis/src/final_obj.ll 2> res1

ASAN_OPTIONS=coverage=1 ./demo
addr2line -e ./demo 10e07e
sancov --print *.sancov

clang++ -g -fsanitize=address -fsanitize-coverage=trace-pc-guard,trace-cmp,trace-div,trace-gep demo.c -o demo

clang++ -fsanitize=address -fsanitize-coverage=trace-pc-guard,trace-cmp,trace-div,trace-gep demo.c -o demo

sancov -symbolize *.sancov ./redis-server > test.symcov

llvm-symbolizer --inlining --print-address --pretty-print --obj=redis-server 0x2a107d
    0x2a107d: processCommand at /home/sjz/Pre-knowledge/redis/src/server.c:3924:9

# first step
cd redis
make bc CC=clang
cd src
llvm-dis final_obj.ll -o final_obj.ll
cd ../..
./getBB redis/src/final_obj.ll 2> redis-BB.txt

# second step
cd redis
make CC=clang
mkdir app
make install PREFIX=/home/sjz/Pre-knowledge/redis/app
cd app/bin
# third step
执行demo.sh脚本
# forth step
执行commit(update_KeyValue)


get commit-id：git log --reverse --format=%H f4549d1cf4830c0584f8e41369a8628842a67aec..HEAD > tmp

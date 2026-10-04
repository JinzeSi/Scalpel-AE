script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
preknowledge_dir=${2:-${PREKNOWLEDGE_DIR:-$script_dir}}
llvm_bin_dir=${3:-${LLVM_BIN_DIR:-}}
if [[ -z "$llvm_bin_dir" ]]; then
    llvm_dis=$(command -v llvm-dis) || { echo "llvm-dis not found; pass LLVM_BIN_DIR as argument 3" >&2; exit 1; }
    llvm_bin_dir=$(dirname "$llvm_dis")
fi
handoff_file=${4:-${REDIS_HANDOFF_FILE:-$(dirname "$script_dir")/call_analyse2.txt}}

FILENAME=$1
# FILENAME="commitId.txt"
while IFS= read -r line; do

   
    cp redis-BB-res-2-new.txt redis-BB-res-2.txt 
    cp redis-BB-res-3-new.txt redis-BB-res-3.txt 
    echo $line > gitshow.txt
    ./gitshow $line >> gitshow.txt
    echo "end" >> gitshow.txt
    cd ${preknowledge_dir}/redis-version/redis/
    git reset --hard
    git checkout $line
    cp ${preknowledge_dir}/Makefile ./src/Makefile
    make distclean
    make bc CC=${llvm_bin_dir}/clang
    cd src
    ${llvm_bin_dir}/llvm-dis final_obj.bc -o final_obj.ll
    cd ${preknowledge_dir}/
    ./getBB ./redis-version/redis/src/final_obj.ll 2> demo-redis-BB.txt
    echo "Function:End" >> demo-redis-BB.txt

    file_path="demo-S2E-times-res-3-flag.txt"

    # 检查文件是否存在
    while [ ! -f "$file_path" ]
    do
    echo "Waiting for file to appear..."
    sleep 3  # 等待5秒
    done    
    cp demo-S2E-times-res-3-flag.txt demo-S2E-times-res-3.txt
    rm demo-S2E-times-res-3-flag.txt
    ./update_KeyValue_hashTable 1 

    #如果触发re-build
    last_line=$(tail -n 1 demo-S2E-times-res-1.txt)
    if [ "$last_line" = "need to re-build pre-knowledge" ]; then
        #要确定demo.sh执行完成，因为有函数在后台执行
        echo "begin rebuild pre-knowledege$line"
        sh demo-1.sh $line
        sh demo-2.sh $line


        #要确定demo.sh执行完成，因为有函数在后台执行
        #重新执行上面的逻辑，然后再进行下一轮
        #update_KeyValue_hashTable要区分是否覆盖 redis-BB-res-2-new.txt
        file_path2="build_KeyValue_hashTable.txt"

        # 检查文件是否存在 标志demo.sh是否完成
        while [ ! -f "$file_path2" ]
        do
        echo "Waiting for file(build_KeyValue_hashTable.txt) to appear..."
        sleep 3  
        done  
        cp redis-BB-res-2.txt redis-BB-res-2-new.txt 
        cp redis-BB-res-3.txt redis-BB-res-3-new.txt 
        rm build_KeyValue_hashTable.txt
        ./update_KeyValue_hashTable 0
    
        touch generate_S2E_case-1.txt
        ./generate_S2E_case > generate_S2E_case-2.txt
        python3 dup_S2E_case-1.py 
        python3 dup_S2E_case.py 

        ./generate_S2E_case-2 > redis-BB-res-4.txt

        rm generate_S2E_case-1.txt

    else
        touch generate_S2E_case-1.txt
        ./generate_S2E_case > generate_S2E_case-2.txt
        python3 dup_S2E_case-1.py 
        python3 dup_S2E_case.py 

        ./generate_S2E_case-2 > redis-BB-res-4.txt

        rm generate_S2E_case-1.txt
    fi
    #删除重复测试用例
    # python3 dup_S2E_case.py

    # 备份
    rm -rf $line
    mkdir $line
    cp gitshow.txt ./$line/gitshow.txt 
    cp demo-redis-BB.txt ./$line/demo-redis-BB.txt
    cp redis-BB-res-4.txt ./$line/redis-BB-res-4.txt 
    cp demo-S2E-times-res-1.txt ./$line/demo-S2E-times-res-1.txt
    cp demo-S2E-times-res-2.txt ./$line/demo-S2E-times-res-2.txt
    cp demo-S2E-times-res-3.txt ./$line/demo-S2E-times-res-3.txt
    cp redis-BB-res-2-new.txt ./$line/redis-BB-res-2.txt 
    cp redis-BB-res-3-new.txt ./$line/redis-BB-res-3.txt 
    cp ${preknowledge_dir}/redis-version/redis/src/final_obj.ll ./$line/final_obj.ll
    
    #发送给ds00/data
    cp redis-BB-res-4.txt ${handoff_file}
done < "$FILENAME"

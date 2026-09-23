/bin/rm /data2/sjz/Pre-knowledge-mysql/demo-S2E-times-res-3-flag.txt
cd /data3/sjz/AE/mysql/mysql-server
git restore .
cd ..

FILENAME="commit-2.txt"
last_commit="158937cd3ff7474b9d138b06082af9da92f96da1"
while IFS= read -r line; do
    
    start_time=$(date +%s)

    echo "$line 脚本开始执行：$(date)" >> time-tall.txt
    bash ./make_symbolic-NULLEND.sh $last_commit $line

    #保存上一个版本的版本号
    last_commit=$line
    # 获取结束时间
    end_time=$(date +%s)

    echo "$line 脚本结束执行：$(date)" >> time-tall.txt

    # 计算并显示总执行时间
    total_time=$((end_time - start_time))
    echo "$line 总执行时间：${total_time} 秒" >> time-tall.txt
    echo "\n\n" >> time-tall.txt
    

done < "$FILENAME"
#!/bin/bash

# 获取开始时间
start_time=$(date +%s)

echo "脚本开始执行：$(date)" >> time-tall.txt

# 在这里放置你要执行的命令
# 例如：
sleep 3
echo "Hello, world!"

# 获取结束时间
end_time=$(date +%s)

echo "脚本结束执行：$(date)" >> time-tall.txt
echo "\n\n" >> time-tall.txt
# 计算并显示总执行时间
total_time=$((end_time - start_time))
echo "总执行时间：${total_time} 秒" >> time-tall.txt

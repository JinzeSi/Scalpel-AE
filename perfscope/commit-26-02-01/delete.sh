# 读取参数一
param1=$1
# 打开参数一文件，并按行读取，如commit-1.txt
while IFS= read -r line; do
    # 删除每行前面的*、| 和空格
    cleaned_line=$(echo "$line" | sed 's/^[*| ]*//')
    # 删除每行后面的空格
    cleaned_line=$(echo "$cleaned_line" | sed 's/[ ]*$//')
    # 输出处理后的行
    echo "$cleaned_line"
done < "$param1"


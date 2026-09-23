# 读取 new_function.txt 中的关键字，存入集合 b
b = set()
with open('new_function.txt', 'r') as f:
    for line in f:
        key = line.strip()  # 去除行尾的换行符和空白字符
        if key:  # 忽略空行
            b.add(key)

# 处理 getFuncName-ini.txt 并输出到 getFuncName.txt
with open('getFuncName-ini.txt', 'r') as fin, open('getFuncName.txt', 'w') as fout:
    for line in fin:
        parts = line.strip().split()  # 按空白字符分割行
        if len(parts) >= 2:  # 确保行至少有 2 列
            if b and parts[1] in b:  # 如果 b 不为空且第 2 列在 b 中
                parts[0] = '1'  # 将第 1 列设置为 1
        fout.write(' '.join(parts) + '\n')  # 输出修改后的行
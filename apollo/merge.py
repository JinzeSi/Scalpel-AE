import os
import shutil

# 定义目录
directories = ['data-5.1', 'data-5.2', 'data-5.3']
output_dir = 'data-5'
output_else_dir = 'data-5-else'

# 创建输出目录
os.makedirs(output_dir, exist_ok=True)
os.makedirs(output_else_dir, exist_ok=True)

# 初始化计数器
then_i = 0
else_i = 0

# 遍历所有目录
for directory in directories:
    # 遍历目录中的文件
    i = 0
    while True:
        # 构建文件名
        txt_file = os.path.join(directory, f'{i}.txt')
        sql_file = os.path.join(directory, f'{i}.sql')
        sql_reduced_file = os.path.join(directory, f'{i}.sql_reduced')
        
        # 如果文件不存在，跳出循环
        if not os.path.exists(txt_file):
            break
        
        # 读取txt文件的第一行
        with open(txt_file, 'r') as f:
            first_line = f.readline().strip()
        
        # 解析浮点数
        try:
            floats = list(map(float, first_line.strip('()').split(',')))
        except ValueError:
            print(f"Error parsing {txt_file}")
            continue
        
        # 检查第二个、第三个、第五个、第六个浮点数是否大于0.1
        if any(floats[j] > 0.1 for j in [1, 2, 4, 5]):
            # 拷贝到data-else目录
            shutil.copy(sql_file, os.path.join(output_else_dir, f'{else_i}.sql'))
            shutil.copy(sql_reduced_file, os.path.join(output_else_dir, f'{else_i}.sql_reduced'))
            shutil.copy(txt_file, os.path.join(output_else_dir, f'{else_i}.txt'))
            else_i += 1
        else:
            # 拷贝到data目录
            shutil.copy(sql_file, os.path.join(output_dir, f'{then_i}.sql'))
            shutil.copy(sql_reduced_file, os.path.join(output_dir, f'{then_i}.sql_reduced'))
            shutil.copy(txt_file, os.path.join(output_dir, f'{then_i}.txt'))
            then_i += 1
        
        i += 1

print(f"Processed {i} files from each directory.")
print(f"then_i: {then_i}, else_i: {else_i}")

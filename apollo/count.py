import os

def read_and_check_files(directory):
    counter = 0
    i = 0
    
    while True:
        file_path = os.path.join(directory, f"{i}.txt")
        
        # 如果文件不存在，退出循环
        if not os.path.exists(file_path):
            break
        
        with open(file_path, 'r') as file:
            first_line = file.readline().strip()
            
            # 检查第一行是否符合格式
            if first_line.startswith('(') and first_line.endswith(')'):
                try:
                    # 提取括号内的浮点数
                    numbers = list(map(float, first_line[1:-1].split(',')))
                    
                    # 检查第一个和第四个浮点数是否大于1.1
                    if len(numbers) >= 4 and numbers[0] > 1.1 and numbers[3] > 1.1:
                        print(file_path)
                        counter += 1
                except ValueError:
                    # 如果转换失败，跳过该文件
                    continue
        
        i += 1
    
    print(f"Total files matching the condition: {counter}")

# 使用示例
directory = 'data-5-else'  # 替换为你的目录路径
read_and_check_files(directory)

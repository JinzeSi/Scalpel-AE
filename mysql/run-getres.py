import re

def extract_number_from_line(line):
    """从给定行中提取数字"""
    # match = re.search(r"end to end took ([\d\.]+) us", line)
    match = re.search(r"(\d+\.\d+)", line)
    if match:
        # print(match)
        return float(match.group(1))  # 将匹配结果转换为浮点数
    return None

def process_file(filename):
    """处理文件，从每行中提取数字，并计算平均值"""
    numbers = []  # 用于存储所有匹配的数字
    with open(filename, 'r') as file:
        for line in file:
            number = extract_number_from_line(line)
            # print(number)
            if number is not None:
                numbers.append(number)
    
    # 排除第一个数字后计算平均值
    
    average = sum(numbers[0:1]) / (len(numbers)) /10
    return  average
       

# 替换 'your_file.txt' 为你的文件名

filename = 'real-execute-res-1.txt'
average1 = process_file(filename)
filename2 = 'real-execute-res-old-1.txt'
average2 = process_file(filename2)

filename3 = 'real-execute-res-pure-1.txt'
average3 = process_file(filename3)


print("新版本沿符号执行")
print(average1)

print("新版本默认执行")
print(average3)

print("旧版本")
print(average2)

print("新旧版本比较（沿符号执行）")
print((average1-average2)/average2)

print("新旧版本比较（默认执行）")
print((average3-average2)/average2)



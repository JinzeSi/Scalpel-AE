import re
import numpy as np

def extract_number_from_line(line):
    """从给定行中提取数字"""
    match = re.search(r"end to end took ([\d\.]+) us", line)
    if match:
        return float(match.group(1))  # 将匹配结果转换为浮点数
    return None

def filter_outliers(data):
    mean = np.mean(data)
    std = np.std(data)
    lower_bound = mean - 2 * std
    upper_bound = mean + 2 * std

    # 过滤掉超出两倍标准差的数据
    filtered_data = [x for x in data if lower_bound <= x <= upper_bound]
    return filtered_data

def process_file(filename):
    """处理文件，从每行中提取数字，并计算平均值"""
    numbers = []  # 用于存储所有匹配的数字
    with open(filename, 'r') as file:
        for line in file:
            number = extract_number_from_line(line)
            if number is not None:
                numbers.append(number)
    
    # 排除第一个数字后计算平均值
    if len(numbers) > 9000:
        average = sum(numbers[5000:]) / (len(numbers) - 5000) 
        subset_numbers = numbers[5000:]

        filtered_numbers = filter_outliers(subset_numbers)


        filtered_mean = np.mean(filtered_numbers)
        print(f"Average (excluding the first number): {filtered_mean:.6f}")
        return filtered_mean
    else:
        average = sum(numbers[30:]) / (len(numbers) - 30) 
        print(f"Average (excluding the first number): {average:.6f}")
        return average

# 替换 'your_file.txt' 为你的文件名

filename = 'real-execute-res-1.txt'
average1 = process_file(filename)
filename2 = 'real-execute-res-old-1.txt'
average2 = process_file(filename2)

filename3 = 'real-execute-res-pure-1.txt'
average3 = process_file(filename3)


print("New version (symbolic path)")
print(average1)

print("New version (default execution)")
print(average3)

print("Old version")
print(average2)

print("New vs. old (symbolic path)")
print((average1-average2)/average2)

print("New vs. old (default execution)")
print((average3-average2)/average2)


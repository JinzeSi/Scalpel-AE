import re

def extract_number_from_line(line):
    """从给定行中提取数字"""
    match = re.search(r"end to end took ([\d\.]+) us", line)
    if match:
        return float(match.group(1))  # 将匹配结果转换为浮点数
    return None
# modified part took 355.719000 us, end to end took 3410.662000 us, about 10.429617%, should usleep 0.000000 us
def extract_number_from_line2(line):
    """从给定行中提取数字"""
    match = re.search(r"modified part took ([\d\.]+) us", line)
    if match:
        return float(match.group(1))  # 将匹配结果转换为浮点数
    return None

def process_file(filename):
    """处理文件，从每行中提取数字，并计算平均值"""
    numbers = []  # 用于存储所有匹配的数字
    numbers2 = []
    with open(filename, 'r') as file:
        for line in file:
            number = extract_number_from_line(line)
            number2 = extract_number_from_line2(line)
            if number is not None:
                numbers.append(number)
                numbers2.append(number2)
    
    # 排除第一个数字后计算平均值
    if len(numbers) > 9000:
        average = sum(numbers[5000:]) / (len(numbers) - 5000) 
        print(f"Average end to end: {average:.6f}")

        average2 = sum(numbers2[5000:]) / (len(numbers2) - 5000) 
        print(f"Average modified part: {average2:.6f}")
        
        print((average2)/average)
        return average
    else:
        average = sum(numbers[30:]) / (len(numbers) - 30) 
        print(f"Average end to end: {average:.6f}")

        average2 = sum(numbers2[30:]) / (len(numbers2) - 30) 
        print(f"Average modified part: {average2:.6f}")

        print((average2)/average)
        return average

# 替换 'your_file.txt' 为你的文件名

filename = 'real-execute-modified-part-res-1.txt'
average1 = process_file(filename)




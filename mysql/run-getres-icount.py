def read_number_from_file(filename):
    """从指定文件中读取一个数字"""
    with open(filename, 'r') as file:
        number = float(file.read().strip())
    return number

def calculate_differences(num1, num2):
    """计算两个数字之间的百分比差异和绝对差异"""
    absolute_difference = abs(num1 - num2)
    if num2 != 0:
        percentage_difference = (absolute_difference / abs(num2)) * 100
    else:
        percentage_difference = 0  # 如果num2为0，则百分比差异无穷大
    return percentage_difference, absolute_difference

# 读取文件中的数字
number_from_a = read_number_from_file('icount-new.txt')
number_from_b = read_number_from_file('icount-old.txt')

# 计算差异
percentage_diff, absolute_diff = calculate_differences(number_from_a, number_from_b)

# 打印结果
print(f"Absolute Difference: {absolute_diff:.2f}")
print(f"Percentage Difference: {percentage_diff:.2f}%")


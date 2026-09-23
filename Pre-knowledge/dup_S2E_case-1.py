def read_and_deduplicate(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # 使用两个换行符分割文本，适应不同操作系统的换行符
    sections = content.split('\n')

    # 去除重复的段落，使用 set 来自动去重
    unique_sections = list(set(sections))

    # 将去重后的段落重新组合成字符串，每个段落之间用两个换行符分隔
    # deduplicated_content = '\n\n'.join(unique_sections)
    file = open(file_path, 'w', encoding='utf-8')
    i="1"
    for unique_section in unique_sections:
    # 写回文件
        if unique_section == "":
            continue
        file.write(unique_section)
        file.write('\n')
    file.close()
            

# 调用函数处理文件
file_path = 'generate_S2E_case-1.txt'
read_and_deduplicate(file_path)

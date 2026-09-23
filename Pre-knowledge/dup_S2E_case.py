def read_and_deduplicate(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # 使用两个换行符分割文本，适应不同操作系统的换行符
    sections = content.split('\n\n')

    # 去除重复的段落，使用 set 来自动去重
    unique_sections = set()

    # 将去重后的段落重新组合成字符串，每个段落之间用两个换行符分隔
    # deduplicated_content = '\n\n'.join(unique_sections)
    file = open(file_path, 'w', encoding='utf-8')
    flag = 0
    deduplicated_content = ""
    for unique_section in sections:
    # 写回文件
        if unique_section == "":
            continue
        if unique_section == "Begin NULL":
            if flag == 0:
                deduplicated_content = "Begin NULL" + "\n\n"
                flag = 1
            continue
        if unique_section == "End NULL":
            if flag == 2 :
                file.write(unique_section)
                file.write('\n\n')
            flag = 0
            continue
            
        if unique_section in unique_sections:
            continue
        if flag == 1:
            file.write(deduplicated_content)
            flag = 2
        unique_sections.add(unique_section)
        file.write(unique_section)
        file.write('\n\n')
    file.close()
            

# 调用函数处理文件
file_path = 'generate_S2E_case-2.txt'
read_and_deduplicate(file_path)

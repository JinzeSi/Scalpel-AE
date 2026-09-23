import os
import sys
import subprocess

def read_file_lines(filepath):
    with open(filepath, 'r') as file:
        return file.readlines()

def is_directory_empty(directory):
    return not any(os.scandir(directory))

def process_commit(last_commit_id, commit_id):
    commit_dir = f"./{commit_id}"
    if is_directory_empty(commit_dir):
        return f"# NC- {commit_id}\n\n"
    
    files_to_check = ["getFuncName.txt", "call_analyse.txt", "symbolic_analyse.txt", "call_analyse2.txt"]
    for filename in files_to_check:
        filepath = os.path.join(commit_dir, filename)
        if os.path.exists(filepath) and os.path.getsize(filepath) == 0:
            return f"# AB- {commit_id}\n{filename}文件为空\n\n"
    
    call_analyse2_path = os.path.join(commit_dir, "call_analyse2.txt")
    testcase_lines = [line.strip() for line in read_file_lines(call_analyse2_path) if line.startswith("testcase:")]
    
    if all(line == "testcase:no testcase" for line in testcase_lines):
        return f"# NT- {commit_id}\n\n"
    
    flag = "PT-" if any(line == "testcase:no testcase" for line in testcase_lines) else "AT-"
    valid_testcases = [line.replace("testcase:", "") for line in testcase_lines if line != "testcase:no testcase"]
    n = len(valid_testcases)
    
    array1, array2 = [], []
    no_symbolic = 0
    for line in read_file_lines(call_analyse2_path):
        if line.startswith("Begin NULL"):
            no_symbolic = 1
        elif line.startswith("End NULL"):
            no_symbolic = 0
        elif line.startswith("testcase:") and not line.startswith("testcase:no testcase"):
            testcase = line.replace("testcase:", "")
            if no_symbolic:
                array1.append(testcase)
            else:
                array2.append(testcase)
    
    output = f"# {flag} {commit_id}\n"
    for i in range(1, n + 1):
        testcase_dir = os.path.join(commit_dir, str(i))
        old_testcase_dir = os.path.join(f"./{last_commit_id}-old", str(i))
        output += f"## 第{i}次符号执行\n"
        if i <= len(array1):
            output += f"{array1[i-1]}\n"
        else:
            output += f"{array2[i-1-len(array1)]}\n"
        
        new_compile_lines = []
        old_compile_lines = []
        
        new_compile_path = os.path.join(testcase_dir, "compile.txt")
        if os.path.exists(new_compile_path):
            new_compile_lines = read_file_lines(new_compile_path)
            
        old_compile_path = os.path.join(old_testcase_dir, "compile.txt")
        if os.path.exists(old_compile_path):
            old_compile_lines = read_file_lines(old_compile_path)
        
        # 新旧版本符号执行情况
        if i <= len(array1):
            output += "无需符号执行\n"
        else:
            # 新版本符号执行情况
            if any("新版本符号执行插桩后编译失败" in line for line in new_compile_lines):
                output += "新版本符号执行插桩后编译失败\n"
            else:
                execution_trace_path = os.path.join(testcase_dir, "execution_trace.json")
                if not os.path.exists(execution_trace_path):
                    output += "新版本timeout\n"
                else:
                    debug_path = os.path.join(testcase_dir, "s2e_res/debug.txt")
                    if os.path.exists(debug_path):
                        debug_lines = read_file_lines(debug_path)
                        if any("received segfault" in line for line in debug_lines):
                            output += "新版本received segfault\n"
                        elif any("bootstrap terminated" in line for line in debug_lines):
                            output += "新版本bootstrap terminated\n"
                        elif any("Program terminated" in line for line in debug_lines):
                            output += "新版本Program terminated\n"
                            if not any("value" in line for line in read_file_lines(execution_trace_path)):
                                output += "新版本无符号执行用例\n"
            
            # 旧版本符号执行情况
            if is_directory_empty(old_testcase_dir):
                output += "old异常\n"
            else:
                if any("旧版本符号执行插桩后编译失败" in line for line in old_compile_lines):
                    output += "旧版本符号执行插桩后编译失败\n"
                else:
                    old_execution_trace_path = os.path.join(old_testcase_dir, "execution_trace.json")
                    if not os.path.exists(old_execution_trace_path):
                        output += "旧版本timeout\n"
                    else:                    
                        old_debug_path = os.path.join(old_testcase_dir, "s2e_res/debug.txt")
                        if os.path.exists(old_debug_path):
                            old_debug_lines = read_file_lines(old_debug_path)
                            if any("received segfault" in line for line in old_debug_lines):
                                output += "旧版本received segfault\n"
                            elif any("bootstrap terminated" in line for line in old_debug_lines):
                                output += "旧版本bootstrap terminated\n"
                            elif any("Program terminated" in line for line in old_debug_lines):
                                output += "旧版本Program terminated\n"

        # 新旧版本真实执行情况
        if any("新版本测量修改部分真实执行插桩后编译失败" in line for line in new_compile_lines):
            output += "新版本测量修改部分真实执行插桩后编译失败\n"
        if any("新版本无占比真实执行插桩后编译失败" in line for line in new_compile_lines):
            output += "新版本无占比真实执行插桩后编译失败\n"
        if any("新版本完全真实执行插桩后编译失败" in line for line in new_compile_lines):
            output += "新版本完全真实执行插桩后编译失败\n"
        if any("旧版本无占比真实执行插桩后编译失败" in line for line in old_compile_lines):
            output += "旧版本无占比真实执行插桩后编译失败\n"
        
        final_res_path = os.path.join(testcase_dir, "final-res.txt")
        if os.path.exists(final_res_path):
            final_res_lines = read_file_lines(final_res_path)
            output += "``` sql \n" + "".join(final_res_lines) + "``` \n"
            for j, line in enumerate(final_res_lines):
                if line.strip() == "新旧版本比较（沿符号执行）":
                    if float(final_res_lines[j + 1].strip()) > 0.02:
                        output += "新旧版本沿符号执行end-to-end有性能问题\n"
                if line.strip() == "新旧版本比较（默认执行）":
                    if float(final_res_lines[j + 1].strip()) > 0.02:
                        output += "新旧版本默认执行end-to-end有性能问题\n"
                elif line.startswith("Average modified part: "):
                    if float(line.split(": ")[1].strip()) == 0:
                        output += "无占比\n"
        
        real_execute_path = os.path.join(testcase_dir, "real-execute-modified-part-res-1.txt")
        if os.path.exists(real_execute_path):
            real_execute_lines = read_file_lines(real_execute_path)
            if len(real_execute_lines) >= 2:
                val1 = float(real_execute_lines[0].split()[3])
                val2 = float(real_execute_lines[1].split()[3])
                if (val1 == 0 or val2 == 0) and not (val1 == 0 and val2 == 0):
                    output += "不幂等\n"

        # if os.path.exists(os.path.join(testcase_dir, "real-execute-res-1.txt")) and os.path.exists(os.path.join(testcase_dir, "real-execute-res-old-1.txt")):
        #     draw_script = "/data3/sjz/AE/mysql/draw.py"
        #     result = subprocess.run(["python3", draw_script, "real-execute-res-1.txt", "real-execute-res-old-1.txt", "real.png"], cwd=testcase_dir, capture_output=True, text=True)
        #     if result.returncode == 0:
        #         output += "``` sql \n" + result.stdout + "``` \n"
        #         output += "![real](" + os.path.join(testcase_dir, "real.png") + ")\n\n"
        #     else:
        #         output += "real绘图失败\n"
        
        # if os.path.exists(os.path.join(testcase_dir, "real-execute-res-pure-1.txt")) and os.path.exists(os.path.join(testcase_dir, "real-execute-res-old-1.txt")):
        #     draw_script = "/data3/sjz/AE/mysql/draw.py"
        #     result = subprocess.run(["python3", draw_script, "real-execute-res-pure-1.txt", "real-execute-res-old-1.txt", "pure.png"], cwd=testcase_dir, capture_output=True, text=True)
        #     if result.returncode == 0:
        #         output += "``` sql \n" + result.stdout + "``` \n"
        #         output += "![pure](" + os.path.join(testcase_dir, "pure.png") + ")\n\n"
        #     else:
        #         output += "pure绘图失败\n"
    
    return output

def main():
    if len(sys.argv) != 2:
        print("Usage: python summary.py <last_commit_id>")
        sys.exit(1)
    last_commit_id = sys.argv[1].strip()
    commit_ids = read_file_lines("commit-tmp.txt")
    markdown_output = ""
    for commit_id in commit_ids:
        print(f"{commit_ids.index(commit_id) + 1}/{len(commit_ids)}")
        commit_id = commit_id.strip()
        markdown_output += process_commit(last_commit_id, commit_id)
        last_commit_id = commit_id
    with open("summary.md", "w") as output_file:
        output_file.write(markdown_output)

if __name__ == "__main__":
    main()
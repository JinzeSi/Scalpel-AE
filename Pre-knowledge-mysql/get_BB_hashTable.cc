#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <cctype>
#include <vector>

// 函数用于删除字符串首尾的空格
std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(' ');
    size_t last = str.find_last_not_of(' ');
    if (first == std::string::npos || last == std::string::npos)
        return "";
    return str.substr(first, (last - first + 1));
}

int main(int argc, char *argv[]) {
  
    // std::ifstream infile("redis-BB.txt");
    // std::ofstream outfile("redis-BB-res-1.txt");
    
    std::string filename1 = argv[1];
    std::string filename2 = argv[2];

    std::ifstream infile(filename1);
    std::ofstream outfile(filename2);
    std::string line;

    if (!infile) {
        std::cerr << "无法打开文件 "<<  filename1 << std::endl;
        return 1;
    }
    std::string functionName;
    std::string BBName;
    std::string hashKey;
    std::vector<std::string> strs;
    while (std::getline(infile, line)) {
        
        std::string trimmed = trim(line);
        size_t firstColon = trimmed.rfind(':');
        std::string area1;
        area1 = trimmed.substr(0, firstColon);
        if(area1 == "Function"){
            functionName = trimmed.substr(firstColon+2);
            continue;   
        }
        if(area1 == "Basic Block Name"){
            BBName = trimmed.substr(firstColon+2);
            strs.clear();
            continue;    
        }
        std::string area2;
        area2 = trimmed.substr(firstColon+1);
        size_t secondColon = area2.rfind(' ');
        std::string line_num;
        std::string column_num;
        line_num = area2.substr(0, secondColon);
        column_num = area2.substr(secondColon + 1); 

        size_t lastSlash = trimmed.rfind('/');
        std::string fileName;
        fileName = trimmed.substr(lastSlash + 1, firstColon - lastSlash - 1);

        std::string Key1;
        Key1 = fileName + "+" + BBName;
        std::string Key2;
        Key2 = fileName;
        if(hashKey != Key1){
            hashKey = Key1;
            outfile << "Key:" << Key1 << "\n"; 
            outfile << "Key2:" << Key2 << " " << BBName <<  "\n"; 
        }   
        std::string tmp;
        tmp = line_num + "+" + column_num;
        auto it = std::find(strs.begin(), strs.end(), tmp);
        if (it != strs.end()) {
            continue;
        } else {
            strs.push_back(tmp);
        }
        outfile << tmp << "\n"; 

    }

    infile.close();
    outfile.close();
    return 0;
}

// std::vector<std::string> strs = {"apple", "banana", "apple", "orange", "banana", "cherry"};

//     // 使用 set 去重
//     std::set<std::string> unique_strs(strs.begin(), strs.end());

//     // 将去重后的结果转存回 vector（如果需要）
//     std::vector<std::string> result(unique_strs.begin(), unique_strs.end());

//     // 输出去重后的结果
//     std::cout << "Unique strings:" << std::endl;
//     for (const auto& str : result) {
//         std::cout << str << std::endl;
//     }
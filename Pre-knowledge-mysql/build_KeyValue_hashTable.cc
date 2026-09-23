#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <cctype>
#include <map>
#include <list>
#include <sstream>
#include <set>
#include <chrono>
#include <thread>


// 函数用于删除字符串首尾的空格

std::string findLineAndColumnNum(std::map<std::string, std::list<std::pair<int,int>>> map,std::string key,std::string line, std::string column){
    int lineNum = std::stoi(line);
    int columnNum = std::stoi(column);
    // if (map.find(key) == map.end()){
    //     return "";
    // }
    std::list<std::pair<int,int>> tmp = map[key];
    for (const auto& element : tmp) {
        if(element.first == lineNum && element.second >= columnNum){
            return key + "+" + std::to_string(element.first) + "+" + std::to_string(element.second);
        }
        if(element.first > lineNum){
            return key + "+" + std::to_string(element.first) + "+" + std::to_string(element.second);
        }
    }
    return "";


}

std::set<std::string> split(const std::string& str, const std::string& delim) {
    std::set<std::string> tokens;
    size_t prev = 0, pos = 0;

    do {
        pos = str.find(delim, prev);
        if (pos == std::string::npos) pos = str.length();
        std::string token = str.substr(prev, pos - prev);
        if (!token.empty()) tokens.insert(token);
        prev = pos + delim.length();
    } while (pos < str.length() && prev < str.length());

    return tokens;
}

std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(' ');
    size_t last = str.find_last_not_of(' ');
    if (first == std::string::npos || last == std::string::npos)
        return "";
    return str.substr(first, (last - first + 1));
}

int main(int argc, char *argv[]) {

    std::string filename1 = argv[1];
    std::string filename2 = argv[2];
    std::string filename3 = argv[3];
    std::string filename4 = argv[4];

    // std::ifstream infile("redis-BB-res-2.txt");

    // std::ifstream infile1("redis-BB-res-3.txt");

    // std::string BBInfo = "re-build/BB-info";

    // std::ifstream infile2("redis-order.txt");
    std::ifstream infile(filename1);

    std::ifstream infile1(filename2);

    std::string BBInfo = "re-build/BB-info";

    std::ifstream infile2(filename3);
   
    std::string line;


    if (!infile) {
        std::cout << "无法打开文件 redis-BB-res-2.txt" << std::endl;
        return 1;
    }
    if (!infile1) {
        std::cout << "无法打开文件 redis-BB-res-3.txt" << std::endl;
        return 1;
    }
    
    std::map<std::string, std::list<std::string>> map;
    std::map<std::string, std::set<std::string>> map2;
   

    std::map<std::string, std::list<std::pair<int,int>>> map3;
    std::map<std::string, std::string> map4;

    while (std::getline(infile, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        // bitops.c+818+13:Basic_Block_29939 
        size_t firstColon = trimmed.rfind(':');
        std::string area1;
        std::string area2;
        area1 = trimmed.substr(0, firstColon);
        // Basic_Block_29939 
        area2 = trimmed.substr(firstColon+1);
        std::istringstream iss(area2);
        std::list<std::string> value_BB;
        std::string token;

        while (iss >> token) {
            value_BB.push_back(token);
        }
        map.insert(std::make_pair(area1, value_BB));

        size_t secondColon = area1.rfind('+');
        int columnNum = std::stoi(area1.substr(secondColon+1));
        
        std::string area3 = area1.substr(0, secondColon);

        size_t thirdColon = area3.rfind('+');
        int lineNum = std::stoi(area3.substr(thirdColon+1));

        std::string Key = area3.substr(0, thirdColon);

        // std::list<std::pair<int,int>> tmp = map3[Key];
        map3[Key].push_back(std::make_pair(lineNum, columnNum));
        // map3[Key] = tmp;
    }

    std::cout << "step1" <<std::endl;
    while (std::getline(infile1, line)){
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        size_t firstColon = trimmed.find(':');
        std::string area1;
        std::string area2;
        area1 = trimmed.substr(0, firstColon);
        area2 = trimmed.substr(firstColon+1);
        std::set<std::string> value_BB;
        if(area2 ==""){
            map2.insert(std::make_pair(area1, value_BB));
            continue;
        }
        std::string delimiter = ";";
        value_BB = split(area2, delimiter);
        map2.insert(std::make_pair(area1, value_BB));
    }
    std::cout << "step2" <<std::endl;
    std::string instruction;
    int numFile = 1;
    std::string lineinfile2;
    while(std::getline(infile2, lineinfile2)){
        // std::string BBInfo = "re-build/redis-order";
        std::string trimmedInfile2 = trim(lineinfile2);
        if(trimmedInfile2 == "")
            continue;
        std::string BBInfoTmp = BBInfo + "-" + std::to_string(numFile)+ ".txt"; 
         std::cout<< BBInfoTmp <<std::endl;
        // std::ifstream infileTmp(BBInfoTmp);
        std::ifstream infileTmp;
        // const std::string filename = "example.txt";

        infileTmp.open(BBInfoTmp);
        while (!infileTmp.is_open()) {
            std::cout << "Failed to open file. Waiting 5 seconds before retrying..." << std::endl;
            std::this_thread::sleep_for(std::chrono::seconds(5));  // 等待 5 秒
            infileTmp.open(BBInfoTmp);  // 再次尝试打开文件
        }
        numFile++;
        if (!infileTmp) {
            std::cout << "无法打开文件 infileTmp" << std::endl;
            return 1;
        }
        
        while (std::getline(infileTmp, line)){
            std::string trimmed = trim(line);
            if(trimmed == "")
                continue;
      
            
            // std::cout<<trimmed <<std::endl;
            size_t firstColon = trimmed.find(':');
            std::string area1;
            std::string area2;
            area1 = trimmed.substr(0, firstColon);
            area1 = trim(area1);
            area2 = trimmed.substr(firstColon+1);
            area2 = trim(area2);
            if(area1 == "Instruction"){
                // instruction = area2;
                instruction = std::to_string(numFile-1);
                map4[instruction] = area2;
                std::cout << instruction <<std::endl;
                std::cout << area1 <<std::endl;
                std::cout << area2 <<std::endl;
                continue;
            }
            //dictRehash at /home/sjz/Pre-knowledge/redis/src/dict.c:414:1
            size_t secondColon= trimmed.rfind(':');
            std::string columnNum = trimmed.substr(secondColon + 1);

            area2 = trimmed.substr(0, secondColon); 

            size_t thirdColon= area2.rfind(':');
            std::string lineNum = area2.substr(thirdColon + 1); 
        
            area2 = area2.substr(0, thirdColon); 

            //dictRehash at /home/sjz/Pre-knowledge/redis/src/dict.c
            size_t forthColon= area2.rfind('/');
            std::string fileName = area2.substr(forthColon + 1);
            // std::cout << fileName <<std::endl; 
            area2 = area2.substr(0, forthColon); 

            // //dictRehash at /home/sjz/Pre-knowledge/redis/src
            // size_t fifthColon= area2.find(' ');
            // std::string funcitonName = area2.substr(0,fifthColon); 

            //acl.c+ACLAddAllowedFirstArg+936+37
            std::string Key1 = fileName + "+" + lineNum + "+" + columnNum;
            // std::cout<< Key1 << std::endl;
            if(lineNum == "0" && columnNum == "0")
                continue;
            if (map.find(Key1) == map.end()){
                // std::cout << "con't find Key1:" << Key1 << std::endl;
                // std::string lineAndColumnNum = findLineAndColumnNum(map3,fileName,lineNum,columnNum);
                std::string lineAndColumnNum ="";

                int lineNumNum = std::stoi(lineNum);
                int columnNumNum = std::stoi(columnNum);
                // if (map.find(key) == map.end()){
                //     return "";
                // }

                std::list<std::pair<int,int>> tmp = map3[fileName];
                int tmpcolumnNumNum = -1;
                int tmplineNumNum = -1;
                int flag_map = 0;
                for (const auto& element : tmp) {
                    if(element.first == lineNumNum){
                        flag_map = 1;
                        if (element.second == columnNumNum){
                            lineAndColumnNum =  fileName + "+" + std::to_string(element.first) + "+" + std::to_string(element.second);
                            break;
                        }
                        else if(element.second > columnNumNum){
                            if(tmpcolumnNumNum == -1 || element.second < tmpcolumnNumNum ){
                                tmpcolumnNumNum = element.second;
                                lineAndColumnNum =  fileName + "+" + std::to_string(element.first) + "+" + std::to_string(element.second);
                            }
                        }
                    }
                    if(flag_map == 0 && element.first > lineNumNum){
                        if(tmplineNumNum == -1 || element.first < tmplineNumNum)
                        tmplineNumNum = element.first;
                        lineAndColumnNum =  fileName + "+" + std::to_string(element.first) + "+" + std::to_string(element.second);
                    }
                }
                
                
                if(lineAndColumnNum == ""){
                    continue;
                }
                Key1 = lineAndColumnNum;
                
            }
            
            std::list<std::string> BBnames = map[Key1];
            for (std::string BBName : BBnames) {
                //acl.c+ACLAddAllowedFirstArg+Basic_Block_2
                std::string Key2 = fileName + "+" + BBName;
                // if (map2.find(Key2) == map2.end()){
                //     std::cout << "con't find Key2:" << Key2 << std::endl;
                //     continue;
                // }
                // std::set<std::string> instructions = map2[Key2];
                map2[Key2].insert(instruction);
                // map2[Key2] = instructions;
            }

        }
        infileTmp.close();
    }


    infile.close();
    infile1.close();
    infile2.close();
    std::cout << "step3" <<std::endl;
    // return 0;

    // std::ofstream outfile("redis-BB-res-3.txt");
    std::ofstream outfile(filename2);

    for (const auto& pair : map2) {
        std::set<std::string> tmp = pair.second;
        outfile << pair.first << ":";
        for (auto it = tmp.begin(); it != tmp.end(); ++it) {
            outfile << *it;  // 输出当前元素
            // std::cout << *it <<std::endl;
            if (std::next(it) != tmp.end()) {  // 检查这是否是最后一个元素
                outfile <<  ";";  // 
            }
        }
        outfile << "\n"; 
    }
    outfile.close();

    std::ofstream outfile2(filename4);

    for (const auto& pair : map4) {
        outfile2 << pair.first  << " "<< pair.second << "\n"; 
    }
    outfile2.close();

    std::ofstream outFile1("build_KeyValue_hashTable.txt");

    // 检查文件是否成功打开
    if (!outFile1) {
        std::cerr << "Error opening file:build_KeyValue_hashTable.txt." << std::endl;
        return 1; // 返回错误代码
    }

    // 执行完成
    outFile1 << "finish build_KeyValue_hashTable.txt" << std::endl;
    // 关闭文件
    outFile1.close();
    // outfile1.close();
    return 0;
}
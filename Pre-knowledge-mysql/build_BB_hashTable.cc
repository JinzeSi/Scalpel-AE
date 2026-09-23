#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <cctype>
#include <map>
#include <list>

// 函数用于删除字符串首尾的空格
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

    // std::ifstream infile("redis-BB-res-1.txt");
    std::ifstream infile(filename1);

    // std::ofstream outfile("redis-BB-res-2.txt");
    // std::ofstream outfile1("redis-BB-res-3.txt");
    std::ofstream outfile(filename2);
    std::ofstream outfile1(filename3);
 
    std::string line;


    if (!infile) {
        std::cerr << "无法打开文件 redis-BB-res-1.txt" << std::endl;
        return 1;
    }
    std::string key;
    std::string key2;
    std::string BBName;
    std::map<std::string, std::list<std::string>> map;
    std::map<std::string, std::string> map2;
    while (std::getline(infile, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        size_t firstColon = trimmed.rfind(':');
        if(firstColon == std::string::npos){
            std::string mapKey;
            std::string mapValue;
            mapKey = key2 + "+" + trimmed;
            mapValue = BBName;
            if (map.find(mapKey) != map.end()) {
                std::list<std::string> tmp = map[mapKey];
                tmp.push_back(mapValue);
                map[mapKey] = tmp;
                // map.insert(std::make_pair(mapKey, tmp));
                // outfile2 << mapKey << ":" << mapValue << std::endl;
            }else{
                std::list<std::string> tmp;
                tmp.push_back(mapValue);
                map.insert(std::make_pair(mapKey, tmp));
            }
            // map.insert(std::make_pair(mapKey, mapValue));
        }
        std::string area1;
        area1 = trimmed.substr(0, firstColon);
        if(area1 == "Key"){
            key = trimmed.substr(firstColon+1);
            map2.insert(std::make_pair(key, ""));
            continue;   
        }
        if(area1 == "Key2"){
            std::string area2;
            area2 = trimmed.substr(firstColon+1);
            size_t secondColon = area2.rfind(' ');
            BBName = area2.substr(secondColon+1);
            key2 = area2.substr(0 , secondColon);
            continue;    
        }
        // std::string area2;
        // area2 = trimmed.substr(firstColon+1);
        // size_t secondColon = area2.rfind(' ');
        // std::string line_num;
        // std::string column_num;
        // line_num = area2.substr(0, secondColon);
        // column_num = area2.substr(secondColon + 1); 

        // size_t lastSlash = trimmed.rfind('/');
        // std::string fileName;
        // fileName = trimmed.substr(lastSlash + 1, firstColon - lastSlash - 1);

        // std::string Key1;
        // Key1 = fileName + "+" + functionName + "+" + BBName;
        // std::string Key2;
        // Key2 = fileName + "+" + functionName;
        // if(hashKey != Key1){
        //     hashKey = Key1;
        //     outfile << Key1 << "\n"; 
        //     outfile << Key2 << " " << BBName <<  "\n"; 
        // }   

        // outfile << line_num << " " << column_num << "\n"; 

    }
    for (const auto& pair : map) {
        std::list<std::string> tmp = pair.second;
        outfile << pair.first << ":";
        for (std::string valuetmp : tmp) {
            outfile << valuetmp << " ";
        }
        outfile << "\n"; 
    }
    for (const auto& pair : map2) {
        // std::list<std::string> tmp = pair.second;
        outfile1 << pair.first << ":";
        outfile1 << "\n"; 
    }


    infile.close();
    outfile.close();
    outfile1.close();
    return 0;
}
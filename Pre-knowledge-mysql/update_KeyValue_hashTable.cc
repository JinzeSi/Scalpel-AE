#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <cctype>
#include <map>
#include <list>
#include <sstream>
#include <set>
#include<algorithm>


//gitshow.txt

//demo-redis-BB.txt

// 函数用于删除字符串首尾的空格

std::string commitId;
std::string findLineAndColumnNum(std::map<std::string, std::set<std::pair<int,int>>> mapTmp,std::string key,std::string line, std::string column){
    int lineNum = std::stoi(line);
    int columnNum = std::stoi(column);
    if (mapTmp.find(key) == mapTmp.end()){
        return "";
    }
    std::set<std::pair<int,int>> tmp = mapTmp[key];
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

std::map<std::string, std::list<std::string>> map;
std::map<std::string, std::set<std::string>> map2;

std::map<std::string, std::set<std::pair<int,int>>> map3;

std::map<std::string, std::string>map4;
std::string changeFunction;

std::map<std::string, std::set<int>> addMap;
std::map<std::string, std::set<int>> deleteMap;
std::map<std::string, std::set<int>> changeMap;
std::set<std::string> changeFunctions;

std::set<std::string> needUpdate;
std::set<std::string> addLineUpdate;

std::map<std::string,std::map<int,int>> changeLineMap;
std::map<std::string,int> changeFunctionsMinLine;
std::map<std::string,int> changeFunctionsMaxLine;
std::map<std::string,int> changeFunctionsChangeLine;

void update(std::string key, int lineNum,int columnNum,std::list<std::string> value_BB){
    if(changeFunctions.find(key) == changeFunctions.end()){
        std::string Key = key + "+" + std::to_string(lineNum) + "+" + std::to_string(columnNum);
        map.insert(std::make_pair(Key, value_BB));
        return;
    }
        
    if(lineNum < changeFunctionsMinLine[key]){
        std::string Key = key + "+" + std::to_string(lineNum) + "+" + std::to_string(columnNum);
        map.insert(std::make_pair(Key, value_BB));
        return;
    }

    if(lineNum > changeFunctionsMaxLine[key]){
        int diff = changeFunctionsChangeLine[key];
        int newLine = lineNum + diff;
        std::string Key = key + "+" + std::to_string(newLine) + "+" + std::to_string(columnNum);
        map.insert(std::make_pair(Key, value_BB));
        return;
    }
    std::set<int> deleteMap_1 = deleteMap[key];
    std::map<int,int> changeLineMap_1 = changeLineMap[key];
    if(deleteMap_1.find(lineNum) == deleteMap_1.end()){
        if(changeLineMap_1.find(lineNum)!= changeLineMap_1.end()){
            int newLine = changeLineMap_1[lineNum];
            std::string Key = key + "+" + std::to_string(newLine) + "+" + std::to_string(columnNum);
            map.insert(std::make_pair(Key, value_BB));
            //newline && std::map<std::string, std::set<int>> changeMap;
            std::set<int> tmpSet = changeMap[key];
            if (tmpSet.find(newLine) != tmpSet.end()) {
                for (std::list<std::string>::iterator it = value_BB.begin(); it != value_BB.end(); ++it) {
                    std::string tmp = key + "+" + *it;
                    addLineUpdate.insert(tmp);
                }
            }
            
        }
        else{
            int nearestNum = 0;
            for (const auto& pair : changeLineMap_1){
                if(pair.first < lineNum && (lineNum - nearestNum) > (lineNum - pair.first)){
                    nearestNum = pair.first;
                }
            }
            int diff = changeLineMap_1[nearestNum] - nearestNum;
            int newLine = lineNum + diff;
            std::string Key = key + "+" + std::to_string(newLine) + "+" + std::to_string(columnNum);
            map.insert(std::make_pair(Key, value_BB));
            //newline && std::map<std::string, std::set<int>> changeMap;
            std::set<int> tmpSet = changeMap[key];
            if (tmpSet.find(newLine) != tmpSet.end()) {
                for (std::list<std::string>::iterator it = value_BB.begin(); it != value_BB.end(); ++it) {
                    std::string tmp = key + "+" + *it;
                    addLineUpdate.insert(tmp);
                }
            }

        }
    }else{
        //value_BB
        for (std::list<std::string>::iterator it = value_BB.begin(); it != value_BB.end(); ++it) {
            std::string tmp = key + "+" + *it;
            needUpdate.insert(tmp);
        }
        
    }

    return;

    
    
}

int main(int argc, char *argv[]) {

    std::string filename1 = argv[2];
    std::string filename2 = argv[3];
    std::string filename3 = argv[4];
    std::string filename4 = argv[5];

    std::string filename8 = argv[8];
    // std::ifstream infile("redis-BB-res-2.txt");
    // std::ifstream infile1("redis-BB-res-3.txt");
    // std::ifstream infile2("demo-redis-BB.txt");
    // std::ifstream infile3("gitshow.txt");
    std::ifstream infile(filename1);
    std::ifstream infile1(filename2);
    std::ifstream infile2(filename3);
    std::ifstream infile3(filename4);

    std::ifstream infile8(filename8);

    std::string line;

    // for (const auto& pair : map4) {
    //     outfile2 << pair.first  << " "<< pair.second << "\n"; 
    // }
    // outfile2.close();
    while (std::getline(infile8, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        size_t firstColon = trimmed.find(' ');
        std::string numKey = trimmed.substr(0, firstColon);
        std::string instruction = trimmed.substr(firstColon+1);
        map4[numKey] = instruction;
        // std::cout << numKey << " instruction:" << instruction <<std::endl;
    }

    if (!infile) {
        std::cerr << "无法打开文件 redis-BB-res-2.txt" << std::endl;
        return 1;
    }
    if (!infile1) {
        std::cerr << "无法打开文件 redis-BB-res-3.txt" << std::endl;
        return 1;
    }

     if (!infile2) {
        std::cerr << "无法打开文件 demo-redis-BB.txt" << std::endl;
        return 1;
    }
    if (!infile3) {
        std::cerr << "无法打开文件 gitshow.txt" << std::endl;
        return 1;
    }
    int changeLineDiff = 0;
    int lastAddNum = 0;
    int flag = true;
    while (std::getline(infile3, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        if(flag){
            commitId = line;
            flag = false;
            continue;
        }
        if(trimmed[trimmed.size() - 1] == '+' || trimmed[trimmed.size() - 1] == '-'){
            size_t firstColon = trimmed.rfind(' ');
            std::string changeSymbol = trimmed.substr(firstColon+1);
            std::string changeLine =  trimmed.substr(0, firstColon);
            int changeLineNum = std::stoi(changeLine);
            if(changeSymbol == "+"){
                std::set<int> tmp = addMap[changeFunction];
                tmp.insert(changeLineNum);
                addMap[changeFunction] = tmp;
                //后续可能要改，还是要通过IR的BB来寻找测试用例
                if(lastAddNum == 0 || lastAddNum == changeLineNum - 1){
                    lastAddNum = changeLineNum;
                    //std::map<std::string, std::set<int>> changeMap;
                    // std::set<int> changeSet = changeMap[changeFunction];
                    // changeSet.insert(changeLineNum - 1);
                    // changeMap[changeFunction] = changeSet;
                }

                else {
                    std::set<int> changeSet = changeMap[changeFunction];
                    changeSet.insert(lastAddNum + 1);
                    changeMap[changeFunction] = changeSet;
                    lastAddNum = changeLineNum;
                }
            }
            else{
                if(lastAddNum > 0 ){
                    std::set<int> changeSet = changeMap[changeFunction];
                    changeSet.insert(lastAddNum + 1);
                    changeMap[changeFunction] = changeSet;
                }
                lastAddNum = 0;
                std::set<int> tmp = deleteMap[changeFunction];
                tmp.insert(changeLineNum);
                deleteMap[changeFunction] = tmp;
            }
        }
        else{
            if(lastAddNum > 0 ){
                std::set<int> changeSet = changeMap[changeFunction];
                changeSet.insert(lastAddNum + 1);
                changeMap[changeFunction] = changeSet;
            }
            if(trimmed.rfind(' ') == std::string::npos){
                std::cout << "old & new line3:" << changeFunction << "  " << changeLineDiff << std::endl;
                
                if(changeFunction != ""){
                    changeFunctionsChangeLine[changeFunction] = changeLineDiff;
                    std::cout << "old & new line2:" << changeFunction << "  " << changeLineDiff << std::endl;
                
                }
                size_t firstColon = trimmed.rfind('/');
                if(firstColon == std::string::npos)
                    changeFunction = trimmed;
                else
                    changeFunction = trimmed.substr(firstColon+1);
                changeFunctions.insert(changeFunction);
                lastAddNum = 0;
            }
            else{
                size_t firstColon = trimmed.rfind(' ');
                int oldLine = std::stoi(trimmed.substr(0, firstColon - 1));
                int newLine = std::stoi(trimmed.substr(firstColon+1));

                std::cout << trimmed << " oldLine:"<<oldLine << " newLine:" << newLine <<std::endl;
                
                std::map<int,int> tmp = changeLineMap[changeFunction];
                tmp[oldLine] = newLine;
                changeLineMap[changeFunction] = tmp;
                changeLineDiff = newLine - oldLine;
                std::cout << "old & new line:" << oldLine << "  " << newLine << "  " << changeLineDiff << std::endl;
                changeFunctionsMinLine[changeFunction] = std::min(oldLine, changeFunctionsMinLine[changeFunction]);
                changeFunctionsMaxLine[changeFunction] = std::max(oldLine, changeFunctionsMaxLine[changeFunction]);
                lastAddNum = 0;
            }
        }
        
    }


//    changeFunctions

    while (std::getline(infile, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        size_t firstColon = trimmed.find(':');
        std::string area1;
        std::string area2;
        area1 = trimmed.substr(0, firstColon);
        area2 = trimmed.substr(firstColon+1);
        std::istringstream iss(area2);
        std::list<std::string> value_BB;
        std::string token;

        while (iss >> token) {
            value_BB.push_back(token);
        }

        

        size_t secondColon = area1.rfind('+');
        int columnNum = std::stoi(area1.substr(secondColon+1));
        
        std::string area3 = area1.substr(0, secondColon);

        size_t thirdColon = area3.rfind('+');

        int lineNum = std::stoi(area3.substr(thirdColon+1));

        std::string Key = area3.substr(0, thirdColon);

        update(Key,lineNum,columnNum,value_BB);
    }


    while (std::getline(infile1, line)){
        //acl.c+Basic_Block_47490:./redis-cli set hello hello
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
        
        size_t secondColon = area1.find('+');

        std::string funcName = area1.substr(0, secondColon);
        std::string blockName = area1.substr(secondColon + 1);

        std::string delimiter = ";";
        value_BB = split(area2, delimiter);
        map2.insert(std::make_pair(area1, value_BB));

    }

    //std::set<std::string> needUpdate;
    
    //返回测试用例
    std::ofstream outfileRes("demo-S2E-times-res-1.txt");
    outfileRes<< "commitId:"<<commitId <<std::endl;
    outfileRes<< "    测试用例1:" <<std::endl;


    for (auto it = needUpdate.begin(); it != needUpdate.end(); ++it) {
        std::set<std::string> value_BB = map2[*it];
        if(value_BB.find("*needUpdate*") != value_BB.end() && value_BB.size() == 1){
            outfileRes<< "need to re-build pre-knowledge" <<std::endl;
            return 0;
        }
        //todo
        value_BB.erase("*needUpdate*");
        outfileRes<< "    " << "    " << "blockName:" <<  *it <<std::endl;
        for (std::set<std::string>::iterator ittmp = value_BB.begin(); ittmp != value_BB.end(); ++ittmp) {
            outfileRes << "    " << "    " << "    " << "instruction:" << *ittmp << std::endl;
            // outfileRes << "    " << "    " << "    " << "instruction:" << *ittmp << std::endl;
        }
        
        // value_BB.insert("*needUpdate*");
        // map2[*it] = value_BB;
        map2[*it].insert("*needUpdate*");

    }
    outfileRes << std::endl;
    


    int numNewBlock = 1;
    std::set<std::string> storeBB; 
    bool BBFlag = true;
    std::string newFileName;
    while (std::getline(infile2, line)){
        //修改    
        /*Function: ThreadsManager_init
            Basic Block Name: Basic_Block_1
                /home/sjz/Pre-knowledge/redis-version/redis/src/threads_mngr.c:48 22
                /home/sjz/Pre-knowledge/redis-version/redis/src/threads_mngr.c:55 1*/
        std::string trimmed = trim(line);
        size_t firstColon = trimmed.rfind(':');
        std::string area1;
        area1 = trimmed.substr(0, firstColon);
        if(area1 == "Function" || area1 == "Basic Block Name"){
            if(BBFlag == false){
                
                std::string newBBName = "Basic_Block_" + commitId + std::to_string(numNewBlock);
             
                // std::cout<< newBBName <<std::endl;

                // std::map<std::string, std::list<std::string>> map;
                // std::list<std::string> listTmp;
                // listTmp.push_back(newBBName);
                for (auto it = storeBB.begin(); it != storeBB.end(); ++it) {
                    std::list<std::string> listTmp = map[*it];
                    listTmp.push_back(newBBName);
                    map[*it] = listTmp;
                    // std::cout<< *it <<std::endl;
                    // std::map<std::string, std::set<std::string>> map2;
                    std::set<std::string> setTmp;
                    std::string newMap2Key= newFileName + "+" + newBBName;
                    
                    // setTmp = map2[newMap2Key];
                    // setTmp.insert("*needUpdate*");
                    // map2[newMap2Key] = setTmp;
                    map2[newMap2Key].insert("*needUpdate*");

                }
                

                numNewBlock++;
            }
            BBFlag = true;
           
            storeBB.clear();
            continue;   
        }
       
        std::string area2;
        area2 = trimmed.substr(firstColon+1);
        size_t secondColon = area2.rfind(' ');
        std::string lineNumString;
        std::string columnNumString;
        lineNumString = area2.substr(0, secondColon);
        columnNumString = area2.substr(secondColon + 1); 

        size_t lastSlash = trimmed.rfind('/');
        std::string fileName;
        fileName = trimmed.substr(lastSlash + 1, firstColon - lastSlash - 1);
        if(changeFunctions.find(fileName) == changeFunctions.end()){
            std::string storeKey = fileName + "+" + lineNumString + "+" + columnNumString;
            storeBB.insert(storeKey);
            continue;
        }
        int lineNum = std::stoi(lineNumString);
        std::set<int> addMapLine = addMap[fileName];
        if (addMapLine.find(lineNum) != addMapLine.end()){
            // std::string newBBName = "Basic_Block_" + '-' + std::to_string(numNewBlock);
            BBFlag = false;
            newFileName = fileName;
            std::string storeKey = fileName + "+" + lineNumString + "+" + '0';
            storeBB.insert(storeKey);
        }
        std::string storeKey = fileName + "+" + lineNumString + "+" + columnNumString;
        storeBB.insert(storeKey);

    }
    outfileRes<< "    测试用例2:" <<std::endl;
    //
    for (auto it = addLineUpdate.begin(); it != addLineUpdate.end(); ++it) {
        std::set<std::string> value_BB = map2[*it];
        std::string tmpTmp= *it;
        if(needUpdate.find(tmpTmp) == needUpdate.end()){
            if(value_BB.find("*needUpdate*") != value_BB.end() && value_BB.size() == 1){ 
                outfileRes<< "need to re-build pre-knowledge" <<std::endl;
                return 0;
            }
        }
        value_BB.erase("*needUpdate*");
        //cout  
        outfileRes << "    " << "    " << "blockName:" << *it << std::endl;
        for (std::set<std::string>::iterator ittmp = value_BB.begin(); ittmp != value_BB.end(); ++ittmp) {
            outfileRes << "    " << "    " << "    " << "instruction:" << *ittmp << std::endl;;
        }

    }
    outfileRes << std::endl;
    outfileRes.close();


    infile.close();
    infile1.close();
    infile2.close();
    infile3.close();
    std::string argInput = argv[1];
    if(argInput == "1"){
        // std::cout << "wuehgiewhgvbiwre" << std::endl;
        std::string filename5 = argv[6];
        // std::ofstream outfile("redis-BB-res-3-new.txt");
        std::ofstream outfile(filename5);

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
        std::string filename6 = argv[7];
        // std::ofstream outfile1("redis-BB-res-2-new.txt");
        std::ofstream outfile1(filename6);
        for (const auto& pair : map) {
            std::list<std::string> tmp = pair.second;
            outfile1 << pair.first << ":";
            for (std::string valuetmp : tmp) {
                outfile1 << valuetmp << " ";
            }
            outfile1 << "\n"; 
        }
        outfile1.close();
    }
    return 0;
}
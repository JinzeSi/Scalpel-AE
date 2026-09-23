#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <cctype>
#include <map>
#include <list>
#include <sstream>
#include <set>
#include <queue>

std::set<std::string> split(const std::string &str, const std::string &delim)
{
    std::set<std::string> tokens;
    size_t prev = 0, pos = 0;

    do
    {
        pos = str.find(delim, prev);
        if (pos == std::string::npos)
            pos = str.length();
        std::string token = str.substr(prev, pos - prev);
        if (!token.empty())
            tokens.insert(token);
        prev = pos + delim.length();
    } while (pos < str.length() && prev < str.length());

    return tokens;
}

std::string trim(const std::string &str)
{
    size_t first = str.find_first_not_of(' ');
    size_t last = str.find_last_not_of(' ');
    if (first == std::string::npos || last == std::string::npos)
        return "";
    return str.substr(first, (last - first + 1));
}
// 606 611 693
// db.c 2016 2018

std::set<std::string> functionChange;
std::map<std::string, std::map<std::string, std::string>> functionCall;

void addchildFunc(std::queue<std::string> &childFunc, std::string FatherFunction)
{

    size_t position_1 = FatherFunction.find(' ');
    std::string funcName = FatherFunction.substr(0, position_1);
    std::string area1 = FatherFunction.substr(position_1 + 1);
    size_t position_2 = area1.find(' ');
    std::string pathName = area1.substr(0, position_2);
    std::string key1 = funcName + " " + pathName;
    auto functionCalltmp = functionCall[key1];
    if (functionCalltmp.empty())
    {
        return;
    }
    else
    {
        std::set<std::string> functionRange;
        area1 = area1.substr(position_2 + 1);
        while (1)
        {
            size_t position_3 = area1.find(' ');
            std::string num1 = area1.substr(0, position_3);
            area1 = area1.substr(position_3 + 1);
            size_t position_4 = area1.find(' ');
            if (position_4 == -1)
            {
                std::string num2 = area1;
                std::string functionRangetmp = num1 + " " + num2;
                functionRange.insert(functionRangetmp);
                break;
            }
            std::string num2 = area1.substr(0, position_4);
            std::string functionRangetmp = num1 + " " + num2;
            functionRange.insert(functionRangetmp);
            area1 = area1.substr(position_4 + 1);
        }
        // functionCalltmp
        for (auto it = functionCalltmp.begin(); it != functionCalltmp.end(); ++it)
        {
            // 打印每个元素的键
            std::string functionCalltmpKey = it->first;
            size_t position = functionCalltmpKey.find('+');
            std::string key = functionCalltmpKey.substr(0, position);
            std::string callLine = functionCalltmpKey.substr(position + 1);

            if (functionRange.find(key) != functionRange.end())
            {

                childFunc.push(it->second);

                std::string functionCalltmpValue = it->second;
                // std::cout << "functionCalltmpValue111:" << functionCalltmpValue <<std::endl;
                addchildFunc(childFunc, functionCalltmpValue);
            }

            // std::cout << "Key: " << it->first << std::endl;
        }
    }
}
int main()
{
    std::ifstream infile("generate_S2E_case-2.txt");
    std::ifstream infile1("generate_S2E_case-1.txt");
    std::ifstream infile2("demo-S2E-times-res-2.txt");

    std::string line;

    if (!infile)
    {
        std::cout << "无法打开文件 redis-BB-res-2.txt" << std::endl;
        return 1;
    }
    if (!infile1)
    {
        std::cout << "无法打开文件 redis-BB-res-3.txt" << std::endl;
        return 1;
    }

    while (std::getline(infile1, line))
    {
        
        std::string trimmed = trim(line);
        if (trimmed == "")
            continue;
        // std::cout << "infile1: " << trimmed <<std::endl;
        functionChange.insert(trimmed);
    }
    
    bool flag = true;
    bool flagFunctionChange = false;
    bool flagFatherFunction = false;
    int numFunctionCall = 0;

    std::queue<std::string> lineNums;
    std::string FatherFunction;
    int numFunctionChild = 0;
    while (std::getline(infile2, line))
    {
        std::string trimmed = trim(line);
        if (trimmed == "")
            continue;
        if (flag)
        {
            // std::cout<< "infile2 - line:" << trimmed <<std::endl;
            // 606 611 693
            int spaceCount = std::count(trimmed.begin(), trimmed.end(), ' ');
            if (spaceCount == 0)
            {
                if (trimmed == "0"){
                
                    numFunctionCall = 1;
                }
                else
                {
                    numFunctionCall = 2;
                    lineNums.push(trimmed);
                }
            }
            else
            {
                numFunctionCall = spaceCount + 2;
                std::string area = trimmed;
                for (int i = 0; i < spaceCount; i++)
                {
                    size_t position = area.find(' ');
                    std::string area1 = area.substr(0, position);
                    std::string area2 = area.substr(position + 1);
                    lineNums.push(area1);
                    area = area2;
                }
                lineNums.push(area);
            }
            flag = false;

            flagFunctionChange = true;
            flagFatherFunction = true;
        }
        else
        {
            if (flagFunctionChange)
            {
                flagFunctionChange = false;
                continue;
            }
            if (flagFatherFunction && numFunctionCall == 1)
            {
                numFunctionCall = 0;
                flag = true;
                flagFunctionChange = false;
                flagFatherFunction = false;
                lineNums = std::queue<std::string>();
                continue;
            }
            if (flagFatherFunction)
            {

                FatherFunction = trimmed;
                // std::cout<< "FatherFunction:" << FatherFunction<<std::endl;
                flagFatherFunction = false;
                numFunctionCall -= 1;
                continue;
            }
            numFunctionCall--;
            numFunctionChild++;
            // std::cout<< "infile2 - Child:" << trimmed <<std::endl;
            std::string lineNum = lineNums.front();
            lineNums.pop();
            if (functionChange.find(trimmed) != functionChange.end())
            {
                // std::cout<< "infile2 - Child inininin:" << trimmed <<std::endl;
                // sigsegvHandler /data/sjz/commit-analysis/redis-run/redis-fe47c2027ba53c1e814f0481a12ffee97106115a/src/debug.c 2122 2122 2125 2134
                size_t position_1 = FatherFunction.find(' ');
                std::string funcName = FatherFunction.substr(0, position_1);
                std::string area1 = FatherFunction.substr(position_1 + 1);
                size_t position_2 = area1.find(' ');
                std::string pathName = area1.substr(0, position_2);
                area1 = area1.substr(position_2 + 1);
                // 2122 2122 2125 2134
                int num1Int = 0, num2Int = 0;
                while (1)
                {
                    size_t position_3 = area1.find(' ');
                    std::string num1 = area1.substr(0, position_3);
                    area1 = area1.substr(position_3 + 1);
                    size_t position_4 = area1.find(' ');
                    int lineNumInt = std::stoi(lineNum);
                    num1Int = std::stoi(num1);
                    if (position_4 == -1)
                    {
                        std::string num2 = area1;
                        num2Int = std::stoi(num2);
                        if (num1Int <= lineNumInt && num2Int >= lineNumInt)
                        {
                            break;
                        }
                        num1Int = 0;
                        num2Int = 0;
                        break;
                    }
                    std::string num2 = area1.substr(0, position_4);
                    num2Int = std::stoi(num2);
                    area1 = area1.substr(position_4 + 1);
                    if (num1Int <= lineNumInt && num2Int >= lineNumInt)
                    {
                        break;
                    }
                }
                if (num1Int == 0 && num2Int == 0)
                {
                    std::cout << "error num1Int && num2Int" << std::endl;
                    return 0;
                }

                // num1Int num2Int lineNum funcName pathName
                std::string key1 = funcName + " " + pathName;
                std::string key2 = std::to_string(num1Int) + " " + std::to_string(num2Int) + "+" + lineNum;
                // std::cout << "key1 & key2" << key1 << " " << key2 << std::endl;
                auto functionCalltmp = functionCall[key1];
                functionCalltmp[key2] = trimmed;
                functionCall[key1] = functionCalltmp;
            }

            if (numFunctionCall == 0)
            {
                numFunctionCall = 0;
                numFunctionChild = 0;
                flag = true;
                flagFunctionChange = false;
                flagFatherFunction = false;
                lineNums = std::queue<std::string>();
            }
        }
    }

    flag = true;
    flagFunctionChange = false;
    flagFatherFunction = false;
    numFunctionCall = 0;
    std::queue<std::string> childFunc;
    std::set<std::string> lineNumsSet;
    bool flagNew = false;
    while (std::getline(infile, line))
    {
        std::string trimmed = trim(line);
        if (trimmed == "")
            continue;
        if (trimmed == "Begin NULL"){
            std::cout << trimmed << std::endl;
            std::cout << std::endl;
            continue;
        }
            
        if (trimmed == "End NULL"){
            std::cout << trimmed << std::endl;
            std::cout << std::endl;
            continue;
        }

        if (flag)
        {
            // 606 611 693
            int spaceCount = std::count(trimmed.begin(), trimmed.end(), ' ');
            if (spaceCount == 0)
            {
                if (trimmed == "0"){
                    lineNums.push(trimmed);
                    numFunctionCall = 2;
                }
                else
                {
                    numFunctionCall = 3;
                    lineNums.push(trimmed);
                    lineNumsSet.insert(trimmed);
                }
            }
            else
            {
                numFunctionCall = spaceCount + 3;
                std::string area = trimmed;
                for (int i = 0; i < spaceCount; i++)
                {
                    size_t position = area.find(' ');
                    std::string area1 = area.substr(0, position);
                    std::string area2 = area.substr(position + 1);
                    lineNums.push(area1);
                    lineNumsSet.insert(area1);
                    area = area2;
                }
                lineNums.push(area);
                lineNumsSet.insert(area);
            }
            flag = false;

            flagFunctionChange = true;
            flagFatherFunction = true;
        }
        else
        {
            childFunc.push(trimmed);
            if (flagFatherFunction)
            {
                FatherFunction = trimmed;
                size_t position_1 = FatherFunction.find(' ');
                std::string funcName = FatherFunction.substr(0, position_1);
                std::string area1 = FatherFunction.substr(position_1 + 1);
                size_t position_2 = area1.find(' ');
                std::string pathName = area1.substr(0, position_2);
                std::string key1 = funcName + " " + pathName;

                //functionChange
                for(std::string functionChangetmp : functionChange){
                    if(functionChangetmp.find(key1) != std::string::npos){

                        flagNew = true;
                        break;
                    }
                   
                }

                flagFatherFunction = false;
                childFunc.pop();
            }
            
            numFunctionCall--;
            if(numFunctionCall == 0){
                if(!flagNew){
                    std::cout << trimmed << std::endl;
                    std::cout << std::endl;
                }
                flagNew = false;
                numFunctionCall = 0;
                numFunctionChild = 0;
                flag = true;
                flagFunctionChange = false;
                flagFatherFunction = false;
                lineNums = std::queue<std::string>();
                lineNumsSet.clear();
                childFunc = std::queue<std::string>();
                continue;
            }
            
            if (numFunctionCall == 1)
            {
                if(flagNew){
                    continue;
                }
                size_t position_1 = FatherFunction.find(' ');
                std::string funcName = FatherFunction.substr(0, position_1);
                std::string area1 = FatherFunction.substr(position_1 + 1);
                size_t position_2 = area1.find(' ');
                std::string pathName = area1.substr(0, position_2);
                std::string key1 = funcName + " " + pathName;
                // std::cout << "1234heihwiebvn: " << key1 <<std::endl;
                auto functionCalltmp = functionCall[key1];
                if (functionCalltmp.empty())
                {
                    
                }
                else
                {
                    // std::cout << "1234heihwiebvn: " << key1 <<std::endl;
                    std::set<std::string> functionRange;
                    area1 = area1.substr(position_2 + 1);
                    while (1)
                    {
                        size_t position_3 = area1.find(' ');
                        std::string num1 = area1.substr(0, position_3);
                        area1 = area1.substr(position_3 + 1);
                        size_t position_4 = area1.find(' ');
                        if (position_4 == -1)
                        {
                            std::string num2 = area1;
                            std::string functionRangetmp = num1 + " " + num2;
                            functionRange.insert(functionRangetmp);
                            break;
                        }
                        std::string num2 = area1.substr(0, position_4);
                        std::string functionRangetmp = num1 + " " + num2;
                        functionRange.insert(functionRangetmp);
                        area1 = area1.substr(position_4 + 1);
                    }
                    // functionCalltmp
                    for (auto it = functionCalltmp.begin(); it != functionCalltmp.end(); ++it)
                    {
                        // 打印每个元素的键
                        std::string functionCalltmpKey = it->first;
                        size_t position = functionCalltmpKey.find('+');
                        std::string key = functionCalltmpKey.substr(0, position);
                        std::string callLine = functionCalltmpKey.substr(position + 1);
                        if (lineNumsSet.find(callLine) == lineNumsSet.end())
                        {
                            if (functionRange.find(key) != functionRange.end())
                            {
                                lineNums.push(callLine);
                                childFunc.push(it->second);

                                std::string functionCalltmpValue = it->second;

                                // std::cout << "functionCalltmpValue:" << functionCalltmpValue <<std::endl;

                                addchildFunc(childFunc, functionCalltmpValue);

                            }
                        }
                        // std::cout << "Key: " << it->first << std::endl;
                    }
                }
                
                // 开始输出
                while(!lineNums.empty()){
                    std::string lineNumtmp = lineNums.front();
                    // std::cout << "lineNumtmp:" <<  lineNumtmp <<std::endl;
                    lineNums.pop();
                    if(lineNumtmp == "0" ){
                        if(lineNums.empty())
                            std::cout << lineNumtmp << " ";
                    }
                    else{
                        std::cout << lineNumtmp << " ";
                    }
                }
                std::cout << std::endl;
                std::cout << FatherFunction << std::endl;
                while(!childFunc.empty()){
                    std::cout << childFunc.front() << std::endl;
                    childFunc.pop();
                }
                


                
                continue;
            }
        }

        
    }
    infile.close();
    infile1.close();
    infile2.close();

    return 0;
}


// ./generate_S2E_case > generate_S2E_case-2.txt
// python3 dup_S2E_case-1.py 
// python3 dup_S2E_case.py 

// ./generate_S2E_case-2 > redis-BB-res-4.txt

// rm generate_S2E_case-1.txt
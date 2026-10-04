#include <iostream>
#include <fstream>
#include <nlohmann/json.hpp>
#include <cmath>
#include <queue>
#include <stack>

using json = nlohmann::json;

// 递归函数来打印 JSON 数据

int num = 0;


std::stack<std::queue<std::string>> VarNameQueues;

std::stack<std::pair<int,int>> queueIteml;
std::queue<int> queueCount;
int maxCount = 0;
std::queue<std::pair<int, std::queue<std::string> >> resQueue;

void print_json(const json& j, bool flag_1, const std::string& prefix = "") {
    int flag_count = 0;
    int tid_count;
    int pid_count;
    int flag_item = 0; 
    int tid;
    int pid;

    for (auto& element : j.items()) {
        
        if (element.value().is_structured()) {
            
            if(element.key() == "items"){
            }
            else
                print_json(element.value(), 0, prefix + "  ");
        } else {
            if(element.key() == "count"){
                int countNow =  int(element.value());             
                queueCount.push(countNow);
                if(countNow > maxCount){
                    maxCount = countNow;
                }
            }

        }
    }
}

int main(int argc, char* argv[]) {
    std::string filename = argv[1];
    // 打开 JSON 文件
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Failed to open file" << std::endl;
        return 1;
    }

    // 解析 JSON 文件
    json j;
    try {
        file >> j;
    } catch (json::parse_error& e) {
        std::cerr << "JSON parse error: " << e.what() << std::endl;
        return 1;
    }

    // 使用递归函数打印 JSON 数据
    print_json(j,0);

    std::cout << maxCount <<std::endl;

    return 0;
}

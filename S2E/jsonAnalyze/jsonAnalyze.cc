#include <iostream>
#include <fstream>
#include <nlohmann/json.hpp>
#include <cmath>
#include <queue>
#include <stack>

using json = nlohmann::json;

// 递归函数来打印 JSON 数据

int num = 0;

// //"items": [
//                         {
//                             "key": "v0_a_194_0",
//                             "value": [
//                                 128,
//                                 1,
//                                 1,
//                                 1
//                             ]
//                         }
//                     ],

std::stack<std::queue<std::string>> VarNameQueues;
void print_json2(const json& j) {
    std::queue<std::string> VarNameQueue;
    for (auto& element : j.items()) {
        json tmp = element.value();
        std::string keyTmp;
        std::string valueTmp;
        for (auto& element2 : tmp.items()) {
            if(element2.key() == "key")
                keyTmp =  std::string(element2.value());
            if(element2.key() == "value"){
                json tmp2 = element2.value();
                int num = 0;
                uint64_t res = 0;
                for (auto& element3 : tmp2.items()) {

                    res += int(element3.value()) * std::pow(128, num);
                    num ++;
                }
                valueTmp = std::to_string(res);
                
            }
            
        }
        std::string keyValueTmp = keyTmp + " " + valueTmp;
        VarNameQueue.push(keyValueTmp);
        // std::cout<< keyValueTmp <<std::endl;
    }
    VarNameQueues.push(VarNameQueue);
}
std::stack<std::pair<int,int>> queueIteml;
std::queue<int> queueCount;
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
                print_json2(element.value());
                num++;
                flag_1 = 1;
                flag_item = 2;
            }
            else
                print_json(element.value(), 0, prefix + "  ");
        } else {
            if(flag_item > 0){
                if(std::string(element.key()) == "pid"){
                    flag_item--;
                    pid = int(element.value());
                    // std::cout <<"element.key()3:" <<element.key() << " "<< element.value()<<std::endl;
                }

                if(element.key() == "tid"){
                    flag_item--;
                    tid = int(element.value());
                }
                if(flag_item == 0){
                    // std::cout << pid<< " " << tid <<std::endl;
                    queueIteml.push(std::make_pair(pid,tid));
                }
            }
            if(flag_count > 0){
                if(element.key() == "pid"){
                    flag_count--;
                    pid_count = int(element.value());
                }

                if(element.key() == "tid"){
                    flag_count--;
                    tid_count = int(element.value());
                }
                if(flag_count == 0){
                    std::pair<int,int> queueItemlPair = queueIteml.top();
                    if(pid_count == queueItemlPair.first && tid_count == queueItemlPair.second){
                        // std::cout<< queueCount.front() << std::endl;
                        queueIteml.pop();
                        std::queue<std::string> VarNameQueue = VarNameQueues.top();
                        int countNum = queueCount.front();
                        resQueue.push(std::make_pair(countNum,VarNameQueue));
                        VarNameQueues.pop();
                        queueCount.pop();


                    }
                    else{
                        

                        queueCount.pop();
                    }

                }   
            }
            if(element.key() == "count" && !queueIteml.empty()){              
                queueCount.push(int(element.value()));
                flag_count =2;
            }

        }
    }
    if(flag_item){
        queueIteml.pop();
        VarNameQueues.pop();
    }
    if(flag_count)
        queueCount.pop();
}
void print_res(){
    // std::queue<std::pair<int, std::queue<std::string> >> resQueue;
    if(resQueue.empty())
        return;
    int maxNum = resQueue.front().first;
    std::queue<std::string> maxQueue = resQueue.front().second;
    while(!resQueue.empty()){
        int compareNum = resQueue.front().first;
        // std::cout << compareNum <<std::endl;
        // std::queue<std::string> maxQueue = VarNameQueues.top();
        if(compareNum > maxNum){
            maxNum = compareNum;
            maxQueue =  resQueue.front().second;
        }
        resQueue.pop();
    }
    // std::cout << "res" <<std::endl;
     while(!maxQueue.empty()){
        std::cout<< maxQueue.front()<<std::endl;
        maxQueue.pop();
    }

}
int main() {
    // 打开 JSON 文件
    std::ifstream file("demo.json");
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

    print_res();

    return 0;
}

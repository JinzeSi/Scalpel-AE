
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

std::string trim(const std::string &str)
{
    size_t first = str.find_first_not_of(' ');
    size_t last = str.find_last_not_of(' ');
    if (first == std::string::npos || last == std::string::npos)
        return "";
    return str.substr(first, (last - first + 1));
}

std::set<std::string> set1;
std::set<std::string> set2;
std::set<std::string> set3;
std::set<std::string> set4;
std::set<std::string> set5;
std::set<std::string> set6;
std::set<std::string> set7;
std::set<std::string> set8;
int main(int argc, char *argv[])
{
    std::ifstream infile("redis-order.txt");
    // std::cout << argc <<std::endl;

    std::string line;
    int i = 0;
    while (std::getline(infile, line))
    {
        std::string trimmed = trim(line);
        if (trimmed == "")
            continue;
        i++;
        if(i > 0 && i<=173){
            set1.insert(trimmed);
        }
        if(i > 173 && i<=175){
            set2.insert(trimmed);
        }
        if(i > 175 && i<=186){
            set3.insert(trimmed);
        }
        if(i > 186 && i<=197){
            set4.insert(trimmed);
        }
        if(i > 197 && i<=198){
            set5.insert(trimmed);
        } 
        if(i > 198 && i<=202){
            set6.insert(trimmed);
        }   
        if(i > 202 && i<=203){
            set7.insert(trimmed);
        }  
        if(i > 203 && i<=210){
            set8.insert(trimmed);
        }  


    }
    std::string argInput;
    for(int i =1 ;i <argc;i++ ){
        std::string tmp = argv[i];
        argInput = argInput + " " + tmp;
    }
    argInput = trim(argInput);
    // std::cout << argInput <<std::endl;
    size_t firstColon = argInput.find(':');
    argInput = argInput.substr(firstColon+1);
    if(set1.find(argInput) !=set1.end()){
        std::cout<< "./redis-server --save \"\" &" <<std::endl;
        return 0;
    }
    if(set2.find(argInput) !=set2.end()){
        std::cout<< "./redis-server --save \"\" --enable-module-command local &" <<std::endl;
        return 0;
    }
    if(set3.find(argInput) !=set3.end()){
        std::cout<< "./redis-server --save \"\" --enable-module-command local --loadmodule ./panda.so &"<<std::endl;
        return 0;
    }
    if(set4.find(argInput) !=set4.end()){
        std::cout<< "./redis-server --save \"\" --cluster-enabled yes &" <<std::endl;
        return 0;
    }
    if(set5.find(argInput) !=set5.end()){
        std::cout<< "./redis-server --save \"\" --appendonly yes &" <<std::endl;
        return 0;
    }

    if(set6.find(argInput) !=set6.end()){
        std::cout<< "./redis-server --save \"\" --enable-debug-command yes &" <<std::endl;
        return 0;
    }

    if(set7.find(argInput) !=set7.end()){
        std::cout<< "./redis-server ./redis.conf --save \"\" &" <<std::endl;
        return 0;
    }
    if(set8.find(argInput) !=set8.end()){
        size_t secondColon = argInput.find(' ');
        argInput = argInput.substr(secondColon+1);

        if (argInput.find("redis.conf") != std::string::npos) {
            std::cout<< "./redis-server ./redis.conf --save \"\" &" <<std::endl;
            return 0;
        }
        if (argInput.find("panda.so") != std::string::npos) {
            std::cout<< "./redis-server --save \"\" --enable-module-command local --loadmodule ./panda.so &"<<std::endl;
            return 0;
        }

        std::cout << "./redis-server" << " " << argInput << " &" <<std::endl;

    }



}
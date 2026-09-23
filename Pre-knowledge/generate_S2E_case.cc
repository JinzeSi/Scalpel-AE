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

void getTestcase4(std::map<std::string,std::map<std::set<std::string>,std::set<std::string>>> res1, std::map<std::set<std::string>,std::set<std::string>>res2,std::queue<std::string> funcAboutCall);
std::map<std::string, std::list<std::string>> map;
std::map<std::string, std::set<std::string>> map2;
std::map<std::string, std::set<std::string>> map3;
std::map<std::string, std::set<std::string>> map4;
std::map<std::string, int> mapPriority;

std::map<std::string,std::string> mapFileNameTofunctionPath;
std::map<std::string,std::string> mapMaxlineToRangeline;
void storeMsg(std::queue<std::string> lineNums, std::queue<std::string> functionMge){
    //dbGenericDelete /data/sjz/commit-analysis/redis-9ee1cc3/src/db.c 579 579 584 584
    mapFileNameTofunctionPath.clear();
    mapMaxlineToRangeline.clear();
    while(!functionMge.empty()){
        std::string functionMgeTmp = functionMge.front();
       
        size_t position = functionMgeTmp.find(' ');
        //dbGenericDelete
        std::string functionName = functionMgeTmp.substr(0, position);
        std::string area1 = functionMgeTmp.substr(position + 1);

        position = area1.find(' ');
        ///data/sjz/commit-analysis/redis-9ee1cc3/src/db.c
        std::string functionPath = area1.substr(0, position);
        std::string area2 = area1.substr(position + 1);
        position = functionPath.rfind('/');
        std::string fileName = functionPath.substr(position + 1);
       
        std::string functionNameAndfunctionPath = functionName + " " +functionPath;
        
        // mapFileNameTofunctionPath.insert(std::make_pair(fileName,functionNameAndfunctionPath));

        //579 579 584 584
        // std::string area2 = area1.substr(position + 1);
        std::string area = area2;
   
        while(1){
            position = area.find(' ');
         
            std::string minLine = area.substr(0, position);
            std::string area1 = area.substr(position + 1);
            position = area1.find(' ');
            if(position == -1){
                std::string maxLine = area1;

                // lineRange.push(std::make_pair(minLine,maxLine));
                std::string newValue = minLine + " " + maxLine;
                std::string newKey = fileName + "+" + std::to_string(std::stoi(maxLine) + 1);
               

                mapFileNameTofunctionPath.insert(std::make_pair(newKey,functionNameAndfunctionPath));

                mapMaxlineToRangeline.insert(std::make_pair(newKey,newValue));
                break;
            }
            std::string maxLine = area1.substr(0, position);
            // lineRange.push(std::make_pair(minLine,maxLine));
            std::string newValue = minLine + " " + maxLine;
            

            std::string newKey = fileName + "+" + std::to_string(std::stoi(maxLine) + 1);
            
            mapFileNameTofunctionPath.insert(std::make_pair(newKey,functionNameAndfunctionPath));
            mapMaxlineToRangeline.insert(std::make_pair(newKey,newValue));
            area = area1.substr(position + 1);
        }
        

        functionMge.pop();
    }
}


//转化，把新行数转化为原来的行数，好像不行，不能这样做
//在update第一步就需要把行数一起给出

std::string findLineAndColumnNum(std::map<std::string, std::set<std::pair<int,int>>> map,std::string key,std::string line, std::string column){
    int lineNum = std::stoi(line);
    int columnNum = std::stoi(column);
    if (map.find(key) == map.end()){
        return "";
    }
    std::set<std::pair<int,int>> tmp = map[key];
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
//606 611 693 
//db.c 2016 2018

void getTestcase2(std::map<std::string,std::set<std::string>> &mapTestcase, std::string area,std::string functionName,std::map<std::string,std::set<std::string>> makeSymMap){
    std::queue<std::pair<std::string,std::string>> lineRange;
    while(1){
        size_t position = area.find(' ');
        
        std::string minLine = area.substr(0, position);
        std::string area1 = area.substr(position + 1);
        position = area1.find(' ');
 
        if(position == -1){
            std::string maxLine = area1;
            lineRange.push(std::make_pair(minLine,maxLine));
            break;
        }
        std::string maxLine = area1.substr(0, position);
        lineRange.push(std::make_pair(minLine,maxLine));
        area = area1.substr(position + 1);
    }

    while (!lineRange.empty())
    {
        std::pair<std::string,std::string> tmp = lineRange.front();
        std::string minLine = tmp.first;
        std::string maxLine = tmp.second;
        std::string makeSymMapKey = functionName + " " + minLine + " " + maxLine;
        std::set<std::string> makeSymMapSetTmp = makeSymMap[makeSymMapKey];
        // for()
        if(makeSymMapSetTmp.empty()){
            // std::cout << "empty()" << std::endl;
            // int minLineNum = std::stoi(minLine);
            int maxLineNum = std::stoi(maxLine) + 1;
            int maxLineAct = maxLineNum;
            
            std::string Key = functionName + "+" + std::to_string(maxLineNum);
            
            std::set<std::string> tmpTmp;
            std::set<std::string> setTmp = map2[Key];
            int maxLineCount = 0;
            while(1){
                if(!setTmp.empty() || maxLineCount > 20)
                    break;
                maxLineAct++;
                std::string Key = functionName + "+" + std::to_string(maxLineAct);
                setTmp = map2[Key];
                maxLineCount++;
            }

            for (std::set<std::string>::iterator it = setTmp.begin(); it != setTmp.end(); ++it) {
                std::set<std::string> map4SetTmp = map4[*it];
                if(!map4SetTmp.empty()){
                    for (std::set<std::string>::iterator it2 = map4SetTmp.begin(); it2 != map4SetTmp.end(); ++it2){
                        if(*it2 != "*needUpdate*")
                            tmpTmp.insert(*it2);
                    }
                }
                else{
                    std::set<std::string> map3SetTmp = map3[*it];
                    if(!map3SetTmp.empty())
                    {
                        for (std::set<std::string>::iterator it2 = map3SetTmp.begin(); it2 != map3SetTmp.end(); ++it2){
                            if(*it2 != "*needUpdate*")
                                tmpTmp.insert(*it2);
                        }
                    }
                }
            }
            if(tmpTmp.empty()){
                int minLineNum = std::stoi(minLine) - 1;
                int minLineAct = minLineNum;
                // int maxLineNum = std::stoi(maxLine) + 1;
                
                Key = functionName + "+" + std::to_string(minLineNum);
                
                setTmp = map2[Key];
                int minLineCount = 0;
                while(1){
                    if(!setTmp.empty() || minLineCount > 20)
                        break;
                    minLineAct--;
                    std::string Key = functionName + "+" + std::to_string(minLineAct);
                    setTmp = map2[Key];
                    minLineCount ++;
                }

                for (std::set<std::string>::iterator it = setTmp.begin(); it != setTmp.end(); ++it) {
                    std::set<std::string> map4SetTmp = map4[*it];
                    if(!map4SetTmp.empty()){
                        for (std::set<std::string>::iterator it2 = map4SetTmp.begin(); it2 != map4SetTmp.end(); ++it2){
                            if(*it2 != "*needUpdate*")
                                tmpTmp.insert(*it2);
                        }
                    }
                    else{
                        std::set<std::string> map3SetTmp = map3[*it];
                        if(!map3SetTmp.empty())
                        {
                            for (std::set<std::string>::iterator it2 = map3SetTmp.begin(); it2 != map3SetTmp.end(); ++it2){
                                if(*it2 != "*needUpdate*")
                                    tmpTmp.insert(*it2);
                            }
                        }
                    }
                }
            }
            std::string Key2 = functionName + "+" + std::to_string(maxLineNum);
            //mapTestcase 的key一定是maxLine + 1; 哪怕用minLine去寻找testcase，目的是保持统一
            mapTestcase.insert(std::make_pair(Key2, tmpTmp));
            // for(auto i :tmpTmp){
            //     std::cout << i <<std::endl;
            // }
            // std::cout << "Key2" <<Key2 <<std::endl;
        }
        else{
            int maxLineNum = std::stoi(maxLine) + 1;
            
            std::string Key = functionName + "+" + std::to_string(maxLineNum);
            //todo:makeSymMapSetTmp来寻找测试用例
            for (std::set<std::string>::iterator makeSymMapSetTmpValue = makeSymMapSetTmp.begin(); makeSymMapSetTmpValue != makeSymMapSetTmp.end(); ++makeSymMapSetTmpValue) {
                std::set<std::string> tmpTmp = mapTestcase[Key];
                std::set<std::string> setTmp = map2[*makeSymMapSetTmpValue];
                
                for (std::set<std::string>::iterator it = setTmp.begin(); it != setTmp.end(); ++it) {
                    std::set<std::string> map4SetTmp = map4[*it];
                    if(!map4SetTmp.empty()){
                        for (std::set<std::string>::iterator it2 = map4SetTmp.begin(); it2 != map4SetTmp.end(); ++it2){
                            if(*it2 != "*needUpdate*")
                                tmpTmp.insert(*it2);
                        }
                    }
                    else{
                        std::set<std::string> map3SetTmp = map3[*it];
                        if(!map3SetTmp.empty())
                        {
                            for (std::set<std::string>::iterator it2 = map3SetTmp.begin(); it2 != map3SetTmp.end(); ++it2){
                                if(*it2 != "*needUpdate*")
                                    tmpTmp.insert(*it2);
                            }
                        }
                    }
                }
                mapTestcase[Key] = tmpTmp;
                // mapTestcase.insert(std::make_pair(*makeSymMapSetTmpValue, tmpTmp));
            }
            

        }
        lineRange.pop();

    }
}
std::map<std::set<std::string>,std::set<std::string>> getTestcase3(std::map<std::string,std::set<std::string>> mapTmp,std::set<std::string> setTmp, std::string name){
    std::set<std::string> intersection(setTmp);
    std::map<std::string,std::set<std::string>> mapintersection(mapTmp);
    std::map<std::string,std::set<std::string>> mapTmpTmp;
    

    std::map<std::set<std::string>,std::set<std::string>> res;
    int numFlag = 1;
    
    while(1){
        
        std::set<std::string> NameSet;
        if(numFlag == 1 && name != "" && intersection.empty()){
            std::set<std::string> keytmp;
            keytmp.insert(name);
            res.insert(std::make_pair(keytmp,intersection));
            numFlag ++;
            continue;
        }
        if(numFlag == 1 && name != ""){
            NameSet.insert(name);
       
        }
        if(mapintersection.empty())
            break;
        for (auto it = mapintersection.begin(); it != mapintersection.end(); ++it) {
            if(intersection.empty() && NameSet.empty()){
            
                intersection = it->second;
                name = it->first;
                NameSet.insert(name);
                
                continue;
            }
            std::string Key = it->first;
            if(Key == name)
                continue;
            std::set<std::string> value = it->second;
            if(value.empty()){
                std::set<std::string> keytmp;
                keytmp.insert(Key);
              
                res.insert(std::make_pair(keytmp,value));
                continue;
            }
            std::set<std::string> tmp;
            std::set_intersection(value.begin(), value.end(),
                          intersection.begin(), intersection.end(),
                          std::inserter(tmp, tmp.begin()));
            if(tmp.empty()){
                
                mapTmpTmp.insert(std::make_pair(Key,value));
                continue;
            }
            else{
                intersection.clear();
                intersection = tmp;
                NameSet.insert(Key);
             
            }
        }
    
        res.insert(std::make_pair(NameSet,intersection));
        mapintersection.clear();
        mapintersection = mapTmpTmp;
        mapTmpTmp.clear();
        intersection.clear();
        numFlag++;
    }
    return res;

}
bool inRange(std::string area, std::string lineNum, std::string &res){
    std::queue<std::pair<std::string,std::string>> lineRange;
    while(1){
        size_t position = area.find(' ');

        std::string minLine = area.substr(0, position);
        std::string area1 = area.substr(position + 1);
        position = area1.find(' ');
        if(position == -1){
            std::string maxLine = area1;
            lineRange.push(std::make_pair(minLine,maxLine));
            break;
        }
        std::string maxLine = area1.substr(0, position);
        lineRange.push(std::make_pair(minLine,maxLine));
        area = area1.substr(position + 1);
    }
    while(1){
        if(lineRange.empty())
            break;
        
        std::pair<std::string,std::string> lineRangePair = lineRange.front();
        int minNum = std::stoi(lineRangePair.first);
        int maxNum = std::stoi(lineRangePair.second);
        int lineNumInt = std::stoi(lineNum);

        if(lineNumInt >= minNum && lineNumInt <= maxNum){
            res = std::to_string(maxNum + 1);
            return true;
        }
        lineRange.pop();
    }
    res = lineNum;
    return false;
}
void getTestcase(std::queue<std::string> lineNums, std::queue<std::string>functionMge, std::map<std::string,std::set<std::string>> makeSymMap){
    
    std::string trimmed = functionMge.front();
    functionMge.pop();
    size_t firstColon = trimmed.find(' ');
    std::string functionName = trimmed.substr(0, firstColon);
    std::string area = trimmed.substr(firstColon + 1);

   
    std::map<std::string,std::set<std::string>> mapTestcase;
  

    getTestcase2(mapTestcase,area,functionName,makeSymMap);
 
    std::map<std::string,std::map<std::string,std::set<std::string>>> mapTestcase2;
    std::queue<std::string> funcAboutCall;
    std::queue<std::string> funcAboutCall2;
    
    while(1){

        if(lineNums.empty())
            break;
        std::string lineNumTmp = lineNums.front();
        std::string functionMgeTmp = functionMge.front();
        size_t secondColon = functionMgeTmp.find(' ');
        std::string functionName2 = functionMgeTmp.substr(0, secondColon);
        std::string lineNumTmp2 = functionMgeTmp.substr(secondColon + 1);
      


        std::map<std::string,std::set<std::string>>  mapTestcase2Value;
        

        //todo:lineNumTmp需要判断是否在被修改的范围内部，下面的逻辑是当lineNumTmp不在被修改的范围内部
        //如果在需要重写
        std::string KeyTmp = functionName + "+" + lineNumTmp;

        std::set<std::string> tmpTmp;
        std::string lineNumRes;
        if(inRange(area,lineNumTmp,lineNumRes)){
           
            std::string KeyTmp2 = functionName + "+" + lineNumRes;
       
            tmpTmp = mapTestcase[KeyTmp2];
        }
        else{
       
            std::string KeyTmp2 = functionName + "+" + lineNumRes;
            std::set<std::string> setTmp = map2[KeyTmp2];
            

           
            if(!setTmp.empty()){

                for (std::set<std::string>::iterator it = setTmp.begin(); it != setTmp.end(); ++it) {
                    std::set<std::string> map4SetTmp = map4[*it];
                    if(!map4SetTmp.empty()){
                        for (std::set<std::string>::iterator it2 = map4SetTmp.begin(); it2 != map4SetTmp.end(); ++it2){
                            if(*it2 != "*needUpdate*"){
                               
                                tmpTmp.insert(*it2);
                            }
                        }
                    }
                    else{

                        std::set<std::string> map3SetTmp = map3[*it];
                        if(!map3SetTmp.empty()){
                            for (std::set<std::string>::iterator it2 = map3SetTmp.begin(); it2 != map3SetTmp.end(); ++it2){
                                if(*it2 != "*needUpdate*"){
                                    
                                    tmpTmp.insert(*it2);
                                }
                                
                            }
                        }
                        
                    }
                }
            }
        }

        
        mapTestcase2Value.insert(std::make_pair(KeyTmp, tmpTmp));
       
        funcAboutCall.push(KeyTmp);
        funcAboutCall2.push(functionName2);

        getTestcase2(mapTestcase2Value,lineNumTmp2,functionName2,makeSymMap);

        mapTestcase2.insert(std::make_pair(KeyTmp,mapTestcase2Value));

        lineNums.pop();
        functionMge.pop();
    }
  
    //mapTestcase mapTestcase2 funcAboutCall funcAboutCall2
    //调用者信息，被调用者信息 调用者调用被调用者时候的行数 被调用者函数名

    // std::set_intersection(set1.begin(), set1.end(),
                        //   set2.begin(), set2.end(),
                        //   std::inserter(intersection, intersection.begin()));

    std::map<std::string,std::map<std::set<std::string>,std::set<std::string>>> res;
    std::queue<std::string> funcAboutCall3;
    while (1)
    {
        if(funcAboutCall.empty())
            break;
        std::string tmp = funcAboutCall.front();
      
         // std::string tmp2 = funcAboutCall2.front();
        funcAboutCall3.push(tmp);
        std::map<std::string,std::set<std::string>> mapTmp = mapTestcase2[tmp];
        std::set<std::string> setTmp = mapTmp[tmp];
       
        std::map<std::set<std::string>,std::set<std::string>> resTmp = getTestcase3(mapTmp,setTmp,tmp);
        
        res.insert(std::make_pair(tmp,resTmp));
      
        funcAboutCall.pop();
        // funcAboutCall2.pop();
    }
    //mapTestcase
    std::set<std::string> setTmp;
    std::map<std::set<std::string>,std::set<std::string>> resTmp = getTestcase3(mapTestcase,setTmp,"");
    // getTestcase4(std::map<std::string,std::map<std::set<std::string>,std::set<std::string>>> res, std::map<std::set<std::string>,std::set<std::string>>res2,)
    getTestcase4(res,resTmp,funcAboutCall3);

    return;
}
void getTestcase4(std::map<std::string,std::map<std::set<std::string>,std::set<std::string>>> res1, std::map<std::set<std::string>,std::set<std::string>>res2,std::queue<std::string> funcAboutCall){
    static int num = 1;
    std::map <std::string,std::pair<std::set<std::string>,std::set<std::string>>> res3;
    std::queue<std::string> funcAboutCall2;
    while(1){
        if(funcAboutCall.empty())
            break;
        std::string tmp = funcAboutCall.front();
        std::map<std::set<std::string>,std::set<std::string>> res1Map = res1[tmp];
        for (auto it = res1Map.begin(); it != res1Map.end(); ++it) {
          
            std::set<std::string> setKey = it->first;
            std::set<std::string> setValue = it->second;
          
            if(setKey.find(tmp) != setKey.end() ){
                if(setValue.empty()){
                 
                    continue;
                }
                //todo 保存下来，和res2 取交集
                funcAboutCall2.push(tmp);
                res3.insert(std::make_pair(tmp,*it));
            }
            else{
                //std::map<std::string,std::string> mapFileNameTofunctionPath;
                // std::map<std::string,std::string> mapMaxlineToRangeline;
              
                std::cout<< "0" << std::endl;
                num ++;
                bool firstTime1 = true;
                for(const auto& element : setKey) {
                    if(firstTime1){
                        // std::size_t positionTmp = element.find('+');
                        // std::string fileName = element.substr(0,positionTmp);
                        std::cout << mapFileNameTofunctionPath[element] << " ";
                        firstTime1 = false;
                    }
                    std::string RangelineTmp = mapMaxlineToRangeline[element];
                   
                    std::cout << RangelineTmp << " ";
                }
                std::cout << std::endl;
                if(setValue.empty()){
                    std::cout<< "testcase:no testcase" << std::endl;
                }
                else{
                    
                    int MaxPriority = -1;
                    std::string MaxElement;
                    for(const auto& element : setValue) {
                        if(mapPriority[element] > MaxPriority){
                            MaxPriority = mapPriority[element];
                            MaxElement = element;
                        }    
                    }
                    // std::cout << "testcase1:" << MaxElement << std::endl;
                    std::cout << "testcase:" << MaxElement << std::endl;
                }     
                std::cout << std::endl;         
            }
        }

        funcAboutCall.pop();
    }
    // res2 和保存下来取交集的操作
    // res2 funcAboutCall2 res3
    for (auto it = res2.begin(); it != res2.end(); ++it) {
        std::set<std::string> setKey = it->first;
        std::set<std::string> setValue = it->second;
        if(setValue.empty()){
 
            std::cout<< "0" << std::endl;
            num ++;
            bool firstTime2 = true;
            for(const auto& element : setKey) {
                if(firstTime2){
                    // std::size_t positionTmp = element.find('+');
                    // std::string fileName = element.substr(0,positionTmp);
                    std::cout << mapFileNameTofunctionPath[element] << " ";
                    firstTime2 = false;
                }

                std::string RangelineTmp = mapMaxlineToRangeline[element];
                
                std::cout << RangelineTmp << " ";
            }
            std::cout<< std::endl;
         
            std::cout<< "testcase:no testcase" << std::endl;
            std::cout<< std::endl;
            
        }
        else{
            std::map <std::string,std::pair<std::set<std::string>,std::set<std::string>>> res3Tmp1;
            std::map <std::string,std::pair<std::set<std::string>,std::set<std::string>>> res3Tmp2;
            // std::set<std::string> testcaseRes;
            for (auto it2 = res3.begin(); it2 != res3.end(); ++it2){
                
                std::string callerMsg = it2->first;

                std::pair<std::set<std::string>,std::set<std::string>> setPair2 = it2->second;
                std::set<std::string> setKey2 = setPair2.first;
                 std::set<std::string> setValue2 = setPair2.second;
                std::set<std::string> setValueTmpTmp;
                if(!(setKey2.size() == 1 && setKey2.find(callerMsg) != setKey2.end())){
                    std::set_intersection(setValue.begin(), setValue.end(),
                            setValue2.begin(), setValue2.end(),
                            std::inserter(setValueTmpTmp, setValueTmpTmp.begin()));
                }
                if(setValueTmpTmp.empty())
                {
                    if(!(setKey2.size() == 1 && setKey2.find(callerMsg) != setKey2.end()))
                        res3Tmp1.insert(std::make_pair(callerMsg,setPair2));
                    continue;
                }      
                else{
                    setValue = setValueTmpTmp;

                    res3Tmp2.insert(std::make_pair(callerMsg,setPair2));
                }
            }
            res3 = res3Tmp1;
            if(res3Tmp2.empty()){

                std::cout<< "0" << std::endl;
                num ++;
                bool firstTime3 = true;
                for(const auto& element : setKey) {
                    if(firstTime3){
                        // std::size_t positionTmp = element.find('+');
                        // std::string fileName = element.substr(0,positionTmp);
                        std::cout << mapFileNameTofunctionPath[element] << " ";
                        firstTime3 = false;
                    }

                    std::string RangelineTmp = mapMaxlineToRangeline[element];
                   
                    std::cout << RangelineTmp << " ";
                }
                std::cout << std::endl;
            
                // for(const auto& element : setValue) {
                //     std::cout << "testcase:" << element << std::endl;
                //     std::cout << std::endl;
                //     break;
                // }
                int MaxPriority = -1;
                std::string MaxElement;
                for(const auto& element : setValue) {
                    if(mapPriority[element] > MaxPriority){
                        MaxPriority = mapPriority[element];
                        MaxElement = element;
                    }    
                }
                // std::cout << "testcase2:" << MaxElement << std::endl;
                std::cout << "testcase:" << MaxElement << std::endl;
                std::cout << std::endl;
            }
            else{
                
                std::queue<std::pair<std::set<std::string>,std::set<std::string>>> queueSetPair2;
                for (auto it2 = res3Tmp2.begin(); it2 != res3Tmp2.end(); ++it2){
                    std::string callerMsg = it2->first;
                    std::pair<std::set<std::string>,std::set<std::string>> setPair2 = it2->second;
                    //functionName + "+" + lineNumTmp;
                    std::size_t callerMsgPostion = callerMsg.find("+");
                    std::cout<< callerMsg.substr(callerMsgPostion + 1) << " ";
                    queueSetPair2.push(setPair2);

                }
                std::cout << std::endl;
                bool firstTime4 = true;
                for(const auto& element : setKey) {
                    
                    if(firstTime4){
                        // std::size_t positionTmp = element.find('+');
                        // std::string fileName = element.substr(0,positionTmp);
                        std::cout << mapFileNameTofunctionPath[element] << " ";
                        firstTime4 = false;
                    }

                    std::string RangelineTmp = mapMaxlineToRangeline[element];
                    std::cout << RangelineTmp << " ";
                }
                std::cout << std::endl;
                while(!queueSetPair2.empty()){
                    std::pair<std::set<std::string>,std::set<std::string>> queueSetPair2Tmp = queueSetPair2.front();
                    std::set<std::string> setKeyTmp = queueSetPair2Tmp.first;
                    bool firstTime5 = true;
                    for(const auto& element : setKeyTmp) {
                        
                        if(firstTime5){
                            // std::size_t positionTmp = element.find('+');
                            // std::string fileName = element.substr(0,positionTmp);

                            if(mapFileNameTofunctionPath[element] == ""){
                                continue;
                            }
                            std::cout << mapFileNameTofunctionPath[element] << " ";
                            firstTime5 = false;
                        }

                        std::string RangelineTmp = mapMaxlineToRangeline[element];
                       
                        std::cout << RangelineTmp << " ";
                    }
                    std::cout << std::endl;
                    queueSetPair2.pop();
                }
                // for(const auto& element : setValue) {
                //     std::cout << "testcase:" << element << std::endl;
                //     std::cout << std::endl;
                //     break;
                // }
                int MaxPriority = -1;
                std::string MaxElement;
                for(const auto& element : setValue) {
                    if(mapPriority[element] > MaxPriority){
                        MaxPriority = mapPriority[element];
                        MaxElement = element;
                    }    
                }
                // std::cout << "testcase3:" << MaxElement << std::endl;
                std::cout << "testcase:" << MaxElement << std::endl;
                std::cout << std::endl;
            }
        }
    }

}

int main(int argc, char *argv[]) {

    std::string filename1 = argv[1];
    std::string filename2 = argv[2];
    std::string filename3 = argv[3];


    // std::ifstream infile("redis-BB-res-2-new.txt");
    // std::ifstream infile1("redis-BB-res-3-new.txt");
    std::ifstream infile(filename1);
    std::ifstream infile1(filename2);

    std::ifstream infile2("demo-S2E-times-res-1.txt");
    std::ifstream infile3("demo-S2E-times-res-2.txt");
    std::ifstream infile4("demo-S2E-times-res-3.txt");
    
    // std::ifstream infile5("redis-order-priority.txt");
    std::ifstream infile5(filename3);
    std::string line;


    if (!infile) {
        std::cout << "无法打开文件 redis-BB-res-2.txt" << std::endl;
        return 1;
    }
    if (!infile1) {
        std::cout << "无法打开文件 redis-BB-res-3.txt" << std::endl;
        return 1;
    }
    int infile5Num = 0;
    std::string infileString;
    while (std::getline(infile5, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        if(infile5Num == 0){
            infileString = trimmed;
            infile5Num = 1;
            continue;
        }
        //mapPriority
        if(infile5Num == 1){
            int priority = std::stoi(trimmed);
            mapPriority[infileString] = priority;
            infile5Num = 0;
            continue;
        }
    }

    while (std::getline(infile, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        size_t firstColon = trimmed.rfind(':');
        std::string area1;
        std::string area2;
        area1 = trimmed.substr(0, firstColon);
        area2 = trimmed.substr(firstColon+1);
        std::istringstream iss(area2);
        std::list<std::string> value_BB;
        std::string token;

        

        size_t secondColon = area1.rfind('+');
        std::string columnNum = area1.substr(secondColon+1);
        
        std::string area3 = area1.substr(0, secondColon);

        size_t thirdColon = area3.rfind('+');
        std::string lineNum = area3.substr(thirdColon+1);

        std::string funcitonName = area3.substr(0, thirdColon);
        //Key: acl.c+1004
        std::string Key = funcitonName + "+" + lineNum;
        std::set<std::string> tmp = map2[Key];

        while (iss >> token) {
            tmp.insert(token);
        }
        map2[Key] = tmp;
    }
    while (std::getline(infile1, line)){
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        size_t firstColon = trimmed.find(':');
        std::string area1;
        std::string area2;
        area1 = trimmed.substr(0, firstColon);
        size_t secondColon = area1.find('+');
        std::string area3;
        area3 = area1.substr(secondColon + 1);
        area2 = trimmed.substr(firstColon + 1);
        std::set<std::string> value_BB;
        if(area2 ==""){
            map3.insert(std::make_pair(area3, value_BB));
            continue;
        }
        std::string delimiter = " Next Inst ";
        value_BB = split(area2, delimiter);
        map3.insert(std::make_pair(area3, value_BB));
    }
    std::string BBName;
    while (std::getline(infile2, line)){
        // commitId:22cc9b512250cf1b59403cb51c507e98185490de
        //     测试用例1:
        //         blockName:dict.c+Basic_Block_1592
        //              instruction:balabala
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        size_t firstColon = trimmed.find(':');
        std::string area1;
        std::string area2;
        area1 = trimmed.substr(0, firstColon);
        area1 = trim(area1);
        area2 = trimmed.substr(firstColon+1);
        area2 = trim(area2);
        if(area1 == "commitId"){
            continue;
        }
        if(area1 == "测试用例1" || area1 == "测试用例2"){
            continue;
        }
        if(area1 == "blockName"){
            //dict.c+Basic_Block_1592 area2
            size_t secondColon = area2.find('+');
            std::string area3;
            area3 = area2.substr(secondColon + 1);
            BBName = area3;
        }
        if(area1 == "instruction"){
            std::set<std::string> tmp = map4[BBName];
            tmp.insert(area2);
            map4[BBName] = tmp;
        }
    }
    std::queue<std::map<std::string,std::set<std::string>>> queueMakeSym;
    std::map<std::string,std::set<std::string>> queueMakeSymMapTmp;
    while(std::getline(infile4, line)){
        std::string trimmed= trim(line);
        if(trimmed == "")
            continue;
        if(trimmed == "NULL"){
        
            std::set<std::string> tmpSet;
            std::string tmpKey = "NULL";
            queueMakeSymMapTmp.insert(std::make_pair(tmpKey,tmpSet));
            // queueMakeSym.push(queueMakeSymMapTmp);
            // queueMakeSymMapTmp.clear();
            continue;
        }
        if(trimmed == "END")
        {
            // if()
            queueMakeSym.push(queueMakeSymMapTmp);
            queueMakeSymMapTmp.clear();
            continue;
        }
        // /data/sjz/commit-analysis/redis-9ee1cc3/src/evict.c:586:9 590 591
        size_t firstColon = trimmed.find(' ');
        std::string area1 = trimmed.substr(0, firstColon);
        std::string area2 = trimmed.substr(firstColon + 1);

        size_t secondColon = area1.rfind('/');

        std::string area3 = area1.substr(secondColon + 1); //evict.c:586:9
        size_t thirdColon = area3.find(':');
        std::string functionNameTmp = area3.substr(0, thirdColon); //evict.c
        size_t forthColon = area3.rfind(':');
        std::string lineNumTmp = area3.substr(thirdColon + 1, forthColon - thirdColon - 1); //586
        size_t fifthColon = area2.find(' '); //590 591
        std::string Num1Tmp = area2.substr(0, fifthColon); 
        std::string Num2Tmp = area2.substr(fifthColon + 1); 
        if(std::stoi(Num1Tmp) <= std::stoi(lineNumTmp) && std::stoi(lineNumTmp) <= std::stoi(Num2Tmp)){
            continue;
        }
        else{
            std::string KeyTmp = functionNameTmp + " " + area2;
            std::set<std::string> setTmp = queueMakeSymMapTmp[KeyTmp];
            std::string valueTmp = functionNameTmp + "+" + lineNumTmp;
            setTmp.insert(valueTmp);
        
            queueMakeSymMapTmp[KeyTmp] = setTmp; 
        }

        
    }
    // 2018 
    // removeExpire /data/sjz/commit-analysis/redis-9ee1cc3/src/db.c 2016 2018
    // cumulativeKeyCountAdd /data/sjz/commit-analysis/redis-9ee1cc3/src/db.c 469 476
    bool flag = true;
    int numFunctionCall = 0;
    int flagFunctionChange = false;
    std::queue<std::string> lineNums;
    std::queue<std::string> functionMge;
    std::queue<std::string> functionMgeComplete;
    std::string flagFunctionChangeString;
    while (std::getline(infile3, line)) {
        std::string trimmed = trim(line);
        if(trimmed == "")
            continue;
        if(flag){
            // 606 611 693 
            int spaceCount = std::count(trimmed.begin(), trimmed.end(), ' ');
            if(spaceCount == 0){
                if(trimmed == "0")
                    numFunctionCall = 1;
                else{
                    numFunctionCall = 2;
                    lineNums.push(trimmed);
                }
            }
            else{
                numFunctionCall = spaceCount + 2;
                std::string area = trimmed;
                for(int i = 0;i < spaceCount;i++){
                    size_t position = area.find(' ');
                    std::string area1 = area.substr(0, position);
                    std::string area2 = area.substr(position + 1);
                    lineNums.push(area1);
                    area = area2;
                }
                lineNums.push(area);
            }
            flag = false;
            flagFunctionChange =true;
        }
        else{
            if(flagFunctionChange == true){
                flagFunctionChange = false;
                flagFunctionChangeString = trimmed;
                continue;
            }
            functionMgeComplete.push(trimmed);
            
            //removeExpire /data/sjz/commit-analysis/redis-9ee1cc3/src/db.c 2016 2018
            size_t position = trimmed.rfind('/');
            std::string area1 = trimmed.substr(position + 1);
            //db.c 2016 2018
            functionMge.push(area1);
            numFunctionCall--;
            if(numFunctionCall == 0){
                //要找testcase
              
                // std::string line2;
                std::map<std::string,std::set<std::string>> queueMakeSymMapTmpTmp = queueMakeSym.front();
                if(queueMakeSymMapTmpTmp.find("NULL") == queueMakeSymMapTmpTmp.end()){
                    
                   
                    // globalLineNums = lineNums;
                    // globalfunctionMge = functionMge;
                    storeMsg(lineNums,functionMgeComplete);
                    // std::cout << "Begin NULL" <<std::endl;
                    getTestcase(lineNums,functionMge,queueMakeSymMapTmpTmp);
                    // std::cout << "End NULL" <<std::endl;

                }
                else{
                    storeMsg(lineNums,functionMgeComplete);
                    std::cout << "Begin NULL" <<std::endl;
                    std::cout <<std::endl;
                    getTestcase(lineNums,functionMge,queueMakeSymMapTmpTmp);
                    std::cout << "End NULL" <<std::endl;
                    std::cout <<std::endl;
                }
       
            
                queueMakeSym.pop();
                int flagFunctionChangeLen = flagFunctionChangeString.length();
                for(int i = 0; i < flagFunctionChangeLen; i=i+2){
                    std::ofstream outfileRes("generate_S2E_case-1.txt",std::ios::app);
                    if(flagFunctionChangeString[i] == '1'){
                        outfileRes<< functionMgeComplete.front() <<std::endl;
                    }
                    functionMgeComplete.pop();
                    outfileRes.close();
                }
                
                flag = true;
                lineNums = std::queue<std::string>(); 
                functionMgeComplete = std::queue<std::string>();
                // lineNums.
                functionMge = std::queue<std::string>(); 
            }

        }
    }

    
    


    infile.close();
    infile1.close();
    infile2.close();

    
    return 0;
}
#include <llvm/IR/Function.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Analysis/CallGraph.h>
#include <llvm/IR/DebugInfo.h>
#include <iostream>
#include <map>
#include <set>
#include <vector>
#include <fstream>

#include <string>
#include <algorithm>
#include <unordered_set>

using namespace llvm;
std::unordered_map<std::string, std::string> functionIsNewInfo;
// 用于存储调用树的简单结构
struct CallTreeNode {
    Function *func;
    std::vector<CallTreeNode*> children;
};

std::map<std::string, std::list<std::pair<std::string, int>>> funtionCallInfo;
// 递归构建调用树
void buildCallTree(CallTreeNode *node, CallGraph &CG, std::set<Function*> &visited, std::vector<std::string> lines) {
    Function *function = node->func;
    if (visited.find(function) != visited.end()) {
        return; // 避免循环调用
    }
    visited.insert(function);

    if (auto CGNode = CG[function]) {
        for (auto &CallRecord : *CGNode) {
            if (Function *callee = CallRecord.second->getFunction()) {
                //
                // if (auto* CallInst = dyn_cast<CallBase>(CallRecord.first)) {
                //   if (DILocation * Loc = CallInst.getDebugLoc()) {
                //     unsigned Line = Loc->getLine();
                //     StringRef File = Loc->getFilename();
                //     errs()  << " at " << File << ":" << Line << "\n";
                //   }
                // }
                
               
                if (callee->isDeclaration()) continue; // 忽略外部声明
                if ((CallRecord.first).has_value()) 
                { 
                    llvm::WeakTrackingVH weakVH = (CallRecord.first).value();
                    auto* CallInst = dyn_cast<CallBase>(weakVH);
                    if (DILocation * Loc = CallInst->getDebugLoc()) {
                        unsigned Line = Loc->getLine();
                        std::string File = (Loc->getFilename()).str();
                        std::string Directory = Loc->getDirectory().str();
                        std::string callerFuncitonName = CGNode->getFunction()->getName().str();
                        std::string calleeFuncitonName = callee->getName().str();
                        if(std::find(lines.begin(), lines.end(),calleeFuncitonName ) != lines.end()){
                            std::list<std::pair<std::string, int>> tmpList = funtionCallInfo[callerFuncitonName];
                            tmpList.push_back(std::pair(calleeFuncitonName, Line));
                            funtionCallInfo[callerFuncitonName] = tmpList;
                        }
                    }
                    
                }
                CallTreeNode *childNode = new CallTreeNode{callee};
                node->children.push_back(childNode);
                // buildCallTree(childNode, CG, visited);
            }
        }
    }
}

//打印getFuncNameDedup中的调用关系
void printCallTreeAboutFuncName(const CallTreeNode *node, std::vector<std::string> lines, std::vector<std::string> &linesTmp, int depth = 0) {
    if (!node) return;
    if (depth > 1)
        return;
    auto it = std::find(lines.begin(), lines.end(), node->func->getName().str());


    if (it != lines.end()) {
        linesTmp.push_back(node->func->getName().str());
        // std::cout << std::string(depth * 2, ' ') << node->func->getName().str() << std::endl;
    }    
    for (auto child : node->children) {
        // auto it = std::find(myStrings.begin(), myStrings.end(), input);
        printCallTreeAboutFuncName(child, lines, linesTmp, depth + 1);
    }
}

void printCallTree(const CallTreeNode *node, int depth = 0) {
    if (!node) return;
    
    std::cout << std::string(depth * 2, ' ') << node->func->getName().str() << std::endl; 
    for (auto child : node->children) {
        // auto it = std::find(myStrings.begin(), myStrings.end(), input);
        printCallTree(child, depth + 1);
    }
}

std::vector<std::vector<std::string>> findMinimumCoverage(
    const std::vector<std::vector<std::string>>& liness,
    const std::vector<std::string>& lines
) {
    std::unordered_set<std::string> needed(lines.begin(), lines.end());
    std::unordered_set<std::string> neededALL(lines.begin(), lines.end());
    std::vector<std::vector<std::string>> result;
    std::vector<bool> used(liness.size(), false);

    while (!neededALL.empty()) {
        size_t best_index = -1;
        size_t covered_max = 0;
        std::unordered_set<std::string> best_covered;

        for (size_t i = 0; i < liness.size(); ++i) {
            if (used[i]) continue;
            std::unordered_set<std::string> covered;
            for (const auto& word : liness[i]) {
                if (needed.count(word) > 0) {
                    covered.insert(word);
                }
            }
            if (covered.size() > covered_max) {
                covered_max = covered.size();
                best_index = i;
                best_covered = std::move(covered);
            }
        }

        if (best_index == -1) break; // No progress, stop

        result.push_back(liness[best_index]);
        used[best_index] = true;
        for (const auto& word : best_covered) {
            if(functionIsNewInfo[word] == "0")
                needed.erase(word);
            neededALL.erase(word);
        }
    }

    return result;
}



int main(int argc, char **argv) {
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " <LLVM bitcode file>\n";
        return 1;
    }

    LLVMContext Context;
    SMDiagnostic Err;
    std::unique_ptr<Module> Mod = parseIRFile(argv[1], Err, Context);

    if (!Mod) {
        Err.print(argv[0], errs());
        return 1;
    }

    std::string filename = argv[2];
    std::ifstream file(filename);

    if (!file.is_open()) {
        std::cerr << "Error opening file: " << filename << std::endl;
        return 1;
    }

    std::vector<std::string> lines;
    std::vector<std::vector<std::string>> liness;
    
    std::unordered_map<std::string, std::string> functionModifyInfo;
    std::string line;

    while (std::getline(file, line)) {
        std::string isFuncNew = line.substr(0, line.find(" "));
        std::string funcName = line.substr(line.find(" ") + 1, line.find(" ", line.find(" ") + 1) - line.find(" ") - 1);
        std::string modifyInfo = line.substr(line.find(" ", line.find(" ") + 1) + 1);
        lines.push_back(funcName);
        functionIsNewInfo[funcName] = isFuncNew;
        functionModifyInfo[funcName] = modifyInfo;
    }

    file.close();

    CallGraph CG(*Mod);

    for (const std::string& storedLine : lines) {
        // std::cout << storedLine << std::endl;
    
        std::set<Function*> visited;

        std::vector<std::string> linesTmp;

        // 假设 main 函数是入口
        Function *entry = Mod->getFunction(storedLine);
        if (!entry) {
            std::cerr << "Error: 'main' function not found in module.\n";
            continue;
        }

        CallTreeNode *root = new CallTreeNode{entry};
        buildCallTree(root, CG, visited,lines);

        // 遍历并输出调用树
        printCallTreeAboutFuncName(root,lines,linesTmp);
        
        liness.push_back(linesTmp);

    // 清理内存
    // ... (这部分需要实现内存回收)
    }
    auto result = findMinimumCoverage(liness, lines);
    // std::cout << "Result:" << result.size() << std::endl;
    for (const auto& group : result) {
        // Print all the group[0]'s call expr's union range
        std::pair<int, int> ranges = {0, 0};
        const auto& tmpList = funtionCallInfo[group[0]];
        // if (!tmpList.empty())
        //     ranges = {tmpList.front().second, tmpList.back().second};
        // std::cout << ranges.first << " " << ranges.second << std::endl;

        for (const auto& r : tmpList)
            std::cout << r.second << " ";

        if (tmpList.empty())
            std::cout << "0" << std::endl;
        else
            std::cout << std::endl;

        for (const auto& word : group)
            std::cout << functionIsNewInfo[word] << " ";
        std::cout << std::endl;

        // Print all the function names in the group
        for (const auto& word : group)
            std::cout << word << " " << functionModifyInfo[word] << std::endl;
        std::cout << std::endl;
    }
    return 0;
}
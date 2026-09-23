//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.

#ifndef POST_DOMINANCE_FRONTIER
#define POST_DOMINANCE_FRONTIER

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Pass.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
namespace llvm {

  struct CreateHammockCFG : public FunctionPass {
    static char ID;

    CreateHammockCFG() : FunctionPass(ID) { }

    virtual bool runOnFunction(Function &F);

    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AU.addRequired<LoopInfoWrapperPass>();
    }
  };

  // 手动实现 PostDominanceFrontier Pass
  class PostDominanceFrontier : public FunctionPass {
  public:
    static char ID;

    // 使用组合模式：内部持有一个数据结构来存储结果
    // DominanceFrontierBase<BlockT, IsPostDom> 是 LLVM 提供的基类容器
    using BaseType = DominanceFrontierBase<BasicBlock, true>;
    BaseType Base;

    // 对外暴露的类型定义
    using DomSetType = BaseType::DomSetType;
    using iterator = BaseType::iterator;
    using const_iterator = BaseType::const_iterator;

    PostDominanceFrontier() : FunctionPass(ID) {}

    // Pass 入口
    bool runOnFunction(Function &F) override {
      Base.releaseMemory();
      // 获取 PostDominatorTree
      PostDominatorTree &DT = getAnalysis<PostDominatorTreeWrapperPass>().getPostDomTree();
      
      // 手动计算 Frontier
      if (DomTreeNode *Root = DT.getRootNode())
        calculate(DT, Root);
        
      return false;
    }

    void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.setPreservesAll();
      AU.addRequired<PostDominatorTreeWrapperPass>();
    }

    // 核心计算逻辑：递归计算 Post Dominance Frontier
    void calculate(PostDominatorTree &DT, DomTreeNode *Node) {
      BasicBlock *BB = Node->getBlock();
      
      // 处理虚拟根节点（Block 为空的情况），直接递归子节点
      if (!BB) {
        for (auto I = Node->begin(), E = Node->end(); I != E; ++I)
          calculate(DT, *I);
        return;
      }

      // 1. DF_local: 计算本地 Frontier
      // PostDom 的 Frontier 是 CFG 前驱中，不被当前节点严格 PostDom 的节点
      DomSetType Local;
      for (auto P : predecessors(BB)) {
        if (DT.getNode(P)->getIDom() != Node)
          Local.insert(P);
      }

      // 将 Local 集合加入 Base，并获取引用以便后续合并
      Base.addBasicBlock(BB, Local);
      DomSetType &S = Base.find(BB)->second;

      // 2. DF_up: 递归合并子节点的 Frontier
      for (auto I = Node->begin(), E = Node->end(); I != E; ++I) {
        DomTreeNode *Child = *I;
        calculate(DT, Child);
        
        if (BasicBlock *ChildBB = Child->getBlock()) {
          // 查找子节点的 Frontier
          auto ChildIt = Base.find(ChildBB);
          if (ChildIt != Base.end()) {
              for (BasicBlock *PB : ChildIt->second) {
                  // 如果当前节点 Node 不严格 PostDom PB，则 PB 属于当前节点的 Frontier
                  if (!DT.properlyDominates(Node, DT.getNode(PB)))
                      S.insert(PB);
              }
          }
        }
      }
    }

    // 兼容性 API：重载 [] 操作符
    // 如果不存在，则创建一个空的并返回
    DomSetType &operator[](BasicBlock *BB) {
      auto It = Base.find(BB);
      if (It == Base.end())
        // addBasicBlock 返回的是迭代器，需要通过 ->second 获取 Set 的引用
        return Base.addBasicBlock(BB, DomSetType())->second;
      return It->second;
    }

    // const 版本
    const DomSetType &operator[](BasicBlock *BB) const { 
      auto It = Base.find(BB);
      if (It != Base.end())
          return It->second;
      static DomSetType Empty;
      return Empty;
    }

    // 迭代器转发
    iterator begin() { return Base.begin(); }
    iterator end() { return Base.end(); }
    const_iterator begin() const { return Base.begin(); }
    const_iterator end() const { return Base.end(); }

    iterator find(BasicBlock *BB) { return Base.find(BB); }
    const_iterator find(BasicBlock *BB) const { return Base.find(BB); }
    
    bool empty() const { return Base.begin() == Base.end(); }
  };
}

#endif

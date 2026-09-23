/**
 *  @file          TestCostModel.cpp
 *
 *  @version       1.0
 *  @created       02/07/2013 02:35:16 PM
 *  @revision      $Id$
 *
 *  @author        Ryan Huang <ryanhuang@cs.ucsd.edu>
 *  @organization  University of California, San Diego
 *  
 *  Copyright (c) 2013, Ryan Huang
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *  http://www.apache.org/licenses/LICENSE-2.0
 *     
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  @section       DESCRIPTION
 *  
 *  Test driver for CostModel
 *
 */

#include <string>

#include "llvm/IR/LLVMContext.h"
#include "llvm/Pass.h"
#include "llvm/IR/LegacyPassManager.h"

#include "llvm/Analysis/TargetLibraryInfo.h" // [新增]
#include "llvm/Support/TargetSelect.h"

#include "llvm/ADT/DepthFirstIterator.h"

#include "llvm/Target/TargetMachine.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/Analysis/TargetTransformInfo.h"

#include "llvm/IR/CFG.h"
#include "llvm/Support/Host.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Support/SourceMgr.h"

#include "analyzer/X86CostModel.h"

using namespace llvm;

X86CostModel * XCM = NULL;

struct CostModelDriver : public FunctionPass {
  static char ID;
  std::string PassName;

  CostModelDriver () : FunctionPass(ID) {
    PassName = "Cost Model Driver: ";
  }

  virtual bool runOnFunction(Function &F) {
    assert(XCM && "Cost model cannot be NULL");
    errs() << F.getName().str() << "\n";
    unsigned cost = XCM->getFunctionCost(&F);
    errs() << "Cost: " << cost << "\n";
    return false;
  }

  virtual StringRef getPassName() const { return PassName.c_str(); }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
  }
};

char CostModelDriver::ID = 0;

int main(int argc, char **argv)
{
  if (argc <= 1) {
    errs() << "Usage: costmodel INPUT\n";
    exit(1);
  }

  const std::string TripleStr = "x86_64-unknown-linux-gnu";
  const std::string FeatureStr = "";
  const std::string CPUStr = llvm::sys::getHostCPUName();
  errs() << "CPU String is " << CPUStr << "\n";
  std::string Err;
  const Target* T;
  // specially call for X86 target for general target, use:
  // InitializeAllTargets();
  // InitializeAllTargetMCs();
  // InitializeAllAsmPrinters();
  // InitializeAllAsmParsers();

  LLVMInitializeX86TargetInfo();
  LLVMInitializeX86Target();
  LLVMInitializeX86TargetMC();
  LLVMInitializeX86AsmPrinter();
  LLVMInitializeX86AsmParser();

  T = TargetRegistry::lookupTarget(TripleStr, Err);
  if(!Err.empty()) {
    errs() << "Cannot find target: " << Err << "\n";
    exit(1);
  }
  // Create TargetMachine
  TargetOptions Options;
  // 需要填充剩余参数：Options, RelocModel, CodeModel, CodeGenOptLevel, JIT
  TargetMachine* TM = T->createTargetMachine(TripleStr, CPUStr, FeatureStr, Options, None, None, CodeGenOpt::Default, false);
  if(TM == NULL) {
    errs() << "Cannot create target machine\n";
    exit(1);
  }

  XCM = new X86CostModel(TM);

  llvm_shutdown_obj Y;  // Call llvm_shutdown() on exit.
  LLVMContext Context;

  // Load the input module...
  const std::string input(argv[1]);
  SMDiagnostic diag;
  Module * M = parseIRFile(input, diag, Context).release();
  if (M == NULL) {
    errs() << "Invalid module format\n";
    exit(1);
  }
  M->setDataLayout(TM->createDataLayout());

  // Build up all of the passes that we want to do to the module.
  legacy::PassManager PM;

  // Add the target data from the target machine, if it exists, or the module.
  Triple TargetTriple(TripleStr);
  TargetLibraryInfoImpl TLII(TargetTriple);
  PM.add(new TargetLibraryInfoWrapperPass(TLII));
  PM.add(createTargetTransformInfoWrapperPass(TM->getTargetIRAnalysis()));
  PM.add(new CostModelDriver()); 
  PM.run(*M);
  return 0;
}


// static RegisterPass<CostModelDriver> X("costmodel", "cost model driver");

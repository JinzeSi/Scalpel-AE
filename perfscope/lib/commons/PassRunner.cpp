//===- PassRunner.cpp - Running Passes Without OPT -------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Optimizations may be specified an arbitrary number of times on the command
// line, They are run in the order specified.
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Analysis/CallGraphSCCPass.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Analysis/RegionPass.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/ADT/Triple.h"
#include "llvm/IR/LegacyPassNameParser.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/Debug.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/PluginLoader.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/SystemUtils.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include "mapper/Matcher.h"
#include "parser/PatchDecoder.h"

#include <memory>
#include <algorithm>
#include <iostream>
#include <stdio.h>

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IRReader/IRReader.h"

using namespace llvm;

// The OptimizationList is automatically populated with registered Passes by the
// PassNameParser.
//
static cl::list<const PassInfo*, bool, PassNameParser>
PassList(cl::desc("Optimizations available:"));

// Other command line options...
//
static cl::opt<std::string>
InputFilename(cl::Positional, cl::desc("<input bitcode file>"),
    cl::init("-"), cl::value_desc("filename"));

static cl::opt<std::string>
OutputFilename("o", cl::desc("Override output filename"),
               cl::value_desc("filename"));

static bool Quiet = false;

// ---------- Define Printers for module and function passes ------------
namespace {

struct CallGraphSCCPassPrinter : public CallGraphSCCPass {
  static char ID;
  const PassInfo *PassToPrint;
  raw_ostream &Out;
  std::string PassName;

  CallGraphSCCPassPrinter(const PassInfo *PI, raw_ostream &out) :
    CallGraphSCCPass(ID), PassToPrint(PI), Out(out) {
      std::string PassToPrintName =  PassToPrint->getPassName();
      PassName = "CallGraphSCCPass Printer: " + PassToPrintName;
    }

  virtual bool runOnSCC(CallGraphSCC &SCC) {
    if (!Quiet)
      Out << "Printing analysis '" << PassToPrint->getPassName() << "':\n";

    // Get and print pass...
    for (CallGraphSCC::iterator I = SCC.begin(), E = SCC.end(); I != E; ++I) {
      Function *F = (*I)->getFunction();
      if (F)
        getAnalysisID<Pass>(PassToPrint->getTypeInfo()).print(Out,
                                                              F->getParent());
    }
    return false;
  }

  virtual StringRef getPassName() const { return PassName.c_str(); }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequiredID(PassToPrint->getTypeInfo());
    AU.setPreservesAll();
  }
};

char CallGraphSCCPassPrinter::ID = 0;

struct ModulePassPrinter : public ModulePass {
  static char ID;
  const PassInfo *PassToPrint;
  raw_ostream &Out;
  std::string PassName;

  ModulePassPrinter(const PassInfo *PI, raw_ostream &out)
    : ModulePass(ID), PassToPrint(PI), Out(out) {
      std::string PassToPrintName =  PassToPrint->getPassName();
      PassName = "ModulePass Printer: " + PassToPrintName;
    }

  virtual bool runOnModule(Module &M) {
    if (!Quiet)
      Out << "Printing analysis '" << PassToPrint->getPassName() << "':\n";

    // Get and print pass...
    getAnalysisID<Pass>(PassToPrint->getTypeInfo()).print(Out, &M);
    return false;
  }

  virtual StringRef getPassName() const { return PassName.c_str(); }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequiredID(PassToPrint->getTypeInfo());
    AU.setPreservesAll();
  }
};

char ModulePassPrinter::ID = 0;
struct FunctionPassPrinter : public FunctionPass {
  const PassInfo *PassToPrint;
  raw_ostream &Out;
  static char ID;
  std::string PassName;

  FunctionPassPrinter(const PassInfo *PI, raw_ostream &out)
    : FunctionPass(ID), PassToPrint(PI), Out(out) {
      std::string PassToPrintName =  PassToPrint->getPassName();
      PassName = "FunctionPass Printer: " + PassToPrintName;
    }

  virtual bool runOnFunction(Function &F) {
    if (!Quiet)
      Out << "Printing analysis '" << PassToPrint->getPassName()
          << "' for function '" << F.getName() << "':\n";

    // Get and print pass...
    getAnalysisID<Pass>(PassToPrint->getTypeInfo()).print(Out,
            F.getParent());
    return false;
  }

  virtual StringRef getPassName() const { return PassName.c_str(); }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequiredID(PassToPrint->getTypeInfo());
    AU.setPreservesAll();
  }
};

char FunctionPassPrinter::ID = 0;

struct LoopPassPrinter : public LoopPass {
  static char ID;
  const PassInfo *PassToPrint;
  raw_ostream &Out;
  std::string PassName;

  LoopPassPrinter(const PassInfo *PI, raw_ostream &out) :
    LoopPass(ID), PassToPrint(PI), Out(out) {
      std::string PassToPrintName =  PassToPrint->getPassName();
      PassName = "LoopPass Printer: " + PassToPrintName;
    }


  virtual bool runOnLoop(Loop *L, LPPassManager &LPM) {
    if (!Quiet)
      Out << "Printing analysis '" << PassToPrint->getPassName() << "':\n";

    // Get and print pass...
    getAnalysisID<Pass>(PassToPrint->getTypeInfo()).print(Out,
                        L->getHeader()->getParent()->getParent());
    return false;
  }

  virtual StringRef getPassName() const { return PassName.c_str(); }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequiredID(PassToPrint->getTypeInfo());
    AU.setPreservesAll();
  }
};

char LoopPassPrinter::ID = 0;

struct RegionPassPrinter : public RegionPass {
  static char ID;
  const PassInfo *PassToPrint;
  raw_ostream &Out;
  std::string PassName;

  RegionPassPrinter(const PassInfo *PI, raw_ostream &out) : RegionPass(ID),
    PassToPrint(PI), Out(out) {
    std::string PassToPrintName =  PassToPrint->getPassName();
    PassName = "RegionPass Printer: " + PassToPrintName;
  }

  virtual bool runOnRegion(Region *R, RGPassManager &RGM) {
    if (!Quiet) {
      Out << "Printing analysis '" << PassToPrint->getPassName() << "' for "
        << "region: '" << R->getNameStr() << "' in function '"
        << R->getEntry()->getParent()->getName().str() << "':\n";
    }
    // Get and print pass...
   getAnalysisID<Pass>(PassToPrint->getTypeInfo()).print(Out,
                       R->getEntry()->getParent()->getParent());
    return false;
  }

  virtual StringRef getPassName() const { return PassName.c_str(); }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequiredID(PassToPrint->getTypeInfo());
    AU.setPreservesAll();
  }
};

char RegionPassPrinter::ID = 0;

struct BasicBlockPassPrinter : public BasicBlockPass {
  const PassInfo *PassToPrint;
  raw_ostream &Out;
  static char ID;
  std::string PassName;

  BasicBlockPassPrinter(const PassInfo *PI, raw_ostream &out)
    : BasicBlockPass(ID), PassToPrint(PI), Out(out) {
      std::string PassToPrintName =  PassToPrint->getPassName();
      PassName = "BasicBlockPass Printer: " + PassToPrintName;
    }

  virtual bool runOnBasicBlock(BasicBlock &BB) {
    if (!Quiet)
      Out << "Printing Analysis info for BasicBlock '" << BB.getName()
          << "': Pass " << PassToPrint->getPassName() << ":\n";

    // Get and print pass...
    getAnalysisID<Pass>(PassToPrint->getTypeInfo()).print(Out,
            BB.getParent()->getParent());
    return false;
  }

  virtual StringRef getPassName() const { return PassName.c_str(); }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequiredID(PassToPrint->getTypeInfo());
    AU.setPreservesAll();
  }
};

char BasicBlockPassPrinter::ID = 0;

struct BreakpointPrinter : public ModulePass {
  raw_ostream &Out;
  static char ID;

  BreakpointPrinter(raw_ostream &out)
    : ModulePass(ID), Out(out) {
    }

  void getContextName(DIScope* Context, std::string &N) {
    if (!Context) return;

    if (auto *NS = dyn_cast<DINamespace>(Context)) {
      if (!NS->getName().empty()) {
        getContextName(NS->getScope(), N);
        N = N + NS->getName().str() + "::";
      }
    } else if (auto *TY = dyn_cast<DIType>(Context)) {
      if (!TY->getName().empty()) {
        getContextName(TY->getScope(), N);
        N = N + TY->getName().str() + "::";
      }
    }
  }

  virtual bool runOnModule(Module &M) {
    StringSet<> Processed;
    if (NamedMDNode *NMD = M.getNamedMetadata("llvm.dbg.sp"))
      for (unsigned i = 0, e = NMD->getNumOperands(); i != e; ++i) {
        // 获取 CompileUnit
        auto *CU = dyn_cast<DICompileUnit>(NMD->getOperand(i));
        if (!CU) continue;

        // 遍历 CompileUnit 中的 Subprograms
        // 注意：在 LLVM 9 中，Subprograms 可能不直接挂在 CU 下，而是分散在各处
        // 但为了兼容旧逻辑，我们尝试遍历 CU 的 subprograms 列表
        // 或者更通用的方法是遍历 Module 中的所有 Function 并获取其 Subprogram
        
        for (auto &F : M) {
          DISubprogram *SP = F.getSubprogram();
          if (!SP) continue;

          std::string Name;
          getContextName(SP->getScope(), Name);
          Name = Name + SP->getName().str();

          if (!Name.empty() && Processed.insert(Name).second) {
            Out << Name << "\n";
          }
        }
      }
    return false;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
  }
};
 
} // anonymous namespace

char BreakpointPrinter::ID = 0;

struct LoopInfoFinder : public FunctionPass {
    static char ID;
    std::string PassName;

    LoopInfoFinder() : FunctionPass(ID) {
            PassName = "LoopInfo Printer: ";
    }

    virtual bool runOnFunction(Function &F) {
        if (F.getName().equals("_ZL23test_if_skip_sort_orderP13st_join_tableP8st_ordermbP6BitmapILj64EE")) {
            errs() << "Function: " << F.getName() << "\n";
            if (!F.isDeclaration())  {
            LoopInfo &li = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
            if (li.begin() == li.end()) {
                errs() << "no loop in this function" << "\n";
            }
            else {
                Scope ls;
                for (LoopInfo::iterator LII = li.begin(),  LIE = li.end(); LII != LIE; LII++) {
                    if (ScopeInfoFinder::getLoopScope(ls, *LII)) { 
                        errs() << "\tloop: " << ls << "\n";
                    }
                }
            }
            }
        }
        /*
        int s = 0;
        Scope scope = hunk->enclosing_scope;
        errs() << hunk->enclosing_scope << " might touch ";
        ScopeInfoFinder::sp_iterator I = matcher.initMatch(chap->fullname);
        Hunk::iterator HI = hunk->begin(), HE = hunk->end();
        Scope ls;
        while ((f = matcher.matchFunction(I, scope)) != NULL ) {
            s++;
            errs() << "scope #" << s << ": " << cpp_demangle(f->getName().data())<< " |=> " << scope << ", ";
            FPasses->run(*f);
            errs() << "\t";
            if (li == NULL) {
                errs() << "NULL loopinfo" << "\n";
                continue;
            }
            if (li->begin() == li->end()) {
                errs() << "no loop in this function" << "\n";
            }
            else {
                //TODO more elegant
                //TODO get function scope
                //TODO loop finder no need to restart
                Loop * loop = NULL;
                while(HI != HE) {
                    mod = *HI;
                    // if there are multiple functions and this mod
                    // crossed the current function's scope, we break
                    // the loop
                    if (scope.end != 0  && mod->scope.begin > scope.begin)
                        break;
                    loop = Matcher::matchLoop(*li, scope);
                    if (loop != NULL) {
                        ScopeInfoFinder::getLoopScope(ls, loop);
                        errs() << "loop: " << ls;
                    }
                    HI++;
                }
                if (loop == NULL)
                    errs() << "loop: none" << "\n";
                else
                    errs() << "\n";
            }
        }
        if (s == 0) {
            errs() << "insignificant scope";
        }
        errs() << "\n";
        */
        return false;
    }

    virtual llvm::StringRef getPassName() const { return PassName.c_str(); }

    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
        AU.setPreservesAll();
        AU.addRequired<DominatorTreeWrapperPass>();
        AU.addRequired<LoopInfoWrapperPass>();
    }
};

char LoopInfoFinder::ID = 0;
static RegisterPass<LoopInfoFinder> X("loopfinder", "Finding loop information");

static inline void addPass(PassManagerBase &PM, Pass *P) {
  // Add the pass to the pass manager...
  PM.add(P);
}


//===----------------------------------------------------------------------===//
// main for opt
//
int Run(int argc, char **argv) 
{

    // Enable debug stream buffering.
    EnableDebugBuffering = false;

    llvm_shutdown_obj Y;  // Call llvm_shutdown() on exit.
    LLVMContext Context;

    // Initialize passes
    PassRegistry &Registry = *PassRegistry::getPassRegistry();
    initializeCore(Registry);
    initializeScalarOpts(Registry);
    initializeIPO(Registry);
    initializeAnalysis(Registry);
    initializeTransformUtils(Registry);
    initializeInstCombine(Registry);
    initializeInstrumentation(Registry);
    initializeTarget(Registry);

    cl::ParseCommandLineOptions(argc, argv,
            "llvm .bc -> .bc modular optimizer and analysis printer\n");

    // Allocate a full target machine description only if necessary.
    // FIXME: The choice of target should be controllable on the command line.
    std::auto_ptr<TargetMachine> target;

    SMDiagnostic Err;

    std::cout << InputFilename << std::endl;
    // Load the input module...
    std::unique_ptr<Module> M = llvm::parseIRFile(
      InputFilename, Err, Context);

    if (M.get() == 0) {
        Err.print(argv[0], errs());
        return 1;
    }

    // Figure out what stream we are supposed to write to...
    std::unique_ptr<ToolOutputFile> Out;
    if (OutputFilename.empty())
        OutputFilename = "-";

    std::error_code EC;
    Out.reset(new ToolOutputFile(OutputFilename, EC, sys::fs::OF_None));
    if (EC) {
        errs() << EC.message() << '\n';
        return 1;
    }

    // Create a PassManager to hold and optimize the collection of passes we are
    // about to build.
    //
    legacy::PassManager Passes;

    // Add an appropriate TargetLibraryInfo pass for the module's triple.
    TargetLibraryInfoImpl TLII(Triple(M->getTargetTriple()));
    Passes.add(new TargetLibraryInfoWrapperPass(TLII));
    
    Passes.add(new LoopInfoWrapperPass());

    // Add an appropriate DataLayout instance for this module.
    DataLayout *TD = 0;
    const std::string &ModuleDataLayout = M.get()->getDataLayout().getStringRepresentation();
    if (!ModuleDataLayout.empty())
        TD = new DataLayout(ModuleDataLayout);

    std::unique_ptr<legacy::FunctionPassManager> FPasses;

    // Create a new optimization pass for each one specified on the command line
    for (unsigned i = 0; i < PassList.size(); ++i) {
        const PassInfo *PassInf = PassList[i];
        Pass *P = 0;
        if (PassInf->getNormalCtor())
            P = PassInf->getNormalCtor()();
        else
            errs() << argv[0] << ": cannot create pass: "
                << PassInf->getPassName() << "\n";
        if (P) {
            addPass(Passes, P);
            /*
            PassKind Kind = P->getPassKind();
            if (AnalyzeOnly) {
                switch (Kind) {
                    case PT_BasicBlock:
                        Passes.add(new BasicBlockPassPrinter(PassInf, Out->os()));
                        break;
                    case PT_Region:
                        Passes.add(new RegionPassPrinter(PassInf, Out->os()));
                        break;
                    case PT_Loop:
                        Passes.add(new LoopPassPrinter(PassInf, Out->os()));
                        break;
                    case PT_Function:
                        Passes.add(new FunctionPassPrinter(PassInf, Out->os()));
                        break;
                    case PT_CallGraphSCC:
                        Passes.add(new CallGraphSCCPassPrinter(PassInf, Out->os()));
                        break;
                    default:
                        Passes.add(new ModulePassPrinter(PassInf, Out->os()));
                        break;
                }
            }
            */
        }
    }
    Passes.add(new LoopInfoFinder()); 

    // Check that the module is well formed on completion of optimization
    // Passes.add(createVerifierPass());

    // Write bitcode or assembly to the output as the last step...
    /*
       if (!NoOutput && !AnalyzeOnly) {
       if (OutputAssembly)
       Passes.add(createPrintModulePass(&Out->os()));
       else
       Passes.add(createBitcodeWriterPass(Out->os()));
       }
       */

    // Now that we have all of the passes ready, run them.
    Passes.run(*M.get());

    return 0;
}

#include "llvm/IR/Function.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
using namespace llvm;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return EXIT_FAILURE;
    }
    int BB_num;
    LLVMContext Context;
    SMDiagnostic Err;
    std::unique_ptr<Module> Mod = parseIRFile(argv[1], Err, Context);

    if (!Mod) {
        Err.print("IRReader", errs());
        return 1;
    }
    BB_num = 1;
    for (auto &Function : *Mod) {
        if (Function.isDeclaration()) continue; // Skip function declarations

        errs()  << "Function: " << Function.getName() << "\n";
        
        for (auto &Block : Function) {
            errs() << "    Basic Block Name: " << "Basic_Block_" << BB_num << "\n";
            BB_num++;
            for (auto &Inst : Block) {
                if (const DebugLoc &Loc = Inst.getDebugLoc()) { // Check if there is a debug location
                    unsigned Line = Loc.getLine();
                    StringRef File = Loc->getFilename();
                    unsigned Column = Loc->getColumn();
            
                    StringRef Dir = Loc->getDirectory();
                    errs() <<"        " << Dir << "/" << File << ":" << Line << " "<< Column <<"\n";
                }
                // } else {
                //     errs() << Inst << " - No debug info available\n";
                // }
            }
        }
    }

    return 0;
}

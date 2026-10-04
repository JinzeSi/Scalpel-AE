#include "llvm/Support/raw_ostream.h"
#include <clang/AST/AST.h>
#include <clang/AST/RecursiveASTVisitor.h>
#include <clang/AST/ASTContext.h>
#include <clang/AST/Mangle.h>
#include <clang/AST/ParentMapContext.h>
#include <clang/Frontend/ASTConsumers.h>
#include <clang/Frontend/FrontendActions.h>
#include <clang/Tooling/CommonOptionsParser.h>
#include <clang/Tooling/Tooling.h>
#include <clang/Rewrite/Core/Rewriter.h>
#include <clang/Basic/SourceManager.h>
#include <clang/Basic/Diagnostic.h>
#include <clang/Frontend/CompilerInstance.h>
#include <clang/Lex/Lexer.h>
#include <unordered_set>
#include <unordered_map>
#include <iostream>
#include <sstream>
#include <fstream>

#define MYSQL

#ifdef MYSQL
std::string Testcase = "";
#endif

using namespace clang;
using namespace clang::tooling;

bool endWith(const std::string& str, const std::string& suffix) {
    if (suffix.size() > str.size()) return false;
    return str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

static llvm::cl::OptionCategory MyToolCategory("my-tool options");
static llvm::cl::opt<bool> IsModifiedPartMeasured("measure-modified-part",
    llvm::cl::desc("Indicate if the latency of modified part will be measured."), 
    llvm::cl::init(false), llvm::cl::cat(MyToolCategory));
static llvm::cl::opt<bool> IsLoopBoost("loop-boost",
    llvm::cl::desc("Indicate if the loop boost is enabled."), 
    llvm::cl::init(false), llvm::cl::cat(MyToolCategory));
static llvm::cl::opt<bool> IsServerLog("server-log",
    llvm::cl::desc("Indicate if the server measure the latency and print it to the log."),
    llvm::cl::init(false), llvm::cl::cat(MyToolCategory));
static llvm::cl::opt<bool> IsEndToEnd("end-to-end",
    llvm::cl::desc("Indicate if need to insert end-to-end function."),
    llvm::cl::init(true), llvm::cl::cat(MyToolCategory));

std::unordered_map<std::string, uint64_t> SymbolicVarValueMap;

std::string StartLocEndToEndFunctionName = "";
std::string StartLocEndToEndFunctionFilePath = "";
std::string StartLocEndToEndFunctionLocation = "";
std::string EndLocEndToEndFunctionName = "";
std::string EndLocEndToEndFunctionFilePath = "";
std::string EndLocEndToEndFunctionLocation = "";
std::string CurrentFilePath = "";
std::string MainFilePath = "";

struct FuncChangeInfoClass {
    std::string FuncName;
    std::string FilePath;
    unsigned CallExprStartLine, CallExprEndLine;
    std::vector<std::pair<unsigned, unsigned>> ChangeRanges;
};

class RealExecutionContext {
public:
    std::vector<unsigned> CallExprLines;
    std::unordered_map<std::string, std::unordered_map<std::string, FuncChangeInfoClass>> FuncChangeInfos;
};

class RealExecutionVisitor : public RecursiveASTVisitor<RealExecutionVisitor> {
public:
    RealExecutionVisitor(ASTContext& Context, Rewriter &R, Preprocessor &PP, const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo, SourceLocation& IncludeLoc)
        : Context(Context), TheRewriter(R), PP(PP), FuncChangeInfo(FuncChangeInfo), IncludeLoc(IncludeLoc), NoNeedToInsertEnd(false), EnableLine(0), DisableLine(0), KillStateLine(0) {}

    bool TraverseFunctionDecl(FunctionDecl* f) {
        if (!f->isThisDeclarationADefinition() || !f->hasBody() || !f->getBody()
            || f->getBody()->child_begin() == f->getBody()->child_end()) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseFunctionDecl(f);
        }

        std::string FuncName = getFunctionName(f);
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        SourceLocation StartLoc = f->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = TheRewriter.getSourceMgr().getExpansionLoc(StartLoc);
        }

        unsigned Line = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);

        const Decl* Ancestor = findOutermostAncestor(f);
        SourceLocation AncestorLoc = Ancestor->getBeginLoc();
        if (AncestorLoc.isMacroID()) {
            AncestorLoc = TheRewriter.getSourceMgr().getExpansionLoc(AncestorLoc);
        }
        unsigned AncestorLine = TheRewriter.getSourceMgr().getSpellingLineNumber(AncestorLoc);
        if (IncludeLoc.isInvalid() || AncestorLine < TheRewriter.getSourceMgr().getSpellingLineNumber(IncludeLoc)) {
            SourceLocation StartOfLine = TheRewriter.getSourceMgr().translateLineCol(TheRewriter.getSourceMgr().getMainFileID(), AncestorLine, 1);
            IncludeLoc = StartOfLine;
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

#ifdef MYSQL
            if (FuncName == "_Z20dispatch_sql_commandP3THDP12Parser_state" || FuncName == "_Z11mysql_parseP3THDP12Parser_state") {
                llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (strncmp(thd->query().str, \"select @@version_comment limit 1\", 16)) {\n";
                if (Testcase != "") {
                    Text = "if (!strncmp(thd->query().str, \"" + Testcase + "\", 16)) {\n";
                }
                if (IsServerLog) {
                    Text += "   clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                        "   modified_part_time = 0;\n"
                        "   loop_usleep_time = 0;\n";
                }
                Text += "   should_symbolize = 1;\n"
                    "}\n";
                llvm::errs() << Text;

                if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                    && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                    TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, Text);
                } else {
                    TheRewriter.InsertText(FirstChildrenStartLoc, Text);
                }
            } else {
#endif

            llvm::errs() << "(TraverseFunctionDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                "modified_part_time = 0;\n"
                "loop_usleep_time = 0;\n"
                "should_symbolize = 1;\n"
                "\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 1;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }
#ifdef MYSQL
            }
#endif
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

            llvm::errs() << "(TraverseFunctionDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            std::string Text = "if (should_symbolize) {\n"
                "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                "   modified_part_time = 0;\n"
                "   loop_usleep_time = 0;\n"
                "}\n"
                "should_symbolize = 0;\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 0;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }
        }

        bool isMainFunction = false;
        if (isChangedFunction) {
            isMainFunction = !(itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff);
            if (isMainFunction) {
                unsigned StartLine, EndLine;
                StartLine = (itr->second.CallExprStartLine == 0? itr->second.ChangeRanges.begin()->first : itr->second.CallExprStartLine);
                EndLine = (itr->second.CallExprEndLine == 0? itr->second.ChangeRanges.rbegin()->second : itr->second.CallExprEndLine);
                for (const auto &ChangeRange : itr->second.ChangeRanges) {
                    if (ChangeRange.first < StartLine) {
                        StartLine = ChangeRange.first;
                    }
                    if (ChangeRange.second > EndLine) {
                        EndLine = ChangeRange.second;
                    }
                }

                Stmt *FuncBody = f->getBody();
                SourceManager &SM = TheRewriter.getSourceMgr();
                unsigned FuncStartLine = SM.getSpellingLineNumber(FuncBody->getBeginLoc());
                unsigned FuncEndLine = SM.getSpellingLineNumber(FuncBody->getEndLoc());
                assert(!(FuncStartLine >= EndLine || FuncEndLine <= StartLine));

                // 在函数体的开始和结束之间找到合适的位置插入代码
                insertCodeAtFunctionBody(FuncBody, StartLine, EndLine, f->getReturnType()->isVoidType());
                llvm::errs() << "EnableLine: " << EnableLine << "\n";
                llvm::errs() << "DisableLine: " << DisableLine << "\n";
                llvm::errs() << "KillStateLine: " << KillStateLine << "\n";

                if (EnableLoc.isInvalid() || DisableLoc.isInvalid() || KillStateLoc.isInvalid()) {
                    llvm::errs() << "Invalid location!!!!!!!!!\n";
                    return true;
                }


                std::string EnableLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                if (IsModifiedPartMeasured)
                    EnableLocStr = "struct timespec _start_, _stop_;\n"
                        "if (should_symbolize) {\n"
                        "   clock_gettime(CLOCK_MONOTONIC, &_start_);\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                EnableLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << EnableLocStr << "\n";
                TheRewriter.InsertText(
                    EnableLoc,
                    EnableLocStr
                );
            }
        }

        bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseFunctionDecl(f);

        if (isChangedFunction) {
            if (isMainFunction) {
                auto& RestoreInfo = RestoreInfos[getFunctionName(f)];
                for (const auto &RI : RestoreInfo) {
                    if (RI.VarDestructionLoc.isValid() && RI.VarDestructionLoc == DisableLoc) {
                        std::string RestoreCall = getRestoreCall(RI.VarName, RI.FlagVarName, RI.RestoreVarName);
                        llvm::errs() << "(TraverseFunctionDecl) Insert at ";
                        DisableLoc.dump(TheRewriter.getSourceMgr());
                        llvm::errs() << RestoreCall << "\n";
                        TheRewriter.InsertTextAfterToken(DisableLoc, RestoreCall);
                    }
                }

                if (!NoNeedToInsertEnd) {
                    std::string KillStateLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_DISABLED;\n"
                        "}\n";
                    if (IsModifiedPartMeasured)
                        KillStateLocStr = "if (should_symbolize) {\n"
                            "   clock_gettime(CLOCK_MONOTONIC, &_stop_);\n"
                            "   long _nanos_ = (_stop_.tv_sec - _start_.tv_sec) * 1000000000 + (_stop_.tv_nsec - _start_.tv_nsec);\n"
                            "   s2e_flag = S2E_DISABLED;\n"
                            "   modified_part_time += _nanos_;\n"
                            "}\n";
                    llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                    KillStateLoc.dump(TheRewriter.getSourceMgr());
                    llvm::errs() << KillStateLocStr << "\n";
                    // 如果是函数末尾的右大括号，则在其前面插入代码，如果是函数体的某个孩子的结尾，则在其后面插入代码
                    TheRewriter.InsertText(
                        KillStateLoc,
                        KillStateLocStr
                    );
                }
            }
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                    "modified_part_time = 0;\n"
                    "loop_usleep_time = 0;\n"
                    "should_symbolize = 1;\n"
                    "\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 1;\n";
                }
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                EndLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (should_symbolize) {\n"
                "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                "   modified_part_time = 0;\n"
                "   loop_usleep_time = 0;\n"
                "}\n"
                "should_symbolize = 0;\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 0;\n";
                }
                llvm::errs() << Text;
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }
        return r;
    }

    bool TraverseCXXMethodDecl(CXXMethodDecl* f) {
        if (!f->isThisDeclarationADefinition() || !f->hasBody() || !f->getBody()
            || f->getBody()->child_begin() == f->getBody()->child_end()) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseCXXMethodDecl(f);
        }

        std::string FuncName = getFunctionName(f);
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        SourceLocation StartLoc = f->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = TheRewriter.getSourceMgr().getExpansionLoc(StartLoc);
        }

        unsigned Line = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);

        const Decl* Ancestor = findOutermostAncestor(f);
        SourceLocation AncestorLoc = Ancestor->getBeginLoc();
        if (AncestorLoc.isMacroID()) {
            AncestorLoc = TheRewriter.getSourceMgr().getExpansionLoc(AncestorLoc);
        }
        unsigned AncestorLine = TheRewriter.getSourceMgr().getSpellingLineNumber(AncestorLoc);
        if (IncludeLoc.isInvalid() || AncestorLine < TheRewriter.getSourceMgr().getSpellingLineNumber(IncludeLoc)) {
            SourceLocation StartOfLine = TheRewriter.getSourceMgr().translateLineCol(TheRewriter.getSourceMgr().getMainFileID(), AncestorLine, 1);
            IncludeLoc = StartOfLine;
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

#ifdef MYSQL
            if (FuncName == "_Z20dispatch_sql_commandP3THDP12Parser_state" || FuncName == "_Z11mysql_parseP3THDP12Parser_state") {
                llvm::errs() << "(TraverseCXXMethodDecl)Insert at ";
                FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (strncmp(thd->query().str, \"select @@version_comment limit 1\", 16)) {\n";
                if (Testcase != "") {
                    Text = "if (!strncmp(thd->query().str, \"" + Testcase + "\", 16)) {\n";
                }
                if (IsServerLog) {
                    Text += "   clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                        "   modified_part_time = 0;\n"
                        "   loop_usleep_time = 0;\n";
                }
                Text += "   should_symbolize = 1;\n"
                    "}\n";
                llvm::errs() << Text;
                if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                    && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                    TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, Text);
                } else {
                    TheRewriter.InsertText(FirstChildrenStartLoc, Text);
                }
            } else {
#endif

            llvm::errs() << "(TraverseCXXMethodDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());

            std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                "modified_part_time = 0;\n"
                "loop_usleep_time = 0;\n"
                "should_symbolize = 1;\n"
                "\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 1;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }

#ifdef MYSQL
            }
#endif
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

            llvm::errs() << "(TraverseCXXMethodDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            std::string Text = "if (should_symbolize) {\n"
                "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                "   modified_part_time = 0;\n"
                "   loop_usleep_time = 0;\n"
                "}\n"
                "should_symbolize = 0;\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 0;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }
        }

        bool isMainFunction = false;
        if (isChangedFunction) {
            isMainFunction = !(itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff);
            if (isMainFunction) {
                unsigned StartLine, EndLine;
                StartLine = (itr->second.CallExprStartLine == 0? itr->second.ChangeRanges.begin()->first : itr->second.CallExprStartLine);
                EndLine = (itr->second.CallExprEndLine == 0? itr->second.ChangeRanges.rbegin()->second : itr->second.CallExprEndLine);
                for (const auto &ChangeRange : itr->second.ChangeRanges) {
                    if (ChangeRange.first < StartLine) {
                        StartLine = ChangeRange.first;
                    }
                    if (ChangeRange.second > EndLine) {
                        EndLine = ChangeRange.second;
                    }
                }

                Stmt *FuncBody = f->getBody();
                SourceManager &SM = TheRewriter.getSourceMgr();
                unsigned FuncStartLine = SM.getSpellingLineNumber(FuncBody->getBeginLoc());
                unsigned FuncEndLine = SM.getSpellingLineNumber(FuncBody->getEndLoc());
                assert(!(FuncStartLine >= EndLine || FuncEndLine <= StartLine));

                // 在函数体的开始和结束之间找到合适的位置插入代码
                insertCodeAtFunctionBody(FuncBody, StartLine, EndLine, f->getReturnType()->isVoidType());
                llvm::errs() << "EnableLine: " << EnableLine << "\n";
                llvm::errs() << "DisableLine: " << DisableLine << "\n";
                llvm::errs() << "KillStateLine: " << KillStateLine << "\n";

                if (EnableLoc.isInvalid() || DisableLoc.isInvalid() || KillStateLoc.isInvalid()) {
                    llvm::errs() << "Invalid location!!!!!!!!!\n";
                    return true;
                }


                std::string EnableLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                if (IsModifiedPartMeasured)
                    EnableLocStr = "struct timespec _start_, _stop_;\n"
                        "if (should_symbolize) {\n"
                        "   clock_gettime(CLOCK_MONOTONIC, &_start_);\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                llvm::errs() << "(TraverseCXXMethodDecl)Insert at ";
                EnableLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << EnableLocStr << "\n";
                TheRewriter.InsertText(
                    EnableLoc,
                    EnableLocStr
                );
            }
        }

        bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseCXXMethodDecl(f);

        if (isChangedFunction) {
            if (isMainFunction) {
                auto& RestoreInfo = RestoreInfos[getFunctionName(f)];
                for (const auto &RI : RestoreInfo) {
                    if (RI.VarDestructionLoc.isValid() && RI.VarDestructionLoc == DisableLoc) {
                        std::string RestoreCall = getRestoreCall(RI.VarName, RI.FlagVarName, RI.RestoreVarName);
                        llvm::errs() << "(TraverseCXXMethodDecl) Insert at ";
                        DisableLoc.dump(TheRewriter.getSourceMgr());
                        llvm::errs() << RestoreCall << "\n";
                        TheRewriter.InsertTextAfterToken(DisableLoc, RestoreCall);
                    }
                }

                if (!NoNeedToInsertEnd) {
                    std::string KillStateLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_DISABLED;\n"
                        "}\n";
                    if (IsModifiedPartMeasured)
                        KillStateLocStr = "if (should_symbolize) {\n"
                            "   clock_gettime(CLOCK_MONOTONIC, &_stop_);\n"
                            "   long _nanos_ = (_stop_.tv_sec - _start_.tv_sec) * 1000000000 + (_stop_.tv_nsec - _start_.tv_nsec);\n"
                            "   s2e_flag = S2E_DISABLED;\n"
                            "   modified_part_time += _nanos_;\n"
                            "}\n";
                    llvm::errs() << "(TraverseCXXMethodDecl)Insert at ";
                    KillStateLoc.dump(TheRewriter.getSourceMgr());
                    llvm::errs() << KillStateLocStr << "\n";
                    // 如果是函数末尾的右大括号，则在其前面插入代码，如果是函数体的某个孩子的结尾，则在其后面插入代码
                    TheRewriter.InsertText(
                        KillStateLoc,
                        KillStateLocStr
                    );
                }
            }
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                    "modified_part_time = 0;\n"
                    "loop_usleep_time = 0;\n"
                    "should_symbolize = 1;\n"
                    "\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 1;\n";
                }
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                llvm::errs() << "(TraverseCXXMethodDecl)Insert at ";
                EndLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (should_symbolize) {\n"
                    "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                    "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                    "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                    "   modified_part_time = 0;\n"
                    "   loop_usleep_time = 0;\n"
                    "}\n"
                    "should_symbolize = 0;\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 0;\n";
                }
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }
        return r;
    }

    bool TraverseCXXConstructorDecl(CXXConstructorDecl* f) {
        if (!f->isThisDeclarationADefinition() || !f->hasBody() || !f->getBody()
            || f->getBody()->child_begin() == f->getBody()->child_end()) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseCXXConstructorDecl(f);
        }

        std::string FuncName = getFunctionName(f);
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        SourceLocation StartLoc = f->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = TheRewriter.getSourceMgr().getExpansionLoc(StartLoc);
        }

        unsigned Line = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);

        const Decl* Ancestor = findOutermostAncestor(f);
        SourceLocation AncestorLoc = Ancestor->getBeginLoc();
        if (AncestorLoc.isMacroID()) {
            AncestorLoc = TheRewriter.getSourceMgr().getExpansionLoc(AncestorLoc);
        }
        unsigned AncestorLine = TheRewriter.getSourceMgr().getSpellingLineNumber(AncestorLoc);
        if (IncludeLoc.isInvalid() || AncestorLine < TheRewriter.getSourceMgr().getSpellingLineNumber(IncludeLoc)) {
            SourceLocation StartOfLine = TheRewriter.getSourceMgr().translateLineCol(TheRewriter.getSourceMgr().getMainFileID(), AncestorLine, 1);
            IncludeLoc = StartOfLine;
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

#ifdef MYSQL
            if (FuncName == "_Z20dispatch_sql_commandP3THDP12Parser_state" || FuncName == "_Z11mysql_parseP3THDP12Parser_state") {
                llvm::errs() << "(TraverseCXXConstructorDecl)Insert at ";
                FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (strncmp(thd->query().str, \"select @@version_comment limit 1\", 16)) {\n";
                if (Testcase != "") {
                    Text = "if (!strncmp(thd->query().str, \"" + Testcase + "\", 16)) {\n";
                }
                if (IsServerLog) {
                    Text += "   clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                        "   modified_part_time = 0;\n"
                        "   loop_usleep_time = 0;\n";
                }
                Text += "   should_symbolize = 1;\n"
                    "}\n";
                llvm::errs() << Text;
                if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                    && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                    TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, Text);
                } else {
                    TheRewriter.InsertText(FirstChildrenStartLoc, Text);
                }
            } else {
#endif

            llvm::errs() << "(TraverseCXXConstructorDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                "modified_part_time = 0;\n"
                "loop_usleep_time = 0;\n"
                "should_symbolize = 1;\n"
                "\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 1;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }

#ifdef MYSQL
            }
#endif
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

            llvm::errs() << "(TraverseCXXConstructorDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            std::string Text = "if (should_symbolize) {\n"
                "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                "   modified_part_time = 0;\n"
                "   loop_usleep_time = 0;\n"
                "}\n"
                "should_symbolize = 0;\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 0;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }
        }

        bool isMainFunction = false;
        if (isChangedFunction) {
            isMainFunction = !(itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff);
            if (isMainFunction) {
                unsigned StartLine, EndLine;
                StartLine = (itr->second.CallExprStartLine == 0? itr->second.ChangeRanges.begin()->first : itr->second.CallExprStartLine);
                EndLine = (itr->second.CallExprEndLine == 0? itr->second.ChangeRanges.rbegin()->second : itr->second.CallExprEndLine);
                for (const auto &ChangeRange : itr->second.ChangeRanges) {
                    if (ChangeRange.first < StartLine) {
                        StartLine = ChangeRange.first;
                    }
                    if (ChangeRange.second > EndLine) {
                        EndLine = ChangeRange.second;
                    }
                }

                Stmt *FuncBody = f->getBody();
                SourceManager &SM = TheRewriter.getSourceMgr();
                unsigned FuncStartLine = SM.getSpellingLineNumber(FuncBody->getBeginLoc());
                unsigned FuncEndLine = SM.getSpellingLineNumber(FuncBody->getEndLoc());
                assert(!(FuncStartLine >= EndLine || FuncEndLine <= StartLine));

                // 在函数体的开始和结束之间找到合适的位置插入代码
                insertCodeAtFunctionBody(FuncBody, StartLine, EndLine, f->getReturnType()->isVoidType());
                llvm::errs() << "EnableLine: " << EnableLine << "\n";
                llvm::errs() << "DisableLine: " << DisableLine << "\n";
                llvm::errs() << "KillStateLine: " << KillStateLine << "\n";

                if (EnableLoc.isInvalid() || DisableLoc.isInvalid() || KillStateLoc.isInvalid()) {
                    llvm::errs() << "Invalid location!!!!!!!!!\n";
                    return true;
                }

                std::string EnableLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                if (IsModifiedPartMeasured)
                    EnableLocStr = "struct timespec _start_, _stop_;\n"
                        "if (should_symbolize) {\n"
                        "   clock_gettime(CLOCK_MONOTONIC, &_start_);\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                llvm::errs() << "(TraverseCXXConstructorDecl)Insert at ";
                EnableLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << EnableLocStr << "\n";
                TheRewriter.InsertText(
                    EnableLoc,
                    EnableLocStr
                );
            }
        }

        bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseCXXConstructorDecl(f);

        if (isChangedFunction) {
            if (isMainFunction) {
                auto& RestoreInfo = RestoreInfos[getFunctionName(f)];
                for (const auto &RI : RestoreInfo) {
                    if (RI.VarDestructionLoc.isValid() && RI.VarDestructionLoc == DisableLoc) {
                        std::string RestoreCall = getRestoreCall(RI.VarName, RI.FlagVarName, RI.RestoreVarName);
                        llvm::errs() << "(TraverseCXXConstructorDecl) Insert at ";
                        DisableLoc.dump(TheRewriter.getSourceMgr());
                        llvm::errs() << RestoreCall << "\n";
                        TheRewriter.InsertTextAfterToken(DisableLoc, RestoreCall);
                    }
                }

                if (!NoNeedToInsertEnd) {
                    std::string KillStateLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_DISABLED;\n"
                        "}\n";
                    if (IsModifiedPartMeasured)
                        KillStateLocStr = "if (should_symbolize) {\n"
                            "   clock_gettime(CLOCK_MONOTONIC, &_stop_);\n"
                            "   long _nanos_ = (_stop_.tv_sec - _start_.tv_sec) * 1000000000 + (_stop_.tv_nsec - _start_.tv_nsec);\n"
                            "   s2e_flag = S2E_DISABLED;\n"
                            "   modified_part_time += _nanos_;\n"
                            "}\n";
                    llvm::errs() << "(TraverseCXXConstructorDecl)Insert at ";
                    KillStateLoc.dump(TheRewriter.getSourceMgr());
                    llvm::errs() << KillStateLocStr << "\n";
                    // 如果是函数末尾的右大括号，则在其前面插入代码，如果是函数体的某个孩子的结尾，则在其后面插入代码
                    TheRewriter.InsertText(
                        KillStateLoc,
                        KillStateLocStr
                    );
                }
            }
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                    "modified_part_time = 0;\n"
                    "loop_usleep_time = 0;\n"
                    "should_symbolize = 1;\n"
                    "\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 1;\n";
                }
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                llvm::errs() << "(TraverseCXXConstructorDecl)Insert at ";
                EndLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (should_symbolize) {\n"
                    "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                    "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                    "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                    "   modified_part_time = 0;\n"
                    "   loop_usleep_time = 0;\n"
                    "}\n"
                    "should_symbolize = 0;\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 0;\n";
                }
                llvm::errs() << Text;
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }
        return r;
    }

    bool TraverseCXXDestructorDecl(CXXDestructorDecl* f) {
        if (!f->isThisDeclarationADefinition() || !f->hasBody() || !f->getBody()
            || f->getBody()->child_begin() == f->getBody()->child_end()) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseCXXDestructorDecl(f);
        }

        std::string FuncName = getFunctionName(f);
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        SourceLocation StartLoc = f->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = TheRewriter.getSourceMgr().getExpansionLoc(StartLoc);
        }

        unsigned Line = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);
        const Decl* Ancestor = findOutermostAncestor(f);
        SourceLocation AncestorLoc = Ancestor->getBeginLoc();
        if (AncestorLoc.isMacroID()) {
            AncestorLoc = TheRewriter.getSourceMgr().getExpansionLoc(AncestorLoc);
        }
        unsigned AncestorLine = TheRewriter.getSourceMgr().getSpellingLineNumber(AncestorLoc);
        if (IncludeLoc.isInvalid() || AncestorLine < TheRewriter.getSourceMgr().getSpellingLineNumber(IncludeLoc)) {
            SourceLocation StartOfLine = TheRewriter.getSourceMgr().translateLineCol(TheRewriter.getSourceMgr().getMainFileID(), AncestorLine, 1);
            IncludeLoc = StartOfLine;
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

#ifdef MYSQL
            if (FuncName == "_Z20dispatch_sql_commandP3THDP12Parser_state" || FuncName == "_Z11mysql_parseP3THDP12Parser_state") {
                llvm::errs() << "(TraverseCXXDestructorDecl)Insert at ";
                FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (strncmp(thd->query().str, \"select @@version_comment limit 1\", 16)) {\n";
                if (Testcase != "") {
                    Text = "if (!strncmp(thd->query().str, \"" + Testcase + "\", 16)) {\n";
                }
                if (IsServerLog) {
                    Text += "   clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                        "   modified_part_time = 0;\n"
                        "   loop_usleep_time = 0;\n";
                }
                Text += "   should_symbolize = 1;\n"
                    "}\n";
                llvm::errs() << Text;
                if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                    && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                    TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, Text);
                } else {
                    TheRewriter.InsertText(FirstChildrenStartLoc, Text);
                }
            } else {
#endif

            llvm::errs() << "(TraverseCXXDestructorDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                "modified_part_time = 0;\n"
                "loop_usleep_time = 0;\n"
                "should_symbolize = 1;\n"
                "\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 1;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }

#ifdef MYSQL
            }
#endif
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

            llvm::errs() << "(TraverseCXXDestructorDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            std::string Text = "if (should_symbolize) {\n"
                "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                "   modified_part_time = 0;\n"
                "   loop_usleep_time = 0;\n"
                "}\n"
                "should_symbolize = 0;\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 0;\n";
            }
            llvm::errs() << Text;
            if (TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc)
                && *TheRewriter.getSourceMgr().getCharacterData(FirstChildrenStartLoc) == ';') {
                TheRewriter.InsertTextAfterToken(FirstChildrenStartLoc, "\n" + Text);
            } else {
                TheRewriter.InsertText(FirstChildrenStartLoc, "\n" + Text);
            }
        }

        bool isMainFunction = false;
        if (isChangedFunction) {
            isMainFunction = !(itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff);
            if (isMainFunction) {
                unsigned StartLine, EndLine;
                StartLine = (itr->second.CallExprStartLine == 0? itr->second.ChangeRanges.begin()->first : itr->second.CallExprStartLine);
                EndLine = (itr->second.CallExprEndLine == 0? itr->second.ChangeRanges.rbegin()->second : itr->second.CallExprEndLine);
                for (const auto &ChangeRange : itr->second.ChangeRanges) {
                    if (ChangeRange.first < StartLine) {
                        StartLine = ChangeRange.first;
                    }
                    if (ChangeRange.second > EndLine) {
                        EndLine = ChangeRange.second;
                    }
                }

                Stmt *FuncBody = f->getBody();
                SourceManager &SM = TheRewriter.getSourceMgr();
                unsigned FuncStartLine = SM.getSpellingLineNumber(FuncBody->getBeginLoc());
                unsigned FuncEndLine = SM.getSpellingLineNumber(FuncBody->getEndLoc());
                assert(!(FuncStartLine >= EndLine || FuncEndLine <= StartLine));

                // 在函数体的开始和结束之间找到合适的位置插入代码
                insertCodeAtFunctionBody(FuncBody, StartLine, EndLine, f->getReturnType()->isVoidType());
                llvm::errs() << "EnableLine: " << EnableLine << "\n";
                llvm::errs() << "DisableLine: " << DisableLine << "\n";
                llvm::errs() << "KillStateLine: " << KillStateLine << "\n";

                if (EnableLoc.isInvalid() || DisableLoc.isInvalid() || KillStateLoc.isInvalid()) {
                    llvm::errs() << "Invalid location!!!!!!!!!\n";
                    return true;
                }


                std::string EnableLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                if (IsModifiedPartMeasured)
                    EnableLocStr = "struct timespec _start_, _stop_;\n"
                        "if (should_symbolize) {\n"
                        "   clock_gettime(CLOCK_MONOTONIC, &_start_);\n"
                        "   s2e_flag = S2E_ENABLED;\n"
                        "}\n";
                llvm::errs() << "(TraverseCXXDestructorDecl)Insert at ";
                EnableLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << EnableLocStr << "\n";
                TheRewriter.InsertText(
                    EnableLoc,
                    EnableLocStr
                );
            }
        }

        bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseCXXDestructorDecl(f);

        if (isChangedFunction) {
            if (isMainFunction) {
                auto& RestoreInfo = RestoreInfos[getFunctionName(f)];
                for (const auto &RI : RestoreInfo) {
                    if (RI.VarDestructionLoc.isValid() && RI.VarDestructionLoc == DisableLoc) {
                        std::string RestoreCall = getRestoreCall(RI.VarName, RI.FlagVarName, RI.RestoreVarName);
                        llvm::errs() << "(TraverseCXXDestructorDecl) Insert at ";
                        DisableLoc.dump(TheRewriter.getSourceMgr());
                        llvm::errs() << RestoreCall << "\n";
                        TheRewriter.InsertTextAfterToken(DisableLoc, RestoreCall);
                    }
                }

                if (!NoNeedToInsertEnd) {
                    std::string KillStateLocStr = "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_DISABLED;\n"
                        "}\n";
                    if (IsModifiedPartMeasured)
                        KillStateLocStr = "if (should_symbolize) {\n"
                            "   clock_gettime(CLOCK_MONOTONIC, &_stop_);\n"
                            "   long _nanos_ = (_stop_.tv_sec - _start_.tv_sec) * 1000000000 + (_stop_.tv_nsec - _start_.tv_nsec);\n"
                            "   s2e_flag = S2E_DISABLED;\n"
                            "   modified_part_time += _nanos_;\n"
                            "}\n";
                    llvm::errs() << "(TraverseCXXDestructorDecl)Insert at ";
                    KillStateLoc.dump(TheRewriter.getSourceMgr());
                    llvm::errs() << KillStateLocStr << "\n";
                    // 如果是函数末尾的右大括号，则在其前面插入代码，如果是函数体的某个孩子的结尾，则在其后面插入代码
                    TheRewriter.InsertText(
                        KillStateLoc,
                        KillStateLocStr
                    );
                }
            }
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                std::string Text = "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                    "modified_part_time = 0;\n"
                    "loop_usleep_time = 0;\n"
                    "should_symbolize = 1;\n"
                    "\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 1;\n";
                }
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                llvm::errs() << "(TraverseCXXDestructorDecl)Insert at ";
                EndLoc.dump(TheRewriter.getSourceMgr());
                std::string Text = "if (should_symbolize) {\n"
                    "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                    "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                    "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                    "   modified_part_time = 0;\n"
                    "   loop_usleep_time = 0;\n"
                    "}\n"
                    "should_symbolize = 0;\n";
                if (!IsServerLog) {
                    Text = "should_symbolize = 0;\n";
                }
                llvm::errs() << Text;
                TheRewriter.InsertText(EndLoc, "\n" + Text);
            }
        }
        return r;
    }

    bool FindChangedNonIfStmt(Stmt* stmt, std::pair<unsigned, unsigned> CR) {
        if (!stmt) {
            return false;
        }

        SourceManager &SM = TheRewriter.getSourceMgr();
        for (Stmt *Child : stmt->children()) {
            if (!Child || isa<IfStmt>(Child)) {
                continue;
            }

            std::string FilePath = SM.getFilename(stmt->getBeginLoc()).str();
            if (FilePath == CurrentFilePath) {
                unsigned ChildLine = SM.getSpellingLineNumber(Child->getBeginLoc());
                if (IsChanged(ChildLine, CR)) {
                    return true;
                }
            }

            if (FindChangedNonIfStmt(Child, CR)) {
                return true;
            }
        }

        return false;
    }

    bool VisitIfStmt(IfStmt *ifStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        unsigned Line = SM.getSpellingLineNumber(ifStmt->getBeginLoc());

        std::string FilePath = SM.getFilename(ifStmt->getBeginLoc()).str();
        if (FilePath != CurrentFilePath) {
            return true;
        }

        std::pair<unsigned, unsigned> CR;
        if (IsChanged(Line, CR)) {
            handleIfStmt(ifStmt, CR);
        } else if (FindChangedNonIfStmt(ifStmt, CR)) {
            handleIfStmt(ifStmt, CR, true);
        }
        return true;
    }

    bool VisitReturnStmt(ReturnStmt *returnStmt, bool force = false) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = returnStmt->getBeginLoc();
        if (!force) assert(!StartLoc.isMacroID());
        if (StartLoc.isMacroID()) {
            StartLoc = SM.getExpansionLoc(StartLoc);
        }
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        std::string FilePath = SM.getFilename(StartLoc).str();
        if (FilePath != CurrentFilePath) {
            return true;
        }

        FunctionDecl *FD = findFirstFunctionDeclAncestor(returnStmt);
        if (!FD) {
            return true;
        }

        // 如果FD是lambda表达式
        if (isLambdaFunctionDecl(FD)) {
            handleReturnOrExitStmt(returnStmt, true, false, false, false);
            return true;
        }

        std::string FuncName = getFunctionName(FD);
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        if (isChangedFunction) {
            if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
                llvm::errs() << "(VisitReturnStmt) Handle return statement in other function " << FuncName << "\n";
                handleReturnOrExitStmt(returnStmt, true, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }

            if (Line > EnableLine && Line <= KillStateLine) {
                llvm::errs() << "(VisitReturnStmt) Handle return statement in first function " << FuncName << "\n";
                handleReturnOrExitStmt(returnStmt, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }
        }

        llvm::errs() << "(VisitReturnStmt) Handle return statement in function " << FuncName << "\n";
        handleReturnOrExitStmt(returnStmt, false, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
        return true;
    }

    bool VisitCallExpr(CallExpr *callExpr) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = callExpr->getBeginLoc();
        if (StartLoc.isMacroID())
            StartLoc = SM.getExpansionLoc(StartLoc);
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        std::string FilePath = SM.getFilename(StartLoc).str();
        if (FilePath != CurrentFilePath) {
            return true;
        }

        FunctionDecl *FD = findFirstFunctionDeclAncestor(callExpr);
        if (!FD) {
            return true;
        }

        std::string FuncName = getFunctionName(FD);
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        if (FunctionDecl *Callee = callExpr->getDirectCallee()) {
            std::string FuncName = getFunctionName(Callee);
            if (!(FuncName == "abort" || FuncName == "exit")) {
                return true;
            }
        } else {
            return true;
        }

        if (isChangedFunction) {
            if (Line > EnableLine && Line <= KillStateLine) {
                llvm::errs() << "(VisitCallExpr) Handle call expression in first function " << FuncName << "\n";
                handleReturnOrExitStmt(callExpr, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }
        }

        llvm::errs() << "(VisitCallExpr) Handle call expression in function " << FuncName << "\n";
        handleReturnOrExitStmt(callExpr, false, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
        return true;
    }

    bool VisitGotoStmt(GotoStmt *gotoStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = gotoStmt->getBeginLoc();
        if (StartLoc.isMacroID())
            StartLoc = SM.getExpansionLoc(StartLoc);
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        std::string FilePath = SM.getFilename(StartLoc).str();
        if (FilePath != CurrentFilePath) {
            return true;
        }

        FunctionDecl *FD = findFirstFunctionDeclAncestor(gotoStmt);
        if (!FD) {
            return true;
        }

        std::string FuncName = getFunctionName(FD);
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        if (LabelDecl *LD = gotoStmt->getLabel()) {
            LabelStmt* LS = LD->getStmt();
            auto [SLoc, ELoc] = findSiblingRange(gotoStmt, LS);
            if (SLoc.isValid() && ELoc.isValid()) {
                TheRewriter.InsertTextAfterToken(SLoc, "\n{");
                TheRewriter.InsertText(ELoc, "}\n");
            }
        }

        if (isChangedFunction) {
            if (!(itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff)) {
                if (Line >= EnableLine && Line <= KillStateLine) {
                    if (LabelDecl *LD = gotoStmt->getLabel()) {
                        SourceLocation LabelLoc = LD->getBeginLoc();
                        if (LabelLoc.isMacroID())
                            LabelLoc = SM.getExpansionLoc(LabelLoc);

                        unsigned LabelLine = SM.getSpellingLineNumber(LabelLoc);
                        if (LabelLine < EnableLine || LabelLine > KillStateLine) {
                            llvm::errs() << "(VisitGotoStmt) Handle goto statement in first function " << FuncName << "\n";
                            handleReturnOrExitStmt(gotoStmt, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                            return true;
                        }
                    }
                }
            }
        }

        llvm::errs() << "(VisitGotoStmt) Handle goto statement in function " << FuncName << "\n";
        handleReturnOrExitStmt(gotoStmt, false, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
        return true;
    }

    bool TraverseForStmt(ForStmt *forStmt) {
        if (!forStmt || !forStmt->getBody() || dyn_cast<NullStmt>(forStmt->getBody())) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseForStmt(forStmt);
        }

        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = forStmt->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = SM.getExpansionLoc(StartLoc);
        }
        unsigned StartLine = SM.getSpellingLineNumber(StartLoc);
        SourceLocation EndLoc = forStmt->getEndLoc();
        if (EndLoc.isMacroID()) {
            EndLoc = SM.getExpansionLoc(EndLoc);
        }
        // EndLoc = Lexer::getLocForEndOfToken(EndLoc, 0, SM, LangOptions());
        while (SM.getCharacterData(EndLoc) && (*SM.getCharacterData(EndLoc) != ';' && *SM.getCharacterData(EndLoc) != '}')) {
            EndLoc = EndLoc.getLocWithOffset(1);
        }
        unsigned EndLine = SM.getSpellingLineNumber(EndLoc);

        std::string FilePath = SM.getFilename(StartLoc).str();
        if (FilePath != CurrentFilePath) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseForStmt(forStmt);
        }

        // Judge if the code in the for loop is changed
        if (!IsRangeChanged(StartLine, EndLine) && !IsLoopInUpperSymbolicScope(forStmt, StartLine, EndLine)) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseForStmt(forStmt);
        }

        std::string LoopStartStr = "{struct timespec _loop_start_, _loop_stop_;\n"
            "if (should_symbolize) {\n"
            "   clock_gettime(CLOCK_MONOTONIC, &_loop_start_);\n"
            "}\n";
        std::string LoopEndStr = "if (should_symbolize) {\n"
            "   clock_gettime(CLOCK_MONOTONIC, &_loop_stop_);\n"
            "   long _loop_nanos_ = (_loop_stop_.tv_sec - _loop_start_.tv_sec) * 1000000000 + (_loop_stop_.tv_nsec - _loop_start_.tv_nsec);\n"
            "   loop_usleep_time += _loop_nanos_;\n"
            "}}\n";

        if (IsLoopBoost) {
            checkAndAddBracesForAncestor(forStmt);
            TheRewriter.InsertText(StartLoc, LoopStartStr);
        }

        LoopFlagStack.push_back(forStmt);
        bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseForStmt(forStmt);
        LoopFlagStack.pop_back();

        if (IsLoopBoost) {
            checkAndAddBracesForAncestor(forStmt->getBody());
            TheRewriter.InsertTextAfterToken(EndLoc, LoopEndStr);
        }

        return r;
    }

    bool TraverseWhileStmt(WhileStmt *whileStmt) {
        if (!whileStmt || !whileStmt->getBody() || dyn_cast<NullStmt>(whileStmt->getBody())) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseWhileStmt(whileStmt);
        }

        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = whileStmt->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = SM.getExpansionLoc(StartLoc);
        }
        unsigned StartLine = SM.getSpellingLineNumber(StartLoc);
        SourceLocation EndLoc = whileStmt->getEndLoc();
        if (EndLoc.isMacroID()) {
            EndLoc = SM.getExpansionLoc(EndLoc);
        }
        while (SM.getCharacterData(EndLoc) && (*SM.getCharacterData(EndLoc) != ';' && *SM.getCharacterData(EndLoc) != '}')) {
            EndLoc = EndLoc.getLocWithOffset(1);
        }
        unsigned EndLine = SM.getSpellingLineNumber(EndLoc);

        std::string FilePath = SM.getFilename(StartLoc).str();
        if (FilePath != CurrentFilePath) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseWhileStmt(whileStmt);
        }

        // Judge if the code in the for loop is changed
        if (!IsRangeChanged(StartLine, EndLine) && !IsLoopInUpperSymbolicScope(whileStmt, StartLine, EndLine)) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseWhileStmt(whileStmt);
        }

        std::string LoopStartStr = "{struct timespec _loop_start_, _loop_stop_;\n"
            "if (should_symbolize) {\n"
            "   clock_gettime(CLOCK_MONOTONIC, &_loop_start_);\n"
            "}\n";
        std::string LoopEndStr = "if (should_symbolize) {\n"
            "   clock_gettime(CLOCK_MONOTONIC, &_loop_stop_);\n"
            "   long _loop_nanos_ = (_loop_stop_.tv_sec - _loop_start_.tv_sec) * 1000000000 + (_loop_stop_.tv_nsec - _loop_start_.tv_nsec);\n"
            "   loop_usleep_time += _loop_nanos_;\n"
            "}}\n";

        if (IsLoopBoost) {
            checkAndAddBracesForAncestor(whileStmt);
            TheRewriter.InsertText(StartLoc, LoopStartStr);
        }

        LoopFlagStack.push_back(whileStmt);
        bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseWhileStmt(whileStmt);
        LoopFlagStack.pop_back();

        if (IsLoopBoost) {
            checkAndAddBracesForAncestor(whileStmt->getBody());
            TheRewriter.InsertTextAfterToken(EndLoc, LoopEndStr);
        }

        return r;
    }

    bool TraverseDoStmt(DoStmt *doStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = doStmt->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = SM.getExpansionLoc(StartLoc);
        }
        unsigned StartLine = SM.getSpellingLineNumber(StartLoc);
        SourceLocation EndLoc = doStmt->getBody()->getEndLoc();
        if (EndLoc.isMacroID()) {
            EndLoc = SM.getExpansionLoc(EndLoc);
        }
        unsigned EndLine = SM.getSpellingLineNumber(EndLoc);

        if (SM.getCharacterData(EndLoc)) {
            assert(*SM.getCharacterData(EndLoc) == '}');
        }

        SourceLocation FinalLoc = doStmt->getEndLoc();
        if (FinalLoc.isMacroID()) {
            FinalLoc = SM.getExpansionLoc(FinalLoc);
        }

        while (SM.getCharacterData(FinalLoc) && *SM.getCharacterData(FinalLoc) != ';') {
            FinalLoc = FinalLoc.getLocWithOffset(1);
        }
        unsigned FinalLine = SM.getSpellingLineNumber(FinalLoc);
        
        std::string FilePath = SM.getFilename(StartLoc).str();
        if (FilePath != CurrentFilePath) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseDoStmt(doStmt);
        }
        
        // Judge if the code in the for loop is changed
        if (!IsRangeChanged(StartLine, EndLine) && !IsLoopInUpperSymbolicScope(doStmt, StartLine, EndLine)) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseDoStmt(doStmt);
        }

        std::string LoopStartStr = "{struct timespec _loop_start_, _loop_stop_;\n"
            "if (should_symbolize) {\n"
            "   clock_gettime(CLOCK_MONOTONIC, &_loop_start_);\n"
            "}\n";
        std::string LoopEndStr = "if (should_symbolize) {\n"
            "   clock_gettime(CLOCK_MONOTONIC, &_loop_stop_);\n"
            "   long _loop_nanos_ = (_loop_stop_.tv_sec - _loop_start_.tv_sec) * 1000000000 + (_loop_stop_.tv_nsec - _loop_start_.tv_nsec);\n"
            "   loop_usleep_time += _loop_nanos_;\n"
            "}}\n";

        if (IsLoopBoost) {
            checkAndAddBracesForAncestor(doStmt);
            TheRewriter.InsertText(StartLoc, LoopStartStr);
            TheRewriter.InsertTextAfterToken(FinalLoc, LoopEndStr);
        }

        LoopFlagStack.push_back(doStmt);
        bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseDoStmt(doStmt);
        LoopFlagStack.pop_back();

        return r;
    }

    bool VisitContinueStmt(ContinueStmt *continueStmt) {
        llvm::errs() << "VisitContinueStmt!!!!!!!!!!!!\n";

        if (LoopFlagStack.empty()) {
            return true;
        }

        std::string FilePath = TheRewriter.getSourceMgr().getFilename(continueStmt->getBeginLoc()).str();
        if (FilePath != CurrentFilePath) {
            return true;
        }

        Stmt* LoopAncestor = LoopFlagStack.back();
        auto itr = LoopRestoreInfos.find(LoopAncestor);
        if (itr == LoopRestoreInfos.end()) {
            return true;
        }

        checkAndAddBracesForAncestor(continueStmt);
        auto& RestoreInfo = itr->second;
        for (const auto &RI : RestoreInfo) {
            std::string RestoreCall = getRestoreCall(RI.VarName, RI.FlagVarName, RI.RestoreVarName);
            llvm::errs() << "(symbolicMemberExpr) Insert at ";
            continueStmt->getBeginLoc().dump(TheRewriter.getSourceMgr());
            llvm::errs() << RestoreCall << "\n";
            TheRewriter.InsertText(continueStmt->getBeginLoc(), RestoreCall);
        }

        return true;
    }

    SourceLocation findCaseOrSwitchEnd(CaseStmt *caseStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        const Stmt *Parent = Context.getParents(*caseStmt)[0].get<Stmt>();
    
        if (!Parent) {
            return caseStmt->getEndLoc(); // 如果没有父节点，返回当前 `case` 的结束位置
        }
    
        if (const CompoundStmt *CS = dyn_cast<CompoundStmt>(Parent)) {
            // 遍历父复合语句的子语句，找到当前 `case` 的下一个语句
            bool foundCurrentCase = false;
            for (const Stmt *Child : CS->body()) {
                if (foundCurrentCase) {
                    // 如果找到下一个语句是 `case` 或 `default`，返回它的开始位置
                    if (isa<CaseStmt>(Child) || isa<DefaultStmt>(Child)) {
                        return Child->getBeginLoc();
                    }
                }
    
                if (Child == caseStmt) {
                    foundCurrentCase = true;
                }
            }
    
            // 如果没有找到下一个 `case` 或 `default`，返回复合语句的结束位置
            return CS->getRBracLoc();
        }
    
        return caseStmt->getEndLoc(); // 默认返回当前 `case` 的结束位置
    }

    bool TraverseCaseStmt(CaseStmt *caseStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();

        // 确保当前 `caseStmt` 的父语句不是另一个 `CaseStmt`
        const Stmt *Parent = Context.getParents(*caseStmt)[0].get<Stmt>();
        if (Parent && isa<CaseStmt>(Parent)) {
            return RecursiveASTVisitor<RealExecutionVisitor>::TraverseCaseStmt(caseStmt);
        }

        // 找到最后一个子语句是 `CaseStmt` 的情况
        CaseStmt *LastCaseStmt = caseStmt;
        while (isa<CaseStmt>(LastCaseStmt->getSubStmt())) {
            LastCaseStmt = cast<CaseStmt>(LastCaseStmt->getSubStmt());
        }

        // 如果 `case` 语句的子语句不是块作用域，则添加块作用域
        Stmt *SubStmt = LastCaseStmt->getSubStmt();
        if (!isa<CompoundStmt>(SubStmt)) {
            SourceLocation SubStmtStartLoc = SubStmt->getBeginLoc();
            if (SubStmtStartLoc.isMacroID()) {
                SubStmtStartLoc = SM.getExpansionLoc(SubStmtStartLoc);
            }
            SourceLocation SubStmtEndLoc = findCaseOrSwitchEnd(caseStmt);
            if (SubStmtEndLoc.isMacroID()) {
                SubStmtEndLoc = SM.getExpansionLoc(SubStmtEndLoc);
            }
    
            // 在 `case` 子语句的开始和结束位置插入 `{` 和 `}`
            TheRewriter.InsertText(SubStmtStartLoc, "{\n", true, true);
            bool r = RecursiveASTVisitor<RealExecutionVisitor>::TraverseCaseStmt(caseStmt);
            TheRewriter.InsertText(SubStmtEndLoc, "\n}");

            return r;
        }

        return RecursiveASTVisitor<RealExecutionVisitor>::TraverseCaseStmt(caseStmt);
    }

    bool TraverseStmt(Stmt *stmt) {
        if (!stmt) {
            return true;
        }

        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = stmt->getBeginLoc();
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        if (StartLoc.isMacroID()) {
            // 获取这个宏的名字
            std::string MacroName = Lexer::getImmediateMacroName(StartLoc, SM, Context.getLangOpts()).str();
            if (MacroName == "DBUG_RETURN" || MacroName == "DBUG_VOID_RETURN") {
                llvm::errs() << "(VisitStmt) Handle DBUG_RETURN statement\n";
                VisitReturnStmt(cast<ReturnStmt>(stmt), true);
                return true;
            }

            return true;
        }

    //     std::pair<unsigned, unsigned> CR;
    //     if (IsChanged(Line, CR)) {
    //         if (!isa<IfStmt>(stmt)) {
    //             // Find the first if ancestor of the current statement
    //             clang::Stmt *Ancestor = findFirstIfAncestor(stmt);
    //             if (Ancestor) {
    //                 handleOuterIfStmt(cast<IfStmt>(Ancestor), CR, true);
    //             }
    //         }
    //     }
        return RecursiveASTVisitor<RealExecutionVisitor>::TraverseStmt(stmt);
    }

    // bool VisitParenExpr(ParenExpr *parenExpr) {
    //     SourceManager &SM = TheRewriter.getSourceMgr();
    //     SourceLocation StartLoc = parenExpr->getBeginLoc();
    //     if (SM.isMacroBodyExpansion(StartLoc)) {
    //         llvm::StringRef MacroName = Lexer::getImmediateMacroName(StartLoc, SM, LangOptions());
    //         if (MacroName == "assert") {
    //             handleAssertMacro(parenExpr);
    //         }
    //     }
    //     return true;
    // }

private:
    std::string getFunctionName(FunctionDecl* f) {
        if (isLambdaFunctionDecl(f)) {
            return std::to_string(f->getBeginLoc().getRawEncoding()) + "_" + std::to_string(f->getID());
        }

        std::string MangledName;
        std::unique_ptr<MangleContext> MC(Context.createMangleContext());
        if (MC->shouldMangleDeclName(f)) {
            llvm::raw_string_ostream MangledNameStream(MangledName);
            if (CXXDestructorDecl *DD = dyn_cast<CXXDestructorDecl>(f)) {
                MC->mangleCXXName({DD, CXXDtorType::Dtor_Complete}, MangledNameStream);
            } else {
                MC->mangleCXXName(f, MangledNameStream);
            }
        } else {
            MangledName = f->getNameInfo().getName().getAsString();
        }

        return MangledName;
    }

    QualType getNonConstType(QualType QT) {
        if (QT.isConstQualified()) {
            return QT.getNonReferenceType().getUnqualifiedType();
        }
        return QT;
    }

    bool isMainFunction(Stmt *stmt) {
        FunctionDecl *FD = findFirstFunctionDeclAncestor(stmt);
        std::string FuncName = getFunctionName(FD);

        auto itr = FuncChangeInfo.find(FuncName);
        if (itr == FuncChangeInfo.end())
            return false;

        return !(itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff);
    }

    bool isInSymbolicScope(Stmt *stmt, unsigned StartLine, unsigned EndLine) {
        FunctionDecl *FD = findFirstFunctionDeclAncestor(stmt);
        std::string FuncName = getFunctionName(FD);

        auto itr = FuncChangeInfo.find(FuncName);
        if (itr == FuncChangeInfo.end())
            return false;

        if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
            return true;
        }

        if (StartLine >= EnableLine && EndLine <= DisableLine) {
            return true;
        }

        return false;
    }

    std::string getSymbolicCall(QualType QT, FunctionDecl* FD, std::string TmpVarName, std::string TmpVarNameStr, std::string FlagVarName, std::string TmpVarAssignmentExpr) {
        std::string SymbolicCall = "if (should_symbolize && s2e_flag != S2E_DISABLED";

        if (FlagVarName != "")
            SymbolicCall += " && !" + FlagVarName;

        SymbolicCall += ") {\n";

        if (TmpVarAssignmentExpr != "")
            SymbolicCall += "    " + TmpVarAssignmentExpr;
        
        auto it = SymbolicVarValueMap.find(TmpVarNameStr);
        if (it != SymbolicVarValueMap.end()) {
            if (!QT->isPointerType()) {
                std::string TmpVarName2 = TmpVarName;
                if (TmpVarName2[0] == '(' && TmpVarName2[TmpVarName2.size() - 1] == ')') {
                    TmpVarName2 = TmpVarName2.substr(1, TmpVarName2.size() - 2);
                }
                if (endWith(CurrentFilePath, ".c")) {
                    SymbolicCall += "    " + TmpVarName + " = (" + getNonConstType(QT).getAsString() + ")" + std::to_string(it->second) + ";\n";
                } else {
                    SymbolicCall += "    " + TmpVarName + " = static_cast<decltype(" + TmpVarName2 + ")>(" + std::to_string(it->second) + ");\n";
                }
            } else {
                if (it->second == 0)
                    SymbolicCall += "    " + TmpVarName + " = nullptr;\n";
            }
        }

        if (FlagVarName != "")
            SymbolicCall += "    " + FlagVarName + " = 1;\n";

        SymbolicCall += "    s2e_flag = S2E_SYMBOLICED;\n"
                        "}\n";
        return SymbolicCall;
    }

    std::string getRestoreCall(std::string VarName, std::string FlagVarName, std::string RestoreVarName) {
        std::string RestoreCall = "if (should_symbolize && s2e_flag != S2E_DISABLED";

        if (FlagVarName != "")
            RestoreCall += " && " + FlagVarName + " == 1";

        RestoreCall += ") {\n";

        if (RestoreVarName != "") {
            std::string VarName2 = VarName;
            if (VarName2[0] == '(' && VarName2[VarName2.size() - 1] == ')') {
                VarName2 = VarName2.substr(1, VarName2.size() - 2);
            }
            if (endWith(CurrentFilePath, ".c")) {
                RestoreCall += "    " + VarName + " = " + RestoreVarName + ";\n";
            } else {
                RestoreCall += "    " + VarName + " = std::any_cast<decltype("+ VarName +")>(" + RestoreVarName + ");\n";
            }
        }

        if (FlagVarName != "")
            RestoreCall += "    " + FlagVarName + " = 2;\n";
        
        RestoreCall += "}\n";

        return RestoreCall;
    }

    bool IsChanged(unsigned Line, std::pair<unsigned, unsigned>& CR) {
        for (const auto &FuncChangeInfo : FuncChangeInfo) {
            for (const auto &ChangeRange : FuncChangeInfo.second.ChangeRanges) {
                if (Line >= ChangeRange.first && Line <= ChangeRange.second) {
                    CR = ChangeRange;
                    return true;
                }
            }
        }
        return false;
    }

    // Judge the [StartLine, EndLine] has intersection with the change ranges of the function
    bool IsRangeChanged(unsigned StartLine, unsigned EndLine) {
        for (const auto &FuncChangeInfo : FuncChangeInfo) {
            for (const auto &ChangeRange : FuncChangeInfo.second.ChangeRanges) {
                if (StartLine <= ChangeRange.second && EndLine >= ChangeRange.first) {
                    return true;
                }
            }
        }
        return false;
    }

    // If the loop is in the upper symbolic function, not been modified, but the callee function in the loop is modified
    bool IsLoopInUpperSymbolicScope(Stmt *stmt, unsigned StartLine, unsigned EndLine) {
        FunctionDecl *FD = findFirstFunctionDeclAncestor(stmt);
        if (!FD) {
            return false;
        }

        std::string FuncName = getFunctionName(FD);
        auto itr = FuncChangeInfo.find(FuncName);
        if (itr == FuncChangeInfo.end()) {
            return false;
        }

        if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
            return false;
        }

        if (StartLine >= EnableLine && EndLine <= DisableLine) {
            return true;
        }

        return false;
    }

    Stmt* findFirstIfAncestor(Stmt *stmt) {
        // llvm::errs() << "Find first if ancestor of the current statement: ";
        // stmt->getBeginLoc().dump(TheRewriter.getSourceMgr());
        // stmt->dumpColor();

        auto NodeList = Context.getParents(*stmt);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            // ParentNode.dump(llvm::outs(), Context);
            // llvm::outs() << "\n";

            // Is the parent an IfStmt?
            if (const IfStmt *Parent = ParentNode.get<IfStmt>()) {
                // llvm::errs() << "Parent is an IfStmt\n";
                return const_cast<IfStmt *>(Parent);
            }

            // Is the parent a FunctionDecl?
            if (ParentNode.get<FunctionDecl>()) {
                // llvm::errs() << "Parent is a FunctionDecl!!!\n";
                return nullptr;
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        // llvm::errs() << "No if ancestor found\n";
        return nullptr;
    }

    const Decl* findOutermostAncestor(FunctionDecl* funcDecl) {
        const Decl* Ancestor = funcDecl;
        auto NodeList = Context.getParents(*funcDecl);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            if (ParentNode.get<TranslationUnitDecl>()) {
                return Ancestor;
            }

            // Keep going up.
            Ancestor = ParentNode.get<Decl>();
            NodeList = Context.getParents(ParentNode);
        }

        return Ancestor;
    }

    Stmt* findOutermostLoopAncestorForVarDecl(VarDecl *varDecl) {
        Stmt* LoopAncestor = nullptr;
        auto NodeList = Context.getParents(*varDecl);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            // Is the parent a ForStmt?
            if (const ForStmt *Parent = ParentNode.get<ForStmt>()) {
                // llvm::errs() << "Parent is a ForStmt\n";
                LoopAncestor = const_cast<ForStmt *>(Parent);
            }

            // Is the parent a WhileStmt?
            if (const WhileStmt *Parent = ParentNode.get<WhileStmt>()) {
                // llvm::errs() << "Parent is a WhileStmt\n";
                LoopAncestor = const_cast<WhileStmt *>(Parent);
            }

            // Is the parent a DoStmt?
            if (const DoStmt *Parent = ParentNode.get<DoStmt>()) {
                // llvm::errs() << "Parent is a DoStmt\n";
                LoopAncestor = const_cast<DoStmt *>(Parent);
            }

            // Is the parent a FunctionDecl?
            if (ParentNode.get<FunctionDecl>()) {
                // llvm::errs() << "Parent is a FunctionDecl!!!\n";
                return LoopAncestor;
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        // llvm::errs() << "No loop ancestor found\n";
        return LoopAncestor;
    }

    Stmt* findOutermostLoopAncestor(Stmt *stmt) {
        Stmt* LoopAncestor = nullptr;
        auto NodeList = Context.getParents(*stmt);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            // Is the parent a ForStmt?
            if (const ForStmt *Parent = ParentNode.get<ForStmt>()) {
                // llvm::errs() << "Parent is a ForStmt\n";
                LoopAncestor = const_cast<ForStmt *>(Parent);
            }

            // Is the parent a WhileStmt?
            if (const WhileStmt *Parent = ParentNode.get<WhileStmt>()) {
                // llvm::errs() << "Parent is a WhileStmt\n";
                LoopAncestor = const_cast<WhileStmt *>(Parent);
            }

            // Is the parent a DoStmt?
            if (const DoStmt *Parent = ParentNode.get<DoStmt>()) {
                // llvm::errs() << "Parent is a DoStmt\n";
                LoopAncestor = const_cast<DoStmt *>(Parent);
            }

            // Is the parent a FunctionDecl?
            if (ParentNode.get<FunctionDecl>()) {
                // llvm::errs() << "Parent is a FunctionDecl!!!\n";
                return LoopAncestor;
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        // llvm::errs() << "No loop ancestor found\n";
        return LoopAncestor;
    }

    ForStmt* findFirstForAncestor(Stmt *stmt) {
        // llvm::errs() << "Find first for ancestor of the current statement: ";
        // stmt->getBeginLoc().dump(TheRewriter.getSourceMgr());
        // stmt->dumpColor();

        auto NodeList = Context.getParents(*stmt);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            // ParentNode.dump(llvm::outs(), Context);
            // llvm::outs() << "\n";

            // Is the parent a ForStmt?
            if (const ForStmt *Parent = ParentNode.get<ForStmt>()) {
                // llvm::errs() << "Parent is a ForStmt\n";
                return const_cast<ForStmt *>(Parent);
            }

            // Is the parent a FunctionDecl?
            if (ParentNode.get<FunctionDecl>()) {
                // llvm::errs() << "Parent is a FunctionDecl!!!\n";
                return nullptr;
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        // llvm::errs() << "No for ancestor found\n";
        return nullptr;
    }

    FunctionDecl* findFirstFunctionDeclAncestor(Stmt *stmt) {
        // llvm::errs() << "Find first function decl ancestor of the current statement\n";
        // stmt->dumpColor();

        auto NodeList = Context.getParents(*stmt);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            // ParentNode.dump(llvm::outs(), Context);
            // llvm::outs() << "\n";

            // Is the parent a FunctionDecl?
            if (const FunctionDecl *Parent = ParentNode.get<FunctionDecl>()) {
                // llvm::errs() << "Parent is a FunctionDecl\n";
                return const_cast<FunctionDecl *>(Parent);
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        // llvm::errs() << "No function decl ancestor found\n";
        return nullptr;
    }

    FunctionDecl* findFirstFunctionDeclAncestor(VarDecl *varDecl) {
        // llvm::errs() << "Find first function decl ancestor of the current variable declaration\n";
        // varDecl->dumpColor();

        auto NodeList = Context.getParents(*varDecl);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            // ParentNode.dump(llvm::outs(), Context);
            // llvm::outs() << "\n";

            // Is the parent a FunctionDecl?
            if (const FunctionDecl *Parent = ParentNode.get<FunctionDecl>()) {
                // llvm::errs() << "Parent is a FunctionDecl\n";
                return const_cast<FunctionDecl *>(Parent);
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        // llvm::errs() << "No function decl ancestor found\n";
        return nullptr;
    }

    bool containsStmt(const Stmt *Parent, const Stmt *Target) {
        if (!Parent) return false;
        if (Parent == Target) return true;
        for (const Stmt *SubStmt : Parent->children()) {
            if (containsStmt(SubStmt, Target)) return true;
        }
        return false;
    };

    std::pair<SourceLocation, SourceLocation> findSiblingRange(Stmt *Stmt1, Stmt *Stmt2) {
        // 向上查找共同祖先
        auto getCommonAncestor = [&](Stmt *S1, Stmt *S2) -> const Stmt* {
            std::unordered_set<const Stmt*> Ancestors1;
            const Stmt *Current = S1;

            // 收集第一个 Stmt 的所有祖先
            while (Current) {
                Ancestors1.insert(Current);
                auto Parents = Context.getParents(*Current);
                if (Parents.empty() || Parents[0].get<FunctionDecl>()) break;
                Current = Parents[0].get<Stmt>();
            }

            // 查找第二个 Stmt 的祖先是否在第一个 Stmt 的祖先集合中
            Current = S2;
            while (Current) {
                if (Ancestors1.count(Current)) {
                    return Current; // 找到共同祖先
                }
                auto Parents = Context.getParents(*Current);
                if (Parents.empty() || Parents[0].get<FunctionDecl>()) break;
                Current = Parents[0].get<Stmt>();
            }

            return nullptr; // 未找到共同祖先
        };

        const Stmt *CommonAncestor = getCommonAncestor(Stmt1, Stmt2);
        if (!CommonAncestor) {
            llvm::errs() << "No common ancestor found.\n";
            return {SourceLocation(), SourceLocation()};
        }

        // 遍历共同祖先的子节点，找到包含 Stmt1 和 Stmt2 的子节点
        const Stmt *Child1 = nullptr, *Child2 = nullptr;
        for (const Stmt *Child : CommonAncestor->children()) {
            if (!Child) continue;

            if (containsStmt(Child, Stmt1)) {
                Child1 = Child;
            } else if (containsStmt(Child, Stmt2)) {
                Child2 = Child;
            }

            if (Child1 && Child2) break;
        }

        if (!Child1 || !Child2) {
            llvm::errs() << "Failed to find sibling nodes.\n";
            return {SourceLocation(), SourceLocation()};
        }

        // 获取 Child1 的结束位置和 Child2 的起始位置
        SourceManager &SM = Context.getSourceManager();
        SourceLocation EndLoc1 = Child1->getEndLoc();
        SourceLocation BeginLoc2 = Child2->getBeginLoc();

        // 确保位置展开宏
        if (EndLoc1.isMacroID()) {
            EndLoc1 = SM.getExpansionLoc(EndLoc1);
        }
        while (SM.getCharacterData(EndLoc1) && (*SM.getCharacterData(EndLoc1) != ';' && *SM.getCharacterData(EndLoc1) != '}')) {
            EndLoc1 = EndLoc1.getLocWithOffset(1);
        }
        if (BeginLoc2.isMacroID()) {
            BeginLoc2 = SM.getExpansionLoc(BeginLoc2);
        }

        return {EndLoc1, BeginLoc2};
    }

    void insertCodeAtFunctionBody(Stmt *FuncBody, unsigned StartLine, unsigned EndLine, bool IsVoid) {
        std::vector<std::pair<SourceLocation, SourceLocation>> ChildrenRanges;
        std::vector<std::pair<std::string, std::string>> ChildrenRangesStr;
        SourceManager &SM = TheRewriter.getSourceMgr();
        // FuncBody->dumpColor();

        KillStateLoc = FuncBody->getEndLoc();
        if (KillStateLoc.isMacroID()) {
            KillStateLoc = SM.getExpansionLoc(KillStateLoc);
        }
        while (SM.getCharacterData(KillStateLoc) && *SM.getCharacterData(KillStateLoc) != '}') {
            KillStateLoc = KillStateLoc.getLocWithOffset(1);
        }
        KillStateLine = SM.getSpellingLineNumber(KillStateLoc);

        for (Stmt *Child : FuncBody->children()) {
            SourceLocation StartLoc = Child->getBeginLoc();
            if (StartLoc.isMacroID()) {
                StartLoc = SM.getExpansionLoc(StartLoc);
            }

            SourceLocation EndLoc = Child->getEndLoc();
            if (EndLoc.isMacroID()) {
                EndLoc = SM.getExpansionLoc(EndLoc);
            }
            while (SM.getCharacterData(EndLoc) && *SM.getCharacterData(EndLoc) != ';' && *SM.getCharacterData(EndLoc) != '}') {
                EndLoc = EndLoc.getLocWithOffset(1);
            }
            ChildrenRanges.push_back(std::make_pair(StartLoc, EndLoc));
            ChildrenRangesStr.push_back(std::make_pair(StartLoc.printToString(SM), EndLoc.printToString(SM)));
        }

        SourceLocation FuncStartLoc = ChildrenRanges.begin()->first;
        SourceLocation FuncEndLoc = ChildrenRanges.rbegin()->second;
        unsigned FuncStartLine = TheRewriter.getSourceMgr().getSpellingLineNumber(FuncStartLoc);
        unsigned FuncEndLine = TheRewriter.getSourceMgr().getSpellingLineNumber(FuncEndLoc);

        if (StartLine > FuncEndLine || EndLine < FuncStartLine) {
            return;
        }

        if (StartLine > FuncStartLine) {
            for (auto ritr = ChildrenRanges.rbegin(); ritr != ChildrenRanges.rend(); ++ritr) {
                SourceLocation StartLoc = ritr->first;
                SourceLocation EndLoc = ritr->second;
                unsigned ChildStartLine = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);
                unsigned ChildEndLine = TheRewriter.getSourceMgr().getSpellingLineNumber(EndLoc);
                if (ChildStartLine <= StartLine && ChildEndLine >= StartLine) {
                    FuncStartLoc = StartLoc;
                    break;
                }
                if (ChildEndLine < StartLine) {
                    FuncStartLoc = EndLoc.getLocWithOffset(2);
                    break;
                }
            }
        }

        if (EndLine < FuncEndLine) {
            SourceManager &SM = TheRewriter.getSourceMgr();
            for (auto itr = ChildrenRanges.begin(); itr != ChildrenRanges.end(); ++itr) {
                SourceLocation StartLoc = itr->first;
                SourceLocation EndLoc = itr->second;
                unsigned ChildStartLine = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);
                unsigned ChildEndLine = TheRewriter.getSourceMgr().getSpellingLineNumber(EndLoc);
                if (ChildStartLine <= EndLine && ChildEndLine >= EndLine) {
                    FuncEndLoc = Lexer::getLocForEndOfToken(EndLoc, 0, SM, Context.getLangOpts());
                    break;
                }
                if (ChildStartLine > EndLine) {
                    FuncEndLoc = StartLoc.getLocWithOffset(-1);
                    break;
                }
            }
        }

        llvm::errs() << "FuncStartLine: ";
        FuncStartLoc.dump(TheRewriter.getSourceMgr());
        llvm::errs() << "FuncEndLine: ";
        FuncEndLoc.dump(TheRewriter.getSourceMgr());

        NoNeedToInsertEnd = !IsVoid && 
            TheRewriter.getSourceMgr().getSpellingLineNumber(KillStateLoc) >= 
            TheRewriter.getSourceMgr().getSpellingLineNumber(ChildrenRanges.rbegin()->second);

        FuncStartLine = TheRewriter.getSourceMgr().getSpellingLineNumber(FuncStartLoc);
        FuncEndLine = TheRewriter.getSourceMgr().getSpellingLineNumber(FuncEndLoc);

        EnableLoc = FuncStartLoc;
        DisableLoc = FuncEndLoc;

        EnableLine = FuncStartLine;
        DisableLine = FuncEndLine;
    }

    // 判断变量定义 VD 是否在 for 语句的初始化部分
    ForStmt* isVarDeclInForInit(VarDecl *VD) {
        ForStmt *FS = nullptr;
        
        auto NodeList = Context.getParents(*VD);
        while (!NodeList.empty()) {
            auto ParentNode = NodeList[0];

            if (const ForStmt *Parent = ParentNode.get<ForStmt>()) {
                FS = const_cast<ForStmt *>(Parent);
                break;
            }

            if (ParentNode.get<FunctionDecl>()) {
                return nullptr;
            }

            NodeList = Context.getParents(ParentNode);
        }

        if (!FS->getInit()) {
            return nullptr;
        }

        if (DeclStmt *DS = dyn_cast<DeclStmt>(FS->getInit())) {
            for (auto DI = DS->decl_begin(); DI != DS->decl_end(); ++DI) {
                if (VarDecl *VDInFor = dyn_cast<VarDecl>(*DI)) {
                    if (VDInFor == VD) {
                        return FS;
                    }
                }
            }
        }

        return nullptr;
    }

    // 判断变量定义 VD 是否在 for 语句的初始化部分
    bool isVarDeclInForInit(VarDecl *VD, ForStmt *FS) {
        if (!FS->getInit()) {
            return false;
        }

        if (DeclStmt *DS = dyn_cast<DeclStmt>(FS->getInit())) {
            for (auto DI = DS->decl_begin(); DI != DS->decl_end(); ++DI) {
                if (VarDecl *VDInFor = dyn_cast<VarDecl>(*DI)) {
                    if (VDInFor == VD) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    SourceLocation findVarDestructionLoc(VarDecl* VD) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation VarDeclLoc = VD->getLocation();
        if (VarDeclLoc.isMacroID())
            VarDeclLoc = SM.getExpansionLoc(VarDeclLoc);

        auto NodeList = Context.getParents(*VD);
        while (!NodeList.empty()) {
            auto ParentNode = NodeList[0];

            if (const CompoundStmt *Parent = ParentNode.get<CompoundStmt>()) {
                SourceLocation ParentEndLoc = Parent->getEndLoc();
                if (ParentEndLoc.isMacroID())
                    ParentEndLoc = SM.getExpansionLoc(ParentEndLoc);
                while (SM.getCharacterData(ParentEndLoc) && *SM.getCharacterData(ParentEndLoc) != '}')
                    ParentEndLoc = ParentEndLoc.getLocWithOffset(1);
                return ParentEndLoc;
            }

            if (const IfStmt* Parent = ParentNode.get<IfStmt>()) {
                SourceLocation IfEndLoc = Parent->getEndLoc();
                if (IfEndLoc.isMacroID())
                    IfEndLoc = SM.getExpansionLoc(IfEndLoc);
                while (SM.getCharacterData(IfEndLoc) && *SM.getCharacterData(IfEndLoc) != ';')
                    IfEndLoc = IfEndLoc.getLocWithOffset(1);
                return IfEndLoc;
            }

            if (const ForStmt *Parent = ParentNode.get<ForStmt>()) {
                SourceLocation ForEndLoc = Parent->getEndLoc();
                if (ForEndLoc.isMacroID())
                    ForEndLoc = SM.getExpansionLoc(ForEndLoc);
                while (SM.getCharacterData(ForEndLoc) && (*SM.getCharacterData(ForEndLoc) != ';' && *SM.getCharacterData(ForEndLoc) != '}'))
                    ForEndLoc = ForEndLoc.getLocWithOffset(1);
                return ForEndLoc;
            }

            if (const WhileStmt *Parent = ParentNode.get<WhileStmt>()) {
                SourceLocation WhileEndLoc = Parent->getEndLoc();
                if (WhileEndLoc.isMacroID())
                    WhileEndLoc = SM.getExpansionLoc(WhileEndLoc);
                while (SM.getCharacterData(WhileEndLoc) && *SM.getCharacterData(WhileEndLoc) != ';')
                    WhileEndLoc = WhileEndLoc.getLocWithOffset(1);
                return WhileEndLoc;
            }

            if (const DoStmt *Parent = ParentNode.get<DoStmt>()) {
                SourceLocation DoEndLoc = Parent->getEndLoc();
                if (DoEndLoc.isMacroID())
                    DoEndLoc = SM.getExpansionLoc(DoEndLoc);
                while (SM.getCharacterData(DoEndLoc) && *SM.getCharacterData(DoEndLoc) != ';')
                    DoEndLoc = DoEndLoc.getLocWithOffset(1);
                return DoEndLoc;
            }

            if (const SwitchStmt *Parent = ParentNode.get<SwitchStmt>()) {
                SourceLocation SwitchEndLoc = Parent->getEndLoc();
                if (SwitchEndLoc.isMacroID())
                    SwitchEndLoc = SM.getExpansionLoc(SwitchEndLoc);
                while (SM.getCharacterData(SwitchEndLoc) && *SM.getCharacterData(SwitchEndLoc) != '}')
                    SwitchEndLoc = SwitchEndLoc.getLocWithOffset(1);
                return SwitchEndLoc;
            }

            if (const CaseStmt *Parent = ParentNode.get<CaseStmt>()) {
                SourceLocation CaseEndLoc = Parent->getEndLoc();
                if (CaseEndLoc.isMacroID())
                    CaseEndLoc = SM.getExpansionLoc(CaseEndLoc);
                while (SM.getCharacterData(CaseEndLoc) && *SM.getCharacterData(CaseEndLoc) != ':')
                    CaseEndLoc = CaseEndLoc.getLocWithOffset(1);
                return CaseEndLoc;
            }

            if (const DefaultStmt *Parent = ParentNode.get<DefaultStmt>()) {
                SourceLocation DefaultEndLoc = Parent->getEndLoc();
                if (DefaultEndLoc.isMacroID())
                    DefaultEndLoc = SM.getExpansionLoc(DefaultEndLoc);
                while (SM.getCharacterData(DefaultEndLoc) && *SM.getCharacterData(DefaultEndLoc) != ':')
                    DefaultEndLoc = DefaultEndLoc.getLocWithOffset(1);
                return DefaultEndLoc;
            }

            if (const FunctionDecl *Parent = ParentNode.get<FunctionDecl>()) {
                SourceLocation FuncEndLoc = Parent->getEndLoc();
                if (FuncEndLoc.isMacroID())
                    FuncEndLoc = SM.getExpansionLoc(FuncEndLoc);
                while (SM.getCharacterData(FuncEndLoc) && *SM.getCharacterData(FuncEndLoc) != '}')
                    FuncEndLoc = FuncEndLoc.getLocWithOffset(1);
                return FuncEndLoc;
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        return SourceLocation();
    }

    Stmt* findVarDestructionLocStmt(VarDecl* VD) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation VarDeclLoc = VD->getLocation();
        if (VarDeclLoc.isMacroID())
            VarDeclLoc = SM.getExpansionLoc(VarDeclLoc);

        auto NodeList = Context.getParents(*VD);
        while (!NodeList.empty()) {
            auto ParentNode = NodeList[0];

            if (const CompoundStmt *Parent = ParentNode.get<CompoundStmt>()) {
                return const_cast<CompoundStmt *>(Parent);
            }

            if (const IfStmt* Parent = ParentNode.get<IfStmt>()) {
                return const_cast<IfStmt *>(Parent);
            }

            if (const ForStmt *Parent = ParentNode.get<ForStmt>()) {
                return const_cast<ForStmt *>(Parent);
            }

            if (const WhileStmt *Parent = ParentNode.get<WhileStmt>()) {
                return const_cast<WhileStmt *>(Parent);
            }

            if (const DoStmt *Parent = ParentNode.get<DoStmt>()) {
                return const_cast<DoStmt *>(Parent);
            }

            if (const SwitchStmt *Parent = ParentNode.get<SwitchStmt>()) {
                return const_cast<SwitchStmt *>(Parent);
            }

            if (const CaseStmt *Parent = ParentNode.get<CaseStmt>()) {
                return const_cast<CaseStmt *>(Parent);
            }

            if (const DefaultStmt *Parent = ParentNode.get<DefaultStmt>()) {
                return const_cast<DefaultStmt *>(Parent);
            }

            if (const FunctionDecl *Parent = ParentNode.get<FunctionDecl>()) {
                return nullptr;
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }

        return nullptr;
    }

    void symbolicVarDecl(IfStmt* ifStmt, DeclRefExpr* DeclRef, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        VarDecl *VD = dyn_cast<VarDecl>(DeclRef->getDecl());
        if (!VD)  return;

        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation VarDeclLoc = VD->getLocation();
        if (VarDeclLoc.isMacroID())
            VarDeclLoc = SM.getExpansionLoc(VarDeclLoc);

        SourceLocation IfStartLoc = ifStmt->getBeginLoc();
        if (IfStartLoc.isMacroID())
            IfStartLoc = SM.getExpansionLoc(IfStartLoc);

        std::string VarName = VD->getNameAsString();
        std::string RestoreVarName = "tmp_" + VarName + "_restore_" + std::to_string(VarDeclLoc.getRawEncoding());
        std::string FlagVarName = "tmp_" + VarName + "_flag_" + std::to_string(VarDeclLoc.getRawEncoding());

        std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
        auto it = SymbolicVarValueMap.find(VarNameStr);
        if (it != SymbolicVarValueMap.end()) {
            // 变量可能是 const 类型或 const & 类型
            QualType Type = VD->getType();
            if ((Type.isConstQualified()) || (Type->isReferenceType() && Type.getNonReferenceType().isConstQualified())) {
                if (Type->isReferenceType()) {
                    Type = Type.getNonReferenceType();
                }
                Type = getNonConstType(Type);
                std::string TmpVarName = "tmp_" + VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
                std::string TmpVarAssignmentExpr = "auto " + TmpVarName + " = " + VarName + ";\n";
                std::string FlagVarName = "tmp_" + VarName + "_flag_" + std::to_string(IfStartLoc.getRawEncoding());
                FunctionDecl* FD = findFirstFunctionDeclAncestor(ifStmt);
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    std::string FlagVarDecl = "";
                    if (VD->isFileVarDecl()) {
                        FlagVarDecl = "static ";
                    }
                    FlagVarDecl = "int " + FlagVarName + " = 0;";
                    Stmt* Loop = nullptr;
                    if ((VD->isStaticLocal() || VD->isLocalVarDecl())) {
                        Loop = findOutermostLoopAncestorForVarDecl(VD);
                    }
                    if (!Loop) {
                        if (VD->isLocalVarDeclOrParm() && !VD->isStaticLocal()) {
                            SourceLocation FunctionBeginLoc = findFirstFunctionDeclAncestor(ifStmt)->getBody()->child_begin()->getBeginLoc();
                            if (FunctionBeginLoc.isMacroID())
                                FunctionBeginLoc = SM.getExpansionLoc(FunctionBeginLoc);
                            llvm::errs() << "(symbolicVarDecl) Insert at ";
                            FunctionBeginLoc.dump(SM);
                            llvm::errs() << FlagVarDecl << "\n";
                            if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                                && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                                    TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                            } else {
                                TheRewriter.InsertText(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                            }
                        } else {
                            SourceLocation FunctionBeginLoc = FD->getBody()->child_begin()->getBeginLoc();
                            if (FunctionBeginLoc.isMacroID())
                                FunctionBeginLoc = SM.getExpansionLoc(FunctionBeginLoc);
                            llvm::errs() << "(symbolicVarDecl) Insert at ";
                            FunctionBeginLoc.dump(SM);
                            llvm::errs() << FlagVarDecl << "\n";
                            if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                                && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                                    TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                            } else {
                                TheRewriter.InsertText(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                            }
                        }
                    } else {
                        SourceLocation LoopBeginLoc = Loop->getBeginLoc();
                        SourceLocation LoopEndLoc = Loop->getEndLoc();
                        if (LoopBeginLoc.isMacroID())
                            LoopBeginLoc = SM.getExpansionLoc(LoopBeginLoc);
                        if (LoopEndLoc.isMacroID())
                            LoopEndLoc = SM.getExpansionLoc(LoopEndLoc);
                        while (SM.getCharacterData(LoopEndLoc) && *SM.getCharacterData(LoopEndLoc) != '}' && *SM.getCharacterData(LoopEndLoc) != ';') {
                            LoopEndLoc = LoopEndLoc.getLocWithOffset(1);
                        }
                        llvm::errs() << "(symbolicVarDecl) Insert at ";
                        LoopBeginLoc.dump(SM);
                        llvm::errs() << FlagVarDecl << "\n";
                        TheRewriter.InsertText(LoopBeginLoc, "\n{\n" + FlagVarDecl + "\n");
                        TheRewriter.InsertTextAfterToken(LoopEndLoc, "\n}\n");
                    }
                    DefinedFlags.insert(FlagVarName);
                }
        
                if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
                    std::string SymbolicCall = getSymbolicCall(Type, findFirstFunctionDeclAncestor(ifStmt), TmpVarName, VarNameStr, FlagVarName, "");
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << TmpVarAssignmentExpr + SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, TmpVarAssignmentExpr + SymbolicCall);
        
                    SymbolicedVarsOfThisIfStmt.insert(VarName);
                }
        
                TheRewriter.ReplaceText(DeclRef->getSourceRange(), TmpVarName);
                return;
            }
        }

        // Static variable
        if ((VD->isFileVarDecl() && VD->getStorageClass() == SC_Static) || VD->isStaticLocal()) {
            std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
            auto it = SymbolicVarValueMap.find(VarNameStr);
            if (it != SymbolicVarValueMap.end()) {
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    QualType QT = getNonConstType(VD->getType());
                    std::string RestoreVarDecl = "static std::any " + RestoreVarName + ";";
                    if (endWith(CurrentFilePath, ".c")) {
                        RestoreVarDecl = "static " + QT.getAsString() + " " + RestoreVarName + ";";
                    }
                    if (QT->isFunctionPointerType()) {
                        std::string VarType = QT.getAsString();
                        size_t pos = VarType.find(" (*)");
                        if (pos != std::string::npos) {
                            VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                            RestoreVarDecl = VarType + ";\n";
                        }
                    }
                    std::string FlagVarDecl = "static int " + FlagVarName + " = 0;";
                    Stmt* Loop = nullptr;
                    if (VD->isStaticLocal() && (Loop = findOutermostLoopAncestorForVarDecl(VD))) {
                        SourceLocation LoopBeginLoc = Loop->getBeginLoc();
                        SourceLocation LoopEndLoc = Loop->getEndLoc();
                        if (LoopBeginLoc.isMacroID())
                            LoopBeginLoc = SM.getExpansionLoc(LoopBeginLoc);
                        if (LoopEndLoc.isMacroID())
                            LoopEndLoc = SM.getExpansionLoc(LoopEndLoc);
                        while (SM.getCharacterData(LoopEndLoc) && *SM.getCharacterData(LoopEndLoc) != '}' && *SM.getCharacterData(LoopEndLoc) != ';') {
                            LoopEndLoc = LoopEndLoc.getLocWithOffset(1);
                        }
                        llvm::errs() << "(symbolicVarDecl) Insert at ";
                        LoopBeginLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        TheRewriter.InsertText(LoopBeginLoc, "\n{\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        TheRewriter.InsertTextAfterToken(LoopEndLoc, "\n}\n");
                    } else {
                        while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                            VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                        llvm::errs() << "(symbolicVarDecl) Insert at ";
                        VarDeclLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        TheRewriter.InsertTextAfterToken(VarDeclLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    }
                    DefinedFlags.insert(FlagVarName);

                    if (VD->isStaticLocal()) {
                        SourceLocation VarDestructionLoc = findVarDestructionLoc(VD);
                        if (VarDestructionLoc.isValid()) {
                            FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                            std::string RestoreCall = getRestoreCall(VarName, FlagVarName, RestoreVarName);
                            bool isMain = isMainFunction(ifStmt);
                            if (isMain && DisableLoc <= VarDestructionLoc) {
                                // llvm::errs() << "(symbolicVarDecl) Insert at ";
                                // DisableLoc.dump(SM);
                                // llvm::errs() << RestoreCall << "\n";
                                // TheRewriter.InsertText(DisableLoc, RestoreCall);
                                RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName, DisableLoc});
                            } else {
                                if (FD->getReturnType()->isVoidType()) {
                                    SourceLocation EndLoc = FD->getBody()->getEndLoc();
                                    TheRewriter.InsertText(EndLoc, RestoreCall);
                                }
                                RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName, VarDestructionLoc});
                            }
                        } else {
                            llvm::errs() << "Error: Static Local VarDestructionLoc is invalid\n";
                        }
                    } else {
                        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                        std::string RestoreCall = getRestoreCall(VarName, FlagVarName, RestoreVarName);    
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain) {
                            // llvm::errs() << "(symbolicVarDecl) Insert at ";
                            // DisableLoc.dump(SM);
                            // llvm::errs() << RestoreCall << "\n";
                            // TheRewriter.InsertText(DisableLoc, RestoreCall);
                            RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName, DisableLoc});
                        } else {
                            if (FD->getReturnType()->isVoidType()) {
                                SourceLocation EndLoc = FD->getBody()->getEndLoc();
                                TheRewriter.InsertText(EndLoc, RestoreCall);
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName});
                        }
                    }
                }

                if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string RestoreAssignExpr = RestoreVarName + " = " + VarName + ";";
                    std::string SymbolicCall = getSymbolicCall(getNonConstType(VD->getType()), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, RestoreAssignExpr);
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                    SymbolicedVarsOfThisIfStmt.insert(VarName);
                }
            }
        }
        // External variable
        else if ((VD->isFileVarDecl() && VD->getStorageClass() == SC_Extern) || VD->isExternC()) {
            std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
            auto it = SymbolicVarValueMap.find(VarNameStr);
            if (it != SymbolicVarValueMap.end()) {
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    // Actually, we should define the flagVar to be "extern int flagVarName;"
                    QualType QT = getNonConstType(VD->getType());
                    std::string RestoreVarDecl = "static std::any " + RestoreVarName + ";";
                    if (endWith(CurrentFilePath, ".c")) {
                        RestoreVarDecl = "static " + QT.getAsString() + " " + RestoreVarName + ";";
                    }
                    if (QT->isFunctionPointerType()) {
                        std::string VarType = QT.getAsString();
                        size_t pos = VarType.find(" (*)");
                        if (pos != std::string::npos) {
                            VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                            RestoreVarDecl = VarType + ";\n";
                        }
                    }
                    std::string FlagVarDecl = "static int " + FlagVarName + " = 0;";
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    DefinedFlags.insert(FlagVarName);

                    FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                    std::string RestoreCall = getRestoreCall(VarName, FlagVarName, RestoreVarName);
                    bool isMain = isMainFunction(ifStmt);
                    if (isMain) {
                        // llvm::errs() << "(symbolicVarDecl) Insert at ";
                        // DisableLoc.dump(SM);
                        // llvm::errs() << RestoreCall << "\n";
                        // TheRewriter.InsertText(DisableLoc, RestoreCall);
                        RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName, DisableLoc});
                    } else {
                        if (FD->getReturnType()->isVoidType()) {
                            SourceLocation EndLoc = FD->getBody()->getEndLoc();
                            TheRewriter.InsertText(EndLoc, RestoreCall);
                        }
                        RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName});
                    }
                }

                if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string RestoreAssignExpr = RestoreVarName + " = " + VarName + ";";
                    std::string SymbolicCall = getSymbolicCall(getNonConstType(VD->getType()), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, RestoreAssignExpr);
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                    SymbolicedVarsOfThisIfStmt.insert(VarName);
                }
            }
        }
        // Global variable
        else if (VD->isFileVarDecl() && VD->getStorageClass() == SC_None) {
            std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
            auto it = SymbolicVarValueMap.find(VarNameStr);
            if (it != SymbolicVarValueMap.end()) {
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    QualType QT = getNonConstType(VD->getType());
                    std::string RestoreVarDecl = "static std::any " + RestoreVarName + ";";
                    if (endWith(CurrentFilePath, ".c")) {
                        RestoreVarDecl = "static " + QT.getAsString() + " " + RestoreVarName + ";";
                    }
                    if (QT->isFunctionPointerType()) {
                        std::string VarType = QT.getAsString();
                        size_t pos = VarType.find(" (*)");
                        if (pos != std::string::npos) {
                            VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                            RestoreVarDecl = VarType + ";\n";
                        }
                    }
                    std::string FlagVarDecl = "static int " + FlagVarName + " = 0;";
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    DefinedFlags.insert(FlagVarName);

                    FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                    std::string RestoreCall = getRestoreCall(VarName, FlagVarName, RestoreVarName);
                    bool isMain = isMainFunction(ifStmt);
                    if (isMain) {
                        // llvm::errs() << "(symbolicVarDecl) Insert at ";
                        // DisableLoc.dump(SM);
                        // llvm::errs() << RestoreCall << "\n";
                        // TheRewriter.InsertText(DisableLoc, RestoreCall);
                        RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName, DisableLoc});
                    } else {
                        if (FD->getReturnType()->isVoidType()) {
                            SourceLocation EndLoc = FD->getBody()->getEndLoc();
                            TheRewriter.InsertText(EndLoc, RestoreCall);
                        }
                        RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName});
                    }
                }

                if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string RestoreAssignExpr = RestoreVarName + " = " + VarName + ";";
                    std::string SymbolicCall = getSymbolicCall(getNonConstType(VD->getType()), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, RestoreAssignExpr);
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                    SymbolicedVarsOfThisIfStmt.insert(VarName);
                }
            }
        }
        // Local variable
        else if (VD->isLocalVarDecl()) {
            std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
            auto it = SymbolicVarValueMap.find(VarNameStr);
            if (it != SymbolicVarValueMap.end()) {
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    QualType QT = getNonConstType(VD->getType());
                    std::string RestoreVarDecl = "std::any " + RestoreVarName + ";";
                    if (endWith(CurrentFilePath, ".c")) {
                        RestoreVarDecl = QT.getAsString() + " " + RestoreVarName + ";";
                    }
                    if (QT->isFunctionPointerType()) {
                        std::string VarType = QT.getAsString();
                        size_t pos = VarType.find(" (*)");
                        if (pos != std::string::npos) {
                            VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                            RestoreVarDecl = VarType + ";\n";
                        }
                    }
                    
                    std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                    Stmt* Loop = findOutermostLoopAncestorForVarDecl(VD);
                    if (!Loop) {
                        while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';') {
                            VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                        }
                        llvm::errs() << "(symbolicVarDecl) Insert at ";
                        VarDeclLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        TheRewriter.InsertTextAfterToken(VarDeclLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    } else {
                        SourceLocation LoopBeginLoc = Loop->getBeginLoc();
                        SourceLocation LoopEndLoc = Loop->getEndLoc();
                        if (LoopBeginLoc.isMacroID())
                            LoopBeginLoc = SM.getExpansionLoc(LoopBeginLoc);
                        if (LoopEndLoc.isMacroID())
                            LoopEndLoc = SM.getExpansionLoc(LoopEndLoc);
                        while (SM.getCharacterData(LoopEndLoc) && *SM.getCharacterData(LoopEndLoc) != '}' && *SM.getCharacterData(LoopEndLoc) != ';') {
                            LoopEndLoc = LoopEndLoc.getLocWithOffset(1);
                        }
                        llvm::errs() << "(symbolicVarDecl) Insert at ";
                        LoopBeginLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        TheRewriter.InsertText(LoopBeginLoc, "\n{\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        TheRewriter.InsertTextAfterToken(LoopEndLoc, "\n}\n");
                    }
                    DefinedFlags.insert(FlagVarName);

                    // 插入恢复代码
                    SourceLocation VarDestructionLoc = findVarDestructionLoc(VD);
                    if (VarDestructionLoc.isValid()) {
                        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain && DisableLoc < VarDestructionLoc) {
                            std::string RestoreCall = getRestoreCall(VarName, FlagVarName, RestoreVarName);
                            // llvm::errs() << "(symbolicVarDecl) Insert at ";
                            // DisableLoc.dump(SM);
                            // llvm::errs() << RestoreCall << "\n";
                            // TheRewriter.InsertText(DisableLoc, RestoreCall);
                            RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName, DisableLoc});
                        }
                    }
                }
                if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string RestoreAssignExpr = RestoreVarName + " = " + VarName + ";";
                    std::string SymbolicCall = getSymbolicCall(getNonConstType(VD->getType()), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, RestoreAssignExpr);
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                    SymbolicedVarsOfThisIfStmt.insert(VarName);
                }
            }
        }
        // Function parameter
        else if (VD->isLocalVarDeclOrParm()) {
            std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
            auto it = SymbolicVarValueMap.find(VarNameStr);
            if (it != SymbolicVarValueMap.end()) {
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    QualType QT = getNonConstType(VD->getType());
                    std::string RestoreVarDecl = "std::any " + RestoreVarName + ";";
                    if (endWith(CurrentFilePath, ".c")) {
                        RestoreVarDecl = QT.getAsString() + " " + RestoreVarName + ";";
                    }
                    if (QT->isFunctionPointerType()) {
                        std::string VarType = QT.getAsString();
                        size_t pos = VarType.find(" (*)");
                        if (pos != std::string::npos) {
                            VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                            RestoreVarDecl = VarType + ";\n";
                        }
                    }
                    
                    std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                    FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                    SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
                    if (InsertLoc.isMacroID())
                        InsertLoc = SM.getExpansionLoc(InsertLoc);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    InsertLoc.dump(SM);
                    llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                    if (TheRewriter.getSourceMgr().getCharacterData(InsertLoc)
                        && *TheRewriter.getSourceMgr().getCharacterData(InsertLoc) == ';') {
                            TheRewriter.InsertTextAfterToken(InsertLoc, "\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    } else {
                        TheRewriter.InsertText(InsertLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    }
                    DefinedFlags.insert(FlagVarName);

                    // 插入恢复代码
                    SourceLocation VarDestructionLoc = findVarDestructionLoc(VD);
                    if (VarDestructionLoc.isValid()) {
                        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain && DisableLoc < VarDestructionLoc) {
                            std::string RestoreCall = getRestoreCall(VarName, FlagVarName, RestoreVarName);
                            // llvm::errs() << "(symbolicVarDecl) Insert at ";
                            // DisableLoc.dump(SM);
                            // llvm::errs() << RestoreCall << "\n";
                            // TheRewriter.InsertText(DisableLoc, RestoreCall);
                            RestoreInfos[getFunctionName(FD)].push_back({VarName, FlagVarName, RestoreVarName, DisableLoc});
                        }
                    }
                }
                if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string RestoreAssignExpr = RestoreVarName + " = " + VarName + ";";
                    std::string SymbolicCall = getSymbolicCall(getNonConstType(VD->getType()), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, RestoreAssignExpr);
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                    SymbolicedVarsOfThisIfStmt.insert(VarName);
                }
            }
        }
        else {
            llvm::errs() << "VarDecl: " << VD->getNameAsString() << " is not a valid variable\n";
        }
    }

    void symbolicFuncCall(IfStmt* ifStmt, CallExpr* FuncCall, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceLocation IfStartLoc = ifStmt->getBeginLoc();
        if (IfStartLoc.isMacroID())
            IfStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(IfStartLoc);

        if (FunctionDecl *FD = FuncCall->getDirectCallee()) {
            QualType QT = getNonConstType(FD->getReturnType());
            std::string FuncName = getFunctionName(FD);
            SourceLocation FuncCallLoc = FuncCall->getBeginLoc();
            if (FuncCallLoc.isMacroID())
                FuncCallLoc = TheRewriter.getSourceMgr().getExpansionLoc(FuncCallLoc);

            Stmt* Loop = findOutermostLoopAncestor(ifStmt);
            if (!Loop) {
                std::string TmpVarName = "tmp_" + FuncName + "_result_" + std::to_string(FuncCallLoc.getRawEncoding());
                std::string FuncCallStmt = "auto " + TmpVarName + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                if (QT->isFunctionPointerType()) {
                    std::string VarType = QT.getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                        FuncCallStmt = VarType + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                    }
                }
                FuncCallStmt += "unused_tmp_value += (uint64_t)" + TmpVarName + ";\n";
                auto it = SymbolicVarValueMap.find(TmpVarName);
                if (it != SymbolicVarValueMap.end()) {
                    std::string SymbolicCall = getSymbolicCall(QT, findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarName, "", "");
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicFuncCall) Insert at ";
                    IfStartLoc.dump(TheRewriter.getSourceMgr());
                    llvm::errs() << FuncCallStmt + SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, FuncCallStmt + SymbolicCall);

                    // 替换if条件中的函数调用为返回值变量
                    TheRewriter.ReplaceText(FuncCall->getSourceRange(), TmpVarName);
                }
            } else {
                std::string FlagVarName = "tmp_" + FuncName + "_flag_" + std::to_string(FuncCallLoc.getRawEncoding());
                std::string TmpVarName = "tmp_" + FuncName + "_result_" + std::to_string(FuncCallLoc.getRawEncoding());
                auto itr = SymbolicVarValueMap.find(TmpVarName);
                if (itr != SymbolicVarValueMap.end()) {
                    if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                        std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                        SourceManager &SM = TheRewriter.getSourceMgr();
                        SourceLocation LoopBeginLoc = Loop->getBeginLoc();
                        SourceLocation LoopEndLoc = Loop->getEndLoc();
                        if (LoopBeginLoc.isMacroID())
                            LoopBeginLoc = SM.getExpansionLoc(LoopBeginLoc);
                        if (LoopEndLoc.isMacroID())
                            LoopEndLoc = SM.getExpansionLoc(LoopEndLoc);
                        while (SM.getCharacterData(LoopEndLoc) && *SM.getCharacterData(LoopEndLoc) != '}' && *SM.getCharacterData(LoopEndLoc) != ';') {
                            LoopEndLoc = LoopEndLoc.getLocWithOffset(1);
                        }
                        llvm::errs() << "(symbolicVarDecl) Insert at ";
                        LoopBeginLoc.dump(SM);
                        llvm::errs() << FlagVarDecl << "\n";
                        TheRewriter.InsertText(LoopBeginLoc, "\n{\n" + FlagVarDecl + "\n");
                        TheRewriter.InsertTextAfterToken(LoopEndLoc, "\n}\n");
                        DefinedFlags.insert(FlagVarName);
                    }

                    std::string FuncCallStmt = "auto " + TmpVarName + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                    if (QT->isFunctionPointerType()) {
                        std::string VarType = QT.getAsString();
                        size_t pos = VarType.find(" (*)");
                        if (pos != std::string::npos) {
                            VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                            FuncCallStmt = VarType + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                        }
                    }
                    FuncCallStmt += "unused_tmp_value += (uint64_t)" + TmpVarName + ";\n";
                    std::string SymbolicCall = getSymbolicCall(QT, findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarName, FlagVarName, "");
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicFuncCall) Insert at ";
                    IfStartLoc.dump(TheRewriter.getSourceMgr());
                    llvm::errs() << FuncCallStmt + SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, FuncCallStmt + SymbolicCall);

                    // 替换if条件中的函数调用为返回值变量
                    TheRewriter.ReplaceText(FuncCall->getSourceRange(), TmpVarName);
                }
            }
        }
    }

    void symbolicAssignment(IfStmt* ifStmt, BinaryOperator* BO, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceLocation StartLoc = ifStmt->getBeginLoc();

        std::string assignmentExprStr = TheRewriter.getRewrittenText(BO->getSourceRange());
        std::string leftValueExprStr = TheRewriter.getRewrittenText(BO->getLHS()->getSourceRange());

        checkAndAddBracesForAncestor(ifStmt);
        llvm::errs() << "(symbolicAssignment) Insert at ";
        StartLoc.dump(TheRewriter.getSourceMgr());
        llvm::errs() << assignmentExprStr + ";\n";
        TheRewriter.InsertText(StartLoc, assignmentExprStr + ";\n");

        // 替换if条件中的赋值表达式为左值变量
        TheRewriter.ReplaceText(BO->getSourceRange(), leftValueExprStr);

        if (DeclRefExpr *DeclRef = dyn_cast<DeclRefExpr>(BO->getLHS())) {
            symbolicVarDecl(ifStmt, DeclRef, SymbolicedVarsOfThisIfStmt, CR);
        } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(BO->getLHS())) {
            if (DeclRefExpr *DeclRef = dyn_cast<DeclRefExpr>(ICE->getSubExpr())) {
                symbolicVarDecl(ifStmt, DeclRef, SymbolicedVarsOfThisIfStmt, CR);
            }
        }
    }

    bool isCXXMemberExpr(MemberExpr *ME) {
        Expr* Base = ME->getBase();
        while (1) {
            if (dyn_cast<DeclRefExpr>(Base)) {
                return false;
            } else if (MemberExpr *SubME = dyn_cast<MemberExpr>(Base)) {
                return isCXXMemberExpr(SubME);
            } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(Base)) {
                return isCXXArraySubscriptExpr(ASE);
            } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(Base)) {
                Base = ICE->getSubExpr();
            } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(ME->getBase())) {
                if (UO->getOpcode() == UO_Deref) {
                    return isCXXDerefExpr(UO);
                } else {
                    return false;
                }
            } else if (dyn_cast<CXXThisExpr>(Base)) {
                return true;
            } else {
                return false;
            }
        }
    }

    bool isCXXArraySubscriptExpr(ArraySubscriptExpr *ASE) {
        Expr *Base = ASE->getBase();
        while (1) {
            if (dyn_cast<DeclRefExpr>(Base)) {
                return false;
            } else if (MemberExpr *ME = dyn_cast<MemberExpr>(Base)) {
                return isCXXMemberExpr(ME);
            } else if (ArraySubscriptExpr *SubASE = dyn_cast<ArraySubscriptExpr>(Base)) {
                return isCXXArraySubscriptExpr(SubASE);
            } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(Base)) {
                Base = ICE->getSubExpr();
            } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(Base)) {
                if (UO->getOpcode() == UO_Deref) {
                    return isCXXDerefExpr(UO);
                } else {
                    return false;
                }
            } else if (dyn_cast<CXXThisExpr>(Base)) {
                return true;
            } else {
                return false;
            }
        }
    }

    bool isCXXDerefExpr(UnaryOperator *UO) {
        if (UO->getOpcode() != UO_Deref) {
            return false;
        }

        Expr *SubExpr = UO->getSubExpr();
        while (1) {
            if (dyn_cast<DeclRefExpr>(SubExpr)) {
                return false;
            } else if (MemberExpr *ME = dyn_cast<MemberExpr>(SubExpr)) {
                return isCXXMemberExpr(ME);
            } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(SubExpr)) {
                return isCXXArraySubscriptExpr(ASE);
            } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(SubExpr)) {
                SubExpr = ICE->getSubExpr();
            } else if (UnaryOperator *SubUO = dyn_cast<UnaryOperator>(SubExpr)) {
                if (SubUO->getOpcode() == UO_Deref) {
                    return isCXXDerefExpr(SubUO);
                } else {
                    return false;
                }
            } else if (dyn_cast<CXXThisExpr>(SubExpr)) {
                return true;
            } else {
                return false;
            }
        }
    }

    DeclRefExpr* getOriginalBaseFromMemberExpr(MemberExpr *ME) {
        Expr* Base = ME->getBase();
        while (1) {
            if (DeclRefExpr *DRE = dyn_cast<DeclRefExpr>(Base)) {
                return DRE;
            } else if (MemberExpr *SubME = dyn_cast<MemberExpr>(Base)) {
                return getOriginalBaseFromMemberExpr(SubME);
            } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(Base)) {
                return getOriginalBaseFromArraySubscriptExpr(ASE);
            } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(Base)) {
                Base = ICE->getSubExpr();
            } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(ME->getBase())) {
                if (UO->getOpcode() == UO_Deref) {
                    return getOriginalBaseFromDerefExpr(UO);
                } else {
                    return nullptr;
                }
            } else {
                return nullptr;
            }
        }
    }

    DeclRefExpr* getOriginalBaseFromArraySubscriptExpr(ArraySubscriptExpr *ASE) {
        Expr *Base = ASE->getBase();
        while (1) {
            if (DeclRefExpr *DRE = dyn_cast<DeclRefExpr>(Base)) {
                return DRE;
            } else if (MemberExpr *ME = dyn_cast<MemberExpr>(Base)) {
                return getOriginalBaseFromMemberExpr(ME);
            } else if (ArraySubscriptExpr *SubASE = dyn_cast<ArraySubscriptExpr>(Base)) {
                return getOriginalBaseFromArraySubscriptExpr(SubASE);
            } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(Base)) {
                Base = ICE->getSubExpr();
            } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(Base)) {
                if (UO->getOpcode() == UO_Deref) {
                    return getOriginalBaseFromDerefExpr(UO);
                } else {
                    return nullptr;
                }
            } else {
                return nullptr;
            }
        }
    }

    DeclRefExpr* getOriginalBaseFromDerefExpr(UnaryOperator *UO) {
        if (UO->getOpcode() != UO_Deref) {
            return nullptr;
        }

        Expr *SubExpr = UO->getSubExpr();
        while (1) {
            if (DeclRefExpr *DRE = dyn_cast<DeclRefExpr>(SubExpr)) {
                return DRE;
            } else if (MemberExpr *ME = dyn_cast<MemberExpr>(SubExpr)) {
                return getOriginalBaseFromMemberExpr(ME);
            } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(SubExpr)) {
                return getOriginalBaseFromArraySubscriptExpr(ASE);
            } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(SubExpr)) {
                SubExpr = ICE->getSubExpr();
            } else if (UnaryOperator *SubUO = dyn_cast<UnaryOperator>(SubExpr)) {
                if (SubUO->getOpcode() == UO_Deref) {
                    return getOriginalBaseFromDerefExpr(SubUO);
                } else {
                    return nullptr;
                }
            } else {
                return nullptr;
            }
        }
    }

    void findAllDeclRefInExpr(Expr *E, std::vector<DeclRefExpr*>& DeclRefs) {
        if (DeclRefExpr *DRE = dyn_cast<DeclRefExpr>(E)) {
            DeclRefs.push_back(DRE);
        } else if (MemberExpr *ME = dyn_cast<MemberExpr>(E)) {
            findAllDeclRefInExpr(ME->getBase(), DeclRefs);
        } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(E)) {
            findAllDeclRefInExpr(ASE->getBase(), DeclRefs);
            findAllDeclRefInExpr(ASE->getIdx(), DeclRefs);
        } else if (ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(E)) {
            findAllDeclRefInExpr(ICE->getSubExpr(), DeclRefs);
        } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(E)) {
            findAllDeclRefInExpr(UO->getSubExpr(), DeclRefs);
        } else {
            for (Stmt *Child : E->children()) {
                if (Expr *ChildExpr = dyn_cast<Expr>(Child)) {
                    findAllDeclRefInExpr(ChildExpr, DeclRefs);
                }
            }
        }
    }

    std::pair<DeclRefExpr*, SourceLocation> findSmallestVarDestructionLoc(std::vector<DeclRefExpr*>& DeclRefs) {
        DeclRefExpr *SmallestDRE = nullptr;
        SourceLocation SmallestLoc;
        for (DeclRefExpr *DRE : DeclRefs) {
            VarDecl *VD = dyn_cast<VarDecl>(DRE->getDecl());
            if (!VD)  continue;

            SourceLocation VarDestructionLoc = findVarDestructionLoc(VD);
            if (!VarDestructionLoc.isValid())  continue;

            if (!SmallestLoc.isValid() || VarDestructionLoc < SmallestLoc) {
                SmallestLoc = VarDestructionLoc;
                SmallestDRE = DRE;
            }
        }
        return {SmallestDRE, SmallestLoc};
    }

    void symbolicCXXMemberExpr(IfStmt* ifStmt, MemberExpr* ME, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation IfStartLoc = ifStmt->getBeginLoc();
        if (IfStartLoc.isMacroID())
            IfStartLoc = SM.getExpansionLoc(IfStartLoc);

        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
        std::string FuncName = getFunctionName(FD);
        
        std::string MemberExprStr = TheRewriter.getRewrittenText(ME->getSourceRange());
        std::string FlagVarName = "tmp_" + MemberExprStr + "_flag";
        std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        FlagVarName += "_" + FuncName;

        std::string RestoreVarName = "tmp_" + MemberExprStr + "_restore";
        std::replace_if(RestoreVarName.begin(), RestoreVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        RestoreVarName += "_" + FuncName;

        std::string VarNameStr = MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
        std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        auto it = SymbolicVarValueMap.find(VarNameStr);
        if (it != SymbolicVarValueMap.end()) {
            // 变量可能是 const 类型或 const & 类型
            QualType Type = ME->getType();
            if ((Type.isConstQualified()) || (Type->isReferenceType() && Type.getNonReferenceType().isConstQualified())) {
                if (Type->isReferenceType()) {
                    Type = Type.getNonReferenceType();
                }
                Type = getNonConstType(Type);
                std::string TmpVarName = "tmp_" + MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
                std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
                    return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
                }, '_');
                std::string TmpVarAssignmentExpr = "auto " + TmpVarName + " = " + MemberExprStr + ";\n";
                std::string FlagVarName = "tmp_" + MemberExprStr + "_flag_" + std::to_string(IfStartLoc.getRawEncoding());
                std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
                    return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
                }, '_');
                FunctionDecl* FD = findFirstFunctionDeclAncestor(ifStmt);
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                    SourceLocation FunctionBeginLoc = FD->getBody()->child_begin()->getBeginLoc();
                    if (FunctionBeginLoc.isMacroID())
                        FunctionBeginLoc = SM.getExpansionLoc(FunctionBeginLoc);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    FunctionBeginLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                        && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                            TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                    } else {
                        TheRewriter.InsertText(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                    }

                    DefinedFlags.insert(FlagVarName);
                }

                if (SymbolicedVarsOfThisIfStmt.find(MemberExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string VarNameStr = MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
                    std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
                        return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
                    }, '_');
                    std::string SymbolicCall = getSymbolicCall(Type, findFirstFunctionDeclAncestor(ifStmt), TmpVarName, VarNameStr, FlagVarName, "");
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << TmpVarAssignmentExpr + SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, TmpVarAssignmentExpr + SymbolicCall);

                    SymbolicedVarsOfThisIfStmt.insert(MemberExprStr);
                }

                TheRewriter.ReplaceText(ME->getSourceRange(), TmpVarName);
                return;
            }

            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                QualType QT = ME->getType();
                std::string RestoreVarDecl = "std::any " + RestoreVarName + ";";
                if (endWith(CurrentFilePath, ".c")) {
                    RestoreVarDecl = QT.getAsString() + " " + RestoreVarName + ";";
                }
                if (QT->isFunctionPointerType()) {
                    std::string VarType = QT.getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                        RestoreVarDecl = VarType + ";\n";
                    }
                }
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                SourceLocation FunctionStartLoc = FD->getBody()->child_begin()->getBeginLoc();
                if (FunctionStartLoc.isMacroID())
                    FunctionStartLoc = SM.getExpansionLoc(FunctionStartLoc);
                llvm::errs() << "(symbolicCXXMemberExpr) Insert at ";
                FunctionStartLoc.dump(SM);
                llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                if (TheRewriter.getSourceMgr().getCharacterData(FunctionStartLoc)
                    && *TheRewriter.getSourceMgr().getCharacterData(FunctionStartLoc) == ';') {
                        TheRewriter.InsertTextAfterToken(FunctionStartLoc, "\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                } else {
                    TheRewriter.InsertText(FunctionStartLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                }
                DefinedFlags.insert(FlagVarName);

                FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                std::string RestoreCall = getRestoreCall(MemberExprStr, FlagVarName, RestoreVarName);
                SourceLocation EndLoc = FD->getBody()->getEndLoc();
                if (EndLoc.isMacroID())
                    EndLoc = SM.getExpansionLoc(EndLoc);
                while (SM.getCharacterData(EndLoc) && *SM.getCharacterData(EndLoc) != '}')
                    EndLoc = EndLoc.getLocWithOffset(1);
                bool isMain = isMainFunction(ifStmt);
                if (isMain) {
                    // llvm::errs() << "(symbolicMemberExpr) Insert at ";
                    // DisableLoc.dump(SM);
                    // llvm::errs() << RestoreCall << "\n";
                    // TheRewriter.InsertText(DisableLoc, RestoreCall);
                    RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName, DisableLoc});
                } else {
                    if (FD->getReturnType()->isVoidType()) {
                        TheRewriter.InsertText(EndLoc, RestoreCall);
                    }
                    RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName});
                }
            }

            if (SymbolicedVarsOfThisIfStmt.find(MemberExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string RestoreAssignExpr = RestoreVarName + " = " + MemberExprStr + ";";
                std::string SymbolicCall = getSymbolicCall(ME->getType(), findFirstFunctionDeclAncestor(ifStmt), "(" + MemberExprStr + ")", VarNameStr, FlagVarName, RestoreAssignExpr);
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicCXXMemberExpr) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(MemberExprStr);
            }
        }
    }

    std::string getFullyQualifiedTypeName(QualType QT) {
        PrintingPolicy Policy(Context.getLangOpts());
        Policy.SuppressTagKeyword = false; // 保留 enum/class/struct 等关键字
        Policy.SuppressScope = false;     // 不省略作用域
        return QT.getAsString(Policy);
    }

    bool isLambdaFunctionDecl(clang::FunctionDecl* FD) {
        // 将 FunctionDecl 转换为 CXXMethodDecl
        if (auto* CXXMethod = llvm::dyn_cast<clang::CXXMethodDecl>(FD)) {
            // 获取 CXXMethodDecl 的父类 CXXRecordDecl
            if (auto* CXXRecord = CXXMethod->getParent()) {
                // 检查 CXXRecordDecl 是否是一个 lambda 表达式
                return CXXRecord->isLambda();
            }
        }
        return false;
    }

    void symbolicMemberExpr(IfStmt* ifStmt, MemberExpr* ME, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        DeclRefExpr *OriginalBase = getOriginalBaseFromMemberExpr(ME);
        if (!OriginalBase)  return;

        VarDecl* VD = dyn_cast<VarDecl>(OriginalBase->getDecl());
        if (!VD)  return;

        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation VarDeclLoc = VD->getLocation();
        if (VarDeclLoc.isMacroID())
            VarDeclLoc = SM.getExpansionLoc(VarDeclLoc);

        SourceLocation IfStartLoc = ifStmt->getBeginLoc();
        if (IfStartLoc.isMacroID())
            IfStartLoc = SM.getExpansionLoc(IfStartLoc);
        
        std::string MemberExprStr = TheRewriter.getRewrittenText(ME->getSourceRange());
        std::string FlagVarName = "tmp_" + MemberExprStr + "_flag";
        std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        FlagVarName += "_" + std::to_string(VarDeclLoc.getRawEncoding());

        std::string RestoreVarName = "tmp_" + MemberExprStr + "_restore";
        std::replace_if(RestoreVarName.begin(), RestoreVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        RestoreVarName += "_" + std::to_string(VarDeclLoc.getRawEncoding());

        std::string VarNameStr = MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
        std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        auto it = SymbolicVarValueMap.find(VarNameStr);
        if (it != SymbolicVarValueMap.end()) {
            // 变量可能是 const 类型或 const & 类型
            QualType Type = ME->getType();
            if ((Type.isConstQualified()) || (Type->isReferenceType() && Type.getNonReferenceType().isConstQualified())) {
                if (Type->isReferenceType()) {
                    Type = Type.getNonReferenceType();
                }
                Type = getNonConstType(Type);
                std::string TmpVarName = "tmp_" + MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
                std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
                    return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
                }, '_');
                std::string TmpVarAssignmentExpr = "auto " + TmpVarName + " = " + MemberExprStr + ";\n";
                std::string FlagVarName = "tmp_" + MemberExprStr + "_flag_" + std::to_string(IfStartLoc.getRawEncoding());
                std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
                    return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
                }, '_');
                FunctionDecl* FD = findFirstFunctionDeclAncestor(ifStmt);
                if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                    std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                    SourceLocation FunctionBeginLoc = FD->getBody()->child_begin()->getBeginLoc();
                    if (FunctionBeginLoc.isMacroID())
                        FunctionBeginLoc = SM.getExpansionLoc(FunctionBeginLoc);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    FunctionBeginLoc.dump(SM);
                    // llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
                    // if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                    //     && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                    //         TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + VarDeclStmt + "\n" + FlagVarDecl + "\n");
                    // } else {
                    //     TheRewriter.InsertText(FunctionBeginLoc, VarDeclStmt + "\n" + FlagVarDecl + "\n");
                    // }
                    llvm::errs() << FlagVarDecl << "\n";
                    if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                        && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                            TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                    } else {
                        TheRewriter.InsertText(FunctionBeginLoc, "\n" + FlagVarDecl + "\n");
                    }

                    DefinedFlags.insert(FlagVarName);
                }
        
                if (SymbolicedVarsOfThisIfStmt.find(MemberExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
                    std::string VarNameStr = MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
                    std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
                        return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
                    }, '_');
                    std::string SymbolicCall = getSymbolicCall(Type, findFirstFunctionDeclAncestor(ifStmt), TmpVarName, VarNameStr, FlagVarName, "");
                    checkAndAddBracesForAncestor(ifStmt);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    IfStartLoc.dump(SM);
                    llvm::errs() << TmpVarAssignmentExpr + SymbolicCall << "\n";
                    TheRewriter.InsertText(IfStartLoc, TmpVarAssignmentExpr + SymbolicCall);
        
                    SymbolicedVarsOfThisIfStmt.insert(MemberExprStr);
                }

                TheRewriter.ReplaceText(ME->getSourceRange(), TmpVarName);
                return;
            }

            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                QualType QT = ME->getType();
                std::string RestoreVarDecl = "std::any " + RestoreVarName + ";";
                if (endWith(CurrentFilePath, ".c")) {
                    RestoreVarDecl = QT.getAsString() + " " + RestoreVarName + ";";
                }
                if (QT->isFunctionPointerType()) {
                    std::string VarType = QT.getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                        RestoreVarDecl = VarType + ";\n";
                    }
                }
                std::string FlagVarDecl = "";
                if (VD->isFileVarDecl()) {
                    FlagVarDecl = "static ";
                    RestoreVarDecl = "static " + RestoreVarDecl;
                }
                FlagVarDecl += "int " + FlagVarName + " = 0;";
                Stmt* Loop = nullptr;
                if ((VD->isStaticLocal() || VD->isLocalVarDecl())) {
                    Loop = findOutermostLoopAncestorForVarDecl(VD);
                }
                if (!Loop) {
                    if (VD->isLocalVarDeclOrParm() && !VD->isStaticLocal()) {
                        SourceLocation FunctionBeginLoc = findFirstFunctionDeclAncestor(ifStmt)->getBody()->child_begin()->getBeginLoc();
                        if (FunctionBeginLoc.isMacroID())
                            FunctionBeginLoc = SM.getExpansionLoc(FunctionBeginLoc);
                        llvm::errs() << "(symbolicDerefExpr) Insert at ";
                        FunctionBeginLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                            && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                                TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        } else {
                            TheRewriter.InsertText(FunctionBeginLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        }
                    } else {
                        while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                            VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                        llvm::errs() << "(symbolicMemberExpr) Insert at ";
                        VarDeclLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        TheRewriter.InsertTextAfterToken(VarDeclLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    }
                } else {
                    SourceLocation LoopBeginLoc = Loop->getBeginLoc();
                    SourceLocation LoopEndLoc = Loop->getEndLoc();
                    if (LoopBeginLoc.isMacroID())
                        LoopBeginLoc = SM.getExpansionLoc(LoopBeginLoc);
                    if (LoopEndLoc.isMacroID())
                        LoopEndLoc = SM.getExpansionLoc(LoopEndLoc);
                    while (SM.getCharacterData(LoopEndLoc) && *SM.getCharacterData(LoopEndLoc) != '}' && *SM.getCharacterData(LoopEndLoc) != ';') {
                        LoopEndLoc = LoopEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(symbolicMemberExpr) Insert at ";
                    LoopBeginLoc.dump(SM);
                    llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                    TheRewriter.InsertText(LoopBeginLoc, "\n{\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    TheRewriter.InsertTextAfterToken(LoopEndLoc, "\n}\n");
                }
                DefinedFlags.insert(FlagVarName);

                std::vector<DeclRefExpr*> DeclRefs;
                findAllDeclRefInExpr(ME, DeclRefs);
                std::pair<DeclRefExpr*, SourceLocation> SmallestVarDestruction = findSmallestVarDestructionLoc(DeclRefs);
                bool success = false;

                // MemberExpr 的 Base 是 Primary 函数中的局部变量或函数参数，且在 Primary 函数中会被销毁
                // 在 DisableLoc 处恢复
                if (SmallestVarDestruction.first) {
                    VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                    if (SmallestVarDecl && SmallestVarDecl->isLocalVarDeclOrParm() && SmallestVarDestruction.second.isValid()) {
                        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);

                        llvm::errs() << "##############\n";
                        if (isLambdaFunctionDecl(FD)) {
                            std::string RestoreCall = getRestoreCall(MemberExprStr, FlagVarName, RestoreVarName);
                            // llvm::errs() << "(symbolicMemberExpr) Insert at ";
                            // SmallestVarDestruction.second.dump(SM);
                            // llvm::errs() << RestoreCall << "\n";
                            // TheRewriter.InsertText(SmallestVarDestruction.second, RestoreCall);
                            llvm::errs() << "################################\n";
                            RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                            success = true;
                        }

                        bool isMain = isMainFunction(ifStmt);
                        if (isMain && DisableLoc <= SmallestVarDestruction.second) {
                            std::string RestoreCall = getRestoreCall(MemberExprStr, FlagVarName, RestoreVarName);
                            // llvm::errs() << "(symbolicMemberExpr) Insert at ";
                            // DisableLoc.dump(SM);
                            // llvm::errs() << RestoreCall << "\n";
                            // TheRewriter.InsertText(DisableLoc, RestoreCall);
                            RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName, DisableLoc});
                            success = true;
                        }
                    }
                }

                // 不是上述情况
                if (!success) {
                    FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                    std::string RestoreCall = getRestoreCall(MemberExprStr, FlagVarName, RestoreVarName);
                    SourceLocation EndLoc = FD->getBody()->getEndLoc();
                    if (EndLoc.isMacroID())
                        EndLoc = SM.getExpansionLoc(EndLoc);
                    while (SM.getCharacterData(EndLoc) && *SM.getCharacterData(EndLoc) != '}')
                        EndLoc = EndLoc.getLocWithOffset(1);

                    if (SmallestVarDestruction.second.isInvalid() || SmallestVarDestruction.second >= EndLoc) {
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain) {
                            RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName, DisableLoc});
                        } else {
                            if (FD->getReturnType()->isVoidType()) {
                                TheRewriter.InsertText(EndLoc, RestoreCall);
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName});
                        }
                    } else {
                        SmallestVarDestruction.second.dump(SM);
                        EndLoc.dump(SM);

                        // 这里用分号和花括号来区分是否需要插入花括号，略有问题，因为可能出现for(int i = 0; i < n; ++i) if(i < 5) {} 这样的写法
                        // 暂时忽略这种情况，假设良好的程序不会写出如此的代码
                        if (*SM.getCharacterData(SmallestVarDestruction.second) == ';') {
                            TheRewriter.InsertTextAfterToken(SmallestVarDestruction.second, RestoreCall);
                            VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                            if (SmallestVarDecl) {
                                ForStmt* fs = isVarDeclInForInit(SmallestVarDecl);
                                if (fs) {
                                    checkAndAddBracesForAncestor(fs->getBody());
                                    LoopRestoreInfos[fs].push_back({MemberExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                                }
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                        } else {
                            VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                            bool NoCompoundBody = false;
                            if (SmallestVarDecl) {
                                Stmt* SmallestVarDestructionStmt = findVarDestructionLocStmt(SmallestVarDecl);
                                if (SmallestVarDestructionStmt) {
                                    ForStmt *fs = dyn_cast<ForStmt>(SmallestVarDestructionStmt);
                                    if (fs && !dyn_cast<CompoundStmt>(fs->getBody())) {
                                        NoCompoundBody = true;
                                    }
                                }
                            }

                            if (NoCompoundBody) {
                                TheRewriter.InsertTextAfterToken(SmallestVarDestruction.second, RestoreCall);
                            } else {
                                TheRewriter.InsertText(SmallestVarDestruction.second, RestoreCall);
                            }
                            if (SmallestVarDecl) {
                                ForStmt* fs = isVarDeclInForInit(SmallestVarDecl);
                                if (fs) {
                                    LoopRestoreInfos[fs].push_back({MemberExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                                }
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({MemberExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                        }
                    }
                }
            }

            if (SymbolicedVarsOfThisIfStmt.find(MemberExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string RestoreAssignExpr = RestoreVarName + " = " + MemberExprStr + ";";
                std::string SymbolicCall = getSymbolicCall(ME->getType(), findFirstFunctionDeclAncestor(ifStmt), "(" + MemberExprStr + ")", VarNameStr, FlagVarName, RestoreAssignExpr);
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicMemberExpr) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(MemberExprStr);
            }
        }
    }

    void symbolicArraySubscriptExpr(IfStmt* ifStmt, ArraySubscriptExpr* ASE,
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        DeclRefExpr *OriginalBase = getOriginalBaseFromArraySubscriptExpr(ASE);
        if (!OriginalBase)  return;

        VarDecl* VD = dyn_cast<VarDecl>(OriginalBase->getDecl());
        if (!VD)  return;
        
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation VarDeclLoc = VD->getLocation();
        if (VarDeclLoc.isMacroID())
            VarDeclLoc = SM.getExpansionLoc(VarDeclLoc);

        SourceLocation IfStartLoc = ifStmt->getBeginLoc();
        if (IfStartLoc.isMacroID())
            IfStartLoc = SM.getExpansionLoc(IfStartLoc);

        std::string ArraySubscriptExprStr = TheRewriter.getRewrittenText(ASE->getSourceRange());
        std::string FlagVarName = "tmp_" + ArraySubscriptExprStr + "_flag";
        std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        FlagVarName += "_" + std::to_string(VarDeclLoc.getRawEncoding());

        std::string RestoreVarName = "tmp_" + ArraySubscriptExprStr + "_restore";
        std::replace_if(RestoreVarName.begin(), RestoreVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        RestoreVarName += "_" + std::to_string(VarDeclLoc.getRawEncoding());

        std::string VarNameStr = ArraySubscriptExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
        std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        auto it = SymbolicVarValueMap.find(VarNameStr);
        if (it != SymbolicVarValueMap.end()) {
            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                QualType QT = ASE->getType();
                std::string RestoreVarDecl = "std::any " + RestoreVarName + ";";
                if (endWith(CurrentFilePath, ".c")) {
                    RestoreVarDecl = QT.getAsString() + " " + RestoreVarName + ";";
                }
                if (QT->isFunctionPointerType()) {
                    std::string VarType = QT.getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                        RestoreVarDecl = VarType + ";\n";
                    }
                }
                std::string FlagVarDecl;
                if (VD->isFileVarDecl()) {
                    FlagVarDecl = "static ";
                    RestoreVarDecl = "static " + RestoreVarDecl;
                }
                FlagVarDecl += "int " + FlagVarName + " = 0;";
                Stmt* Loop = nullptr;
                if ((VD->isStaticLocal() || VD->isLocalVarDecl())) {
                    Loop = findOutermostLoopAncestorForVarDecl(VD);
                }
                if (!Loop) {
                    if (VD->isLocalVarDeclOrParm() && !VD->isStaticLocal()) {
                        SourceLocation FunctionBeginLoc = findFirstFunctionDeclAncestor(ifStmt)->getBody()->child_begin()->getBeginLoc();
                        if (FunctionBeginLoc.isMacroID())
                            FunctionBeginLoc = SM.getExpansionLoc(FunctionBeginLoc);
                        llvm::errs() << "(symbolicDerefExpr) Insert at ";
                        FunctionBeginLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                            && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                                TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        } else {
                            TheRewriter.InsertText(FunctionBeginLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        }
                    } else {
                        while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                            VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                        llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
                        VarDeclLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        TheRewriter.InsertTextAfterToken(VarDeclLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    }
                } else {
                    SourceLocation LoopBeginLoc = Loop->getBeginLoc();
                    SourceLocation LoopEndLoc = Loop->getEndLoc();
                    if (LoopBeginLoc.isMacroID())
                        LoopBeginLoc = SM.getExpansionLoc(LoopBeginLoc);
                    if (LoopEndLoc.isMacroID())
                        LoopEndLoc = SM.getExpansionLoc(LoopEndLoc);
                    while (SM.getCharacterData(LoopEndLoc) && *SM.getCharacterData(LoopEndLoc) != '}' && *SM.getCharacterData(LoopEndLoc) != ';') {
                        LoopEndLoc = LoopEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
                    LoopBeginLoc.dump(SM);
                    llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                    TheRewriter.InsertText(LoopBeginLoc, "\n{\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    TheRewriter.InsertTextAfterToken(LoopEndLoc, "\n}\n");
                }
                DefinedFlags.insert(FlagVarName);

                std::vector<DeclRefExpr*> DeclRefs;
                findAllDeclRefInExpr(ASE, DeclRefs);
                std::pair<DeclRefExpr*, SourceLocation> SmallestVarDestruction = findSmallestVarDestructionLoc(DeclRefs);
                bool success = false;
                if (SmallestVarDestruction.first) {
                    VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                    if (SmallestVarDecl && SmallestVarDecl->isLocalVarDeclOrParm() && SmallestVarDestruction.second.isValid()) {
                        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain && DisableLoc <= SmallestVarDestruction.second) {
                            std::string RestoreCall = getRestoreCall(ArraySubscriptExprStr, FlagVarName, RestoreVarName);
                            // llvm::errs() << "(symbolicMemberExpr) Insert at ";
                            // DisableLoc.dump(SM);
                            // llvm::errs() << RestoreCall << "\n";
                            // TheRewriter.InsertText(DisableLoc, RestoreCall);
                            RestoreInfos[getFunctionName(FD)].push_back({ArraySubscriptExprStr, FlagVarName, RestoreVarName, DisableLoc});
                            success = true;
                        }
                    }
                }

                if (!success) {
                    FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                    std::string RestoreCall = getRestoreCall(ArraySubscriptExprStr, FlagVarName, RestoreVarName);
                    SourceLocation EndLoc = FD->getBody()->getEndLoc();
                    if (EndLoc.isMacroID())
                        EndLoc = SM.getExpansionLoc(EndLoc);
                    while (SM.getCharacterData(EndLoc) && *SM.getCharacterData(EndLoc) != '}')
                        EndLoc = EndLoc.getLocWithOffset(1);

                    if (SmallestVarDestruction.second.isInvalid() || SmallestVarDestruction.second >= EndLoc) {
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain) {
                            RestoreInfos[getFunctionName(FD)].push_back({ArraySubscriptExprStr, FlagVarName, RestoreVarName, DisableLoc});
                        } else {
                            if (FD->getReturnType()->isVoidType()) {
                                TheRewriter.InsertText(EndLoc, RestoreCall);
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({ArraySubscriptExprStr, FlagVarName, RestoreVarName});
                        }
                    } else {
                        SmallestVarDestruction.second.dump(SM);
                        EndLoc.dump(SM);

                        if (*SM.getCharacterData(SmallestVarDestruction.second) == ';') {
                            TheRewriter.InsertTextAfterToken(SmallestVarDestruction.second, RestoreCall);
                            VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                            if (SmallestVarDecl) {
                                ForStmt* fs = isVarDeclInForInit(SmallestVarDecl);
                                if (fs) {
                                    checkAndAddBracesForAncestor(fs->getBody());
                                    LoopRestoreInfos[fs].push_back({ArraySubscriptExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                                }
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({ArraySubscriptExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                        } else {
                            VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                            bool NoCompoundBody = false;
                            if (SmallestVarDecl) {
                                Stmt* SmallestVarDestructionStmt = findVarDestructionLocStmt(SmallestVarDecl);
                                if (SmallestVarDestructionStmt) {
                                    ForStmt *fs = dyn_cast<ForStmt>(SmallestVarDestructionStmt);
                                    if (fs && !dyn_cast<CompoundStmt>(fs->getBody())) {
                                        NoCompoundBody = true;
                                    }
                                }
                            }

                            if (NoCompoundBody) {
                                TheRewriter.InsertTextAfterToken(SmallestVarDestruction.second, RestoreCall);
                            } else {
                                TheRewriter.InsertText(SmallestVarDestruction.second, RestoreCall);
                            }
                            if (SmallestVarDecl) {
                                ForStmt* fs = isVarDeclInForInit(SmallestVarDecl);
                                if (fs) {
                                    LoopRestoreInfos[fs].push_back({ArraySubscriptExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                                }
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({ArraySubscriptExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                        }
                    }
                }
            }

            if (SymbolicedVarsOfThisIfStmt.find(ArraySubscriptExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string RestoreAssignExpr = RestoreVarName + " = " + ArraySubscriptExprStr + ";";
                std::string SymbolicCall = getSymbolicCall(ASE->getType(), findFirstFunctionDeclAncestor(ifStmt), "(" + ArraySubscriptExprStr + ")", VarNameStr, FlagVarName, RestoreAssignExpr);
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(ArraySubscriptExprStr);
            }
        }
    }

    void symbolicDerefExpr(IfStmt* ifStmt, UnaryOperator* UO,
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        DeclRefExpr *OriginalBase = getOriginalBaseFromDerefExpr(UO);
        if (!OriginalBase)  return;

        VarDecl* VD = dyn_cast<VarDecl>(OriginalBase->getDecl());
        if (!VD)  return;
        
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation VarDeclLoc = VD->getLocation();
        if (VarDeclLoc.isMacroID())
            VarDeclLoc = SM.getExpansionLoc(VarDeclLoc);

        SourceLocation IfStartLoc = ifStmt->getBeginLoc();
        if (IfStartLoc.isMacroID())
            IfStartLoc = SM.getExpansionLoc(IfStartLoc);
        
        std::string DerefExprStr = TheRewriter.getRewrittenText(UO->getSourceRange());
        std::string FlagVarName = "tmp_" + DerefExprStr + "_flag";
        std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        FlagVarName += "_" + std::to_string(VarDeclLoc.getRawEncoding());

        std::string RestoreVarName = "tmp_" + DerefExprStr + "_restore";
        std::replace_if(RestoreVarName.begin(), RestoreVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        RestoreVarName += "_" + std::to_string(VarDeclLoc.getRawEncoding());

        std::string VarNameStr = DerefExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
        std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        auto it = SymbolicVarValueMap.find(VarNameStr);
        if (it != SymbolicVarValueMap.end()) {
            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                QualType QT = UO->getType();
                std::string RestoreVarDecl = "std::any " + RestoreVarName + ";";
                if (endWith(CurrentFilePath, ".c")) {
                    RestoreVarDecl = QT.getAsString() + " " + RestoreVarName + ";";
                }
                if (QT->isFunctionPointerType()) {
                    std::string VarType = QT.getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + RestoreVarName + ")");
                        RestoreVarDecl = VarType + ";\n";
                    }
                }
                
                std::string FlagVarDecl = "";
                if (VD->isFileVarDecl()) {
                    FlagVarDecl = "static ";
                    RestoreVarDecl = "static " + RestoreVarDecl;
                }
                FlagVarDecl += "int " + FlagVarName + " = 0;";
                Stmt* Loop = nullptr;
                if ((VD->isStaticLocal() || VD->isLocalVarDecl())) {
                    Loop = findOutermostLoopAncestorForVarDecl(VD);
                }
                if (!Loop) {
                    if (VD->isLocalVarDeclOrParm() && !VD->isStaticLocal()) {
                        SourceLocation FunctionBeginLoc = findFirstFunctionDeclAncestor(ifStmt)->getBody()->child_begin()->getBeginLoc();
                        if (FunctionBeginLoc.isMacroID())
                            FunctionBeginLoc = SM.getExpansionLoc(FunctionBeginLoc);
                        llvm::errs() << "(symbolicDerefExpr) Insert at ";
                        FunctionBeginLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        if (TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc)
                            && *TheRewriter.getSourceMgr().getCharacterData(FunctionBeginLoc) == ';') {
                                TheRewriter.InsertTextAfterToken(FunctionBeginLoc, "\n" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        } else {
                            TheRewriter.InsertText(FunctionBeginLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                        }
                    } else {
                        while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                            VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                        llvm::errs() << "(symbolicDerefExpr) Insert at ";
                        VarDeclLoc.dump(SM);
                        llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                        TheRewriter.InsertTextAfterToken(VarDeclLoc, RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    }
                } else {
                    SourceLocation LoopBeginLoc = Loop->getBeginLoc();
                    SourceLocation LoopEndLoc = Loop->getEndLoc();
                    if (LoopBeginLoc.isMacroID())
                        LoopBeginLoc = SM.getExpansionLoc(LoopBeginLoc);
                    if (LoopEndLoc.isMacroID())
                        LoopEndLoc = SM.getExpansionLoc(LoopEndLoc);
                    while (SM.getCharacterData(LoopEndLoc) && *SM.getCharacterData(LoopEndLoc) != '}' && *SM.getCharacterData(LoopEndLoc) != ';') {
                        LoopEndLoc = LoopEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(symbolicDerefExpr) Insert at ";
                    LoopBeginLoc.dump(SM);
                    llvm::errs() << RestoreVarDecl + FlagVarDecl << "\n";
                    TheRewriter.InsertText(LoopBeginLoc, "{" + RestoreVarDecl + "\n" + FlagVarDecl + "\n");
                    TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
                }
                DefinedFlags.insert(FlagVarName);

                std::vector<DeclRefExpr*> DeclRefs;
                findAllDeclRefInExpr(UO, DeclRefs);
                std::pair<DeclRefExpr*, SourceLocation> SmallestVarDestruction = findSmallestVarDestructionLoc(DeclRefs);
                bool success = false;
                if (SmallestVarDestruction.first) {
                    VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                    if (SmallestVarDecl && SmallestVarDecl->isLocalVarDeclOrParm() && SmallestVarDestruction.second.isValid()) {
                        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain && DisableLoc < SmallestVarDestruction.second) {
                            std::string RestoreCall = getRestoreCall(DerefExprStr, FlagVarName, RestoreVarName);
                            // llvm::errs() << "(symbolicMemberExpr) Insert at ";
                            // DisableLoc.dump(SM);
                            // llvm::errs() << RestoreCall << "\n";
                            // TheRewriter.InsertText(DisableLoc, RestoreCall);
                            RestoreInfos[getFunctionName(FD)].push_back({DerefExprStr, FlagVarName, RestoreVarName, DisableLoc});
                            success = true;
                        }
                    }
                }

                if (!success) {
                    FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                    std::string RestoreCall = getRestoreCall(DerefExprStr, FlagVarName, RestoreVarName);
                    SourceLocation EndLoc = FD->getBody()->getEndLoc();
                    if (EndLoc.isMacroID())
                        EndLoc = SM.getExpansionLoc(EndLoc);
                    while (SM.getCharacterData(EndLoc) && *SM.getCharacterData(EndLoc) != '}')
                        EndLoc = EndLoc.getLocWithOffset(1);

                    if (SmallestVarDestruction.second.isInvalid() || SmallestVarDestruction.second >= EndLoc) {
                        bool isMain = isMainFunction(ifStmt);
                        if (isMain) {
                            RestoreInfos[getFunctionName(FD)].push_back({DerefExprStr, FlagVarName, RestoreVarName, DisableLoc});
                        } else {
                            if (FD->getReturnType()->isVoidType()) {
                                TheRewriter.InsertText(EndLoc, RestoreCall);
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({DerefExprStr, FlagVarName, RestoreVarName});
                        }
                    } else {
                        SmallestVarDestruction.second.dump(SM);
                        EndLoc.dump(SM);

                        if (*SM.getCharacterData(SmallestVarDestruction.second) == ';') {
                            TheRewriter.InsertTextAfterToken(SmallestVarDestruction.second, RestoreCall);
                            VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                            if (SmallestVarDecl) {
                                ForStmt* fs = isVarDeclInForInit(SmallestVarDecl);
                                if (fs) {
                                    checkAndAddBracesForAncestor(fs->getBody());
                                    LoopRestoreInfos[fs].push_back({DerefExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                                }
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({DerefExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                        } else {
                            VarDecl* SmallestVarDecl = dyn_cast<VarDecl>(SmallestVarDestruction.first->getDecl());
                            bool NoCompoundBody = false;
                            if (SmallestVarDecl) {
                                Stmt* SmallestVarDestructionStmt = findVarDestructionLocStmt(SmallestVarDecl);
                                if (SmallestVarDestructionStmt) {
                                    ForStmt *fs = dyn_cast<ForStmt>(SmallestVarDestructionStmt);
                                    if (fs && !dyn_cast<CompoundStmt>(fs->getBody())) {
                                        NoCompoundBody = true;
                                    }
                                }
                            }

                            if (NoCompoundBody) {
                                TheRewriter.InsertTextAfterToken(SmallestVarDestruction.second, RestoreCall);
                            } else {
                                TheRewriter.InsertText(SmallestVarDestruction.second, RestoreCall);
                            }
                            if (SmallestVarDecl) {
                                ForStmt* fs = isVarDeclInForInit(SmallestVarDecl);
                                if (fs) {
                                    LoopRestoreInfos[fs].push_back({DerefExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                                }
                            }
                            RestoreInfos[getFunctionName(FD)].push_back({DerefExprStr, FlagVarName, RestoreVarName, SmallestVarDestruction.second});
                        }
                    }
                }
            }

            if (SymbolicedVarsOfThisIfStmt.find(DerefExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string RestoreAssignExpr = RestoreVarName + " = " + DerefExprStr + ";";
                std::string SymbolicCall = getSymbolicCall(UO->getType(), findFirstFunctionDeclAncestor(ifStmt), "(" + DerefExprStr + ")", VarNameStr, FlagVarName, RestoreAssignExpr);
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicDerefExpr) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(DerefExprStr);
            }
        }
    }

    void symbolicMacroExpr(IfStmt* ifStmt, Expr* ME,
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = ifStmt->getBeginLoc();

        std::string MacroName = TheRewriter.getRewrittenText(SourceRange(
            SM.getExpansionLoc(ME->getBeginLoc()),
            SM.getExpansionLoc(ME->getEndLoc())
        ));
        const MacroInfo *MI = PP.getMacroInfo(PP.getIdentifierInfo(MacroName));
        if (!MI)
            llvm::errs() << "MacroInfo is null for " << MacroName << "\n";
        if (MI) {
            llvm::errs() << "MacroInfo: " << MacroName << "\n";
            if(!MI->isFunctionLike()) {
                llvm::errs() << "Macro is not function-like\n";
                return;
            }
        }
        
        SourceRange MacroSourceRange = SM.getExpansionRange(ME->getSourceRange()).getAsRange();
        std::string MacroExprStr = TheRewriter.getRewrittenText(MacroSourceRange);
        std::string TmpVarName = "tmp_" + MacroExprStr + "_result";
        std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        TmpVarName += "_" + std::to_string(StartLoc.getRawEncoding());

        std::string tmpVarAssignmentExpr = TmpVarName + " = " + MacroExprStr + ";\n";
        tmpVarAssignmentExpr += "unused_tmp_value += (uint64_t)" + TmpVarName + ";\n";
        std::string FlagVarName = "tmp_" + MacroExprStr + "_flag";
        std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        FlagVarName += "_" + std::to_string(StartLoc.getRawEncoding());

        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
        std::string UniqueID = TmpVarName + "_" + getFunctionName(FD);
        
        std::string TmpVarNameStr = TmpVarName + "_" + std::to_string(StartLoc.getRawEncoding());
        auto it = SymbolicVarValueMap.find(TmpVarNameStr);
        if (it != SymbolicVarValueMap.end()) {
            if (DefinedFlags.find(UniqueID) == DefinedFlags.end()) {
                std::string VarDeclStmt = getNonConstType(ME->getType()).getAsString() + " " + TmpVarName + ";\n";
                if (ME->getType()->isFunctionPointerType()) {
                    std::string VarType = getNonConstType(ME->getType()).getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                        VarDeclStmt = VarType + ";\n";
                    }
                }
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;\n";
                SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
                if (InsertLoc.isMacroID()) {
                    InsertLoc = TheRewriter.getSourceMgr().getExpansionLoc(InsertLoc);
                }
                llvm::errs() << "(symbolicMacroExpr) Insert at ";
                InsertLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
                if (TheRewriter.getSourceMgr().getCharacterData(InsertLoc)
                    && *TheRewriter.getSourceMgr().getCharacterData(InsertLoc) == ';') {
                        TheRewriter.InsertTextAfterToken(InsertLoc, "\n" + VarDeclStmt + "\n" + FlagVarDecl + "\n");
                } else {
                    TheRewriter.InsertText(InsertLoc, VarDeclStmt + "\n" + FlagVarDecl + "\n");
                }
                DefinedFlags.insert(UniqueID);
            }

            std::string TmpVarNameStr = TmpVarName + "_" + std::to_string(StartLoc.getRawEncoding());
            if (SymbolicedVarsOfThisIfStmt.find(MacroExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string SymbolicCall = getSymbolicCall(ME->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicMacroExpr) Insert at ";
                StartLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << tmpVarAssignmentExpr + SymbolicCall << "\n";
                TheRewriter.InsertText(StartLoc, tmpVarAssignmentExpr + SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(MacroExprStr);
            }

            TheRewriter.ReplaceText(MacroSourceRange, TmpVarName);
        }
    }

    void handleIfStmt(IfStmt *ifStmt, const std::pair<unsigned, unsigned>& CR, bool IsForced = false) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = ifStmt->getBeginLoc();
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        std::pair<unsigned, unsigned> unused;
        if (!IsChanged(Line, unused) && !IsForced)
            return;

        std::string ifLocStr = StartLoc.printToString(SM);
        auto it = MakeSymbolicedIfStmts.find(ifLocStr);
        if (it != MakeSymbolicedIfStmts.end()) {
            return;
        }
        MakeSymbolicedIfStmts.insert(ifLocStr);

        Expr *Cond = ifStmt->getCond();
        std::vector<Expr*> SymbolicExprs;
        findVarDeclsAndFuncCalls(Cond, SymbolicExprs);

        std::unordered_set<std::string> SymbolicedVarsOfThisIfStmt;
        for (const auto &SymbolicExpr : SymbolicExprs) {
            if (SymbolicExpr->getBeginLoc().isMacroID() && SymbolicExpr->getEndLoc().isMacroID()) {
                symbolicMacroExpr(ifStmt, SymbolicExpr, SymbolicedVarsOfThisIfStmt, CR);
                continue;
            }

            if (DeclRefExpr *DeclRef = dyn_cast<DeclRefExpr>(SymbolicExpr)) {
                symbolicVarDecl(ifStmt, DeclRef, SymbolicedVarsOfThisIfStmt, CR);
            } else if (CallExpr *FuncCall = dyn_cast<CallExpr>(SymbolicExpr)) {
                symbolicFuncCall(ifStmt, FuncCall, SymbolicedVarsOfThisIfStmt, CR);
            } else if (BinaryOperator *BO = dyn_cast<BinaryOperator>(SymbolicExpr)) {
                // BO->dumpColor();
                symbolicAssignment(ifStmt, BO, SymbolicedVarsOfThisIfStmt, CR);
            } else if (MemberExpr *ME = dyn_cast<MemberExpr>(SymbolicExpr)) {
                // ME->dumpColor();
                if (isCXXMemberExpr(ME)) {
                    symbolicCXXMemberExpr(ifStmt, ME, SymbolicedVarsOfThisIfStmt, CR);
                } else {
                    symbolicMemberExpr(ifStmt, ME, SymbolicedVarsOfThisIfStmt, CR);
                }
            } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(SymbolicExpr)) {
                // ASE->dumpColor();
                symbolicArraySubscriptExpr(ifStmt, ASE, SymbolicedVarsOfThisIfStmt, CR);
            } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(SymbolicExpr)) {
                if (UO->getOpcode() == UO_Deref) {
                    // if (DeclRefExpr *DeclRef = dyn_cast<DeclRefExpr>(UO->getSubExpr())) {
                        symbolicDerefExpr(ifStmt, UO, SymbolicedVarsOfThisIfStmt, CR);
                    // }
                }
            }
        }
    }

    void handleOuterIfStmt(IfStmt *ifStmt, const std::pair<unsigned, unsigned>& CR, bool IsForced = false) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = ifStmt->getBeginLoc();
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        std::pair<unsigned, unsigned> unused;
        if (!IsChanged(Line, unused) && !IsForced)
            return;

        std::string ifLocStr = StartLoc.printToString(SM);
        auto it = MakeSymbolicedIfStmts.find(ifLocStr);
        if (it != MakeSymbolicedIfStmts.end()) {
            return;
        }
        MakeSymbolicedIfStmts.insert(ifLocStr);

        Expr *Cond = ifStmt->getCond();
        std::vector<Expr*> SymbolicExprs;
        findVarDeclsAndFuncCalls(Cond, SymbolicExprs);

        std::unordered_set<std::string> SymbolicedVarsOfThisIfStmt;
        for (const auto &SymbolicExpr : SymbolicExprs) {
            if (SymbolicExpr->getBeginLoc().isMacroID() && SymbolicExpr->getEndLoc().isMacroID()) {
                symbolicMacroExpr(ifStmt, SymbolicExpr, SymbolicedVarsOfThisIfStmt, CR);
                continue;
            }

            if (DeclRefExpr *DeclRef = dyn_cast<DeclRefExpr>(SymbolicExpr)) {
                symbolicVarDecl(ifStmt, DeclRef, SymbolicedVarsOfThisIfStmt, CR);
            } else if (CallExpr *FuncCall = dyn_cast<CallExpr>(SymbolicExpr)) {
                symbolicFuncCall(ifStmt, FuncCall, SymbolicedVarsOfThisIfStmt, CR);
            } else if (BinaryOperator *BO = dyn_cast<BinaryOperator>(SymbolicExpr)) {
                // BO->dumpColor();
                symbolicAssignment(ifStmt, BO, SymbolicedVarsOfThisIfStmt, CR);
            } else if (MemberExpr *ME = dyn_cast<MemberExpr>(SymbolicExpr)) {
                // ME->dumpColor();
                symbolicMemberExpr(ifStmt, ME, SymbolicedVarsOfThisIfStmt, CR);
            } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(SymbolicExpr)) {
                // ASE->dumpColor();
                symbolicArraySubscriptExpr(ifStmt, ASE, SymbolicedVarsOfThisIfStmt, CR);
            } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(SymbolicExpr)) {
                if (UO->getOpcode() == UO_Deref) {
                    // if (DeclRefExpr *DeclRef = dyn_cast<DeclRefExpr>(UO->getSubExpr())) {
                        symbolicDerefExpr(ifStmt, UO, SymbolicedVarsOfThisIfStmt, CR);
                    // }
                }
            }
        }
    }

    void handleReturnOrExitStmt(Stmt *stmt, bool IsChangedFunction, bool IsFuncFirst, bool IsStartLocEndToEndFunction, bool IsEndLocEndToEndFunction) {
        SourceLocation Loc = stmt->getBeginLoc();
        if (Loc.isMacroID()) {
            Loc = TheRewriter.getSourceMgr().getExpansionLoc(Loc);
        }
        SourceManager &SM = TheRewriter.getSourceMgr();
        unsigned Line = SM.getSpellingLineNumber(Loc);

        std::string CodeToInsert = "";

        FunctionDecl *FD = findFirstFunctionDeclAncestor(stmt);
        if (isLambdaFunctionDecl(FD)) {
            llvm::errs() << "&&&&&&&&&&&&&&&&&&&&&&&&&&&&" << "\n";
        }
        auto& RestoreInfo = RestoreInfos[getFunctionName(FD)];
        for (const auto &RI : RestoreInfo) {
            if (RI.VarDestructionLoc.isValid() && RI.VarDestructionLoc < Loc)
                continue;
            CodeToInsert += getRestoreCall(RI.VarName, RI.FlagVarName, RI.RestoreVarName);
        }

        if (IsChangedFunction) {
            if (IsFuncFirst) {
                if (IsModifiedPartMeasured) {
                    CodeToInsert += "if (should_symbolize) {\n"
                        "   clock_gettime(CLOCK_MONOTONIC, &_stop_);\n"
                        "   long _nanos_ = (_stop_.tv_sec - _start_.tv_sec) * 1000000000 + (_stop_.tv_nsec - _start_.tv_nsec);\n"
                        "   s2e_flag = S2E_DISABLED;\n"
                        "   modified_part_time += _nanos_;\n"
                        "}\n";
                } else {
                    CodeToInsert += "if (should_symbolize) {\n"
                        "   s2e_flag = S2E_DISABLED;\n"
                        "}\n";
                }
            }
        }

        if (IsStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "end") {
            if (IsServerLog) {
                CodeToInsert += "clock_gettime(CLOCK_MONOTONIC, &__start__);\n"
                    "modified_part_time = 0;\n"
                    "loop_usleep_time = 0;\n"
                    "should_symbolize = 1;\n"
                    "\n";
            } else {
                CodeToInsert += "should_symbolize = 1;\n";
            }
        }

        if (IsEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "end") {
            std::string Text = "if (should_symbolize) {\n"
                "   clock_gettime(CLOCK_MONOTONIC, &__stop__);\n"
                "   long __nanos__ = (__stop__.tv_sec - __start__.tv_sec) * 1000000000 + (__stop__.tv_nsec - __start__.tv_nsec);\n"
                "   printf(\"modified part took %f us, end to end took %f us, about %f%%, should usleep %f us\\n\", modified_part_time / 1000.0, __nanos__ / 1000.0, modified_part_time * 100.0 / __nanos__, loop_usleep_time / 1000.0);\n"
                "   modified_part_time = 0;\n"
                "   loop_usleep_time = 0;\n"
                "}\n"
                "should_symbolize = 0;\n";
            if (!IsServerLog) {
                Text = "should_symbolize = 0;\n";
            }
            CodeToInsert += "\n" + Text;
        }

        if (CodeToInsert == "") {
            return;
        }
        checkAndAddBracesForAncestor(stmt);

        // If the return statement contains a function call, we need to extract the return value expression and insert it before the return statement.
        if (ReturnStmt *RS = dyn_cast<ReturnStmt>(stmt)) {
            Expr *RetValue = RS->getRetValue();
            if (RetValue != nullptr) {
                std::vector<Expr*> SymbolicExprs;
                findVarDeclsAndFuncCalls(RetValue, SymbolicExprs);
                for (const auto &SymbolicExpr : SymbolicExprs) {
                    if (dyn_cast<CallExpr>(SymbolicExpr)) {
                        SourceLocation StartLoc = RS->getRetValue()->getBeginLoc();
                        if (StartLoc.isMacroID()) {
                            StartLoc = SM.getExpansionLoc(StartLoc);
                        }
                        SourceLocation EndLoc = RS->getRetValue()->getEndLoc();
                        if (EndLoc.isMacroID()) {
                            EndLoc = SM.getExpansionLoc(EndLoc);
                        }
                        while (SM.getCharacterData(EndLoc) && *SM.getCharacterData(EndLoc) != ';') {
                            EndLoc = EndLoc.getLocWithOffset(1);
                        }
                        EndLoc = EndLoc.getLocWithOffset(-1);

                        std::string RetValueStr = TheRewriter.getRewrittenText(SourceRange(StartLoc, EndLoc));
                        std::string RetValueVarName = "tmp_ret_value";
                        // std::string RetValueVarDecl = RetValue->getType().getAsString() + " " + RetValueVarName + " = " + RetValueStr + ";\n";
                        std::string RetValueVarDecl = "auto " + RetValueVarName + " = " + RetValueStr + ";\n";
                        TheRewriter.InsertText(RS->getBeginLoc(), RetValueVarDecl);
                        TheRewriter.ReplaceText(SourceRange(StartLoc, EndLoc), RetValueVarName);
                        break;
                    }
                }
            }
        }

        llvm::errs() << "(handleReturnOrExitStmt) Insert at ";
        Loc.dump(SM);
        llvm::errs() << CodeToInsert << "\n";
        TheRewriter.InsertText(Loc, CodeToInsert);
    }

    void checkAndAddBracesForAncestor(Stmt *stmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        auto NodeList = Context.getParents(*stmt);
        while (!NodeList.empty()) {
            // Get the first parent.
            auto ParentNode = NodeList[0];

            // Is the parent an IfStmt?
            if (const IfStmt *Parent = ParentNode.get<IfStmt>()) {
                if (CheckedBracesStmts.find(Parent) != CheckedBracesStmts.end())
                    return;
                // Check if the if statement's then and else has braces, if not, add them.
                Stmt *Then = const_cast<IfStmt *>(Parent)->getThen();
                Stmt *Else = const_cast<IfStmt *>(Parent)->getElse();
                if (Then && !isa<CompoundStmt>(Then)) {
                    SourceLocation ThenBeginLoc = Then->getBeginLoc();
                    if (ThenBeginLoc.isMacroID()) {
                        ThenBeginLoc = SM.getExpansionLoc(ThenBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    ThenBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(ThenBeginLoc, "{\n");
                    SourceLocation ThenEndLoc = Then->getEndLoc();
                    if (ThenEndLoc.isMacroID()) {
                        ThenEndLoc = SM.getExpansionLoc(ThenEndLoc);
                    }
                    while (SM.getCharacterData(ThenEndLoc) && *SM.getCharacterData(ThenEndLoc) != ';' && *SM.getCharacterData(ThenEndLoc) != '}') {
                        ThenEndLoc = ThenEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    ThenEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(ThenEndLoc.getLocWithOffset(1), "}\n");
                }
                if (Else && !isa<CompoundStmt>(Else)) {
                    SourceLocation ElseBeginLoc = Else->getBeginLoc();
                    if (ElseBeginLoc.isMacroID()) {
                        ElseBeginLoc = SM.getExpansionLoc(ElseBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    ElseBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(ElseBeginLoc, "{\n");
                    SourceLocation ElseEndLoc = Else->getEndLoc();
                    if (ElseEndLoc.isMacroID()) {
                        ElseEndLoc = SM.getExpansionLoc(ElseEndLoc);
                    }
                    while (SM.getCharacterData(ElseEndLoc) && *SM.getCharacterData(ElseEndLoc) != ';' && *SM.getCharacterData(ElseEndLoc) != '}') {
                        ElseEndLoc = ElseEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    ElseEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(ElseEndLoc.getLocWithOffset(1), "}\n");
                }
                CheckedBracesStmts.insert(Parent);
                return;
            }

            if (const ForStmt *Parent = ParentNode.get<ForStmt>()) {
                if (CheckedBracesStmts.find(Parent) != CheckedBracesStmts.end())
                    return;
                // Check if the for statement's body has braces, if not, add them.
                Stmt *Body = const_cast<ForStmt *>(Parent)->getBody();
                if (Body && !isa<CompoundStmt>(Body)) {
                    SourceLocation BodyBeginLoc = Body->getBeginLoc();
                    if (BodyBeginLoc.isMacroID()) {
                        BodyBeginLoc = SM.getExpansionLoc(BodyBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    BodyBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(BodyBeginLoc, "{\n");
                    SourceLocation BodyEndLoc = Body->getEndLoc();
                    if (BodyEndLoc.isMacroID()) {
                        BodyEndLoc = SM.getExpansionLoc(BodyEndLoc);
                    }
                    while (SM.getCharacterData(BodyEndLoc) && *SM.getCharacterData(BodyEndLoc) != ';' && *SM.getCharacterData(BodyEndLoc) != '}') {
                        BodyEndLoc = BodyEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    BodyEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(BodyEndLoc.getLocWithOffset(1), "}\n");
                }
                CheckedBracesStmts.insert(Parent);
                return;
            }

            if (const WhileStmt *Parent = ParentNode.get<WhileStmt>()) {
                if (CheckedBracesStmts.find(Parent) != CheckedBracesStmts.end())
                    return;
                // Check if the while statement's body has braces, if not, add them.
                Stmt *Body = const_cast<WhileStmt *>(Parent)->getBody();
                if (Body && !isa<CompoundStmt>(Body)) {
                    SourceLocation BodyBeginLoc = Body->getBeginLoc();
                    if (BodyBeginLoc.isMacroID()) {
                        BodyBeginLoc = SM.getExpansionLoc(BodyBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    BodyBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(BodyBeginLoc, "{\n");
                    SourceLocation BodyEndLoc = Body->getEndLoc();
                    if (BodyEndLoc.isMacroID()) {
                        BodyEndLoc = SM.getExpansionLoc(BodyEndLoc);
                    }
                    while (SM.getCharacterData(BodyEndLoc) && *SM.getCharacterData(BodyEndLoc) != ';' && *SM.getCharacterData(BodyEndLoc) != '}') {
                        BodyEndLoc = BodyEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    BodyEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(BodyEndLoc.getLocWithOffset(1), "}\n");
                }
                CheckedBracesStmts.insert(Parent);
                return;
            }

            if (const DoStmt *Parent = ParentNode.get<DoStmt>()) {
                if (CheckedBracesStmts.find(Parent) != CheckedBracesStmts.end())
                    return;
                // Check if the do statement's body has braces, if not, add them.
                Stmt *Body = const_cast<DoStmt *>(Parent)->getBody();
                if (Body && !isa<CompoundStmt>(Body)) {
                    SourceLocation BodyBeginLoc = Body->getBeginLoc();
                    if (BodyBeginLoc.isMacroID()) {
                        BodyBeginLoc = SM.getExpansionLoc(BodyBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    BodyBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(BodyBeginLoc, "{\n");
                    SourceLocation BodyEndLoc = Body->getEndLoc();
                    if (BodyEndLoc.isMacroID()) {
                        BodyEndLoc = SM.getExpansionLoc(BodyEndLoc);
                    }
                    while (SM.getCharacterData(BodyEndLoc) && *SM.getCharacterData(BodyEndLoc) != ';' && *SM.getCharacterData(BodyEndLoc) != '}') {
                        BodyEndLoc = BodyEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    BodyEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(BodyEndLoc.getLocWithOffset(1), "}\n");
                }
                CheckedBracesStmts.insert(Parent);
                return;
            }

            if (const SwitchStmt *Parent = ParentNode.get<SwitchStmt>()) {
                if (CheckedBracesStmts.find(Parent) != CheckedBracesStmts.end())
                    return;
                // Check if the switch statement's body has braces, if not, add them.
                Stmt *Body = const_cast<SwitchStmt *>(Parent)->getBody();
                if (Body && !isa<CompoundStmt>(Body)) {
                    SourceLocation BodyBeginLoc = Body->getBeginLoc();
                    if (BodyBeginLoc.isMacroID()) {
                        BodyBeginLoc = SM.getExpansionLoc(BodyBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    BodyBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(BodyBeginLoc, "{\n");
                    SourceLocation BodyEndLoc = Body->getEndLoc();
                    if (BodyEndLoc.isMacroID()) {
                        BodyEndLoc = SM.getExpansionLoc(BodyEndLoc);
                    }
                    while (SM.getCharacterData(BodyEndLoc) && *SM.getCharacterData(BodyEndLoc) != ';' && *SM.getCharacterData(BodyEndLoc) != '}') {
                        BodyEndLoc = BodyEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    BodyEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(BodyEndLoc.getLocWithOffset(1), "}\n");
                }
                CheckedBracesStmts.insert(Parent);
                return;
            }

            if (const CaseStmt *Parent = ParentNode.get<CaseStmt>()) {
                if (CheckedBracesStmts.find(Parent) != CheckedBracesStmts.end())
                    return;
                // Check if the case statement's body has braces, if not, add them.
                Stmt *SubStmt = const_cast<CaseStmt *>(Parent)->getSubStmt();
                if (SubStmt && !isa<CompoundStmt>(SubStmt)) {
                    SourceLocation SubStmtBeginLoc = SubStmt->getBeginLoc();
                    if (SubStmtBeginLoc.isMacroID()) {
                        SubStmtBeginLoc = SM.getExpansionLoc(SubStmtBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    SubStmtBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(SubStmtBeginLoc, "{\n");
                    SourceLocation SubStmtEndLoc = SubStmt->getEndLoc();
                    if (SubStmtEndLoc.isMacroID()) {
                        SubStmtEndLoc = SM.getExpansionLoc(SubStmtEndLoc);
                    }
                    while (SM.getCharacterData(SubStmtEndLoc) && *SM.getCharacterData(SubStmtEndLoc) != ';' && *SM.getCharacterData(SubStmtEndLoc) != '}') {
                        SubStmtEndLoc = SubStmtEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    SubStmtEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(SubStmtEndLoc.getLocWithOffset(1), "}\n");
                }
                CheckedBracesStmts.insert(Parent);
                return;
            }

            if (const DefaultStmt *Parent = ParentNode.get<DefaultStmt>()) {
                if (CheckedBracesStmts.find(Parent) != CheckedBracesStmts.end())
                    return;
                // Check if the default statement's body has braces, if not, add them.
                Stmt *SubStmt = const_cast<DefaultStmt *>(Parent)->getSubStmt();
                if (SubStmt && !isa<CompoundStmt>(SubStmt)) {
                    SourceLocation SubStmtBeginLoc = SubStmt->getBeginLoc();
                    if (SubStmtBeginLoc.isMacroID()) {
                        SubStmtBeginLoc = SM.getExpansionLoc(SubStmtBeginLoc);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert at ";
                    SubStmtBeginLoc.dump(SM);
                    llvm::errs() << "{\n";
                    TheRewriter.InsertText(SubStmtBeginLoc, "{\n");
                    SourceLocation SubStmtEndLoc = SubStmt->getEndLoc();
                    if (SubStmtEndLoc.isMacroID()) {
                        SubStmtEndLoc = SM.getExpansionLoc(SubStmtEndLoc);
                    }
                    while (SM.getCharacterData(SubStmtEndLoc) && *SM.getCharacterData(SubStmtEndLoc) != ';' && *SM.getCharacterData(SubStmtEndLoc) != '}') {
                        SubStmtEndLoc = SubStmtEndLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(checkAndAddBracesForAncestor) Insert after ";
                    SubStmtEndLoc.dump(SM);
                    llvm::errs() << "}\n";
                    TheRewriter.InsertText(SubStmtEndLoc.getLocWithOffset(1), "}\n");
                }
                CheckedBracesStmts.insert(Parent);
                return;
            }

            // Is the parent a FunctionDecl?
            if (ParentNode.get<FunctionDecl>()) {
                return;
            }

            // Keep going up.
            NodeList = Context.getParents(ParentNode);
        }
    }

    // void handleAssertMacro(ParenExpr *parenExpr) {
    //     SourceManager &SM = TheRewriter.getSourceMgr();
    //     SourceLocation ExpansionLoc = SM.getExpansionLoc(parenExpr->getBeginLoc());
    //     unsigned Line = SM.getSpellingLineNumber(ExpansionLoc);

    //     // llvm::errs() << "handleAssertMacro: (" << SM.getSpellingColumnNumber(ExpansionLoc) << ", " << SM.getSpellingColumnNumber(SM.getExpansionRange(parenExpr->getSourceRange()).getEnd()) << ")\n";

    //     if (Line >= StartLine && Line <= EndLine) {
    //         const CXXStaticCastExpr *Arg = dyn_cast<CXXStaticCastExpr>(parenExpr->getSubExpr());
    //         if (!Arg) {
    //             return;
    //         }
    //         std::string ArgStr;
    //         llvm::raw_string_ostream ArgStream(ArgStr);
    //         Arg->children().begin()
    //         ->printPretty(ArgStream, nullptr, PrintingPolicy(LangOptions()));
    //         ArgStream.flush();

    //         parenExpr->dumpColor();
    //         llvm::errs() << "Arg: ";
    //         Arg->dumpColor();
    //         llvm::errs() << "ArgStr: " << ArgStr << "\n";
    //         Arg->children().begin()->dumpColor();

    //         // 构造替换代码
    //         std::string CodeToInsert = "if (!(" + ArgStr + ")) {\n"
    //                                    "    s2e_thread_exec_disable_current();\n"
    //                                    "    if (s2e_flag == SYMBOLICED)\n"
    //                                    "        s2e_kill_state(0, \"Program terminated\");\n"
    //                                    "}\n";
    //         // Replace the assert macro(expansion location) with the inserted code
    //         TheRewriter.ReplaceText(SM.getExpansionRange(parenExpr->getSourceRange()), CodeToInsert);
    //     }
    // }

    void findVarDeclsAndFuncCalls(Expr *E, std::vector<Expr*>& SymbolicExprs) {
        // If the E is a macro, we just skip it.
        if (E->getBeginLoc().isMacroID() && E->getEndLoc().isMacroID()) {
            SymbolicExprs.push_back(E);
            return;
        }

        if (DeclRefExpr *DRE = dyn_cast<DeclRefExpr>(E)) {
            SymbolicExprs.push_back(DRE);
            return;
        } else if (CallExpr *CE = dyn_cast<CallExpr>(E)) {
            SymbolicExprs.push_back(CE);
            return;
        } else if (BinaryOperator *BO = dyn_cast<BinaryOperator>(E)) {
            if (BO->isAssignmentOp()) {
                // BO->dumpColor();
                // llvm::errs() << '\n';
                if (dyn_cast<DeclRefExpr>(BO->getLHS())) {
                    // BO->getLHS()->dumpColor();
                    SymbolicExprs.push_back(BO);
                    return;
                }
                if (dyn_cast<ImplicitCastExpr>(BO->getLHS())) {
                    ImplicitCastExpr *ICE = dyn_cast<ImplicitCastExpr>(BO->getLHS());
                    if (dyn_cast<DeclRefExpr>(ICE->getSubExpr())) {
                        SymbolicExprs.push_back(BO);
                        return;
                    }
                }
            }
        } else if (MemberExpr *ME = dyn_cast<MemberExpr>(E)) {
            SymbolicExprs.push_back(ME);
            return;
        } else if (ArraySubscriptExpr *ASE = dyn_cast<ArraySubscriptExpr>(E)) {
            SymbolicExprs.push_back(ASE);
            return;
        } else if (UnaryOperator *UO = dyn_cast<UnaryOperator>(E)) {
            if (UO->getOpcode() == UO_Deref) {
                SymbolicExprs.push_back(UO);
                return;
            }
            if (UO->getOpcode() == UO_AddrOf) {
                return;
            }
        }
        for (Stmt *Child : E->children()) {
            if (Expr *ChildExpr = dyn_cast<Expr>(Child)) {
                findVarDeclsAndFuncCalls(ChildExpr, SymbolicExprs);
            }
        }
    }

    struct RestoreInfo {
        std::string VarName;
        std::string FlagVarName;
        std::string RestoreVarName;
        SourceLocation VarDestructionLoc;
    };

    ASTContext &Context;
    Rewriter &TheRewriter;
    Preprocessor &PP;
    const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo;
    std::unordered_set<std::string> DefinedFlags;
    std::unordered_set<std::string> MakeSymbolicedIfStmts;
    std::unordered_set<const Stmt*> CheckedBracesStmts;
    std::vector<Stmt*> LoopFlagStack;
    std::unordered_map<Stmt*, std::vector<RestoreInfo>> LoopRestoreInfos;
    std::unordered_map<std::string, std::vector<RestoreInfo>> RestoreInfos;
    std::unordered_set<VarDecl*> ConstVarDecls;

    SourceLocation& IncludeLoc;
    bool NoNeedToInsertEnd;
    SourceLocation EnableLoc, DisableLoc, KillStateLoc;
    unsigned EnableLine, DisableLine, KillStateLine;
};

class RealExecutionConsumer : public ASTConsumer {
public:
    RealExecutionConsumer(Rewriter &R, Preprocessor &PP, const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : R(R), PP(PP), FuncChangeInfo(FuncChangeInfo) {}

    void HandleTranslationUnit(ASTContext &Context) override {
        RealExecutionVisitor Visitor(Context, R, PP, FuncChangeInfo, IncludeLoc);
        Visitor.TraverseDecl(Context.getTranslationUnitDecl());

        if (IncludeLoc.isInvalid()) {
            // 获取源代码管理器
            SourceManager &SourceMgr = Context.getSourceManager();
            // 获取主文件的FileID
            FileID MainFileID = SourceMgr.getMainFileID();
            // 获取文件的开始位置
            IncludeLoc = SourceMgr.getLocForStartOfFile(MainFileID);
        }
        
        // 获取源代码管理器
        SourceManager &SourceMgr = Context.getSourceManager();

        llvm::errs() << "(HandleTranslationUnit) Insert at ";
        IncludeLoc.dump(SourceMgr);

        // 如果 CurrentFilePath 以.c结尾
        if (endWith(CurrentFilePath, ".c")) {
            llvm::errs() << "#include <symbolic.h>\n"
                "extern int should_symbolize;\n"
                "extern uint64_t modified_part_time;\n"
                "extern uint64_t unused_tmp_value;\n"
                "extern uint64_t loop_usleep_time;\n"
                "extern struct timespec __start__, __stop__;\n"
                "extern int s2e_flag;\n\n";

            R.InsertText(
                IncludeLoc,
                "#include <symbolic.h>\n"
                "extern int should_symbolize;\n"
                "extern uint64_t modified_part_time;\n"
                "extern uint64_t unused_tmp_value;\n"
                "extern uint64_t loop_usleep_time;\n"
                "extern struct timespec __start__, __stop__;\n"
                "extern int s2e_flag;\n\n"
            );
        } else {
            llvm::errs() << "#include <any>\n"
                "extern \"C\" {\n"
                "#include <symbolic.h>\n"
                "extern int should_symbolize;\n"
                "extern uint64_t modified_part_time;\n"
                "extern uint64_t unused_tmp_value;\n"
                "extern uint64_t loop_usleep_time;\n"
                "extern struct timespec __start__, __stop__;\n"
                "extern int s2e_flag;\n"
                "}\n\n";

            R.InsertText(
                IncludeLoc,
                "#include <any>\n"
                "extern \"C\" {\n"
                "#include <symbolic.h>\n"
                "extern int should_symbolize;\n"
                "extern uint64_t modified_part_time;\n"
                "extern uint64_t unused_tmp_value;\n"
                "extern uint64_t loop_usleep_time;\n"
                "extern struct timespec __start__, __stop__;\n"
                "extern int s2e_flag;\n"
                "}\n\n"
            );
        }
    }

private:
    Rewriter &R;
    Preprocessor &PP;
    const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo;
    SourceLocation IncludeLoc;
};

class RealExecutionAction : public ASTFrontendAction {
public:
    RealExecutionAction() = default;
    RealExecutionAction(const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : FuncChangeInfo(FuncChangeInfo) {}

    std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI, StringRef file) override {
        TheRewriter.setSourceMgr(CI.getSourceManager(), CI.getLangOpts());
        return std::make_unique<RealExecutionConsumer>(TheRewriter, CI.getPreprocessor(), FuncChangeInfo);
    }

    void ExecuteAction() override {
        // 调用基类的ExecuteAction
        ASTFrontendAction::ExecuteAction();
    }

    bool shouldEraseOutputFiles() override {
        return FrontendAction::shouldEraseOutputFiles();
    }

    void EndSourceFile() override {
        FrontendAction::EndSourceFile();
    }

    void EndSourceFileAction() override {
        // SourceManager &SM = TheRewriter.getSourceMgr();
        // llvm::errs() << "** EndSourceFileAction for: "
        //              << SM.getFileEntryRefForID(SM.getMainFileID())->getName() << "\n";
        // TheRewriter.getEditBuffer(SM.getMainFileID()).write(llvm::outs());

        // Inplace overwrite the changed files
        llvm::errs() << "Inplace overwrite the changed files\n";
        llvm::errs() << FuncChangeInfo.size() << "\n";
        TheRewriter.overwriteChangedFiles();
    }

private:
    Rewriter TheRewriter;
    const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo;
};

class RealExecutionActionFactory : public FrontendActionFactory {
public:
    RealExecutionActionFactory(const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : FuncChangeInfo(FuncChangeInfo) {}

    std::unique_ptr<FrontendAction> create() override {
        return std::make_unique<RealExecutionAction>(FuncChangeInfo);
    }

private:
    const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo;
};

std::string exec(const char* cmd) {
    std::array<char, 128> buffer;
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
        llvm::errs() << "popen() failed!\n";
        return "";
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    return result;
}

int main(int argc, const char **argv) {
    auto ExpectedParser = CommonOptionsParser::create(argc, argv, MyToolCategory);
    if (!ExpectedParser) {
        llvm::errs() << ExpectedParser.takeError();
        return 1;
    }
    CommonOptionsParser &OptionsParser = ExpectedParser.get();

    std::cout << "IsModifiedPartMeasured: " << IsModifiedPartMeasured << "\n";
    std::cout << "IsLoopBoost: " << IsLoopBoost << "\n";
    std::cout << "IsServerLog: " << IsServerLog << "\n";
    std::cout << "IsEndToEnd: " << IsEndToEnd << "\n";

#ifdef MYSQL
    std::ifstream ifs("testcase.txt");
    if (!ifs.is_open()) {
        llvm::errs() << "Open testcase.txt failed\n";
        return 1;
    }
    std::getline(ifs, Testcase);
    Testcase = Testcase.substr(0, Testcase.size() - 1);
    ifs.close();
#endif

    std::ifstream File("symbolic_testcase.txt");
    if (File) {
        std::string SymbolicVarValueLine;
        while (std::getline(File, SymbolicVarValueLine)) {
            if (SymbolicVarValueLine == "EOF" || SymbolicVarValueLine == "") {
                break;
            }
            std::stringstream ss(SymbolicVarValueLine);
            std::string VarName;
            ss >> VarName;
            size_t pos = VarName.find_first_of('_');
            if (pos != std::string::npos)
                VarName = VarName.substr(pos + 1);
            pos = VarName.find_last_of('_');
            if (pos != std::string::npos)
                VarName = VarName.substr(0, pos);
            uint64_t VarValue;
            ss >> VarValue;
            SymbolicVarValueMap[VarName] = VarValue;
        }
        File.close();
    }

    for (const auto &SymbolicVarValue : SymbolicVarValueMap) {
        llvm::errs() << SymbolicVarValue.first << " " << SymbolicVarValue.second << "\n";
    }

    if (IsEndToEnd) {
        File.open("end_to_end.txt");
        if (!File) {
            llvm::errs() << "Open end_to_end.txt failed\n";
            return 1;
        }
        File >> StartLocEndToEndFunctionFilePath >> StartLocEndToEndFunctionName >> StartLocEndToEndFunctionLocation;
        File >> EndLocEndToEndFunctionFilePath >> EndLocEndToEndFunctionName >> EndLocEndToEndFunctionLocation;
        File.close();
    }

    std::string line;
    bool IsStartLocEndToEndFileChanged = false;
    bool IsEndLocEndToEndFileChanged = false;
    while (std::getline(std::cin, line)) {
        if (line == "EOF" || line == "") {
            break;
        }
        
        RealExecutionContext Context;
        std::stringstream ss(line);
        unsigned CallExprLine;
        while (ss >> CallExprLine) {
            Context.CallExprLines.push_back(CallExprLine);
        }
        sort(Context.CallExprLines.begin(), Context.CallExprLines.end());
        ss.clear();
        bool IsFirst = true;
        while (std::getline(std::cin, line)) {
            if (line == "EOF" || line == "") {
                break;
            }
            if (line.find("testcase") == 0) {
                continue;
            }

            FuncChangeInfoClass FuncChangeInfo;
            std::stringstream ss(line);
            unsigned StartLine, EndLine;
            ss >> FuncChangeInfo.FuncName;
            ss >> FuncChangeInfo.FilePath;
            while (ss >> StartLine >> EndLine)
                FuncChangeInfo.ChangeRanges.push_back(std::make_pair(StartLine, EndLine));
            if (IsFirst) {
                assert(Context.CallExprLines.size() > 0);
                FuncChangeInfo.CallExprStartLine = *Context.CallExprLines.begin();
                FuncChangeInfo.CallExprEndLine = *Context.CallExprLines.rbegin();
                MainFilePath = FuncChangeInfo.FilePath;
                IsFirst = false;
            } else {
                FuncChangeInfo.CallExprStartLine = 0xffffffff;
                FuncChangeInfo.CallExprEndLine = 0xffffffff;
            }
            Context.FuncChangeInfos[FuncChangeInfo.FilePath][FuncChangeInfo.FuncName] = FuncChangeInfo;
        }

        for (const auto &FuncChangeInfo : Context.FuncChangeInfos) {
            std::string FilePath = FuncChangeInfo.first;
            std::vector<std::string> SourcePaths = {FilePath};
            if (FilePath == StartLocEndToEndFunctionFilePath) {
                IsStartLocEndToEndFileChanged = true;
            }

            if (FilePath == EndLocEndToEndFunctionFilePath) {
                IsEndLocEndToEndFileChanged = true;
            }

            CompilationDatabase &Compilations = OptionsParser.getCompilations();
            const std::vector<clang::tooling::CompileCommand>& CompileCommands =
                Compilations.getCompileCommands(FilePath);

            std::string Directory = ".";
            std::vector<std::string> Args;
            for (const auto &CompileCommand : CompileCommands) {
                Directory = CompileCommand.Directory;
                if (Directory.find("/test") != std::string::npos || Directory.find("/client") != std::string::npos) {
                    continue;
                }
                for (const auto &Arg : CompileCommand.CommandLine) {
                    Args.push_back(Arg);
                }
                Args.erase(Args.begin());
                Args.pop_back();
                Args.pop_back();
                break;
            }

            FixedCompilationDatabase FixedCompilations(Directory, Args);
            ClangTool Tool(FixedCompilations, SourcePaths);

            std::string ResourceDir = exec("clang --print-resource-dir");
            size_t pos = ResourceDir.find_first_of("\n");
            if (pos != std::string::npos)
                ResourceDir = ResourceDir.substr(0, pos);
            // llvm::outs() << "ResourceDir: " << ResourceDir << "\n";

            if (ResourceDir == "") {
                llvm::errs() << "Get clang resource dir failed\n";
                return 1;
            }

            // 添加额外的编译选项
            std::vector<std::string> extraArgs = {
                "-resource-dir", ResourceDir
            };

            Tool.appendArgumentsAdjuster(getInsertArgumentAdjuster(extraArgs, ArgumentInsertPosition::END));

            RealExecutionActionFactory Factory(FuncChangeInfo.second);
            llvm::errs() << "Run Tool on: " << FilePath << "\n";
            CurrentFilePath = FilePath;
            Tool.run(&Factory);
        }
    }

    if (StartLocEndToEndFunctionFilePath != "" && !IsStartLocEndToEndFileChanged) {
        std::vector<std::string> SourcePaths = {StartLocEndToEndFunctionFilePath};
        CompilationDatabase &Compilations = OptionsParser.getCompilations();
        const std::vector<clang::tooling::CompileCommand>& CompileCommands =
            Compilations.getCompileCommands(StartLocEndToEndFunctionFilePath);

        std::string Directory = ".";
        std::vector<std::string> Args;
        for (const auto &CompileCommand : CompileCommands) {
            Directory = CompileCommand.Directory;
            if (Directory.find("/test") != std::string::npos || Directory.find("/client") != std::string::npos) {
                continue;
            }
            for (const auto &Arg : CompileCommand.CommandLine) {
                Args.push_back(Arg);
            }
            Args.erase(Args.begin());
            Args.pop_back();
            Args.pop_back();
            break;
        }

        FixedCompilationDatabase FixedCompilations(Directory, Args);
        ClangTool Tool(FixedCompilations, SourcePaths);

        std::string ResourceDir = exec("clang --print-resource-dir");
        size_t pos = ResourceDir.find_first_of("\n");
        if (pos != std::string::npos)
            ResourceDir = ResourceDir.substr(0, pos);
        // llvm::outs() << "ResourceDir: " << ResourceDir << "\n";

        if (ResourceDir == "") {
            llvm::errs() << "Get clang resource dir failed\n";
            return 1;
        }

        // 添加额外的编译选项
        std::vector<std::string> extraArgs = {
            "-resource-dir", ResourceDir
        };

        Tool.appendArgumentsAdjuster(getInsertArgumentAdjuster(extraArgs, ArgumentInsertPosition::END));

        RealExecutionActionFactory Factory({});
        llvm::errs() << "Run Tool on: " << StartLocEndToEndFunctionFilePath << "\n";
        CurrentFilePath = StartLocEndToEndFunctionFilePath;
        Tool.run(&Factory);
    }

    if (EndLocEndToEndFunctionFilePath != "" && 
        EndLocEndToEndFunctionFilePath != StartLocEndToEndFunctionFilePath && 
        !IsEndLocEndToEndFileChanged) {
        std::vector<std::string> SourcePaths = {EndLocEndToEndFunctionFilePath};
        CompilationDatabase &Compilations = OptionsParser.getCompilations();
        const std::vector<clang::tooling::CompileCommand>& CompileCommands =
            Compilations.getCompileCommands(EndLocEndToEndFunctionFilePath);

        std::string Directory = ".";
        std::vector<std::string> Args;
        for (const auto &CompileCommand : CompileCommands) {
            Directory = CompileCommand.Directory;
            if (Directory.find("/test") != std::string::npos || Directory.find("/client") != std::string::npos) {
                continue;
            }
            for (const auto &Arg : CompileCommand.CommandLine) {
                Args.push_back(Arg);
            }
            Args.erase(Args.begin());
            Args.pop_back();
            Args.pop_back();
            break;
        }

        FixedCompilationDatabase FixedCompilations(Directory, Args);
        ClangTool Tool(FixedCompilations, SourcePaths);

        std::string ResourceDir = exec("clang --print-resource-dir");
        size_t pos = ResourceDir.find_first_of("\n");
        if (pos != std::string::npos)
            ResourceDir = ResourceDir.substr(0, pos);
        // llvm::outs() << "ResourceDir: " << ResourceDir << "\n";

        if (ResourceDir == "") {
            llvm::errs() << "Get clang resource dir failed\n";
            return 1;
        }

        // 添加额外的编译选项
        std::vector<std::string> extraArgs = {
            "-resource-dir", ResourceDir
        };

        Tool.appendArgumentsAdjuster(getInsertArgumentAdjuster(extraArgs, ArgumentInsertPosition::END));

        RealExecutionActionFactory Factory({});
        llvm::errs() << "Run Tool on: " << EndLocEndToEndFunctionFilePath << "\n";
        CurrentFilePath = EndLocEndToEndFunctionFilePath;
        Tool.run(&Factory);
    }
    
    return 0;
}
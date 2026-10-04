#include <clang/AST/AST.h>
#include <clang/AST/RecursiveASTVisitor.h>
#include <clang/AST/ASTContext.h>
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
#include <unistd.h>

using namespace clang;
using namespace clang::tooling;

static llvm::cl::OptionCategory MyToolCategory("my-tool options");
static llvm::cl::opt<bool> IsNewVersion("new-version",
    llvm::cl::desc("Indicate if the target code is new version."), 
    llvm::cl::init(true), llvm::cl::cat(MyToolCategory));

std::string StartLocEndToEndFunctionName = "";
std::string StartLocEndToEndFunctionFilePath = "";
std::string StartLocEndToEndFunctionLocation = "";
std::string EndLocEndToEndFunctionName = "";
std::string EndLocEndToEndFunctionFilePath = "";
std::string EndLocEndToEndFunctionLocation = "";
std::string ModifiedPartFunctionName = "";
std::string CurrentFilePath = "";
std::string CurrentDirectory = "";
int ModifiedPartEnableLocEncoding = 0;
int ModifiedPartDisableLocEncoding = 0;

struct FuncChangeInfoClass {
    std::string FuncName;
    std::string FilePath;
    unsigned CallExprStartLine, CallExprEndLine;
    std::vector<std::pair<unsigned, unsigned>> ChangeRanges;
};

class MakeSymbolicContext {
public:
    std::vector<unsigned> CallExprLines;
    std::unordered_map<std::string, std::unordered_map<std::string, FuncChangeInfoClass>> FuncChangeInfos;
};

class MakeSymbolicVisitor : public RecursiveASTVisitor<MakeSymbolicVisitor> {
public:
    MakeSymbolicVisitor(ASTContext& Context, Rewriter &R, Preprocessor &PP, const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo, SourceLocation& IncludeLoc)
        : Context(Context), TheRewriter(R), PP(PP), FuncChangeInfo(FuncChangeInfo), IncludeLoc(IncludeLoc), NoNeedToInsertEnd(false), EnableLine(0), DisableLine(0), KillStateLine(0) {}

    bool TraverseFunctionDecl(FunctionDecl* f) {
        if (!f->isThisDeclarationADefinition() || !f->hasBody() || !f->getBody()
            || f->getBody()->child_begin() == f->getBody()->child_end()) {
            return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseFunctionDecl(f);
        }

        std::string FuncName = f->getNameInfo().getName().getAsString();
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        bool isModifiedPartFunction = (!IsNewVersion && FuncName == ModifiedPartFunctionName);
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction && !isModifiedPartFunction) {
            return true;
        }

        SourceLocation StartLoc = f->getBeginLoc();
        if (StartLoc.isMacroID()) {
            StartLoc = TheRewriter.getSourceMgr().getExpansionLoc(StartLoc);
        }

        unsigned Line = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);
        if (IncludeLoc.isInvalid() || Line < TheRewriter.getSourceMgr().getSpellingLineNumber(IncludeLoc)) {
            IncludeLoc = StartLoc;
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

            llvm::errs() << "(TraverseFunctionDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << "should_symbolize = 1;\n";

            TheRewriter.InsertText(
                FirstChildrenStartLoc,
                "should_symbolize = 1;\n"
            );
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "start") {
            SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
            if (FirstChildrenStartLoc.isMacroID()) {
                FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
            }

            llvm::errs() << "(TraverseFunctionDecl)Insert at ";
            FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << "should_symbolize = 0;\n";

            TheRewriter.InsertText(
                FirstChildrenStartLoc,
                "should_symbolize = 0;\n"
            );
        }

        bool isMainFunction = false;
        if (IsNewVersion && isChangedFunction) {
            isMainFunction = !(itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff);
            if (!isMainFunction) {
                SourceLocation FirstChildrenStartLoc = f->getBody()->child_begin()->getBeginLoc();
                if (FirstChildrenStartLoc.isMacroID()) {
                    FirstChildrenStartLoc = TheRewriter.getSourceMgr().getExpansionLoc(FirstChildrenStartLoc);
                }
                llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                FirstChildrenStartLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << "static int s2e_func_called = 0;\n";
                TheRewriter.InsertText(
                    FirstChildrenStartLoc,
                    "static int s2e_func_called = 0;\n"
                );
            } else {
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
                insertCodeAtFunctionBody(FuncBody, StartLine, EndLine, f->getReturnType()->isVoidType(), FuncName);
                llvm::errs() << "EnableLine: " << EnableLine << "\n";
                llvm::errs() << "DisableLine: " << DisableLine << "\n";
                llvm::errs() << "KillStateLine: " << KillStateLine << "\n";

                llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                EnableLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << "if (should_symbolize) {\n"
                    "   s2e__thread_exec_enable_current();\n"
                    "   s2e__icount_reset();\n"
                    "   s2e__icount_begin();\n"
                    "   s2e__enable_forking();\n"
                    "   s2e_flag = S2E_ENABLED;\n"
                    "}\n";
                TheRewriter.InsertText(
                    EnableLoc,
                    "if (should_symbolize) {\n"
                    "   s2e__thread_exec_enable_current();\n"
                    "   s2e__icount_reset();\n"
                    "   s2e__icount_begin();\n"
                    "   s2e__enable_forking();\n"
                    "   s2e_flag = S2E_ENABLED;\n"
                    "}\n"
                );
            }
        }

        if (!IsNewVersion && isModifiedPartFunction) {
            Stmt *FuncBody = f->getBody();
 
            // 在函数体的开始和结束之间找到合适的位置插入代码
            insertCodeAtFunctionBodyForOldVersion(FuncBody, f->getReturnType()->isVoidType());
            llvm::errs() << "EnableLine: " << EnableLine << "\n";
            llvm::errs() << "DisableLine: " << DisableLine << "\n";
            llvm::errs() << "KillStateLine: " << KillStateLine << "\n";

            llvm::errs() << "(TraverseFunctionDecl)Insert at ";
            EnableLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << "if (should_symbolize) {\n"
                "   s2e__thread_exec_enable_current();\n"
                "   s2e__icount_reset();\n"
                "   s2e__icount_begin();\n"
                "   s2e__enable_forking();\n"
                "   s2e_flag = S2E_ENABLED;\n"
                "}\n";
            TheRewriter.InsertText(
                EnableLoc,
                "if (should_symbolize) {\n"
                "   s2e__thread_exec_enable_current();\n"
                "   s2e__icount_reset();\n"
                "   s2e__icount_begin();\n"
                "   s2e__enable_forking();\n"
                "   s2e_flag = S2E_ENABLED;\n"
                "}\n"
            );
        }

        bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseFunctionDecl(f);

        if (IsNewVersion && isChangedFunction) {
            if (!isMainFunction) {
                if (f->getReturnType()->isVoidType()) {
                    SourceLocation EndLoc = f->getBody()->getEndLoc();
                    TheRewriter.InsertText(EndLoc, "if (should_symbolize) {\n"
                        "   s2e_func_called = 1;\n"
                        "}\n");
                }
            } else {
                llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                DisableLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << "if (should_symbolize) {\n"
                    "    s2e__disable_forking();\n"
                    "}\n";

                if (TheRewriter.getSourceMgr().getCharacterData(DisableLoc)
                    && (*TheRewriter.getSourceMgr().getCharacterData(DisableLoc) == ';'
                        || *TheRewriter.getSourceMgr().getCharacterData(DisableLoc) == '}')) {
                    TheRewriter.InsertTextAfterToken(
                        DisableLoc,
                        "if (should_symbolize) {\n"
                        "    s2e__disable_forking();\n"
                        "}\n"
                    );
                } else {
                    TheRewriter.InsertText(
                        DisableLoc,
                        "if (should_symbolize) {\n"
                        "    s2e__disable_forking();\n"
                        "}\n"
                    );
                }

                if (!NoNeedToInsertEnd) {
                    llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                    KillStateLoc.dump(TheRewriter.getSourceMgr());
                    llvm::errs() << "if (should_symbolize) {\n"
                        "    s2e__thread_exec_disable_current();\n"
                        "    if (s2e_flag == S2E_SYMBOLICED)\n"
                        "        s2e__kill_state(0, \"Program terminated\");\n"
                        "    s2e__icount_end();\n"
                        "    s2e_flag = S2E_DISABLED;\n"
                        "}\n";

                    // 如果是函数末尾的右大括号，则在其前面插入代码，如果是函数体的某个孩子的结尾，则在其后面插入代码
                    TheRewriter.InsertText(
                        KillStateLoc,
                        "\n"
                        "if (should_symbolize) {\n"
                        "    s2e__thread_exec_disable_current();\n"
                        "    if (s2e_flag == S2E_SYMBOLICED)\n"
                        "        s2e__kill_state(0, \"Program terminated\");\n"
                        "    s2e__icount_end();\n"
                        "    s2e_flag = S2E_DISABLED;\n"
                        "}\n"
                    );
                }
            }
        }

        if (!IsNewVersion && isModifiedPartFunction) {
            llvm::errs() << "(TraverseFunctionDecl)Insert at ";
            DisableLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << "if (should_symbolize) {\n"
                "    s2e__disable_forking();\n"
                "}\n";

            if (TheRewriter.getSourceMgr().getCharacterData(DisableLoc)
                && (*TheRewriter.getSourceMgr().getCharacterData(DisableLoc) == ';'
                    || *TheRewriter.getSourceMgr().getCharacterData(DisableLoc) == '}')) {
                TheRewriter.InsertTextAfterToken(
                    DisableLoc,
                    "if (should_symbolize) {\n"
                    "    s2e__disable_forking();\n"
                    "}\n"
                );
            } else {
                TheRewriter.InsertText(
                    DisableLoc,
                    "if (should_symbolize) {\n"
                    "    s2e__disable_forking();\n"
                    "}\n"
                );
            }

            if (!NoNeedToInsertEnd) {
                llvm::errs() << "(TraverseFunctionDecl)Insert at ";
                KillStateLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << "if (should_symbolize) {\n"
                    "    s2e__thread_exec_disable_current();\n"
                    "    if (s2e_flag == S2E_SYMBOLICED)\n"
                    "        s2e__kill_state(0, \"Program terminated\");\n"
                    "    s2e__icount_end();\n"
                    "    s2e_flag = S2E_DISABLED;\n"
                    "}\n";

                // 如果是函数末尾的右大括号，则在其前面插入代码，如果是函数体的某个孩子的结尾，则在其后面插入代码
                TheRewriter.InsertText(
                    KillStateLoc,
                    "\n"
                    "if (should_symbolize) {\n"
                    "    s2e__thread_exec_disable_current();\n"
                    "    if (s2e_flag == S2E_SYMBOLICED)\n"
                    "        s2e__kill_state(0, \"Program terminated\");\n"
                    "    s2e__icount_end();\n"
                    "    s2e_flag = S2E_DISABLED;\n"
                    "}\n"
                );
            }
        }

        if (isStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                TheRewriter.InsertText(EndLoc, "should_symbolize = 1;\n");
            }
        }

        if (isEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "end") {
            if (f->getReturnType()->isVoidType()) {
                SourceLocation EndLoc = f->getBody()->getEndLoc();
                TheRewriter.InsertText(EndLoc, "should_symbolize = 0;\n");
            }
        }
        return r;
    }

    bool VisitIfStmt(IfStmt *ifStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        unsigned Line = SM.getSpellingLineNumber(ifStmt->getBeginLoc());

        std::pair<unsigned, unsigned> CR;
        if (IsChanged(Line, CR)) {
            handleIfStmt(ifStmt, CR);
        }
        return true;
    }

    bool VisitReturnStmt(ReturnStmt *returnStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = returnStmt->getBeginLoc();
        assert(!StartLoc.isMacroID());
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        FunctionDecl *FD = findFirstFunctionDeclAncestor(returnStmt);
        if (!FD) {
            return true;
        }

        std::string FuncName = FD->getNameInfo().getName().getAsString();
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        bool isModifiedPartFunction = (!IsNewVersion && FuncName == ModifiedPartFunctionName);
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction && !isModifiedPartFunction) {
            return true;
        }

        if (IsNewVersion && isChangedFunction) {
            if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
                llvm::errs() << "(VisitReturnStmt) Handle return statement in other function " << FuncName << "\n";
                handleReturnOrExitStmt(returnStmt, true, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }

            if (Line >= EnableLine && Line <= KillStateLine) {
                llvm::errs() << "(VisitReturnStmt) Handle return statement in first function " << FuncName << "\n";
                handleReturnOrExitStmt(returnStmt, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }
        }
        
        if (!IsNewVersion && isModifiedPartFunction) {
            if (Line >= EnableLine && Line <= KillStateLine) {
                llvm::errs() << "(VisitReturnStmt) Handle return statement in old version function " << FuncName << "\n";
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

        FunctionDecl *FD = findFirstFunctionDeclAncestor(callExpr);
        if (!FD) {
            return true;
        }

        std::string FuncName = FD->getNameInfo().getName().getAsString();
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        bool isModifiedPartFunction = (!IsNewVersion && FuncName == ModifiedPartFunctionName);
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction && !isModifiedPartFunction) {
            return true;
        }

        if (FunctionDecl *Callee = callExpr->getDirectCallee()) {
            std::string FuncName = Callee->getNameInfo().getName().getAsString();
            if (!(FuncName == "abort" || FuncName == "exit")) {
                return true;
            }
        } else {
            return true;
        }

        if (IsNewVersion && isChangedFunction) {
            if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
                llvm::errs() << "(VisitCallExpr) Handle call expression in other function " << FuncName << "\n";
                handleReturnOrExitStmt(callExpr, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }

            if (Line >= EnableLine && Line <= KillStateLine) {
                llvm::errs() << "(VisitCallExpr) Handle call expression in first function " << FuncName << "\n";
                handleReturnOrExitStmt(callExpr, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }
        } else if (!IsNewVersion && isModifiedPartFunction) {
            if (Line >= EnableLine && Line <= KillStateLine) {
                llvm::errs() << "(VisitCallExpr) Handle call expression in old version function " << FuncName << "\n";
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

        FunctionDecl *FD = findFirstFunctionDeclAncestor(gotoStmt);
        if (!FD) {
            return true;
        }

        std::string FuncName = FD->getNameInfo().getName().getAsString();
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        bool isModifiedPartFunction = (!IsNewVersion && FuncName == ModifiedPartFunctionName);
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction && !isModifiedPartFunction) {
            return true;
        }

        if (IsNewVersion && isChangedFunction) {
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
        } else if (!IsNewVersion && isModifiedPartFunction) {
            if (Line >= EnableLine && Line <= KillStateLine) {
                if (LabelDecl *LD = gotoStmt->getLabel()) {
                    SourceLocation LabelLoc = LD->getBeginLoc();
                    if (LabelLoc.isMacroID()) {
                        LabelLoc = SM.getExpansionLoc(LabelLoc);
                    }
    
                    unsigned LabelLine = SM.getSpellingLineNumber(LabelLoc);
                    if (LabelLine < EnableLine || LabelLine > KillStateLine) {
                        llvm::errs() << "(VisitGotoStmt) Handle goto statement in old version function " << FuncName << "\n";
                        handleReturnOrExitStmt(gotoStmt, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                        return true;
                    }
                }
            }
        }

        llvm::errs() << "(VisitGotoStmt) Handle goto statement in function " << FuncName << "\n";
        handleReturnOrExitStmt(gotoStmt, false, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
        return true;
    }

    bool TraverseForStmt(ForStmt *forStmt) {
        if (!forStmt || !forStmt->getBody() || !IsNewVersion) {
            return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseForStmt(forStmt);
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

        if (isInSymbolicScope(forStmt, StartLine, EndLine) && dyn_cast<NullStmt>(forStmt->getBody())) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(forStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.ReplaceText(EndLoc, 1, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(forStmt->getBody());
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            }

            LoopFlagStack.push_back(forStmt);
            bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseForStmt(forStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        // if (IsRangeChanged(StartLine, EndLine) && StartLine >= EnableLine && EndLine <= DisableLine) {
        //     std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
        //     std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
        //     std::string LoopFlagAssignStr = "if (should_symbolize) {\n    " + LoopFlag + " = 1;\n    s2e__disable_forking();\n}\n";
        //     checkAndAddBracesForAncestor(forStmt);
        //     TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
        //     if (*SM.getCharacterData(EndLoc) == ';') {
        //         TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
        //         checkAndAddBracesForAncestor(forStmt->getBody());
        //         TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
        //             "    s2e__enable_forking();\n"
        //             "}\n");
        //     } else {
        //         TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
        //         TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
        //             "    s2e__enable_forking();\n"
        //             "}\n");
        //     }

        //     LoopFlagStack.push_back(LoopFlag);
        //     bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseForStmt(forStmt);
        //     LoopFlagStack.pop_back();

        //     return r;
        // }

        if (isInSymbolicScope(forStmt, StartLine, EndLine)) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(forStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(forStmt->getBody());
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            } else if (dyn_cast<CompoundStmt>(forStmt->getBody())) {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            } else {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            }

            LoopFlagStack.push_back(forStmt);
            bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseForStmt(forStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        // Judge if the code in the for loop is changed
        // if (IsRangeChanged(StartLine, EndLine)) {
        //     std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
        //     std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
        //     std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n}\n";
        //     checkAndAddBracesForAncestor(forStmt);
        //     TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
        //     if (*SM.getCharacterData(EndLoc) == ';') {
        //         TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
        //         checkAndAddBracesForAncestor(forStmt->getBody());
        //     } else {
        //         TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
        //     }

        //     LoopFlagStack.push_back(LoopFlag);
        //     bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseForStmt(forStmt);
        //     LoopFlagStack.pop_back();

        //     return r;   
        // }

        return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseForStmt(forStmt);
    }

    bool TraverseWhileStmt(WhileStmt *whileStmt) {
        if (!whileStmt || !whileStmt->getBody() || !IsNewVersion) {
            return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseWhileStmt(whileStmt);
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

        if (isInSymbolicScope(whileStmt, StartLine, EndLine) && dyn_cast<NullStmt>(whileStmt->getBody())) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(whileStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.ReplaceText(EndLoc, 1, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(whileStmt->getBody());
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            }

            LoopFlagStack.push_back(whileStmt);
            bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseWhileStmt(whileStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        // if (IsRangeChanged(StartLine, EndLine) && StartLine >= EnableLine && EndLine <= DisableLine) {
        //     std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
        //     std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
        //     std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n    s2e__disable_forking();\n}\n";
        //     checkAndAddBracesForAncestor(whileStmt);
        //     TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
        //     if (*SM.getCharacterData(EndLoc) == ';') {
        //         TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
        //         checkAndAddBracesForAncestor(whileStmt->getBody());
        //         TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
        //             "    s2e__enable_forking();\n"
        //             "}\n");
        //     } else {
        //         TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
        //         TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
        //             "    s2e__enable_forking();\n"
        //             "}\n");
        //     }

        //     LoopFlagStack.push_back(LoopFlag);
        //     bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseWhileStmt(whileStmt);
        //     LoopFlagStack.pop_back();

        //     return r;
        // }

        if (isInSymbolicScope(whileStmt, StartLine, EndLine)) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(whileStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(whileStmt->getBody());
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            } else if (dyn_cast<CompoundStmt>(whileStmt->getBody())) {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            } else {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                // TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                //     "    s2e__enable_forking();\n"
                //     "}\n");
            }

            LoopFlagStack.push_back(whileStmt);
            bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseWhileStmt(whileStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        // Judge if the code in the for loop is changed
        // if (IsRangeChanged(StartLine, EndLine)) {
        //     std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
        //     std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
        //     std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n}\n";
        //     checkAndAddBracesForAncestor(whileStmt);
        //     TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
        //     if (*SM.getCharacterData(EndLoc) == ';') {
        //         TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
        //         checkAndAddBracesForAncestor(whileStmt->getBody());
        //     } else {
        //         TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
        //     }

        //     LoopFlagStack.push_back(LoopFlag);
        //     bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseWhileStmt(whileStmt);
        //     LoopFlagStack.pop_back();

        //     return r;
        // }

        return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseWhileStmt(whileStmt);
    }

    bool TraverseDoStmt(DoStmt *doStmt) {
        if (!doStmt || !doStmt->getBody() || !IsNewVersion) {
            return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseDoStmt(doStmt);
        }

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

        // if (IsRangeChanged(StartLine, EndLine) && StartLine >= EnableLine && EndLine <= DisableLine) {
        //     std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
        //     std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
        //     std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n    s2e__disable_forking();\n}\n";
        //     checkAndAddBracesForAncestor(doStmt);
        //     TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
        //     TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
        //     TheRewriter.InsertTextAfterToken(FinalLoc, "if (should_symbolize) {\n"
        //         "    s2e__enable_forking();\n"
        //         "}\n");

        //     LoopFlagStack.push_back(LoopFlag);
        //     bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseDoStmt(doStmt);
        //     LoopFlagStack.pop_back();

        //     return r;
        // }

        if (isInSymbolicScope(doStmt, StartLine, EndLine)) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(doStmt);
            TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
            // TheRewriter.InsertTextAfterToken(FinalLoc, "if (should_symbolize) {\n"
            //     "    s2e__enable_forking();\n"
            //     "}\n");

            LoopFlagStack.push_back(doStmt);
            bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseDoStmt(doStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        // Judge if the code in the for loop is changed
        // if (IsRangeChanged(StartLine, EndLine)) {
        //     std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
        //     std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
        //     std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n}\n";
        //     checkAndAddBracesForAncestor(doStmt);
        //     TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
        //     TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);

        //     LoopFlagStack.push_back(LoopFlag);
        //     bool r = RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseDoStmt(doStmt);
        //     LoopFlagStack.pop_back();

        //     return r;
        // }

        return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseDoStmt(doStmt);
    }

    bool VisitContinueStmt(ContinueStmt *continueStmt) {
        if (LoopFlagStack.empty()) {
            return true;
        }

        std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
        checkAndAddBracesForAncestor(continueStmt);
        TheRewriter.InsertText(continueStmt->getBeginLoc(), LoopFlagAssignStr);
        return true;

        // if (LoopFlagStack.back() == "") {
        //     std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
        //     checkAndAddBracesForAncestor(continueStmt);
        //     TheRewriter.InsertText(continueStmt->getBeginLoc(), LoopFlagAssignStr);
        //     return true;
        // }

        // std::string LoopFlagAssignStr = "if (should_symbolize) {\n    " + LoopFlagStack.back() + " = 1;\n    s2e__disable_forking();\n}\n";
        // checkAndAddBracesForAncestor(continueStmt);
        // TheRewriter.InsertText(continueStmt->getBeginLoc(), LoopFlagAssignStr);
        // return true;
    }

    bool TraverseStmt(Stmt *stmt) {
        if (!stmt) {
            return true;
        }

        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = stmt->getBeginLoc();
        unsigned Line = SM.getSpellingLineNumber(StartLoc);

        if (StartLoc.isMacroID()) {
            return true;
        }

        std::pair<unsigned, unsigned> CR;
        if (IsChanged(Line, CR)) {
            if (!isa<IfStmt>(stmt)) {
                // Find the first if ancestor of the current statement
                clang::Stmt *Ancestor = findFirstIfAncestor(stmt);
                if (Ancestor) {
                    handleIfStmt(cast<IfStmt>(Ancestor), CR, true);
                }
            }
        }
        return RecursiveASTVisitor<MakeSymbolicVisitor>::TraverseStmt(stmt);
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
    QualType getNonConstType(QualType QT) {
        if (QT.isConstQualified()) {
            return QT.getNonReferenceType().getUnqualifiedType();
        }
        return QT;
    }

    bool isInSymbolicScope(Stmt *stmt, unsigned StartLine, unsigned EndLine) {
        FunctionDecl *FD = findFirstFunctionDeclAncestor(stmt);
        std::string FuncName = FD->getNameInfo().getName().getAsString();

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
        
        std::string FuncName = FD->getNameInfo().getName().getAsString();
        auto itr = FuncChangeInfo.find(FuncName);
        if (itr != FuncChangeInfo.end()) {
            if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
                SymbolicCall += " && !s2e_func_called";
            }
        }

        // if (!LoopFlagStack.empty())
        //     SymbolicCall += " && !" + LoopFlagStack.back();

        if (FlagVarName != "")
            SymbolicCall += " && !" + FlagVarName;

        SymbolicCall += ") {\n";

        if (TmpVarAssignmentExpr != "")
            SymbolicCall += "    " + TmpVarAssignmentExpr;

        if (QT->isPointerType()) {
            SymbolicCall += "    uint64_t disj_values[] = {" + TmpVarName + ", 0};\n"
                            "    s2e__make_symbolic(&" + TmpVarName + ", sizeof(" + TmpVarName + "), \"" + TmpVarNameStr + "\");\n"
                            "    s2e__assume_disjunction64(" + TmpVarName + ", 2, disj_values);\n";
        } else {
            SymbolicCall += "    s2e__make_symbolic(&" + TmpVarName + ", sizeof(" + TmpVarName + "), \"" + TmpVarNameStr + "\");\n";
        }

        if (FlagVarName != "")
            SymbolicCall += "    " + FlagVarName + " = 1;\n";

        SymbolicCall += "    s2e_flag = S2E_SYMBOLICED;\n"
                        "}\n";
        return SymbolicCall;
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

    void insertCodeAtFunctionBody(Stmt *FuncBody, unsigned StartLine, unsigned EndLine, bool IsVoid, std::string FuncName) {
        std::vector<std::pair<SourceLocation, SourceLocation>> ChildrenRanges;
        std::vector<std::pair<std::string, std::string>> ChildrenRangesStr;
        SourceManager &SM = TheRewriter.getSourceMgr();
        int EnableLocEncoding = 0, DisableLocEncoding = 0;

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
            int locEncoding = 2 * ChildrenRanges.size();
            for (auto ritr = ChildrenRanges.rbegin(); ritr != ChildrenRanges.rend(); ++ritr) {
                SourceLocation StartLoc = ritr->first;
                SourceLocation EndLoc = ritr->second;
                unsigned ChildStartLine = TheRewriter.getSourceMgr().getSpellingLineNumber(StartLoc);
                unsigned ChildEndLine = TheRewriter.getSourceMgr().getSpellingLineNumber(EndLoc);
                if (ChildStartLine <= StartLine && ChildEndLine >= StartLine) {
                    FuncStartLoc = StartLoc;
                    locEncoding--;
                    break;
                }
                if (ChildEndLine < StartLine) {
                    FuncStartLoc = EndLoc.getLocWithOffset(2);
                    break;
                }

                locEncoding -= 2;
            }
            EnableLocEncoding = locEncoding;
        }

        if (EndLine < FuncEndLine) {
            int locEncoding = 1;
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
                    locEncoding++;
                    break;
                }

                locEncoding += 2;
            }

            DisableLocEncoding = 2 * ChildrenRanges.size() + 1 - locEncoding;
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

        if (CurrentDirectory == CurrentFilePath.substr(0, CurrentDirectory.length())) {
            std::ofstream ModifiedPartInfoFile("modified_part_info.txt");
            ModifiedPartInfoFile << CurrentFilePath.substr(CurrentDirectory.length() + 1) << "\n";
            ModifiedPartInfoFile << FuncName << "\n";
            ModifiedPartInfoFile << EnableLocEncoding << " " << DisableLocEncoding << "\n";
            ModifiedPartInfoFile.close();
        }
    }

    void insertCodeAtFunctionBodyForOldVersion(Stmt *FuncBody, bool IsVoid) {
        std::vector<std::pair<SourceLocation, SourceLocation>> ChildrenRanges;
        std::vector<std::pair<std::string, std::string>> ChildrenRangesStr;
        SourceManager &SM = TheRewriter.getSourceMgr();

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

        if (ModifiedPartEnableLocEncoding) {
            auto& child = ChildrenRanges[(ModifiedPartEnableLocEncoding - 1) / 2];
            SourceLocation StartLoc = child.first;
            SourceLocation EndLoc = child.second;
            if (ModifiedPartEnableLocEncoding & 1) {
                FuncStartLoc = StartLoc;
            } else {
                FuncStartLoc = EndLoc.getLocWithOffset(2);
            }
        }

        if (ModifiedPartDisableLocEncoding) {
            auto& child = ChildrenRanges[(2 * ChildrenRanges.size() + 1 - ModifiedPartDisableLocEncoding - 1) / 2];
            SourceLocation StartLoc = child.first;
            SourceLocation EndLoc = child.second;
            if (!(ModifiedPartDisableLocEncoding & 1)) {
                FuncEndLoc = Lexer::getLocForEndOfToken(EndLoc, 0, SM, Context.getLangOpts());
            } else {
                FuncEndLoc = StartLoc.getLocWithOffset(-1);
            }
        }

        if (FuncStartLoc > FuncEndLoc)
            FuncEndLoc = FuncStartLoc;

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
        std::string FlagVarName = "tmp_" + VarName + "_flag_" + std::to_string(VarDeclLoc.getRawEncoding());

        // Static variable
        if ((VD->isFileVarDecl() && VD->getStorageClass() == SC_Static) || VD->isStaticLocal()) {
            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
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
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertText(LoopBeginLoc, "{" + FlagVarDecl);
                    TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
                } else {
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, FlagVarDecl);
                }
                DefinedFlags.insert(FlagVarName);
            }

            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
        }
        // External variable
        else if ((VD->isFileVarDecl() && VD->getStorageClass() == SC_Extern) || VD->isExternC()) {
            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                // Actually, we should define the flagVar to be "extern int flagVarName;"
                std::string FlagVarDecl = "static int " + FlagVarName + " = 0;";
                while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                    VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                VarDeclLoc.dump(SM);
                llvm::errs() << FlagVarDecl << "\n";
                TheRewriter.InsertTextAfterToken(VarDeclLoc, FlagVarDecl);
                DefinedFlags.insert(FlagVarName);
            }

            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
        }
        // Global variable
        else if (VD->isFileVarDecl() && VD->getStorageClass() == SC_None) {
            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                std::string FlagVarDecl = "static int " + FlagVarName + " = 0;";
                while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                    VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                VarDeclLoc.dump(SM);
                llvm::errs() << FlagVarDecl << "\n";
                TheRewriter.InsertTextAfterToken(VarDeclLoc, FlagVarDecl);
                DefinedFlags.insert(FlagVarName);
            }

            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
        }
        // Local variable
        else if (VD->isLocalVarDecl()) {
            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;";

                // ForStmt *FS = findFirstForAncestor(ifStmt);
                // if (!isVarDeclInForInit(VD, FS)) {

                Stmt* Loop = findOutermostLoopAncestorForVarDecl(VD);
                if (!Loop) {
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';') {
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, FlagVarDecl);
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
                    TheRewriter.InsertText(LoopBeginLoc, "{" + FlagVarDecl);
                    TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
                }
                DefinedFlags.insert(FlagVarName);
            }

            std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
        }
        // Function parameter
        else if (VD->isLocalVarDeclOrParm()) {
            if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
                if (InsertLoc.isMacroID())
                    InsertLoc = SM.getExpansionLoc(InsertLoc);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                InsertLoc.dump(SM);
                llvm::errs() << FlagVarDecl << "\n";
                TheRewriter.InsertText(InsertLoc, FlagVarDecl);
                DefinedFlags.insert(FlagVarName);
            }

            std::string VarNameStr = VarName + "_" + std::to_string(IfStartLoc.getRawEncoding());
            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                IfStartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
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
            std::string FuncName = FD->getNameInfo().getName().getAsString();
            SourceLocation FuncCallLoc = FuncCall->getBeginLoc();
            if (FuncCallLoc.isMacroID())
                FuncCallLoc = TheRewriter.getSourceMgr().getExpansionLoc(FuncCallLoc);

            Stmt* Loop = findOutermostLoopAncestor(ifStmt);
            if (!Loop) {
                std::string TmpVarName = "tmp_" + FuncName + "_result_" + std::to_string(FuncCallLoc.getRawEncoding());
                std::string FuncCallStmt = QT.getAsString() + " " + TmpVarName + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                if (QT->isFunctionPointerType()) {
                    std::string VarType = QT.getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                        FuncCallStmt = VarType + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                    }
                }
                std::string SymbolicCall = getSymbolicCall(QT, findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarName, "", "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicFuncCall) Insert at ";
                IfStartLoc.dump(TheRewriter.getSourceMgr());
                llvm::errs() << FuncCallStmt + SymbolicCall << "\n";
                TheRewriter.InsertText(IfStartLoc, FuncCallStmt + SymbolicCall);

                // 替换if条件中的函数调用为返回值变量
                TheRewriter.ReplaceText(FuncCall->getSourceRange(), TmpVarName);
            } else {
                std::string FlagVarName = "tmp_" + FuncName + "_flag_" + std::to_string(FuncCallLoc.getRawEncoding());

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
                    TheRewriter.InsertText(LoopBeginLoc, "{" + FlagVarDecl);
                    TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
                    DefinedFlags.insert(FlagVarName);
                }

                std::string TmpVarName = "tmp_" + FuncName + "_result_" + std::to_string(FuncCallLoc.getRawEncoding());
                std::string FuncCallStmt = QT.getAsString() + " " + TmpVarName + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                if (QT->isFunctionPointerType()) {
                    std::string VarType = QT.getAsString();
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                        FuncCallStmt = VarType + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                    }
                }
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

    void symbolicBitFieldMemberExpr(IfStmt* ifStmt, MemberExpr* ME, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        DeclRefExpr *OriginalBase = getOriginalBaseFromMemberExpr(ME);
        if (!OriginalBase)  return;

        VarDecl* VD = dyn_cast<VarDecl>(OriginalBase->getDecl());
        if (!VD)  return;

        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation IfStartLoc = ifStmt->getBeginLoc();
        if (IfStartLoc.isMacroID())
            IfStartLoc = SM.getExpansionLoc(IfStartLoc);

        std::string MemberExprStr = TheRewriter.getRewrittenText(ME->getSourceRange());
        std::string TmpVarName = "tmp_" + MemberExprStr;
        std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        std::string tmpVarAssignmentExpr = TmpVarName + " = " + MemberExprStr + ";\n";
        std::string FlagVarName = "tmp_" + MemberExprStr + "_flag";
        std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');

        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
        FlagVarName += "_" + FD->getNameInfo().getName().getAsString();
        if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
            std::string VarDeclStmt = getNonConstType(ME->getType()).getAsString() + " " + TmpVarName + ";\n";
            if (ME->getType()->isFunctionPointerType()) {
                std::string VarType = getNonConstType(ME->getType()).getAsString();
                size_t pos = VarType.find(" (*)");
                if (pos != std::string::npos) {
                    VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                    VarDeclStmt = VarType + ";\n";
                }
            }
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
                    llvm::errs() << "(symbolicMemberExpr) Insert at ";
                    FunctionBeginLoc.dump(SM);
                    llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
                    TheRewriter.InsertText(FunctionBeginLoc, VarDeclStmt + FlagVarDecl);
                } else {
                    SourceLocation VarDeclLoc = VD->getLocation();
                    if (VarDeclLoc.isMacroID())
                        VarDeclLoc = SM.getExpansionLoc(VarDeclLoc);
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    llvm::errs() << "(symbolicMemberExpr) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, VarDeclStmt + FlagVarDecl);
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
                llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
                TheRewriter.InsertText(LoopBeginLoc, "{" + VarDeclStmt + FlagVarDecl);
                TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
            }
            DefinedFlags.insert(FlagVarName);
        }

        if (SymbolicedVarsOfThisIfStmt.find(MemberExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
            std::string VarNameStr = MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
            std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
                return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
            }, '_');
            std::string SymbolicCall = getSymbolicCall(ME->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, VarNameStr, FlagVarName, "");
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicMemberExpr) Insert at ";
            IfStartLoc.dump(SM);
            llvm::errs() << tmpVarAssignmentExpr + SymbolicCall << "\n";
            TheRewriter.InsertText(IfStartLoc, tmpVarAssignmentExpr + SymbolicCall);

            SymbolicedVarsOfThisIfStmt.insert(MemberExprStr);
        }

        TheRewriter.ReplaceText(ME->getSourceRange(), TmpVarName);
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

        if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
            std::string FlagVarDecl = "";
            if (VD->isFileVarDecl()) {
                FlagVarDecl = "static ";
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
                    llvm::errs() << "(symbolicMemberExpr) Insert at ";
                    FunctionBeginLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertText(FunctionBeginLoc, FlagVarDecl);
                } else {
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    llvm::errs() << "(symbolicMemberExpr) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, FlagVarDecl);
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
                llvm::errs() << FlagVarDecl << "\n";
                TheRewriter.InsertText(LoopBeginLoc, "{" + FlagVarDecl);
                TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
            }
            DefinedFlags.insert(FlagVarName);
        }

        if (SymbolicedVarsOfThisIfStmt.find(MemberExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
            std::string VarNameStr = MemberExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
            std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
                return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
            }, '_');
            std::string SymbolicCall = getSymbolicCall(ME->getType(), findFirstFunctionDeclAncestor(ifStmt), "(" + MemberExprStr + ")", VarNameStr, FlagVarName, "");
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicMemberExpr) Insert at ";
            IfStartLoc.dump(SM);
            llvm::errs() << SymbolicCall << "\n";
            TheRewriter.InsertText(IfStartLoc, SymbolicCall);

            SymbolicedVarsOfThisIfStmt.insert(MemberExprStr);
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

        if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
            std::string FlagVarDecl;
            if (VD->isFileVarDecl()) {
                FlagVarDecl = "static ";
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
                    llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
                    FunctionBeginLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertText(FunctionBeginLoc, FlagVarDecl);
                } else {
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, FlagVarDecl);
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
                llvm::errs() << FlagVarDecl << "\n";
                TheRewriter.InsertText(LoopBeginLoc, "{" + FlagVarDecl);
                TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
            }
            DefinedFlags.insert(FlagVarName);
        }

        if (SymbolicedVarsOfThisIfStmt.find(ArraySubscriptExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
            std::string VarNameStr = ArraySubscriptExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
            std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
                return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
            }, '_');
            std::string SymbolicCall = getSymbolicCall(ASE->getType(), findFirstFunctionDeclAncestor(ifStmt), "(" + ArraySubscriptExprStr + ")", VarNameStr, FlagVarName, "");
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
            IfStartLoc.dump(SM);
            llvm::errs() << SymbolicCall << "\n";
            TheRewriter.InsertText(IfStartLoc, SymbolicCall);

            SymbolicedVarsOfThisIfStmt.insert(ArraySubscriptExprStr);
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

        if (DefinedFlags.find(FlagVarName) == DefinedFlags.end()) {
            std::string FlagVarDecl = "";
            if (VD->isFileVarDecl()) {
                FlagVarDecl = "static ";
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
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertText(FunctionBeginLoc, FlagVarDecl);
                } else {
                    while (SM.getCharacterData(VarDeclLoc) && *SM.getCharacterData(VarDeclLoc) != ';')
                        VarDeclLoc = VarDeclLoc.getLocWithOffset(1);
                    llvm::errs() << "(symbolicDerefExpr) Insert at ";
                    VarDeclLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertTextAfterToken(VarDeclLoc, FlagVarDecl);
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
                llvm::errs() << FlagVarDecl << "\n";
                TheRewriter.InsertText(LoopBeginLoc, "{" + FlagVarDecl);
                TheRewriter.InsertTextAfterToken(LoopEndLoc, "}\n");
            }
            DefinedFlags.insert(FlagVarName);
        }

        if (SymbolicedVarsOfThisIfStmt.find(DerefExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
            std::string VarNameStr = DerefExprStr + "_" + std::to_string(IfStartLoc.getRawEncoding());
            std::replace_if(VarNameStr.begin(), VarNameStr.end(), [](char c) {
                return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
            }, '_');
            std::string SymbolicCall = getSymbolicCall(UO->getType(), findFirstFunctionDeclAncestor(ifStmt), "(" + DerefExprStr + ")", VarNameStr, FlagVarName, "");
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicDerefExpr) Insert at ";
            IfStartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << SymbolicCall << "\n";
            TheRewriter.InsertText(IfStartLoc, SymbolicCall);

            SymbolicedVarsOfThisIfStmt.insert(DerefExprStr);
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
        std::string FlagVarName = "tmp_" + MacroExprStr + "_flag";
        std::replace_if(FlagVarName.begin(), FlagVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        FlagVarName += "_" + std::to_string(StartLoc.getRawEncoding());

        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
        std::string UniqueID = TmpVarName + "_" + FD->getNameInfo().getName().getAsString();
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
            TheRewriter.InsertText(InsertLoc, VarDeclStmt + FlagVarDecl);
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
                if (FieldDecl *FD = dyn_cast<FieldDecl>(ME->getMemberDecl())) {
                    if (FD->isBitField()) {
                        symbolicBitFieldMemberExpr(ifStmt, ME, SymbolicedVarsOfThisIfStmt, CR);
                    } else {
                        symbolicMemberExpr(ifStmt, ME, SymbolicedVarsOfThisIfStmt, CR);
                    }
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

    void handleReturnOrExitStmt(Stmt *stmt, bool IsChangedFunction, bool IsFuncFirst, bool IsStartLocEndToEndFunction, bool IsEndLocEndToEndFunction) {
        SourceLocation Loc = stmt->getBeginLoc();
        if (Loc.isMacroID()) {
            Loc = TheRewriter.getSourceMgr().getExpansionLoc(Loc);
        }
        SourceManager &SM = TheRewriter.getSourceMgr();
        unsigned Line = SM.getSpellingLineNumber(Loc);

        std::string CodeToInsert = "";
        if (IsChangedFunction) {
            if (IsFuncFirst) {
                CodeToInsert = "if (should_symbolize) {\n"
                            "   s2e__thread_exec_disable_current();\n"
                            "   if (s2e_flag == S2E_SYMBOLICED)\n"
                            "       s2e__kill_state(0, \"Program terminated\");\n"
                            "   s2e__icount_end();\n";
                if (LoopFlagStack.size() > 0) {
                    CodeToInsert += "   s2e__enable_forking();\n";
                }
                CodeToInsert += "   s2e_flag = S2E_DISABLED;\n"
                            "}\n";
            } else {
                CodeToInsert = "if (should_symbolize) {\n"
                    "   s2e_func_called = 1;\n";
                if (LoopFlagStack.size() > 0) {
                    CodeToInsert += "   s2e__enable_forking();\n";
                }
                CodeToInsert += "}\n";
            }
        }

        if (IsStartLocEndToEndFunction && StartLocEndToEndFunctionLocation == "end") {
            CodeToInsert += "should_symbolize = 1;\n";
        }

        if (IsEndLocEndToEndFunction && EndLocEndToEndFunctionLocation == "end") {
            CodeToInsert += "should_symbolize = 0;\n";
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
                        std::string RetValueVarDecl = RetValue->getType().getAsString() + " " + RetValueVarName + " = " + RetValueStr + ";\n";
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
        }
        for (Stmt *Child : E->children()) {
            if (Expr *ChildExpr = dyn_cast<Expr>(Child)) {
                findVarDeclsAndFuncCalls(ChildExpr, SymbolicExprs);
            }
        }
    }

    ASTContext &Context;
    Rewriter &TheRewriter;
    Preprocessor &PP;
    const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo;
    std::unordered_set<std::string> DefinedFlags;
    std::unordered_set<std::string> MakeSymbolicedIfStmts;
    std::unordered_set<const Stmt*> CheckedBracesStmts;
    std::vector<Stmt*> LoopFlagStack;

    SourceLocation& IncludeLoc;
    bool NoNeedToInsertEnd;
    SourceLocation EnableLoc, DisableLoc, KillStateLoc;
    unsigned EnableLine, DisableLine, KillStateLine;
};

class MakeSymbolicConsumer : public ASTConsumer {
public:
    MakeSymbolicConsumer(Rewriter &R, Preprocessor &PP, const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : R(R), PP(PP), FuncChangeInfo(FuncChangeInfo) {}

    void HandleTranslationUnit(ASTContext &Context) override {
        MakeSymbolicVisitor Visitor(Context, R, PP, FuncChangeInfo, IncludeLoc);
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
        llvm::errs() << "#include <symbolic.h>\n"
                     "extern int should_symbolize;\n"
                     "extern int s2e_flag;\n\n";

        R.InsertText(
            IncludeLoc,
            "#include <symbolic.h>\n"
            "extern int should_symbolize;\n"
            "extern int s2e_flag;\n\n"
        );
    }

private:
    Rewriter &R;
    Preprocessor &PP;
    const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo;
    SourceLocation IncludeLoc;
};

class MakeSymbolicAction : public ASTFrontendAction {
public:
    MakeSymbolicAction() = default;
    MakeSymbolicAction(const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : FuncChangeInfo(FuncChangeInfo) {}

    std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI, StringRef file) override {
        TheRewriter.setSourceMgr(CI.getSourceManager(), CI.getLangOpts());
        return std::make_unique<MakeSymbolicConsumer>(TheRewriter, CI.getPreprocessor(), FuncChangeInfo);
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

class MakeSymbolicActionFactory : public FrontendActionFactory {
public:
    MakeSymbolicActionFactory(const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : FuncChangeInfo(FuncChangeInfo) {}

    std::unique_ptr<FrontendAction> create() override {
        return std::make_unique<MakeSymbolicAction>(FuncChangeInfo);
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

    // Get current directory
    char CurrentDir[PATH_MAX];
    if (getcwd(CurrentDir, sizeof(CurrentDir)) == NULL) {
        llvm::errs() << "Get current directory failed\n";
        return 1;
    }
    CurrentDirectory = CurrentDir;

    std::cout << "IsNewVersion: " << IsNewVersion << std::endl;
    std::cout << "CurrentDirectory: " << CurrentDirectory << std::endl;

    std::ofstream ofs("testcase.txt");
    if (!ofs.is_open()) {
        llvm::errs() << "Open testcase.txt failed\n";
        return 1;
    }

    std::ifstream File;
    File.open("end_to_end.txt");
    if (!File) {
        llvm::errs() << "Open end_to_end.txt failed\n";
        return 1;
    }
    File >> StartLocEndToEndFunctionFilePath >> StartLocEndToEndFunctionName >> StartLocEndToEndFunctionLocation;
    File >> EndLocEndToEndFunctionFilePath >> EndLocEndToEndFunctionName >> EndLocEndToEndFunctionLocation;
    File.close();

    std::string line;
    bool IsStartLocEndToEndFileChanged = false;
    bool IsEndLocEndToEndFileChanged = false;

    if (IsNewVersion) {
        while (std::getline(std::cin, line)) {
            if (line == "EOF" || line == "") {
                break;
            }
            
            MakeSymbolicContext Context;
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

                // if the line start with testcase, we need to write it to the testcase.txt
                if (line.find("testcase") == 0) {
                    ofs << line << "\n";
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

                ClangTool Tool(OptionsParser.getCompilations(), SourcePaths);

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
                    "-I./deps/hiredis",
                    "-I./deps/linenoise",
                    "-I./deps/lua/src",
                    "-I./deps/hdr_histogram",
                    "-I./deps/fpconv",
                    "-I./deps/fast_float",
                    "-resource-dir", ResourceDir
                };

                Tool.appendArgumentsAdjuster(getInsertArgumentAdjuster(extraArgs, ArgumentInsertPosition::END));

                MakeSymbolicActionFactory Factory(FuncChangeInfo.second);
                llvm::errs() << "Run Tool on: " << FilePath << "\n";
                CurrentFilePath = FilePath;
                Tool.run(&Factory);
            }
        }
    } else {
        std::string FilePath;
        std::ifstream ModifiedPartInfoFile;
        ModifiedPartInfoFile.open("modified_part_info.txt");
        std::getline(ModifiedPartInfoFile, FilePath);
        std::getline(ModifiedPartInfoFile, ModifiedPartFunctionName);
        ModifiedPartInfoFile >> ModifiedPartEnableLocEncoding >> ModifiedPartDisableLocEncoding;
        ModifiedPartInfoFile.close();

        FilePath = CurrentDirectory + "/" + FilePath;

        std::vector<std::string> SourcePaths = {FilePath};
        if (FilePath == StartLocEndToEndFunctionFilePath) {
            IsStartLocEndToEndFileChanged = true;
        }

        if (FilePath == EndLocEndToEndFunctionFilePath) {
            IsEndLocEndToEndFileChanged = true;
        }

        ClangTool Tool(OptionsParser.getCompilations(), SourcePaths);

        std::string ResourceDir = exec("clang --print-resource-dir");
        size_t pos = ResourceDir.find_first_of("\n");
        if (pos != std::string::npos)
            ResourceDir = ResourceDir.substr(0, pos);

        if (ResourceDir == "") {
            llvm::errs() << "Get clang resource dir failed\n";
            return 1;
        }

        // 添加额外的编译选项
        std::vector<std::string> extraArgs = {
            "-I./deps/hiredis",
            "-I./deps/linenoise",
            "-I./deps/lua/src",
            "-I./deps/hdr_histogram",
            "-I./deps/fpconv",
            "-I./deps/fast_float",
            "-resource-dir", ResourceDir
        };

        Tool.appendArgumentsAdjuster(getInsertArgumentAdjuster(extraArgs, ArgumentInsertPosition::END));

        MakeSymbolicActionFactory Factory({});
        llvm::errs() << "Run Tool on: " << FilePath << "\n";
        CurrentFilePath = FilePath;
        Tool.run(&Factory);
    }

    ofs.close();

    if (StartLocEndToEndFunctionFilePath != "" && !IsStartLocEndToEndFileChanged) {
        std::vector<std::string> SourcePaths = {StartLocEndToEndFunctionFilePath};
        ClangTool Tool(OptionsParser.getCompilations(), SourcePaths);

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
            "-I./deps/hiredis",
            "-I./deps/linenoise",
            "-I./deps/lua/src",
            "-I./deps/hdr_histogram",
            "-I./deps/fpconv",
            "-I./deps/fast_float",
            "-resource-dir", ResourceDir
        };

        Tool.appendArgumentsAdjuster(getInsertArgumentAdjuster(extraArgs, ArgumentInsertPosition::END));

        MakeSymbolicActionFactory Factory({});
        llvm::errs() << "Run Tool on: " << StartLocEndToEndFunctionFilePath << "\n";
        CurrentFilePath = StartLocEndToEndFunctionFilePath;
        Tool.run(&Factory);
    }

    if (EndLocEndToEndFunctionFilePath != "" && 
        EndLocEndToEndFunctionFilePath != StartLocEndToEndFunctionFilePath && 
        !IsEndLocEndToEndFileChanged) {
        std::vector<std::string> SourcePaths = {EndLocEndToEndFunctionFilePath};
        ClangTool Tool(OptionsParser.getCompilations(), SourcePaths);

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
            "-I./deps/hiredis",
            "-I./deps/linenoise",
            "-I./deps/lua/src",
            "-I./deps/hdr_histogram",
            "-I./deps/fpconv",
            "-I./deps/fast_float",
            "-resource-dir", ResourceDir
        };

        Tool.appendArgumentsAdjuster(getInsertArgumentAdjuster(extraArgs, ArgumentInsertPosition::END));

        MakeSymbolicActionFactory Factory({});
        llvm::errs() << "Run Tool on: " << EndLocEndToEndFunctionFilePath << "\n";
        CurrentFilePath = EndLocEndToEndFunctionFilePath;
        Tool.run(&Factory);
    }
    
    return 0;
}
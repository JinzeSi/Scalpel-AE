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

using namespace clang;
using namespace clang::tooling;

std::string StartLocEndToEndFunctionName = "";
std::string StartLocEndToEndFunctionFilePath = "";
std::string StartLocEndToEndFunctionLocation = "";
std::string EndLocEndToEndFunctionName = "";
std::string EndLocEndToEndFunctionFilePath = "";
std::string EndLocEndToEndFunctionLocation = "";
std::string CurrentFilePath = "";

struct FuncChangeInfoClass {
    std::string FuncName;
    std::string FilePath;
    unsigned CallExprStartLine, CallExprEndLine;
    std::vector<std::pair<unsigned, unsigned>> ChangeRanges;
};

class SymbolicAnalyseContext {
public:
    std::vector<unsigned> CallExprLines;
    std::unordered_map<std::string, std::unordered_map<std::string, FuncChangeInfoClass>> FuncChangeInfos;
};

std::ofstream OutFile;
bool IsSomeLineSymboliced = false;

class SymbolicAnalyseVisitor : public RecursiveASTVisitor<SymbolicAnalyseVisitor> {
public:
    SymbolicAnalyseVisitor(ASTContext& Context, Rewriter &R, Preprocessor &PP, const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo, SourceLocation& IncludeLoc)
        : Context(Context), TheRewriter(R), PP(PP), FuncChangeInfo(FuncChangeInfo), IncludeLoc(IncludeLoc), NoNeedToInsertEnd(false), EnableLine(0), DisableLine(0), KillStateLine(0) {}

    bool TraverseFunctionDecl(FunctionDecl* f) {
        if (!f->isThisDeclarationADefinition() || !f->hasBody() || !f->getBody()
            || f->getBody()->child_begin() == f->getBody()->child_end()) {
            return RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseFunctionDecl(f);
        }

        std::string FuncName = f->getNameInfo().getName().getAsString();
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
        if (isChangedFunction) {
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
                insertCodeAtFunctionBody(FuncBody, StartLine, EndLine, f->getReturnType()->isVoidType());
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

        bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseFunctionDecl(f);

        if (isChangedFunction) {
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

                TheRewriter.InsertTextAfterToken(
                    DisableLoc,
                    "if (should_symbolize) {\n"
                    "    s2e__disable_forking();\n"
                    "}\n"
                );

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
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        if (isChangedFunction) {
            if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
                handleReturnOrExitStmt(returnStmt, true, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }

            if (Line >= EnableLine && Line <= KillStateLine) {
                handleReturnOrExitStmt(returnStmt, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                return true;
            }
        } else {
            handleReturnOrExitStmt(returnStmt, false, false, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
            return true;
        }

        return true;
    }

    bool VisitCallExpr(CallExpr *callExpr) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        unsigned Line = SM.getSpellingLineNumber(callExpr->getBeginLoc());

        FunctionDecl *FD = findFirstFunctionDeclAncestor(callExpr);
        if (!FD) {
            return true;
        }

        std::string FuncName = FD->getNameInfo().getName().getAsString();
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        if (Line >= EnableLine && Line <= KillStateLine) {
            if (FunctionDecl *Callee = callExpr->getDirectCallee()) {
                std::string FuncName = Callee->getNameInfo().getName().getAsString();
                if (FuncName == "abort" || FuncName == "exit") {
                    handleReturnOrExitStmt(callExpr, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                }
            }
        }
        return true;
    }

    bool VisitGotoStmt(GotoStmt *gotoStmt) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        unsigned Line = SM.getSpellingLineNumber(gotoStmt->getBeginLoc());

        FunctionDecl *FD = findFirstFunctionDeclAncestor(gotoStmt);
        if (!FD) {
            return true;
        }

        std::string FuncName = FD->getNameInfo().getName().getAsString();
        bool isStartLocEndToEndFunction = (FuncName == StartLocEndToEndFunctionName && CurrentFilePath == StartLocEndToEndFunctionFilePath);
        bool isEndLocEndToEndFunction = (FuncName == EndLocEndToEndFunctionName && CurrentFilePath == EndLocEndToEndFunctionFilePath);

        auto itr = FuncChangeInfo.find(FuncName);
        bool isChangedFunction = (itr != FuncChangeInfo.end());
        if (!isStartLocEndToEndFunction && !isEndLocEndToEndFunction && !isChangedFunction) {
            return true;
        }

        if (Line >= EnableLine && Line <= KillStateLine) {
            if (LabelDecl *LD = gotoStmt->getLabel()) {
                SourceLocation LabelLoc = LD->getBeginLoc();
                if (LabelLoc.isMacroID()) {
                    LabelLoc = SM.getExpansionLoc(LabelLoc);
                }

                unsigned LabelLine = SM.getSpellingLineNumber(LabelLoc);
                if (LabelLine < EnableLine || LabelLine > KillStateLine) {
                    handleReturnOrExitStmt(gotoStmt, true, true, isStartLocEndToEndFunction, isEndLocEndToEndFunction);
                }
            }
        }
        return true;
    }

    bool TraverseForStmt(ForStmt *forStmt) {
        if (!forStmt || !forStmt->getBody()) {
            return RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseForStmt(forStmt);
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

        if (StartLine >= EnableLine && EndLine <= DisableLine && dyn_cast<NullStmt>(forStmt->getBody())) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(forStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.ReplaceText(EndLoc, 1, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(forStmt->getBody());
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            }

            LoopFlagStack.push_back("");
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseForStmt(forStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        if (IsRangeChanged(StartLine, EndLine) && StartLine >= EnableLine && EndLine <= DisableLine) {
            std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
            std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    " + LoopFlag + " = 1;\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(forStmt);
            TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(forStmt->getBody());
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            }

            LoopFlagStack.push_back(LoopFlag);
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseForStmt(forStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        if (StartLine >= EnableLine && EndLine <= DisableLine) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(forStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(forStmt->getBody());
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            }

            LoopFlagStack.push_back("");
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseForStmt(forStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        // Judge if the code in the for loop is changed
        if (IsRangeChanged(StartLine, EndLine)) {
            std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
            std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n}\n";
            checkAndAddBracesForAncestor(forStmt);
            TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(forStmt->getBody());
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
            }

            LoopFlagStack.push_back(LoopFlag);
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseForStmt(forStmt);
            LoopFlagStack.pop_back();

            return r;   
        }

        return RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseForStmt(forStmt);
    }

    bool TraverseWhileStmt(WhileStmt *whileStmt) {
        if (!whileStmt || !whileStmt->getBody()) {
            return RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseWhileStmt(whileStmt);
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

        if (StartLine >= EnableLine && EndLine <= DisableLine && dyn_cast<NullStmt>(whileStmt->getBody())) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(whileStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.ReplaceText(EndLoc, 1, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(whileStmt->getBody());
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            }

            LoopFlagStack.push_back("");
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseWhileStmt(whileStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        if (IsRangeChanged(StartLine, EndLine) && StartLine >= EnableLine && EndLine <= DisableLine) {
            std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
            std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(whileStmt);
            TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(whileStmt->getBody());
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            }

            LoopFlagStack.push_back(LoopFlag);
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseWhileStmt(whileStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        if (StartLine >= EnableLine && EndLine <= DisableLine) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(whileStmt);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(whileStmt->getBody());
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
                TheRewriter.InsertTextAfterToken(EndLoc, "if (should_symbolize) {\n"
                    "    s2e__enable_forking();\n"
                    "}\n");
            }

            LoopFlagStack.push_back("");
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseWhileStmt(whileStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        // Judge if the code in the for loop is changed
        if (IsRangeChanged(StartLine, EndLine)) {
            std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
            std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n}\n";
            checkAndAddBracesForAncestor(whileStmt);
            TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
            if (*SM.getCharacterData(EndLoc) == ';') {
                TheRewriter.InsertTextAfterToken(EndLoc, LoopFlagAssignStr);
                checkAndAddBracesForAncestor(whileStmt->getBody());
            } else {
                TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
            }

            LoopFlagStack.push_back(LoopFlag);
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseWhileStmt(whileStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        return RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseWhileStmt(whileStmt);
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

        if (IsRangeChanged(StartLine, EndLine) && StartLine >= EnableLine && EndLine <= DisableLine) {
            std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
            std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(doStmt);
            TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
            TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
            TheRewriter.InsertTextAfterToken(FinalLoc, "if (should_symbolize) {\n"
                "    s2e__enable_forking();\n"
                "}\n");

            LoopFlagStack.push_back(LoopFlag);
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseDoStmt(doStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        if (StartLine >= EnableLine && EndLine <= DisableLine) {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(doStmt);
            TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);
            TheRewriter.InsertTextAfterToken(FinalLoc, "if (should_symbolize) {\n"
                "    s2e__enable_forking();\n"
                "}\n");

            LoopFlagStack.push_back("");
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseDoStmt(doStmt);
            LoopFlagStack.pop_back();

            return r;
        }


        // Judge if the code in the for loop is changed
        if (IsRangeChanged(StartLine, EndLine)) {
            std::string LoopFlag = "tmp_loop_flag_" + std::to_string(StartLine);
            std::string LoopFlagDefineStr = "int " + LoopFlag + " = " + (LoopFlagStack.empty()? "0" : LoopFlagStack.back()) +";\n";
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n" + LoopFlag + " = 1;\n}\n";
            checkAndAddBracesForAncestor(doStmt);
            TheRewriter.InsertText(StartLoc, LoopFlagDefineStr);
            TheRewriter.InsertText(EndLoc, LoopFlagAssignStr);

            LoopFlagStack.push_back(LoopFlag);
            bool r = RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseDoStmt(doStmt);
            LoopFlagStack.pop_back();

            return r;
        }

        return RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseDoStmt(doStmt);
    }

    bool VisitContinueStmt(ContinueStmt *continueStmt) {
        if (LoopFlagStack.empty()) {
            return true;
        }

        if (LoopFlagStack.back() == "") {
            std::string LoopFlagAssignStr = "if (should_symbolize) {\n    s2e__disable_forking();\n}\n";
            checkAndAddBracesForAncestor(continueStmt);
            TheRewriter.InsertText(continueStmt->getBeginLoc(), LoopFlagAssignStr);
            return true;
        }

        std::string LoopFlagAssignStr = "if (should_symbolize) {\n    " + LoopFlagStack.back() + " = 1;\n    s2e__disable_forking();\n}\n";
        checkAndAddBracesForAncestor(continueStmt);
        TheRewriter.InsertText(continueStmt->getBeginLoc(), LoopFlagAssignStr);
        return true;
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
        return RecursiveASTVisitor<SymbolicAnalyseVisitor>::TraverseStmt(stmt);
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

    std::string getSymbolicCall(QualType QT, FunctionDecl* FD, std::string TmpVarName, std::string TmpVarNameStr, std::string FlagVarName, std::string TmpVarAssignmentExpr) {
        std::string SymbolicCall = "if (should_symbolize && s2e_flag != S2E_DISABLED";
        
        std::string FuncName = FD->getNameInfo().getName().getAsString();
        auto itr = FuncChangeInfo.find(FuncName);
        if (itr != FuncChangeInfo.end()) {
            if (itr->second.CallExprStartLine == 0xffffffff && itr->second.CallExprEndLine == 0xffffffff) {
                SymbolicCall += " && !s2e_func_called";
            }
        }

        if (!LoopFlagStack.empty())
            SymbolicCall += " && !" + LoopFlagStack.back();

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
                    FuncStartLoc = EndLoc.getLocWithOffset(1);
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

    void symbolicVarDecl(IfStmt* ifStmt, DeclRefExpr* DeclRef, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceManager &SM = TheRewriter.getSourceMgr();
        SourceLocation StartLoc = ifStmt->getBeginLoc();
        
        VarDecl *VD = dyn_cast<VarDecl>(DeclRef->getDecl());
        if (!VD) {
            return;
        }

        std::string VarName = VD->getNameAsString();
        std::string FlagVarName = "tmp_" + VarName + "_flag";

        if (VD->isStaticLocal()) {
            SourceLocation DeclLoc = VD->getLocation();
            if (DeclLoc.isMacroID()) {
                DeclLoc = SM.getExpansionLoc(DeclLoc);
            }
            std::string DeclLocStr = DeclLoc.printToString(SM);
            FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
            std::string UniqueID = VarName + "_" + DeclLocStr + "_" + FD->getNameInfo().getName().getAsString();
            std::string VarType = getNonConstType(VD->getType()).getAsString();
            std::string TmpVarName = "tmp_" + VarName + "_result";
            std::string TmpVarNameStr = TmpVarName + "_" + std::to_string(StartLoc.getRawEncoding());

            if (DefinedFlags.find(UniqueID) == DefinedFlags.end()) {
                std::string VarDeclStmt = VarType + " " + TmpVarName + " = " + VarName + ";\n";
                if (VD->getType()->isFunctionPointerType()) {
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                        VarDeclStmt = VarType + " = " + VarName + ";\n";
                    }
                }
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                while (SM.getCharacterData(DeclLoc) && *SM.getCharacterData(DeclLoc) != ';') {
                    DeclLoc = DeclLoc.getLocWithOffset(1);
                }
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                DeclLoc.dump(SM);
                llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
                TheRewriter.InsertText(DeclLoc.getLocWithOffset(1), VarDeclStmt + FlagVarDecl);
                DefinedFlags.insert(UniqueID);
            }

            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                StartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                OutFile << StartLoc.printToString(SM) << " " << CR.first << " " << CR.second << "\n";
                IsSomeLineSymboliced = true;
                TheRewriter.InsertText(StartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
            
            // 替换if条件中的变量为临时变量，注意，不是替换整个条件，比如if (a == 1) 替换为 if (tmp_a_result == 1)
            TheRewriter.ReplaceText(DeclRef->getSourceRange(), TmpVarName);
        } else if (VD->isFileVarDecl() || VD->isExternC()) {
            SourceLocation DeclLoc = VD->getLocation();
            if (DeclLoc.isMacroID()) {
                DeclLoc = SM.getExpansionLoc(DeclLoc);
            }
            std::string DeclLocStr = DeclLoc.printToString(SM);
            FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
            std::string UniqueID = VarName + "_" + DeclLocStr + "_" + FD->getNameInfo().getName().getAsString();
            std::string VarType = getNonConstType(VD->getType()).getAsString();
            std::string TmpVarName = "tmp_" + VarName + "_result";
            std::string TmpVarNameStr = TmpVarName + "_" + std::to_string(StartLoc.getRawEncoding());

            if (DefinedFlags.find(UniqueID) == DefinedFlags.end()) {
                std::string VarDeclStmt = VarType + " " + TmpVarName + " = " + VarName + ";\n";
                if (VD->getType()->isFunctionPointerType()) {
                    size_t pos = VarType.find(" (*)");
                    if (pos != std::string::npos) {
                        VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                        VarDeclStmt = VarType + " = " + VarName + ";\n";
                    }
                }
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
                if (InsertLoc.isMacroID()) {
                    InsertLoc = SM.getExpansionLoc(InsertLoc);
                }
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                InsertLoc.dump(SM);
                llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
                TheRewriter.InsertText(InsertLoc, VarDeclStmt + FlagVarDecl);
                DefinedFlags.insert(UniqueID);
            }

            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                StartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                OutFile << StartLoc.printToString(SM) << " " << CR.first << " " << CR.second << "\n";
                IsSomeLineSymboliced = true;
                TheRewriter.InsertText(StartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
            // 替换if条件中的变量为临时变量，注意，不是替换整个条件，比如if (a == 1) 替换为 if (tmp_a_result == 1)
            TheRewriter.ReplaceText(DeclRef->getSourceRange(), TmpVarName);
        } else if (VD->isLocalVarDecl()) {
            SourceLocation DeclLoc = VD->getLocation();
            if (DeclLoc.isMacroID()) {
                DeclLoc = SM.getExpansionLoc(DeclLoc);
            }
            std::string DeclLocStr = DeclLoc.printToString(SM);
            std::string UniqueID = VarName + "_" + DeclLocStr;
            if (DefinedFlags.find(UniqueID) == DefinedFlags.end()) {
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                bool IsInForInit = false;
                // 判断变量定义VD是否在for语句的初始化部分
                if (ForStmt *FS = findFirstForAncestor(ifStmt)) {
                    if (FS->getInit()) {
                        if (DeclStmt *DS = dyn_cast<DeclStmt>(FS->getInit())) {
                            for (auto DI = DS->decl_begin(); DI != DS->decl_end(); ++DI) {
                                if (VarDecl *VDInFor = dyn_cast<VarDecl>(*DI)) {
                                    if (VDInFor == VD) {
                                        IsInForInit = true;
                                        SourceLocation ForBeginLoc = FS->getBeginLoc();
                                        SourceLocation ForEndLoc = FS->getEndLoc();
                                        if (ForBeginLoc.isMacroID()) {
                                            ForBeginLoc = SM.getExpansionLoc(ForBeginLoc);
                                        }
                                        if (ForEndLoc.isMacroID()) {
                                            ForEndLoc = SM.getExpansionLoc(ForEndLoc);
                                        }
                                        while (SM.getCharacterData(ForEndLoc) && *SM.getCharacterData(ForEndLoc) != '}' && *SM.getCharacterData(ForEndLoc) != ';') {
                                            ForEndLoc = ForEndLoc.getLocWithOffset(1);
                                        }
                                        llvm::errs() << "(symbolicVarDecl) Insert at ";
                                        ForBeginLoc.dump(SM);
                                        llvm::errs() << FlagVarDecl << "\n";
                                        TheRewriter.InsertText(ForBeginLoc, "{" + FlagVarDecl);
                                        TheRewriter.InsertTextAfterToken(ForEndLoc, "}\n");
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                if (!IsInForInit) {
                    while (SM.getCharacterData(DeclLoc) && *SM.getCharacterData(DeclLoc) != ';') {
                        DeclLoc = DeclLoc.getLocWithOffset(1);
                    }
                    llvm::errs() << "(symbolicVarDecl) Insert at ";
                    DeclLoc.dump(SM);
                    llvm::errs() << FlagVarDecl << "\n";
                    TheRewriter.InsertText(DeclLoc.getLocWithOffset(1), "\n" + FlagVarDecl);
                }
                DefinedFlags.insert(UniqueID);
            }

            std::string VarNameStr = VarName + "_" + std::to_string(StartLoc.getRawEncoding());
            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                StartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                OutFile << StartLoc.printToString(SM) << " " << CR.first << " " << CR.second << "\n";
                IsSomeLineSymboliced = true;
                TheRewriter.InsertText(StartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
        } else if (VD->isLocalVarDeclOrParm()) {
            SourceLocation DeclLoc = VD->getLocation();
            if (DeclLoc.isMacroID()) {
                DeclLoc = SM.getExpansionLoc(DeclLoc);
            }
            std::string DeclLocStr = DeclLoc.printToString(SM);
            std::string UniqueID = VarName + "_" + DeclLocStr;
            if (DefinedFlags.find(UniqueID) == DefinedFlags.end()) {
                std::string FlagVarDecl = "int " + FlagVarName + " = 0;";
                FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
                SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
                if (InsertLoc.isMacroID()) {
                    InsertLoc = SM.getExpansionLoc(InsertLoc);
                }
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                InsertLoc.dump(SM);
                llvm::errs() << FlagVarDecl << "\n";
                TheRewriter.InsertText(InsertLoc, FlagVarDecl);
                DefinedFlags.insert(UniqueID);
            }

            std::string VarNameStr = VarName + "_" + std::to_string(StartLoc.getRawEncoding());
            if (SymbolicedVarsOfThisIfStmt.find(VarName) == SymbolicedVarsOfThisIfStmt.end()) {
                std::string SymbolicCall = getSymbolicCall(VD->getType(), findFirstFunctionDeclAncestor(ifStmt), VarName, VarNameStr, FlagVarName, "");
                checkAndAddBracesForAncestor(ifStmt);
                llvm::errs() << "(symbolicVarDecl) Insert at ";
                StartLoc.dump(SM);
                llvm::errs() << SymbolicCall << "\n";
                OutFile << StartLoc.printToString(SM) << " " << CR.first << " " << CR.second << "\n";
                IsSomeLineSymboliced = true;
                TheRewriter.InsertText(StartLoc, SymbolicCall);

                SymbolicedVarsOfThisIfStmt.insert(VarName);
            }
        } else {
            // llvm::errs() << "VarDecl: " << VD->getNameAsString() << " is a valid variable\n";
        }
    }

    void symbolicFuncCall(IfStmt* ifStmt, CallExpr* FuncCall, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceLocation StartLoc = ifStmt->getBeginLoc();

        if (FunctionDecl *FD = FuncCall->getDirectCallee()) {
            std::string FuncName = FD->getNameInfo().getName().getAsString();
            std::string ReturnType = FD->getReturnType().getAsString();
            std::string TmpVarName = "tmp_" + FuncName + "_result_" + std::to_string(FuncCall->getBeginLoc().getRawEncoding());
            std::string FuncCallStmt = ReturnType + " " + TmpVarName + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
            if (FD->getReturnType()->isFunctionPointerType()) {
                std::string VarType = FD->getReturnType().getAsString();
                size_t pos = VarType.find(" (*)");
                if (pos != std::string::npos) {
                    VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                    FuncCallStmt = VarType + " = " + TheRewriter.getRewrittenText(FuncCall->getSourceRange()) + ";\n";
                }
            }
            std::string SymbolicCall = getSymbolicCall(FD->getReturnType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarName, "", "");
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicFuncCall) Insert at ";
            StartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << FuncCallStmt + SymbolicCall << "\n";
            OutFile << StartLoc.printToString(TheRewriter.getSourceMgr()) << " " << CR.first << " " << CR.second << "\n";
            IsSomeLineSymboliced = true;
            TheRewriter.InsertText(StartLoc, FuncCallStmt + SymbolicCall);

            // 替换if条件中的函数调用为返回值变量
            TheRewriter.ReplaceText(FuncCall->getSourceRange(), TmpVarName);
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

    void symbolicMemberExpr(IfStmt* ifStmt, MemberExpr* ME, 
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceLocation StartLoc = ifStmt->getBeginLoc();
        
        std::string MemberExprStr = TheRewriter.getRewrittenText(ME->getSourceRange());
        std::string TmpVarName = "tmp_" + MemberExprStr;
        std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        std::string tmpVarAssignmentExpr = TmpVarName + " = " + MemberExprStr + ";\n";
        std::string FlagVarName = TmpVarName + "_flag";

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
            std::string FlagVarDecl = "int " + TmpVarName + "_flag = 0;\n";
            SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
            if (InsertLoc.isMacroID()) {
                InsertLoc = TheRewriter.getSourceMgr().getExpansionLoc(InsertLoc);
            }
            llvm::errs() << "(symbolicMemberExpr) Insert at ";
            InsertLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
            TheRewriter.InsertText(InsertLoc, VarDeclStmt + FlagVarDecl);
            DefinedFlags.insert(UniqueID);
        }

        std::string TmpVarNameStr = TmpVarName + "_" + std::to_string(StartLoc.getRawEncoding());
        if (SymbolicedVarsOfThisIfStmt.find(MemberExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
            std::string SymbolicCall = getSymbolicCall(ME->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarNameStr, FlagVarName, tmpVarAssignmentExpr);
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicMemberExpr) Insert at ";
            StartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << SymbolicCall << "\n";
            OutFile << StartLoc.printToString(TheRewriter.getSourceMgr()) << " " << CR.first << " " << CR.second << "\n";
            IsSomeLineSymboliced = true;
            TheRewriter.InsertText(StartLoc, SymbolicCall);

            SymbolicedVarsOfThisIfStmt.insert(MemberExprStr);
        }
        
        TheRewriter.ReplaceText(ME->getSourceRange(), TmpVarName);
    }

    void symbolicArraySubscriptExpr(IfStmt* ifStmt, ArraySubscriptExpr* ASE,
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceLocation StartLoc = ifStmt->getBeginLoc();
        
        std::string ArraySubscriptExprStr = TheRewriter.getRewrittenText(ASE->getSourceRange());
        std::string TmpVarName = "tmp_" + ArraySubscriptExprStr;
        std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        std::string tmpVarAssignmentExpr = TmpVarName + " = " + ArraySubscriptExprStr + ";\n";
        std::string FlagVarName = TmpVarName + "_flag";

        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
        std::string UniqueID = TmpVarName + "_" + FD->getNameInfo().getName().getAsString();
        if (DefinedFlags.find(UniqueID) == DefinedFlags.end()) {
            std::string VarDeclStmt = getNonConstType(ASE->getType()).getAsString() + " " + TmpVarName + ";\n";
            if (ASE->getType()->isFunctionPointerType()) {
                std::string VarType = getNonConstType(ASE->getType()).getAsString();
                size_t pos = VarType.find(" (*)");
                if (pos != std::string::npos) {
                    VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                    VarDeclStmt = VarType + ";\n";
                }
            }
            std::string FlagVarDecl = "int " + TmpVarName + "_flag = 0;\n";
            SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
            if (InsertLoc.isMacroID()) {
                InsertLoc = TheRewriter.getSourceMgr().getExpansionLoc(InsertLoc);
            }
            llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
            InsertLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
            TheRewriter.InsertText(InsertLoc, VarDeclStmt + FlagVarDecl);
            DefinedFlags.insert(UniqueID);
        }

        std::string TmpVarNameStr = TmpVarName + "_" + std::to_string(StartLoc.getRawEncoding());
        if (SymbolicedVarsOfThisIfStmt.find(ArraySubscriptExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
            std::string SymbolicCall = getSymbolicCall(ASE->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarNameStr, FlagVarName, tmpVarAssignmentExpr);
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicArraySubscriptExpr) Insert at ";
            StartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << SymbolicCall << "\n";
            OutFile << StartLoc.printToString(TheRewriter.getSourceMgr()) << " " << CR.first << " " << CR.second << "\n";
            IsSomeLineSymboliced = true;
            TheRewriter.InsertText(StartLoc, SymbolicCall);

            SymbolicedVarsOfThisIfStmt.insert(ArraySubscriptExprStr);
        }
        
        TheRewriter.ReplaceText(ASE->getSourceRange(), TmpVarName);
    }

    void symbolicDerefExpr(IfStmt* ifStmt, UnaryOperator* UO,
        std::unordered_set<std::string>& SymbolicedVarsOfThisIfStmt,
        const std::pair<unsigned, unsigned>& CR) {
        SourceLocation StartLoc = ifStmt->getBeginLoc();
        
        std::string DerefExprStr = TheRewriter.getRewrittenText(UO->getSourceRange());
        std::string TmpVarName = "tmp_" + DerefExprStr;
        std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        std::string tmpVarAssignmentExpr = TmpVarName + " = " + DerefExprStr + ";\n";
        std::string FlagVarName = TmpVarName + "_flag";

        FunctionDecl *FD = findFirstFunctionDeclAncestor(ifStmt);
        std::string UniqueID = TmpVarName + "_" + FD->getNameInfo().getName().getAsString();
        if (DefinedFlags.find(UniqueID) == DefinedFlags.end()) {
            std::string VarDeclStmt = getNonConstType(UO->getType()).getAsString() + " " + TmpVarName + ";\n";
            if (UO->getType()->isFunctionPointerType()) {
                std::string VarType = getNonConstType(UO->getType()).getAsString();
                size_t pos = VarType.find(" (*)");
                if (pos != std::string::npos) {
                    VarType.replace(pos, 4, " (*" + TmpVarName + ")");
                    VarDeclStmt = VarType + ";\n";
                }
            }
            std::string FlagVarDecl = "int " + TmpVarName + "_flag = 0;\n";
            SourceLocation InsertLoc = FD->getBody()->child_begin()->getBeginLoc();
            if (InsertLoc.isMacroID()) {
                InsertLoc = TheRewriter.getSourceMgr().getExpansionLoc(InsertLoc);
            }
            llvm::errs() << "(symbolicDerefExpr) Insert at ";
            InsertLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << VarDeclStmt + FlagVarDecl << "\n";
            TheRewriter.InsertText(InsertLoc, VarDeclStmt + FlagVarDecl);
            DefinedFlags.insert(UniqueID);
        }

        std::string TmpVarNameStr = TmpVarName + "_" + std::to_string(StartLoc.getRawEncoding());
        if (SymbolicedVarsOfThisIfStmt.find(DerefExprStr) == SymbolicedVarsOfThisIfStmt.end()) {
            std::string SymbolicCall = getSymbolicCall(UO->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarNameStr, FlagVarName, tmpVarAssignmentExpr);
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicDerefExpr) Insert at ";
            StartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << SymbolicCall << "\n";
            OutFile << StartLoc.printToString(TheRewriter.getSourceMgr()) << " " << CR.first << " " << CR.second << "\n";
            IsSomeLineSymboliced = true;
            TheRewriter.InsertText(StartLoc, SymbolicCall);

            SymbolicedVarsOfThisIfStmt.insert(DerefExprStr);
        }

        TheRewriter.ReplaceText(UO->getSourceRange(), TmpVarName);
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
        std::string TmpVarName = "tmp_" + MacroExprStr;
        std::replace_if(TmpVarName.begin(), TmpVarName.end(), [](char c) {
            return !((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_');
        }, '_');
        std::string tmpVarAssignmentExpr = TmpVarName + " = " + MacroExprStr + ";\n";
        std::string FlagVarName = TmpVarName + "_flag";

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
            std::string FlagVarDecl = "int " + TmpVarName + "_flag = 0;\n";
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
            std::string SymbolicCall = getSymbolicCall(ME->getType(), findFirstFunctionDeclAncestor(ifStmt), TmpVarName, TmpVarNameStr, FlagVarName, tmpVarAssignmentExpr);
            checkAndAddBracesForAncestor(ifStmt);
            llvm::errs() << "(symbolicMacroExpr) Insert at ";
            StartLoc.dump(TheRewriter.getSourceMgr());
            llvm::errs() << SymbolicCall << "\n";
            OutFile << StartLoc.printToString(TheRewriter.getSourceMgr()) << " " << CR.first << " " << CR.second << "\n";
            IsSomeLineSymboliced = true;
            TheRewriter.InsertText(StartLoc, SymbolicCall);

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
            if (SymbolicExpr->getBeginLoc().isMacroID()) {
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
        if (IsChangedFunction) {
            if (IsFuncFirst) {
                if (Line >= EnableLine && Line <= KillStateLine) {
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
                }
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

    void findVarDeclsAndFuncCalls(Expr *E, std::vector<Expr*>& SymbolicExprs) {
        // If the E is a macro, we just skip it.
        if (E->getBeginLoc().isMacroID()) {
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
    std::vector<std::string> LoopFlagStack;

    SourceLocation& IncludeLoc;
    bool NoNeedToInsertEnd;
    SourceLocation EnableLoc, DisableLoc, KillStateLoc;
    unsigned EnableLine, DisableLine, KillStateLine;
};

class SymbolicAnalyseConsumer : public ASTConsumer {
public:
    SymbolicAnalyseConsumer(Rewriter &R, Preprocessor &PP, const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : R(R), PP(PP), FuncChangeInfo(FuncChangeInfo) {}

    void HandleTranslationUnit(ASTContext &Context) override {
        SymbolicAnalyseVisitor Visitor(Context, R, PP, FuncChangeInfo, IncludeLoc);
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

class SymbolicAnalyseAction : public ASTFrontendAction {
public:
    SymbolicAnalyseAction() = default;
    SymbolicAnalyseAction(const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : FuncChangeInfo(FuncChangeInfo) {}

    std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI, StringRef file) override {
        TheRewriter.setSourceMgr(CI.getSourceManager(), CI.getLangOpts());
        return std::make_unique<SymbolicAnalyseConsumer>(TheRewriter, CI.getPreprocessor(), FuncChangeInfo);
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
        SourceManager &SM = TheRewriter.getSourceMgr();
        llvm::errs() << "** EndSourceFileAction for: "
                     << SM.getFileEntryRefForID(SM.getMainFileID())->getName() << "\n";
        // TheRewriter.getEditBuffer(SM.getMainFileID()).write(llvm::outs());
    }

private:
    Rewriter TheRewriter;
    const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo;
};

static llvm::cl::OptionCategory MyToolCategory("my-tool options");

class SymbolicAnalyseActionFactory : public FrontendActionFactory {
public:
    SymbolicAnalyseActionFactory(const std::unordered_map<std::string, FuncChangeInfoClass>& FuncChangeInfo)
        : FuncChangeInfo(FuncChangeInfo) {}

    std::unique_ptr<FrontendAction> create() override {
        return std::make_unique<SymbolicAnalyseAction>(FuncChangeInfo);
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
    OutFile.open("symbolic_analyse.txt", std::ios::out);
    if (OutFile.fail()) {
        llvm::errs() << "Open file " << "symbolic_analyse.txt" << " failed\n";
        return 1;
    }

    std::string line;
    bool IsStartLocEndToEndFileChanged = false;
    bool IsEndLocEndToEndFileChanged = false;
    while (std::getline(std::cin, line)) {
        if (line == "EOF" || line == "") {
            break;
        }
        
        SymbolicAnalyseContext Context;
        std::stringstream ss(line);
        unsigned CallExprLine;
        while (ss >> CallExprLine) {
            Context.CallExprLines.push_back(CallExprLine);
        }
        sort(Context.CallExprLines.begin(), Context.CallExprLines.end());
        ss.clear();
        std::getline(std::cin, line);
        bool IsFirst = true;
        while (std::getline(std::cin, line)) {
            if (line == "EOF" || line == "") {
                break;
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

        IsSomeLineSymboliced = false;
        for (const auto &FuncChangeInfo : Context.FuncChangeInfos) {
            std::string FilePath = FuncChangeInfo.first;
            std::vector<std::string> SourcePaths = {FilePath};
            if (FilePath == StartLocEndToEndFunctionFilePath) {
                IsStartLocEndToEndFileChanged = true;
            }

            if (FilePath == EndLocEndToEndFunctionFilePath) {
                IsEndLocEndToEndFileChanged = true;
            }

            auto ExpectedParser = CommonOptionsParser::create(argc, argv, MyToolCategory);
            if (!ExpectedParser) {
                llvm::errs() << ExpectedParser.takeError();
                return 1;
            }
            CommonOptionsParser &OptionsParser = ExpectedParser.get();
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

            SymbolicAnalyseActionFactory Factory(FuncChangeInfo.second);
            llvm::errs() << "Run Tool on: " << FilePath << "\n";
            CurrentFilePath = FilePath;
            Tool.run(&Factory);
        }

        if (!IsSomeLineSymboliced)  OutFile << "NULL\n";
        OutFile << "END\n";
    }
    
    return 0;
}
#include <git2.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <unistd.h>
#include <clang-c/Index.h>
#include <clang-c/CXCompilationDatabase.h>
#include <unordered_map>
#include <unordered_set>
#include <algorithm>
#include <regex>
#include <cxxabi.h>

struct diff_info {
    std::string new_path;
    unsigned line_added;
};

std::vector<diff_info> diffs;
std::unordered_map<std::string, std::vector<std::pair<int, int>>> modified_functions;
std::unordered_set<std::string> new_functions;

// 错误处理宏
#define CHECK_ERROR(err, msg) \
    if (err < 0) { \
        const git_error *e = git_error_last(); \
        std::cerr << msg << ": " << (e && e->message ? e->message : "Unknown error") << std::endl; \
        exit(err); \
    }

// 差异回调函数
int diff_file_cb(const git_diff_delta *delta, float progress, void *payload) {
    // std::cout << "--- " << delta->old_file.path << std::endl;
    // std::cout << "+++ " << delta->new_file.path << std::endl;
    return 0;
}

int diff_hunk_cb(const git_diff_delta *delta, const git_diff_hunk *hunk, void *payload) {
    // std::cout << "Hunk: " << hunk->new_start << "," << hunk->new_lines << std::endl;
    // std::cout << hunk->header << std::endl;
    return 0;
}

int diff_line_cb(const git_diff_delta *delta, const git_diff_hunk *hunk, const git_diff_line *line, void *payload) {
    if (line->origin == GIT_DIFF_LINE_ADDITION) {
        diffs.push_back({std::string(delta->new_file.path), (unsigned) line->new_lineno});
    }
    //     std::cout << "+ " << line->new_lineno << ": " << std::string(line->content, line->content_len);
    // } else if (line->origin == GIT_DIFF_LINE_DELETION) {
    //     std::cout << "- " << line->old_lineno << ": " << std::string(line->content, line->content_len);
    // } else if (line->origin == GIT_DIFF_LINE_CONTEXT) {
    //     std::cout << "  " << line->new_lineno << ": " << std::string(line->content, line->content_len);
    // }
    return 0;
}

struct client_data_t {
    std::string filename;
    unsigned line;
};

struct modified_info_t {
    std::string filename;
    std::string funcName;
    std::pair<int, int> range;
    bool& isNew;
};

// 获取函数名
std::string getFunctionName(CXCursor cursor) {
    CXString name = clang_getCursorSpelling(cursor);
    std::string functionName = clang_getCString(name);
    clang_disposeString(name);
    return functionName;
}

// 获取文件名
std::string getFileName(CXSourceLocation location) {
    CXFile file;
    clang_getSpellingLocation(location, &file, nullptr, nullptr, nullptr);
    CXString fileName = clang_getFileName(file);
    std::string fileNameStr = clang_getCString(fileName);
    clang_disposeString(fileName);
    return fileNameStr;
}

std::string demangle(const char* mangled_name) {
    int status = 0;
    std::unique_ptr<char, void (*)(void*)> demangled_name(
        abi::__cxa_demangle(mangled_name, nullptr, nullptr, &status), free);
    return (status == 0) ? demangled_name.get() : mangled_name;
}

// 获取完整的函数名，包括命名空间和类名（如果有）
std::string getQualifiedName(CXCursor cursor) {
    std::string qualifiedName;
    CXCursor parent = cursor;
    while (!clang_Cursor_isNull(parent) && clang_getCursorKind(parent) != CXCursor_TranslationUnit) {
        CXString cursorSpelling = clang_getCursorSpelling(parent);
        std::string name = clang_getCString(cursorSpelling);
        clang_disposeString(cursorSpelling);
        if (!name.empty()) {
            if (!qualifiedName.empty()) {
                qualifiedName = name + "::" + qualifiedName;
            } else {
                qualifiedName = name;
            }
        }
        parent = clang_getCursorSemanticParent(parent);
    }
    return qualifiedName;
}

// 获取函数的mangle名称
std::string getMangledName(CXCursor cursor) {
    CXString mangledName = clang_Cursor_getMangling(cursor);
    std::string mangledNameStr = clang_getCString(mangledName);
    clang_disposeString(mangledName);
    return mangledNameStr;
}

// 递归遍历 AST
CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data) {
    // if (clang_getCursorKind(cursor) == CXCursor_CXXMethod) {
    //     CXSourceRange range = clang_getCursorExtent(cursor);
    //     CXSourceLocation start = clang_getRangeStart(range);
    //     CXSourceLocation end = clang_getRangeEnd(range);

    //     unsigned startLine, startColumn, endLine, endColumn;
    //     clang_getSpellingLocation(start, nullptr, &startLine, &startColumn, nullptr);
    //     clang_getSpellingLocation(end, nullptr, &endLine, &endColumn, nullptr);

    //     if (((client_data_t*)client_data)->filename == "/data/sjz/commit-analysis/mongo-latest/src/mongo/db/admission/throughput_probing.cpp")
    //         // std::cout << "Function: " << getFunctionName(cursor) << " starts at line " << startLine << " and ends at line " << endLine << std::endl;
    // }

    if (clang_getCursorKind(cursor) == CXCursor_FunctionDecl || clang_getCursorKind(cursor) == CXCursor_CXXMethod
        || clang_getCursorKind(cursor) == CXCursor_Constructor || clang_getCursorKind(cursor) == CXCursor_Destructor) {
        if (clang_isCursorDefinition(cursor) == 0)
            return CXChildVisit_Continue;

        unsigned line = ((client_data_t*)client_data)->line;
        CXSourceRange range = clang_getCursorExtent(cursor);
        CXSourceLocation start = clang_getRangeStart(range);
        CXSourceLocation end = clang_getRangeEnd(range);

        unsigned startLine, startColumn, endLine, endColumn;
        clang_getSpellingLocation(start, nullptr, &startLine, &startColumn, nullptr);
        clang_getSpellingLocation(end, nullptr, &endLine, &endColumn, nullptr);

        std::string startFile = getFileName(start);
        std::string endFile = getFileName(end);

        if (startFile == endFile && startFile == ((client_data_t*)client_data)->filename) {
            // std::cout << startFile << " " << endFile << " " << ((client_data_t*)client_data)->filename << std::endl;
            if (line >= startLine && line <= endLine) {
                //std::string qualifiedName = getQualifiedName(cursor);
                std::string mangledName = getMangledName(cursor);
                // std::cout << "Function: " << qualifiedName
                //           << " (mangled: " << mangledName << ")"
                //           << " (demangled: " << demangle(mangledName.c_str()) << ")"
                //           << " in file: " << clang_getCString(fileName)
                //           << " at line: " << line << std::endl;
                // 获取函数参数的类型
                // CXType type = clang_getCursorType(cursor);
                // unsigned numArgs = clang_Cursor_getNumArguments(cursor);
                // for (unsigned i = 0; i < numArgs; ++i) {
                //     CXCursor argCursor = clang_Cursor_getArgument(cursor, i);
                //     CXString argName = clang_getCursorSpelling(argCursor);
                //     CXType argType = clang_getCursorType(argCursor);
                //     std::cout << "Argument " << clang_getCString(argName) << " has type: " << clang_getCString(clang_getTypeSpelling(argType)) << std::endl;
                //     clang_disposeString(argName);
                // }
                // std::string demangledName = demangle(mangledName.c_str());

                // std::cout << "Line " << line << " is in function: " << getFunctionName(cursor) << std::endl;
                // std::cout << getFunctionName(cursor) << std::endl;
                auto itr = modified_functions.find(mangledName + " " + ((client_data_t*)client_data)->filename);
                if (itr == modified_functions.end())
                    itr = modified_functions.insert({mangledName + " " + ((client_data_t*)client_data)->filename, {}}).first;
                auto& modified_ranges = itr->second;
                if (!modified_ranges.empty() && modified_ranges.back().second + 1 == line)
                    modified_ranges.back().second = line;
                else
                    modified_ranges.push_back({line, line});
                return CXChildVisit_Break;
            }
        }
    }
    return CXChildVisit_Recurse;
}

std::string exec(const char* cmd) {
    std::array<char, 128> buffer;
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
        return "";
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    return result;
}

void findFunctionAtLine(const std::string& filename, unsigned line, CXCompilationDatabase& db) {
    static std::string filenameStr = "";
    static CXIndex index = nullptr;
    static CXTranslationUnit unit = nullptr;
    
    if (filenameStr != filename) {
        if (unit != nullptr)
            clang_disposeTranslationUnit(unit);
        if (index != nullptr)
            clang_disposeIndex(index);

        index = clang_createIndex(0, 0);

        CXCompileCommands commands = clang_CompilationDatabase_getCompileCommands(db, filename.c_str());
        unsigned int commands_count = clang_CompileCommands_getSize(commands);
        if (commands_count == 0) {
            std::cerr << "No compile commands found for " << filename << std::endl;
            return;
        }

        std::vector<const char *> args;
        for (unsigned int i = 0; i < commands_count; ++i) {
            CXCompileCommand command = clang_CompileCommands_getCommand(commands, i);
            CXString directory = clang_CompileCommand_getDirectory(command);
            const char* directoryStr = clang_getCString(directory);
            if (strstr(directoryStr, "/test") != nullptr || strstr(directoryStr, "/client") != nullptr) {
                continue;
            }
            unsigned int num_args = clang_CompileCommand_getNumArgs(command);
            for (int j = 1; j < num_args - 2; ++j) {
                CXString arg = clang_CompileCommand_getArg(command, j);
                const char* argStr = clang_getCString(arg);
                args.push_back(argStr);
                clang_disposeString(arg);
            }
            break;
        }

        std::string ResourceDir = exec("clang --print-resource-dir");
        size_t pos = ResourceDir.find_first_of("\n");
        if (pos != std::string::npos)
            ResourceDir = ResourceDir.substr(0, pos);

        if (ResourceDir == "") {
            std::cerr << "Failed to get resource directory" << std::endl;
            return;
        }

        // 添加额外的编译选项
        args.push_back("-resource-dir");
        args.push_back(ResourceDir.c_str());

        CXErrorCode error = clang_parseTranslationUnit2(index, filename.c_str(), args.data(), args.size(), nullptr, 0, CXTranslationUnit_None, &unit);
        if (error != CXError_Success) {
            std::cerr << "Failed to parse translation unit for " << filename << ", error code: " << error << std::endl;
            return;
        }

        clang_CompileCommands_dispose(commands);

        filenameStr = filename;
    }

    client_data_t data = {filename, line};

    CXCursor cursor = clang_getTranslationUnitCursor(unit);
    clang_visitChildren(cursor, visitor, &data);
}

// 检查函数是否是新增的，后续可能需要联合函数名和文件名来判断
bool isFunctionNew(const std::string &funcName) {
    if (new_functions.find(funcName) != new_functions.end()) {
        return true;
    }

    return false;
}

bool is_c_or_cpp_file(const std::string& filename) {
    // 定义C和C++源文件的扩展名
    const std::vector<std::string> c_ext = {".c"};
    const std::vector<std::string> cpp_ext = {".cpp", ".cc", ".cxx", ".C", ".CPP", ".c++", ".cp", ".cxx", ".h", ".hpp"};

    auto endsWith = [](const std::string& str, const std::string suffix) -> bool {
        if (suffix.length() > str.length())  return false;
        return (str.rfind(suffix) == (str.length() - suffix.length()));
    };

    // 检查是否是测试文件，例如路径中包含tests
    if (filename.find("tests") != std::string::npos
        || filename.find("/test") != std::string::npos
        || endsWith(filename, "Test.c")
        || filename.find("/unittest") != std::string::npos) {
        return false;
    }

    // 检查是否是C源文件
    for (const auto& ext : c_ext) {
        if (filename.size() >= ext.size() && 
            filename.compare(filename.size() - ext.size(), ext.size(), ext) == 0) {
            return true;
        }
    }

    // 检查是否是C++源文件
    for (const auto& ext : cpp_ext) {
        if (filename.size() >= ext.size() && 
            filename.compare(filename.size() - ext.size(), ext.size(), ext) == 0) {
            return true;
        }
    }

    return false;
}

int main(int argc, char *argv[]) {
    const char *parent_commit_id_str = nullptr;
    const char *commit_id_str = nullptr;

    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " </path/to/compile_commands.json> [parent_commit_id] [commit_id]" << std::endl;
        return 1;
    }

    const char *compile_commands = argv[1];
    if (argc >= 4) {
        parent_commit_id_str = argv[2];
        commit_id_str = argv[3];
    }

    git_libgit2_init();

    git_repository *repo = nullptr;
    int error = git_repository_open(&repo, ".");
    CHECK_ERROR(error, "Failed to open repository");

    git_oid commit_id;
    if (commit_id_str) {
        error = git_oid_fromstr(&commit_id, commit_id_str);
        CHECK_ERROR(error, "Failed to parse commit ID");
    } else {
        error = git_reference_name_to_id(&commit_id, repo, "HEAD");
        CHECK_ERROR(error, "Failed to resolve HEAD");
    }

    git_commit *commit = nullptr;
    error = git_commit_lookup(&commit, repo, &commit_id);
    CHECK_ERROR(error, "Failed to lookup commit");

    git_tree *tree = nullptr;
    error = git_commit_tree(&tree, commit);
    CHECK_ERROR(error, "Failed to get commit tree");

    if (git_commit_parentcount(commit) == 0) {
        std::cerr << "No parent commit found" << std::endl;
        return 1;
    }

    git_commit *parent_commit = nullptr;

    if (parent_commit_id_str) {
        git_oid parent_commit_id;
        error = git_oid_fromstr(&parent_commit_id, parent_commit_id_str);
        CHECK_ERROR(error, "Failed to parse parent commit ID");

        error = git_commit_lookup(&parent_commit, repo, &parent_commit_id);
        CHECK_ERROR(error, "Failed to lookup parent commit");
    } else {
        error = git_commit_parent(&parent_commit, commit, 0);
        CHECK_ERROR(error, "Failed to get parent commit");
    }

    git_tree *parent_tree = nullptr;
    error = git_commit_tree(&parent_tree, parent_commit);
    CHECK_ERROR(error, "Failed to get parent commit tree");

    git_diff *diff = nullptr;
    error = git_diff_tree_to_tree(&diff, repo, parent_tree, tree, nullptr);
    CHECK_ERROR(error, "Failed to get diff");

    error = git_diff_foreach(diff, diff_file_cb, nullptr, diff_hunk_cb, diff_line_cb, nullptr);
    CHECK_ERROR(error, "Failed to iterate over diff");

    git_diff_free(diff);
    git_tree_free(parent_tree);
    git_commit_free(parent_commit);
    git_tree_free(tree);
    git_commit_free(commit);
    git_repository_free(repo);
    git_libgit2_shutdown();

    std::ifstream new_functions_file("new_function.txt");
    std::string new_function;

    if (new_functions_file.is_open()) {
        while (std::getline(new_functions_file, new_function)) {
            new_functions.insert(new_function);
        }
        new_functions_file.close();
    }

    // get the cwd absolute path
    char cwd[1024];
    if (getcwd(cwd, sizeof(cwd)) == nullptr) {
        std::cerr << "Failed to get current working directory" << std::endl;
        return 1;
    }

    CXCompilationDatabase_Error errorCode;
    CXCompilationDatabase db = clang_CompilationDatabase_fromDirectory(argv[1], &errorCode);
    if (errorCode != CXCompilationDatabase_NoError) {
        std::cerr << "Failed to load compilation database" << std::endl;
        return 1;
    }

    for (const auto &diff : diffs) {
        if (!is_c_or_cpp_file(diff.new_path)) {
            continue;
        }

        std::string filename = std::string(cwd) + "/" + diff.new_path;
        findFunctionAtLine(filename, diff.line_added, db);
    }

    clang_CompilationDatabase_dispose(db);

    for (const auto& [func, ranges] : modified_functions) {
        if (isFunctionNew(func.substr(0, func.find(" ")))) {
            std::cout << "1 ";
        } else {
            std::cout << "0 ";
        }

        std::cout << func;
        for (const auto& range : ranges)
            std::cout << " " << range.first << " " << range.second;
        std::cout << std::endl;
    }

    return 0;
}
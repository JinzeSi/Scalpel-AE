#include <git2.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <unistd.h>
#include <clang-c/Index.h>
#include <unordered_map>
#include <unordered_set>
#include <algorithm>
#include <regex>

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

// 递归遍历 AST
CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data) {
    if (clang_getCursorKind(cursor) == CXCursor_FunctionDecl) {
        unsigned line = ((client_data_t*)client_data)->line;
        CXSourceRange range = clang_getCursorExtent(cursor);
        CXSourceLocation start = clang_getRangeStart(range);
        CXSourceLocation end = clang_getRangeEnd(range);

        unsigned startLine, startColumn, endLine, endColumn;
        clang_getSpellingLocation(start, nullptr, &startLine, &startColumn, nullptr);
        clang_getSpellingLocation(end, nullptr, &endLine, &endColumn, nullptr);

        // std::cout << "Function: " << getFunctionName(cursor) << " starts at line " << startLine << " and ends at line " << endLine << std::endl;

        std::string startFile = getFileName(start);
        std::string endFile = getFileName(end);

        if (startFile == endFile && startFile == ((client_data_t*)client_data)->filename) {
            // std::cout << startFile << " " << endFile << " " << ((client_data_t*)client_data)->filename << std::endl;
            if (line >= startLine && line <= endLine) {
                // std::cout << "Line " << line << " is in function: " << getFunctionName(cursor) << std::endl;
                // std::cout << getFunctionName(cursor) << std::endl;
                auto itr = modified_functions.find(getFunctionName(cursor) + " " + ((client_data_t*)client_data)->filename);
                if (itr == modified_functions.end())
                    itr = modified_functions.insert({getFunctionName(cursor) + " " + ((client_data_t*)client_data)->filename, {}}).first;
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

std::vector<std::string> extractDefines(const std::string& filename) {
    std::ifstream file(filename);
    std::string line;
    std::vector<std::string> defines;
    std::regex ifdef_regex(R"(^\s*#\s*ifdef\s+(\w+))");
    std::regex if_defined_regex(R"(^\s*#\s*if\s+defined\((\w+)\))");

    while (std::getline(file, line)) {
        std::smatch match;
        if (std::regex_search(line, match, ifdef_regex)) {
            defines.push_back("-D" + match[1].str());
        }

        if (std::regex_search(line, match, if_defined_regex)) {
            defines.push_back("-D" + match[1].str());
        }
    }

    return defines;
}

void findFunctionAtLine(const std::string& filename, unsigned line) {
    static std::string filenameStr = "";
    static CXIndex index = nullptr;
    static CXTranslationUnit unit = nullptr;
    
    if (filenameStr != filename) {
        if (unit != nullptr)
            clang_disposeTranslationUnit(unit);
        if (index != nullptr)
            clang_disposeIndex(index);

        index = clang_createIndex(0, 0);
        std::vector<std::string> defines = extractDefines(filename);
        std::vector<const char*> args;
        for (const auto& define : defines) {
            args.push_back(define.c_str());
        }

        unit = clang_parseTranslationUnit(index, filename.c_str(), args.data(), args.size(), nullptr, 0, CXTranslationUnit_None);
        if (unit == nullptr) {
            std::cerr << "Unable to parse translation unit. Quitting." << std::endl;
            return;
        }
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
    const std::vector<std::string> cpp_ext = {".cpp", ".cc", ".cxx", ".C", ".CPP", ".c++", ".cp", ".cxx"};

    auto endsWith = [](const std::string& str, const std::string suffix) -> bool {
        if (suffix.length() > str.length())  return false;
        return (str.rfind(suffix) == (str.length() - suffix.length()));
    };

    // 检查是否是测试文件，例如路径中包含tests
    if (filename.find("tests") != std::string::npos
        || endsWith(filename, "Test.c")) {
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
    const char *commit_id_str = nullptr;

    if (argc >= 2) {
        commit_id_str = argv[1];
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
    error = git_commit_parent(&parent_commit, commit, 0);
    CHECK_ERROR(error, "Failed to get parent commit");

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

    for (const auto &diff : diffs) {
        if (!is_c_or_cpp_file(diff.new_path)) {
            continue;
        }

        std::string filename = std::string(cwd) + "/" + diff.new_path;
        findFunctionAtLine(filename, diff.line_added);
    }

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
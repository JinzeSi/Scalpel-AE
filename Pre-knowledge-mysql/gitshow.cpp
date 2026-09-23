#include <git2.h>
#include <iostream>
#include <vector>
#include <string>

// 错误处理宏
#define CHECK_ERROR(err, msg) \
    if (err < 0) { \
        const git_error *e = git_error_last(); \
        std::cerr << msg << ": " << (e && e->message ? e->message : "Unknown error") << std::endl; \
        exit(err); \
    }

bool startsWith(const std::string& str, const std::string& prefix) {
    if (str.length() < prefix.length()) {
        return false;
    }
    return str.substr(0, prefix.length()) == prefix;
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
// 差异回调函数
int diff_file_cb(const git_diff_delta *delta, float progress, void *payload) {
    // std::cout << "--- " << delta->old_file.path << std::endl;
    if (!is_c_or_cpp_file(delta->new_file.path)) {
        return 0;
    }
    std::cout << delta->new_file.path << std::endl;
    return 0;
}

// int diff_hunk_cb(const git_diff_delta *delta, const git_diff_hunk *hunk, void *payload) {
//     // std::cout << "Hunk: " << hunk->new_start << "," << hunk->new_lines << std::endl;
//     // std::cout << hunk->header << std::endl;
//     return 0;
// }

int diff_line_cb(const git_diff_delta *delta, const git_diff_hunk *hunk, const git_diff_line *line, void *payload) {
    if (!is_c_or_cpp_file(delta->new_file.path)) {
        return 0;
    }

    if (line->origin == GIT_DIFF_LINE_ADDITION) {
        std::cout << line->new_lineno << " +" << std::endl;
    } else if (line->origin == GIT_DIFF_LINE_DELETION) {
        std::cout << line->old_lineno << " -" << std::endl;
    } else if (line->origin == GIT_DIFF_LINE_CONTEXT) {
        std::cout << line->old_lineno << "  " << line->new_lineno  << std::endl;
        // << ": " << std::string(line->content, line->content_len);
    }
    return 0;
}

int main(int argc, char *argv[]) {
    const char *commit_id_str = nullptr;
    const char * filename1 = nullptr;
    if (argc >= 3) {
        commit_id_str = argv[1];
        filename1 = argv[2];
    }
    else{
        filename1 = argv[1];
    }

    git_libgit2_init();

    git_repository *repo = nullptr;
    // int error = git_repository_open(&repo, "/data2/sjz/Pre-knowledge/redis-version/redis/");
    int error = git_repository_open(&repo, filename1);
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

    // error = git_diff_foreach(diff, diff_file_cb, nullptr, diff_hunk_cb, diff_line_cb, nullptr);
    error = git_diff_foreach(diff, diff_file_cb, nullptr, nullptr, diff_line_cb, nullptr);
    CHECK_ERROR(error, "Failed to iterate over diff");

    git_diff_free(diff);
    git_tree_free(parent_tree);
    git_commit_free(parent_commit);
    git_tree_free(tree);
    git_commit_free(commit);
    git_repository_free(repo);
    git_libgit2_shutdown();

    return 0;
}
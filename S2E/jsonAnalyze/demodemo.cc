#include <iostream>
#include <fstream>
#include <vector>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// 函数来递归地遍历 JSON，并尝试找到指定键的祖父节点
void find_grandparent(const json& j, const std::vector<std::string>& path, const std::string& target_key) {
    for (auto& element : j.items()) {
        std::vector<std::string> current_path = path;
        current_path.push_back(element.key());

        if (element.value().is_structured()) {
            // 如果是对象或数组，继续递归
            find_grandparent(element.value(), current_path, target_key);
        } else {
            // 检查当前键是否是目标键
            if (element.key() == target_key) {
                // 如果当前路径长度大于等于3，说明存在祖父节点
                if (current_path.size() >= 3) {
                    std::string grandparent_key = current_path[current_path.size() - 3];
                    std::cout << "Grandparent of '" << target_key << "' is '" << grandparent_key << "'" << std::endl;
                } else {
                    std::cout << "No grandparent found for '" << target_key << "'" << std::endl;
                }
            }
        }
    }
}

int main() {
    // 打开 JSON 文件
    std::ifstream file("example.json");
    if (!file.is_open()) {
        std::cerr << "Failed to open file" << std::endl;
        return 1;
    }

    // 解析 JSON 文件
    json j;
    try {
        file >> j;
    } catch (json::parse_error& e) {
        std::cerr << "JSON parse error: " << e.what() << std::endl;
        return 1;
    }

    // 从根部开始递归搜索
    find_grandparent(j, {}, "target_key");

    return 0;
}

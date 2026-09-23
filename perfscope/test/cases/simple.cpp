// simple.cpp
#include <iostream>

int add(int a, int b) {
    return a + b;
}

void swap(int* a, int* b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

int main() {
    int x = 5;
    int y = 7;
    swap(&x, &y);
    int result = add(x, y);
    std::cout << "The result is: " << result << std::endl;
    return 0;
}
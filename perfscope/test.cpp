#include <stdlib.h>
#include <string>

typedef struct FuncCost {
  std::string name;
  unsigned cost;
  FuncCost() : cost(0) {}
  FuncCost(const char *n, unsigned cost) : name(n), cost(cost) {}
} FuncCost;

int compareFuncCost(const void *a, const void *b)
{
  FuncCost * fa = (FuncCost *) a;
  FuncCost * fb = (FuncCost *) b;
  return (fb->cost - fa->cost); // reverse order
}

int main(int argc, char* argv[]) {
  int size = argv[1][0] - '0';
  printf("%d\n", size);
  FuncCost * func_cost = new FuncCost[size];
  for (int i = 0; i < size; ++i) {
    func_cost[i].cost = rand();
    func_cost[i].name.assign(std::to_string(rand() % 10 + '0') + "7777777777777");
  }
  for (int i = 0; i < size; ++i) {
    printf("%s\n", func_cost[i].name.c_str());
  }
  qsort(func_cost, size, sizeof(FuncCost), compareFuncCost);
  for (int i = 0; i < size; ++i) {
    printf("%s\n", func_cost[i].name.c_str());
  }
  delete []func_cost;
  return 0;
}
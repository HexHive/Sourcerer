#include <vector>

template <typename number> 
void condense() {
  std::pair<int, double> p;
}

void add_line() {
  auto x  = std::vector<std::pair<int, double> >();
  auto y = std::pair<int, double>(1, 2.0);
  x.push_back(y);
}

int main() {
	// condense<int>();
  add_line();
  return 0;
}

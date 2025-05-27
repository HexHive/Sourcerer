// Generic class sort
#include <vector>
#include <string>

template<typename T>
class generic_class_sort {
    public:
      void add(const std::initializer_list<T> & values)
      {
        data.insert(data.end(), values);
      }

    private:
        std::vector<T> data;
};

void test_class_sort() {
//  generic_class_sort<int> ints;
//  ints.add({ 5,6,4,3,6,7,2,1 });

  generic_class_sort<std::string> strings;
  strings.add({ "e", "a", "d", "c", "f", "b" });
}

int main() {
  test_class_sort();
  return 0;
}

// Generic class sort
#include <vector>
#include <string>
#include <iostream>
#include <algorithm>

template<typename T>
class generic_class_sort {
    public:
        void add(const T &val) {
            data.push_back(val);
        }

        void add(const std::initializer_list<T> & values)
        {
            data.insert(data.end(), values);
        }

        void sort() {
            // No predicate, use default predicate (std::less)
            std::sort(data.begin(), data.end());
        }

        void print() {
            // Print all Ts
            for (const T & t : data)
            {
                std::cout << t << " ";
            }

            std::cout << "\n";
        }

    private:
        std::vector<T> data;
};

void test_class_sort() {
    generic_class_sort<int> ints;
    ints.add({ 5,6,4,3,6,7,2,1 });
    ints.sort();
    ints.print();

    // Output: 1 2 3 4 5 6 6 7

    generic_class_sort<std::string> strings;
    strings.add({ "e", "a", "d", "c", "f", "b" });
    strings.sort();
    strings.print();

    // Output: a b c d e f
}

int main() {
  test_class_sort();
  return 0;
}

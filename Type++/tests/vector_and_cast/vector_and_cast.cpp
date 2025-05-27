#include <iostream>
#include <vector>

class A {
public:
};

class B : public A {
public:
    std::string a = "hello";
};

int main() {
    std::vector<A*> objects;
    objects.push_back(new A());
    objects.push_back(new B());

    A* firstObject = objects[0];
    B* castedObject = static_cast<B*>(firstObject);
    std::cout << castedObject->a << std::endl;
    std::vector<A*>* sameObjects = static_cast<std::vector<A*>*>(((void*)&objects));
    return 0;
}

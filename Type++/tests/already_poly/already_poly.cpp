#include <iostream>
#include <vector>

class A {
public:
    virtual ~A() {}
};

class B : public A {
public:
    std::string a = "hello";
    virtual ~B() {}
};

int main() {
    std::vector<A*> objects;
    objects.push_back(new A());
    objects.push_back(new B());

    A* firstObject = objects[0];
    B* castedObject = static_cast<B*>(firstObject);
    std::cout << castedObject->a << std::endl;

    return 0;
}

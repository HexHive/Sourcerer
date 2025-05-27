#include <stdlib.h> 

class Base {
public:
    int x;
};

class Derived : public Base {
public:
    int y;
};

int main() {
    Base* b = reinterpret_cast<Base*>(malloc(sizeof(Base)));
    Derived* d = (Derived*)(b);
    d = reinterpret_cast<Derived*>(b);
    d = static_cast<Derived*>(b);
    free(b);
    b = (Base*)(malloc(sizeof(Base)));
    d = (Derived*)(b);
    d = reinterpret_cast<Derived*>(b);
    d = static_cast<Derived*>(b);
}

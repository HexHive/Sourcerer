#include <stdlib.h>
class A {
public:
    int x;
};


class B : public A {
public:
    int y;
};

class C : public A {
public:
    int z;
};

class D {
public:
    int w;
};

class E {
public:
    int v;
}; 

void foo(void* ptr) {
}

int main () {
    void* b = (void*)new B();
    C* c = static_cast<C*>(b);
    E* e = (E*) malloc(sizeof(E));  
    foo(new D());
    return 0;
}

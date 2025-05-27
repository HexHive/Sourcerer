#include <memory>

class B {
    // Define class B members here
    //B() = delete;
};

class D {

};

class E {

};

class C {
    public:
    // Define class C members here
    D d;
};

class A {
public:
    int x = 1;
    int y = 12;
    B b;
    C c;
    int z = 3;
};

int main() {
    A* a = (A*)malloc(sizeof(A));
    A* a2 = new A();
    C* c = reinterpret_cast<C*>(&a->b);

    // Use the allocated A and casted C here

    D* d = new D();
    E* c2 = reinterpret_cast<E*>(d);
    E* c3 = reinterpret_cast<E*>(&a->c.d);
    free(a);
    return 0;
}

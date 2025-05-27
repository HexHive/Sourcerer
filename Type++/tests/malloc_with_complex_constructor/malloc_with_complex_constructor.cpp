#include <stdlib.h> 

class D {
public:
    int x;
    D(int x) : x(x) {}
};

D* foo() {
    return new D(0);
};

class Base {
public:
    int x;
    D* d;
    Base(int x=0, D* d = foo()) {
        this->x = x;
        this->d = d;
    }
};

class Derived : public Base {
public:
    int y;
};

class Base2 {
public:
    int x;
    D* d;
    Base2(int x=0, D* d = new D(0)) {
        this->x = x;
        this->d = d;
    }
};

class Derived2 : public Base2 {
public:
    int y;
};

class Base3 {
public:
    int x;
    D* d;
    Base3(int x=0, D* d = (D*)malloc(sizeof(D))) {
        this->x = x;
        this->d = d;
    }
};

class Derived3 : public Base3 {
public:
    int y;
};

class Base4 {
public:
    int x;
    D* d;
    Base4(int x=0, D* d = 0) {
        this->x = x;
        this->d = d;
    }
};

class Derived4 : public Base4 {
public:
    int y;
};

int main() {
    Base* b = (Base*)(malloc(sizeof(Base)));
    Derived* d = (Derived*)(b);
    free(b);
    Base2* b2 = (Base2*)(malloc(sizeof(Base2)));
    Derived2* d2 = (Derived2*)(b2);
    free(b2);
    Base3* b3 = (Base3*)(malloc(sizeof(Base3)));
    Derived3* d3= (Derived3*)(b3);
    free(b3);
    Base4* b4 = (Base4*)(malloc(sizeof(Base4)));
    Derived4* d4= (Derived4*)(b4);
    free(b4);
}

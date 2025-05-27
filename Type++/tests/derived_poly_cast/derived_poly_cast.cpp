class A {
public:
    int x = 0;
};

class B : public A {
public:
    int y = 0;
    virtual ~B() {};
};  

class C : public A {
public:
    int z = 0;
};

void fun(A* arg) {
    C* c = static_cast<C*>(arg);
   // c->z = 1;
}

int main() {
    A* c = new B();
    C* c2 = static_cast<C*>(c);
    A* c1 = new C();
    C* c3 = static_cast<C*>(c1);
    //fun(c);
    return 0;
}

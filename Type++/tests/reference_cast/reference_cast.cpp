class Base1 {
public:
    int base1;
};

class Child1 : public Base1 {
public:
    int child1;
};

class Child2 : public Base1 {
public:
    int child2;
};

class E {
public:
    int e;
};

class F {
public:
    int f;
};

class Unrelated {
public:
    int unrelated;
};

int main() {
    Child1 c1 = Child1();
    c1.child1 = 1;
    c1.base1 = 2;
    Base1& b1 = static_cast<Base1&>(c1);
    Child1& c3 = static_cast<Child1&>(b1);
    Child2& c4 = static_cast<Child2&>(b1);
    E e = E();
    E* e2 = static_cast<E*>((void*)(&e));
    Unrelated* u = static_cast<Unrelated*>((void*)(&e));
    return 0;
}

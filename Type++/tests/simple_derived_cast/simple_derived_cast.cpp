
class A{};

class B: public A{
    int b = 3;
};

class C: public B{
    long c = 4;
}; 

int main(){
    A* a = new A();
    A* ab = new B();
    A* ac = new C();

    B* b = static_cast<B*>(a); // Derived type confusion
    B* b2 = static_cast<B*>(ab); // derived handle cast
    B* b3 = static_cast<B*>(ac); // derived handle cast 

    C* c = static_cast<C*>(a); // derived type confusion
    C* c2 = static_cast<C*>(ab); // derived type confusion
    C* c3 = static_cast<C*>(ac); // derived handle cast
    C* c4 = static_cast<C*>(b2); // derived type confusion
    C* c5 = static_cast<C*>(b3); // derived handle cast
}
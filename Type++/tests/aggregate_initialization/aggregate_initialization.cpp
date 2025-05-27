// Reference : https://en.cppreference.com/w/cpp/language/aggregate_initialization
// Definition : Initializes an aggregate from an initializer list.

#include <iostream>
using namespace std;



class D {};
class E : public D {
    float y = 0.0f;
};
class F : public D {
    int index = 0; 
};
class G {};

struct A {
    D* d;
    void* e;
};

int main(void){
    D* d = new D;
    E* e = new E;
    //A a = {new E, new E};
    A a = A{d, static_cast<void*>(e)};

    F* f = static_cast<F*>(a.d); // derived type confusion
    G* g = static_cast<G*>(a.e); // unrelated type confusion

    A a2{new F, new E}; // OK

    D* d2 = static_cast<E*>(a2.e); // unrelated handled cast
    E* e2 = static_cast<E*>(a2.d); // derived type confusion

    return 0;
}




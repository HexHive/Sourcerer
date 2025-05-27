#include <string>
#include <cstdlib>
#include <iostream>
using namespace std;

class D {
    public:
    float x = 1.0;
};

class E : public D {
    public:
    string y = "hello";
};

class F : public D {   
    public:
    int z = 2;
};

class G {
    public:
    unsigned long long w = 3;
    void doSomething() {}
};

int main(){
    char* ptr = (char*)malloc(sizeof(E)+sizeof(D)+sizeof(G));

    E* e = new(ptr) E();
    D* d = new(ptr+sizeof(E)) D();
    G* g = new(ptr+sizeof(E)+sizeof(D)) G();

    cout << e << " " << d << " " << g << endl;
    cout << e->y << " " << d->x << " " << g->w << endl;

    D* d2 = static_cast<E*>(e); // upcast
    F* f = static_cast<F*>(d2); // derived type confusion

    F* f2 = static_cast<F*>(d); // derived type confusion

    G* g2 = (G*)static_cast<void*>(g); // unrelated handle cast

    F* f3 = static_cast<F*>((void*)g); // unrelated type confusion

    // with ptr now

    D* d3 = static_cast<D*>((void*)ptr); // unrelated handle cast
    F* f4 = static_cast<F*>(d3); // derived type confusion

    E* e2 = static_cast<E*>((void*)(ptr+sizeof(E))); // unrelated type confusion

    G* g3 = static_cast<G*>((void*)(ptr+sizeof(E)+sizeof(D))); // unrelated handle cast


}
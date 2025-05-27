#include <cstddef>
#include <string>
#include <iostream>

using namespace std;

class A {
    float aId = 32.23f;
};

class D{
    public:
    int val = 10;
    void hello(){
        val = val -10;
        cout << "Hi I'm Dee!" << endl;
    }
};

class E : public D {
    string strq = "str";
    public:
    void hello(){
        cout << "Hello I'm Eee! " << val << endl;
    }
};

class F: public D {
    float fl = 10.0f;
    public:
    void hello(){
        cout << "Hello I'm Eff! " << val << endl;
    }
    
};

union Union {
    A* a;
    D* d;
    E* e;
    F* f;

    ~Union() {};
};



int main(){



    Union u = {};
    D* d = new D();
    u.d = d;

    F* f = static_cast<F*>(u.d); // derived type confusion

    Union u2 = {};
    E* e = new E();
    u2.d = static_cast<D*>(e);

    F* f2 = static_cast<F*>(u2.d); // derived type confusion
    

    return 0;
}

// duplicates:
// two classes same function, let function names, need to have the same layout
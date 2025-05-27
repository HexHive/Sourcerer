
#include <iostream>
#include <string>
using namespace std;

class D {};
class E : public D {
    float y = 0.0f;
    void hello(){
        cout << "Hello I'm Eee!" << endl;
    };
};

class F : public D {
    string str = "str";
    void sleep(){
        cout << "I'm sleeping" << endl;
    };
};

class G {
    void bye(string message){
        cout << message << endl;
    }
};

int main(){
    D d = D();
    E e = E();
    F f = F();

    D* dtab[3] = {&d, &e, &f};
    
    for (int i = 0; i < 3; i++){
        D* di = dtab[i];
        E* ei = static_cast<E*>(di); // 1 derived handled cast, 2 invalid cast (derived type confusion)
        // the 2 invalid cast are wrongly cast
    }


    G g = G();
    void* vtab[4] = {&e, &f, &d, &g};

    for (int i = 0; i < 4; i++){
        G* gi = reinterpret_cast<G*>(vtab[i]); // 3 unrelated type confusion 
    }
}
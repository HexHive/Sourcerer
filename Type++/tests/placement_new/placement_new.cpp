// placement new using classes and objects

#include <iostream>
using namespace std;

class A {
    private: 
        unsigned char buffer[10*sizeof(int)] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'};
        int a_;

    public:
    A (int arg): a_(arg) {
        cout << "A constructor with value a = " << a_ << endl;
    }

    void printMyChar(){
        if (a_ < 10 && a_ > 0){
            cout << "My char is " << buffer[a_] << endl;
        } else {
            cout << "My char is out of bounds" << endl;
        }
    }

    ~A() {
        cout << "A destructor with value a = " << a_ << endl;
    }
};

class D{
    int d_;
    public:

    D(long arg): d_(arg) {
        cout << "D constructor with value d = " << d_ << endl;
    }

    ~D() {
        cout << "D destructor with value d = " << d_ << endl;
    }
    
};

class E : public D {
    
    long e_;
    string my_password;

    public:
    E(int argd, long arge, string password): D(argd), e_(arge), my_password(password){
        cout << "E constructor with value e = " << e_ << endl;
    }

    void print(){
        cout << "e = " << e_ << endl;
    }

    void printPassword(){
        cout << "password = " << my_password << endl;
    }

    ~E() {
        cout << "E destructor with value e = " << e_ << endl;
    }
};

struct F: public D {
    private:
    long f_;
    
    public:
    F(int argd, long argf): D(argd) , f_(argf){
        cout << "F constructor with value f = " << f_ << endl;
    }

    ~F() {
        cout << "F destructor with value f = " << f_ << endl;
    }
};

int main(){
    
    // placement new after new

    A* a = new A(42);

    cout << "a reference " << a << endl;

    D* d = new (a) D(1234567890); 

    cout << "d reference " << d << endl;

    E* e = static_cast<E*>(d); // Derived Type confusion 

    A* a2 = reinterpret_cast<A*>(d); // Unrelated Type confusion

}
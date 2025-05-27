// Reference : https://en.cppreference.com/w/cpp/language/new
// Definition : Creates and initializes objects with dynamic storage duration, 
// that is, objects whose lifetime is not necessarily limited by the scope in which they were created.

// TODO placement new (create an object from an other object)

#include <iostream>
#include <string>

using namespace std;

struct D{
    int val = 10;
    void hello(){
        cout << "Hi !" << endl;
    }

    D(){
        val = 10;
    }
};

struct E : public D {

    void hello(){
        val = val + 20;
        cout << "Hello !" << val << endl;
    }
    E(){
        val = 30;
    }
};

struct F: public D {
    void hello(){
        val = val + 30;
        cout << "Bonjour !" << val << endl;
    }

    F(){
        val = 40;
    }
};

int main(){
    void *t = new D();
    E* ptr = (E*)t; // Unrelated type confusion ?

    
}
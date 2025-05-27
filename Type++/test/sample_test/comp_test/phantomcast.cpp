#include <iostream>

using namespace std;

class Parent {
    int c;
};

class Child: public Parent {
    // int b;
};

class Child2: public Child {
    int a;
};

int main(int argc, char** argv) {

    Child *aa; // = new Child();
    Child2 *bb; // = new Child2();

    Parent* zz = new Parent();
    Child* xx = static_cast<Child*>(zz);

    Child* qq = static_cast<Child*>(bb);
    Child2* ww = static_cast<Child2*>(aa);

    return 0;
}

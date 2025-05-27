#include <stdio.h>
class  A {
public:
    int x;
    A(int y){x = y;};
};

class B {
    A a;
    B(A a2) { 
        a = a2;
    };

};

int main() {
    A a = A(2);
    printf("%i", a.x);
}
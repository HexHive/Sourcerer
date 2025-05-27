#include <stdlib.h>
#include <memory>
#include <iostream>

using namespace std;

template<class T>
class A {
	int x = 0;
};

class B {
};
template<class T> 
struct C // template definition
{
    void f() {}
    void g(); // never defined
}; 
 
template struct C<double>; // explicit instantiation of C<double>
C<int> a;                  // implicit instantiation of C<int>
C<char>* p;                // nothing is instantiated here

int main (void) {
	A<int>* a = new A<int>();
	B* b = (B*)malloc(sizeof(B));



	cout << "Hello" << endl;

}
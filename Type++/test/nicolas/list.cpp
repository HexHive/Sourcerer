#include <list>

// dealII issue. 
// Segfault when list is intiliazed
// A should be in the Target list

using namespace std;

class Z {

};


class A {
	public:
	list<Z> l;
	int x;
	A() {x = 2;};
};

int main(void) {
	A a = A(); 	
	Z z;
	a.l.push_back(z);
	return a.x;
}
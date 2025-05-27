using namespace std;
#include <memory>
#include <iostream>

class A {
	public:
	int x = 2;
};

class B : public  A {
	public:
	int y;
};

class C: public B {
	public:
	int z [10000000];
};

class D: public C{
	public:
	int a;
};

int main (void) {
	B* b = new B();
	C* c = static_cast<C*>(b);
	for(int i = 0; i< 10000000; ++i) {
		c->z[i] = 1;
	}
	A* a = (A*) c;

	return a->x + c->z[0];
}
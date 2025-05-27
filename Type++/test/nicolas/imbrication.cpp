#include <stdlib.h>
#include <iostream>

class A {
	int y;

};
class CC {};

class C {
	public:
	int x;
	C(){};
	int fun() {
		std::cout<<"hello2\n"<<std::endl;

	}
};

class D: public C {
	public:
	int y[10000];
	public:
	int fun() {
		std::cout<<"hello\n"<<std::endl;
		return 1;
	}
};

class B {
	public:
	C c = C();
};


int main(void) {

	B* b = (B*) malloc(sizeof(B));
	D* c0 = reinterpret_cast<D*>(&(b[0].c));
	c0->y[10000] = 2;
	return c0->fun();
}
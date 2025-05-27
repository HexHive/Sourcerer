#include <memory>

class A {
public:
	A() {};
	virtual ~A() {};
};

class B {

	virtual ~B() {};
};


int main(void) {
	unsigned long a2 = (unsigned long)new A();
	B* b2 = (B*) a2; // this is an unrelated cast, not detected by LLVM-CFI nor Type++
	//void* a = new A(); 
	//B* b = (B*) a;	// Unrelated cast detected by both.
	return 0;
}
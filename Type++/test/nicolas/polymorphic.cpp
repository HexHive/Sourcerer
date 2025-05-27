using namespace std;

// Should spun out B & C as target class.
// Type confusion from B to C
// Should crash.

class Z {

};

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
	Z z;
	virtual int func() {
	};
};

int main (void) {
	B* b = new B();
	C* c = static_cast<C*>(b);
	for(int i = 0; i< 10000000; ++i) {
		c->z[i] = 1;
	}
	A* a = c;

	return a->x + c->z[0];
}
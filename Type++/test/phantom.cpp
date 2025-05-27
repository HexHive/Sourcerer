class A {
	int x;
};

class B : public A {
};

A a = A();
B* b = static_cast<B*>(&a);
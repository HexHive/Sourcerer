#include <stdlib.h> /* malloc, free, rand */

/*
 Type++ should not instrument these classes

$ export TYPEPLUS_LOG_PATH=/tmp/poly_test
$ export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}/merged.txt
$ rm -drf ${TYPEPLUS_LOG_PATH}
$ mkdir -p ${TYPEPLUS_LOG_PATH}
$ /home/nbadoux/Typesafety-vtable/LLVM/build/bin/clang++ -fsanitize=typeplus  \
 		-mllvm -create-derived-cast-type-list \
 		-mllvm -create-unrelated-cast-type-list \
 		polymorphic_derived_cast.cpp
$ ./a.out
$ cat ${TYPEPLUS_LOG_PATH}/casting_obj_init*

Should not produce print anything as not casting_obj_init... file should be
present in TYPEPLUS_LOG_PATH

$ /home/nbadoux/Typesafety-vtable/LLVM/build/bin/clang++ -fsanitize=typeplus  \
		-mllvm -check-unrelated-casting \
		-mllvm -check-base-to-derived-casting \
		-mllvm -apply-vtable-standard \
		-mllvm -cast-obj-opt \
		-mllvm -collect-profiling-data  \
		-flto \
		-fvisibility=hidden \
		polymorphic_derived_cast.cpp
$ ./a.out

Should detect a typeconfusion (check typeplus.h to make sure logging is ON)

*/

class A {
	public:
  virtual ~A();
	int x;
};

A::~A() {}


class B : public A {
	public: 
    virtual ~B();
	double z; 
};
B::~B() {}

class C : public A {
	public:
    virtual ~C();
	int x;
};

C::~C() {}
int main(void) {
	A* aa = new A();
	B* bb = new B();
	C* c = new C();
	A* aaa = dynamic_cast<A*>(bb);
	C* cc = dynamic_cast<C*>(aaa);
	aaa = static_cast<A*>(bb);
	cc = static_cast<C*>(aaa);
	return 0;
}

#include <stdlib.h> /* malloc, free, rand */

/*
 Type++ should instrument the class A

$ export TYPEPLUS_LOG_PATH=/tmp/poly_test
$ export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}/merged.txt
$ rm -drf ${TYPEPLUS_LOG_PATH}
$ mkdir -p ${TYPEPLUS_LOG_PATH}
$ /home/nbadoux/Typesafety-vtable/LLVM/build/bin/clang++ -fsanitize=typeplus  \
 		-mllvm -create-derived-cast-type-list \
 		-mllvm -create-unrelated-cast-type-list \
 		basic_derived_cast.cpp
$ ./a.out
$ cat ${TYPEPLUS_LOG_PATH}/casting_obj_init*

It should detect the class A as a class to be involved in forced polymorphism.

$ cp ${TYPEPLUS_LOG_PATH}/casting_obj_init* ${TARGET_TYPE_LIST_PATH}
$ /home/nbadoux/Typesafety-vtable/LLVM/build/bin/clang++ -fsanitize=typeplus  \
		-mllvm -check-unrelated-casting \
		-mllvm -check-base-to-derived-casting \
		-mllvm -apply-vtable-standard \
		-mllvm -cast-obj-opt \
		-mllvm -collect-profiling-data  \
		-flto \
		-fvisibility=hidden \
		basic_derived_cast.cpp
$ ./a.out

Should detect a typeconfusion (check typeplus.h to make sure logging is ON)

*/
class A {
	public:
	int x;
};


class B : public A {
	public: 
	double z; 
};

class C : public A {
	public:
	int x;
	virtual ~C() = default;
};

int main(void) {
	A* aa = new A();
	B* bb = new B();
	C* c = new C();
	A* aaa = static_cast<A*>(bb);
	C* cc = static_cast<C*>(aaa);
	aaa = reinterpret_cast<A*>(bb); // not counted by LLVM-CFI
	cc = reinterpret_cast<C*>(aaa);
	return cc->x + aaa->x;
}

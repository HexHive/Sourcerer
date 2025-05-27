//#include <stdio.h>
#include <new>
/* CFI

class __tree_node__tree_node {
	public:
	virtual ~__tree_node__tree_node(){};

};

class B {
	public:
	int a = 3;
};
*//*
class A  {
	int x;
	A (int a) {

	};
	int get() {return x;};
};
class __tree_node {
	A a;
public:
	int z;
	__tree_node(int x)  {
		z = 1;
	};
}; 

class Z {

};


int main(void) {
	__tree_node* a  = static_cast<__tree_node*>(std::__libcpp_allocate(sizeof(__tree_node), 0));
	printf("Should be 1 == %i\n", a->z);
//	__tree_node* aa  = static_cast<__tree_node*>(::operator new(sizeof(__tree_node)));
//	printf("Should be 1 == %i\n", aa->z);
//	__tree_node(1);

	return 0; 
};*/

template<class T>
class __tree_node {
public:
	__tree_node() {};
	int a;
	__tree_node(int x)  {
		a = 1;
	};
};
/*
class Z {

};
*/
int main(void) {
	__tree_node<int>* a  = static_cast<__tree_node<int>*>(std::__libcpp_allocate(sizeof(__tree_node<int>), 0));
	//printf("Should be 1 == %i\n", a->a);
	//__tree_node<int>* aa  = static_cast<__tree_node<int>*>(::operator new(sizeof(__tree_node<int>)));
		//printf("Should be 1 == %i\n", aa->a);
		__tree_node<int>();
//	a->a = 2;
//	printf("Should be 2 == %i\n", a->a);
//	void * b = a;
//	// CFI B* aa = static_cast<B*>(b);
//	__tree_node* aa = static_cast<__tree_node*>(b);
//	printf("Should be 2 == %i\n", aa->a);
//	void* aa = a;
//	B* b = static_cast<B*>(aa);
//	__tree_node* c;
//	c = new __tree_node();
//	int* x = new int(1);
	//void* zz = ::operator new(1 * sizeof(Z));
	//Z* z  = static_cast<Z*>(zz);
	//Z* z2  = static_cast<Z*>(::operator new(1 * sizeof(Z)));
	return 0;
}
/*
void* a = new __tree_node();

B* b = static_cast<B>(a);


static_cast_report_void*(void* a)

if (enabled cfi_unrelated_cast) 
	unrelated cast raise error
	else 
		continue
add/overwrite vtable because it comes from new


void* x = ..
static_cast<__tree_node>(x);


__tree_node a = new (buf) __tree_node 1



new:

add consturctor call everytime



static_cast/reinterpret_cast

check_derived_to_base 
if no vtable
	we add one here

*/
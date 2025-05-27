#include <stdlib.h> /* malloc, free, rand */
#include <stdio.h>
#include <cstddef>
class DLPSV {
	public:
	int x = 11;
	int y = 11;

	DLPSV() { x = 12;};
};

#define MAXA 100000

class CC {
	public:
	float cc;
	CC() {
		cc=3.4;

	}
};
class A {
	public:
	int x;
};
template <class DATA>
   struct Item
   {
			CC c;
      DATA data; ///< data element
      DATA data2; ///< data element
      int info;  ///< element number. info \f$\in\f$ [0,thesize-1]
                 ///< iff element is used
			A a; 
   };
template <class DATA>
class DataSet
{
public:
	 Item<DATA>* theitem;  ///< array of elements in the #DataSet

	DataSet() {
		theitem = (Item<DATA>*)malloc(sizeof(Item<DATA>));
		theitem->info = 1;
		DLPSV *d = new DLPSV();
	}
};



int main(void) {
	DataSet<DLPSV>* set = new DataSet<DLPSV>();
	printf("%f\n", set->theitem->c.cc);
	printf("%d\n", set->theitem->data.x);
	void* d = reinterpret_cast<void*>(&set->theitem->data);
	A* aa = new A();
	A* a = reinterpret_cast<A*>(d);
	DLPSV* dd = reinterpret_cast<DLPSV*>(d);
	printf("offset of data: %i, c: %i, info: %i, a: %i, data2: %i\n", offsetof(Item<DLPSV>, data), offsetof(Item<DLPSV>, c), offsetof(Item<DLPSV>, info), offsetof(Item<DLPSV>, a), offsetof(Item<DLPSV>, data2));
	/*for(int i = 0; i < MAXA; i++) {
		a->a[i] = 100000;
	}//*/
//	DLPSV* d = new DLPSV();
//	A* aa = reinterpret_cast<A*>(d);
//	return aa->a[0];
}
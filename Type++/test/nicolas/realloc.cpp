// export CUSTOM_HEADER_SIZE=48 # set the header size for pov malloc
#include <malloc.h>
#include <iostream>

using namespace std;
class A{
	public:
	int x = 1;
	A() {
		x = 2;
	};
};

static void* spx_realloc(void* x, int y) {
	return nullptr;
}

size_t HEADER_SIZE = 0x30;

static void* pov_malloc(size_t s) {
	void * x  = malloc(s+HEADER_SIZE);
	char* xx = (char*)x;
	for(int i = 0; i < HEADER_SIZE; i++) {
		xx[i] = 'A';
	}
	return (void*)(((char*)x)+HEADER_SIZE);
}

static void* test_calloc(size_t s, size_t x) {
	return calloc(s,x);
}

static void* test_malloc(size_t s) {
	return malloc(s);
}

static void* pov_realloc(void* p, size_t s) {
	if(p != NULL) {
		p = (void*)(((char*)p)-HEADER_SIZE);
	}
	s = s+HEADER_SIZE;
	char* new_p = (char*)realloc(p, s);
	for(int i = 0; i < HEADER_SIZE; i++) {
		new_p[i] = 'A';
	}
	return (void*)(new_p+HEADER_SIZE);
}

static void* pov_free(void* p) {
	free((void*)(((char*)p) - HEADER_SIZE));
}

static void* test_realloc(void* p, size_t s) {
	return realloc(p, s);
}

int main() {
	cout << "\t\t\t\tMalloc\n";
	A* a0 =(A*) malloc(sizeof(A));
	cout << "\t\t\t\tCalloc 1\n";
	A* a1 =(A*) calloc(1, sizeof(A));
	cout << "\t\t\t\tCustom malloc\n";
	A* a2 =(A*) test_malloc(sizeof(A));
	cout << "\t\t\t\tMalloc 10\n";
	A* a3 =(A*) malloc(10*sizeof(A));
	cout << "\t\t\t\tMalloc with header\n";
	A* a4 =(A*) pov_malloc(sizeof(A));
	cout << "\t\t\t\tCalloc 10\n";
	A* a5 =(A*) calloc(10, sizeof(A));
	cout << "\t\t\t\tCustom calloc\n";
	A* a6 =(A*) test_calloc(10, sizeof(A));
	cout << "\t\t\t\tRealloc +10\n";
	a5 =(A*) realloc(a5, sizeof(A) * 20);
	cout << "\t\t\t\tCustom realloc +10\n";
	a6 =(A*) test_realloc(a6, sizeof(A) * 20);
	cout << "\t\t\t\tCustom realloc +10\n";
	a4 =(A*) pov_realloc(a4, sizeof(A) * 20);
	cout << "\t\t\t\tRealloc +0\n";
	/*a5 =(A*) realloc(a5, sizeof(A) * 20);
	cout << "\t\t\t\tRealloc -19\n"; // not handeled correctly
	a5 =(A*) realloc(a5, sizeof(A) * 1);
	cout << "\t\t\t\tRealloc -> free\n"; //not handle corectly
	a5 =(A*) realloc(a5, sizeof(A) * 0);//*/ 

	cout << "\t\t\t\tRealloc from null\n";
	A* a7 = NULL;
	a7 = (A*) realloc(a7, sizeof(A));
	cout << "\t\t\t\tRealloc from null\n"; // Could cause issue if we removed header size from NULL
	A** a8 = NULL;
	a8 = (A**) pov_realloc(a8, sizeof(A*));
	a8[0] = (A*) malloc(sizeof(A));//*/

	free(a0);
	free(a1);
	free(a2);
	free(a3);
	pov_free(a4);
	/*free(a5);
	free(a6);//*/
	free(a7);
	free(a8);//*/
	return 0;
}
#include <malloc.h>
#include <iostream>

class A{
	public:
	int x = 0;
	/*A() {
		x = 2;
	};*/
};

static void* spx_realloc(void* x, int y) {
	return nullptr;
}

int main() {
	A* z =(A*) malloc(sizeof(A));
	A* y =(A*) calloc(1, sizeof(A));
	A* x =(A*) calloc(10, sizeof(A));
	x =(A*) realloc(x, sizeof(A) * 20);
	x =(A*) realloc(x, sizeof(A) * 20);
	x =(A*) realloc(x, sizeof(A) * 1);
	x =(A*) realloc(x, sizeof(A) * 0);
	A* x =(A*) malloc(sizeof(A));
/*	for(int i = 0; i < 100; i++) {
		void* x = calloc(i, sizeof(i));
		int a = malloc_usable_size(x);
		std::cout << i << "-" << i*sizeof(i) << ": " << a << "\n";


	}
	std::cout << "\n";*/
	int ret = x->x;
	free(x);
	free(y);
	free(z);
	return ret;
}
#include <stdlib.h>
#include <malloc.h>

int main(void) {
	
	char* a;

	a = (char*) calloc(12, sizeof(char));
	printf("%i\n", malloc_usable_size(a));
	printf("%i\n", malloc_usable_size(a+1));
	a = (char*)realloc(a, 30*sizeof(char));
	printf("%i\n", malloc_usable_size(a));
	return 0;
}
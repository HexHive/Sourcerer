#include<memory>

template<class T>
class Z {
	public:
	int a = 12;
//	Z() {};
	Z(int x) {a = x;}
};

template<class T>
class B {
	public:
	//Z a; 
	const Z<T> a; 
	int b = 2;
};


int main(void) {
	B<int>* b = (B<int>*)calloc(2, sizeof(B<int>));
	//B* b = (B*)calloc(2, sizeof(B));
	return b->b;
};
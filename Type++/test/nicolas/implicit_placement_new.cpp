#include <stdio.h>
class X {
	public:
	const char x[1] = "";
};
class Y {
	public:
	char __blob_[sizeof(X)];
};
int main(int argc, char *argv[]) {
	X* x = new X();
	Y* y = new Y();
	y = reinterpret_cast<Y*>(x);
	y->__blob_[0] = 'a';
	X* x2 = reinterpret_cast<X*>(y);
	// static_assert(sizeof(X) == sizeof(Y), "");|\label{fig:charcastinga}|
	printf("%c\n", x2->x[0]);
	return 0;
}
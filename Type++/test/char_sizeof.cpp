#include <stdio.h>
class X {
};
struct Y {
 char __blob_[sizeof(X)];
};
int main(int argc, char *argv[])
{
 Y y;
 // static_assert(sizeof(Y) == sizeof(X), "");
 X* x = reinterpret_cast<X*>(y.__blob_);
 return 0;
}

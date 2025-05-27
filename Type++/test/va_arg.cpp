#include <stdarg.h>

class P {
};

void hello(P* p, ...) {
    va_list ap;
    va_start(ap,p);
    P *pat = va_arg(ap,P*);
}
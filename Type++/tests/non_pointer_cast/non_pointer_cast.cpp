
class A {
public:
    int x = 0;
};

class B {
public:
    int y = 0;
    B(A* a) {
        a->x = 1;
    }
};

int main () {
    short a=2000;
    // implicit cast
    int b = (int) a;
    const char * c = "sample text";
    // const cast
    char* cc = const_cast<char *> (c);
    return 0;
}

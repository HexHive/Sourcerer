class C {
public:
    int x = 0;
};

class D {
public:
    int y = 0;
};

void fun(int* arg) {
    C* c = reinterpret_cast<C*>(arg);
    c->x = 1;
}

int main() {
    C* c = new C();
    fun((int*)c);
    D* d = new D();
    fun((int*)d);
    return 0;
}

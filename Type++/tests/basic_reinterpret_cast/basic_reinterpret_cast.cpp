class C {
public:
    int x = 0;
};

class D {
public:
    int y = 0;
};

void fun(void* arg) {
    C* c = (C*)(arg);
    C* cc = reinterpret_cast<C*>(arg);
    C* ccc = static_cast<C*>(arg);
}

int main() {
    C* c = new C();
    fun(c);
    D* d = new D();
    fun(d);
    return 0;
}

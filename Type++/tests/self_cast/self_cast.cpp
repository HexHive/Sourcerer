
class A {
public:
    int x = 0;
};      

int main () {
    A* a = new A();
    A* aa = static_cast<A*>(a);
    A* aaa = reinterpret_cast<A*>(a);
    return 0;
}

#include <iostream>
#include <memory>

using namespace std;

class B1 {
    public:
        int payload;
};

class B : public B1 {
public:

    // int payload;
    // double payload2;
    // B1 b1;
    explicit B() {payload=0xc;}

    virtual void foo2() {

        cout << "I am foo()\n";
    }

    B& operator=(const B& theRHS)
	{
        this->payload = theRHS.payload;
        return *this;
	}
};
class A {
public:
    // to try:
    // A(const B& b = B()) {
    // A(const B1& b = B()) { // parent child
    // A(const B b = B()) {
    // A(const B1 b = B()) {
        // m_b = b;
    A(int *a = nullptr) {
        m_a = a;
    }
    // explicit A() {
    //     m_b = B();
    // }

    void foo() {
        cout << "I am foo()\n";
        // cout << "m_b is " << this->m_b.payload <<"\n";
    }
private:

    // B m_b;
    // B1 m_b;
    int *m_a;
};

int main(int argc, const char* argv[]) {

    A* a = (A*)malloc(2*sizeof(A));
    a->foo();
    // A a = A();
    // a.foo();
    // A *a = new A();
    // a->foo();
    // for (int i = 0; i < 10; i++) {
    //     A *a = new A();
    //     a->foo();
    // }

    return 0;
}
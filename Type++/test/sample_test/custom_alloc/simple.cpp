#include <iostream>
#include <string.h>

using namespace std;

class MemoryManager
{
public:
    virtual ~MemoryManager() {}
    virtual void* allocate(size_t size) = 0;
    virtual void deallocate(void* p) = 0;
protected :
    MemoryManager() {}
private:
    MemoryManager(const MemoryManager&);
    MemoryManager& operator=(const MemoryManager&);
};

class MemoryManagerImpl: public MemoryManager
{
public:

    MemoryManagerImpl() {}
    
    virtual ~MemoryManagerImpl() {}
    
    virtual void* allocate(size_t size);

    virtual void deallocate(void* p);

private:
    MemoryManagerImpl(const MemoryManagerImpl&);
    MemoryManagerImpl& operator=(const MemoryManagerImpl&);

};


void* MemoryManagerImpl::allocate(size_t size)
{
    void* memptr = malloc(size);
    return memptr;
}

void MemoryManagerImpl::deallocate(void* p)
{
    free(p);
}

class B {
private:
    char *x = "I am b";
};

B *fB = 0;

class A {
public:
    A(B *pB = fB) {
        memcpy(this->str, "ciaone\0",10);
        this->mB = fB;
    }
    
    void foo() {
        cout << this->str << endl;
    }
private:
    char str[10];
    B *mB;
};

void* my_malloc(size_t x) {
    return malloc(x);
}

int main(int argc, const char* argv[]) {

    // MemoryManagerImpl *memmng = new MemoryManagerImpl();
    MemoryManager *memmng = new MemoryManagerImpl();

    // char *c = (char*)memmng->allocate(10);
    // memcpy(c, "ciao\0", 5);
    // cout << c << endl;

    A *a = (A*)memmng->allocate(sizeof(A));
    // A *a = (A*)malloc(2*sizeof(A));
    // A *a = (A*)my_malloc(2*sizeof(A));

    a->foo();

    return 0;
}
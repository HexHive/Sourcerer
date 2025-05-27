#include <map>

template <typename T1>
class Class2 {

public:
    ~Class2();
};

class OtherClass {
public:
    int value;
    OtherClass()  {}
    bool operator<(const OtherClass& rhs) const {
        return value < rhs.value;
    }
    ~OtherClass() {}
};

template<typename T>
class allocator {
public:
    T* allocate(size_t n) {
        return new T[n];
    }
    void deallocate(T* p, size_t n) {
        delete[] p;
    }
};

template <typename T>
class map2 {
public:
    T* ptr;
    Class2<T>* c2;
    map2() {
    }
    allocator<Class2<T> > alloc;
    
    
    void destroy() {
        ptr->~T();
    };
};

int main() {
    OtherClass o = OtherClass();
    std::map<OtherClass, int> myMap;
    myMap[o] = 1;
    //map2<OtherClass> m = map2<OtherClass>();
    //m.destroy();
    //myMap.erase(o);
    OtherClass* c = new OtherClass();
    void* p = c;
    return 0;
}

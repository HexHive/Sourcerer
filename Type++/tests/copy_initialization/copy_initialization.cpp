// Reference : https://en.cppreference.com/w/cpp/language/copy_initialization
// Definition : Initializes an object from another object. 


#include <string>

class A {
    public:
        int a = 0;
};

class B : public A {
    public:
        int b = 1;
};

class C: public A {
    public:
        int c = 2;
};

class D {
    public:
        std::string s = "I'm dee";
};

C* fromAtoC(A* ptr){

    C* newptr = static_cast<C*>(ptr); // derived_type_confusion
    return newptr;
}

D* fromVoidToD(void* ptr){
    D* newptr = (D*)ptr; // unrelated_type_confusion 
    return newptr;
}


B* fromAtoB(A object){
    B* newptr = static_cast<B*>(&object);
    // object is of type A, it's reference is a ptr on A, then it's downcast => derived_type_confusion
    return newptr;
}

C fromDtoC(D object){
    void* newptr = static_cast<void*>(&object);
    C* newCptr = static_cast<C*>(newptr);
    // unrelated Type Confusion
    return *newCptr; 
}


int main(){

    B* b = new B();
    A* aFromBptr = static_cast<A*>(b); // upcast is fine
    C* c = fromAtoC(aFromBptr); // derived type confusion

    A* a = new A();

    D* d = fromVoidToD((void*)a); // unrelated type confusion

    C* c2 = new C();

    A* arrayA[3] = {a, (A*)b, (A*)c2}; // fine

    B* ptrsB = (B*)arrayA[0]; // derived type_confusion 

    B* ptrsB2 = static_cast<B*>(arrayA[1]); // derived handled cast

    B* ptrsB3 = static_cast<B*>(arrayA[2]); // derived type confusion

    C cObj = C();

    A aObj = {cObj}; // implicit upcasting but is fine

    B* bptr = fromAtoB(aObj); // derived type confusion

    D dObj = D();

    C cObj2 = fromDtoC(dObj); // unrelated type confusion

    B bObj = B();
    
    A* arrayA2[2] = {&aObj, &bObj};

    B bObj2 = *(static_cast<B*>(arrayA2[1])); // derived handled cast

    return 0;
}

#include <iostream>

using namespace std;

struct Base{
    int bId;
    Base(int id): bId(id){};
};

struct Derived: public Base{
    int dId;
    Derived(int dId, int bId): Base(bId), dId(dId) {};
};

struct AnotherDerived: public Base{
    int adId;
    AnotherDerived(int adId, int bId): Base(bId), adId(adId) {};
};

struct Unrelated{
    Derived d;

    Unrelated(Derived d): d(d) {};
};

void printMyDerived(Derived* d){
    cout << "My base id is " << d->bId << endl;
    cout << "My derived id is " << d->dId << endl;
}

Base createMyBase(int i){
    return {i};
}

int main()
{
    Derived d  = {1,2};
    Base* b = &d;

    Derived* d1 = static_cast<Derived*>(b); // Derived Handled Cast

    printMyDerived(static_cast<Derived*>(new Base{1})); // Derived Type confusion
    Base b2 = createMyBase(2);

    AnotherDerived* adId = static_cast<AnotherDerived*>(&b2); // Derived Type confusion

    Unrelated u = Unrelated({1,2});

    Base* b3 = &u.d;
    Derived* d2 = (Derived *)b3; // Derived Handle Cast 
}
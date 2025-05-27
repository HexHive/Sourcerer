// Reference : https://en.cppreference.com/w/cpp/language/direct_initialization
// Definition : Initializes an object from explicit set of constructor arguments. 


#include <iostream>
#include <string>

using namespace std;
struct Structure{
    private:
        int id;
        string name;
    protected:
        Structure(int id, string name): id(id), name(name) {};
    public: 
        Structure(string name): id(0), name(name){};

};

struct AnotherStructure : public Structure {
    int aId;
    AnotherStructure(string name): Structure(0, name), aId(0){}
    AnotherStructure(): Structure(0,""), aId(0){};
};

class ParentClass{
    int pid;
    long timestamp;

    protected:
        ParentClass(): pid(0), timestamp(0L){};

    public:
        ParentClass(int p, long t): pid(p), timestamp(t){};
        
};

class myClass : public ParentClass, public AnotherStructure {
    myClass() : ParentClass(), AnotherStructure(){};

    myClass(string name) : ParentClass(), AnotherStructure(name){};

    public:
        myClass(string name, int p, long t);

        myClass static create_myClass_default(){
            return myClass();
        }

        myClass static create_myClass_using_name(string name){
            return myClass(name);
        }
};

myClass::myClass(string name, int p, long t): ParentClass(p, t), AnotherStructure(name){};


int main(){

    ParentClass p(10, 100L);
    myClass* mc4 = static_cast<myClass*>(&p); // derived type confusion

    myClass mc = myClass::create_myClass_default();
    Structure* s = &mc; // upcast
    AnotherStructure* as = static_cast<AnotherStructure*>(s); // derived handled cast

    myClass mc2 = myClass::create_myClass_using_name("myClass");
    ParentClass* p2 = &mc2; // upcast
    void* v = static_cast<void*>(p2); // cast outside of inheritance hierarchy
    Structure* s2 = static_cast<Structure*>(v); // unrelated type confusion

    myClass mc3("myClass", 10, 100L);
    AnotherStructure* as2 = &mc3; // upcast
    myClass* mc3bis = static_cast<myClass*>(as2); // derived handled cast

    Structure s4{"test"};
    myClass* mc6 = static_cast<myClass*>(&s4); // derived type confusion (missed by Typepp)

    Structure* sptr = new AnotherStructure();
    AnotherStructure* asptr = static_cast<AnotherStructure*>(sptr); // derived handled cast

}
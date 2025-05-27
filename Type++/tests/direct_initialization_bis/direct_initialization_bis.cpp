
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


class myClass : public AnotherStructure {
    myClass() : AnotherStructure(){};

    myClass(string name) : AnotherStructure(name){};

    public:
        myClass(string name, int p, long t);

        myClass static create_myClass_default(){
            return myClass();
        }

        myClass static create_myClass_using_name(string name){
            return myClass(name);
        }
};

myClass::myClass(string name, int p, long t): AnotherStructure(name){};

int main(){
    Structure s4{"test"};
    myClass* mc6 = static_cast<myClass*>(&s4); // derived type confusion (missed by Typepp)
}

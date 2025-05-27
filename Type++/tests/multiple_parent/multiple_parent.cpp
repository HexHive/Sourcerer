#include <iostream>
#include <string>

using namespace std;
class Parent {
    protected:
        string pname;
};

class OtherParent{
    protected:
        string opname;

};

class Child : public Parent, public OtherParent { 
    string cname;

    public:
        void parentName(){
            cout << "my parent is " << pname << " and my other parent is " << opname << endl; 
        }

        Child(string c, string p, string op) {
            cname =c;
            pname = p;
            opname = op;
        };


};

int main(){

    Child* cptr = new Child("Thomas", "Alice", "Bob");
    Child* cptr2 = new Child("Charles", "David", "Eve");
    
    cptr->parentName();

    // Upcast into Downcast 
    Parent* pptr = (Parent*)cptr; // upcast
    Child* correct_cptr1 = (Child*)pptr; // derived handled cast

    OtherParent* opptr = (OtherParent*)cptr2; // upcast
    Child* correct_cptr2 = (Child*)opptr; // derived handled cast

    // Downcast from base1 to derived
    Parent* pptr2 = new Parent();
    Child* cptr3 = (Child*)pptr2; // derived_type_confusion

    // Downcast from base2 to derived
    OtherParent* opptr2 = new OtherParent();
    Child* cptr4 = (Child*)opptr2; // derived_type_confusion however the cast is missed when testing

    // Unrelated type confusion
    void* pptr3 = new Parent();
    OtherParent* opptr3 = (OtherParent*)pptr3; // unrelated_type_confusion

}
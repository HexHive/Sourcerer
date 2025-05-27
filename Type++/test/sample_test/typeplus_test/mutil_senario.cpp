#include <iostream> 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h>

using namespace std; 
  
class TypeA { 
public: 
  int a, b;
  TypeA() { } //TODO (issue 1): Should create default constructor although user declare constructor with parameter 
  TypeA(int a1, int b1) { a = a1; b = b1; } // user defined constructor 
  TypeA(const TypeA &p2) { a = p2.a; b = p2.b; } // copy constructor 
  TypeA(TypeA &&p2) { a = p2.a; b = p2.b; } // move constructor 
  TypeA& operator = (const TypeA &t) { a = t.a; b = t.b; return *this; } // copy assignment
  TypeA& operator = (TypeA &&t) { a = move(t.a); b = move(t.b); return *this; } // move assignment
}; 

class TypeA_child : public TypeA { 
public: 
    int c, d; 
}; 


TypeA moveConstructor() { TypeA a(7, 7); return std::move(a); }

TypeA globalA(1,1);

int paratest(TypeA paraA) {
  TypeA_child *ptrAMemcpy = static_cast<TypeA_child *>(&paraA);
  /*
  if (ptrAMemcpy == nullptr)
    printf("Test4: Parameter test success\n");
  else
    printf("Test4: Parameter test fail\n");*/
  return 0;
}

int paratest2(TypeA &paraA) {
  TypeA_child *ptrAMemcpy = static_cast<TypeA_child *>(&paraA);
  /*
  if (ptrAMemcpy == nullptr)
    printf("Test5: Parameter (reference) test success\n");
  else
    printf("Test5: Parameter (reference) test fail\n");*/
  return 0;
}

int main() 
{ 
  // init
  TypeA *ptrA = (TypeA*)malloc(10 * sizeof(TypeA));    
  TypeA_child *ptrAChild = static_cast<TypeA_child *>(ptrA);
  TypeA_child *ptrAChild2 = static_cast<TypeA_child *>(ptrA);

  // Test1: stack
  TypeA stackA(1,1);
  TypeA_child *ptrAChildStack = static_cast<TypeA_child *>(&stackA);
  /*
  if (!ptrAChildStack)
    printf("Test1: Stack test success\n");
  else
    printf("Test1: Stack test fail\n");
  */

  // Test2: global
  TypeA_child *ptrAChildGlobal = static_cast<TypeA_child *>(&globalA);
  /*
  if (!ptrAChildGlobal)
    printf("Test2: Global test success\n");
  else
    printf("Test2: Global test fail\n");
  */

  // Test3: memcpy case
  TypeA memcpyA(1,2);
  memcpy(&memcpyA, ptrA, sizeof(TypeA));
  TypeA_child *ptrAMemcpy = static_cast<TypeA_child *>(&memcpyA);
  /*
  if (!ptrAMemcpy)
    printf("Test3: Memcpy test success\n");
  else
    printf("Test3: Memcpy test fail\n");
  */

  // Test4: parameter
  TypeA paraA(1,2);
  paratest(paraA);

  // Test5: reference case
  TypeA paraB(2,3);
  paratest2(paraB);

  // Test6: copy constructor
  TypeA copyCon(2,3);
  TypeA copyCon2 = copyCon;

  TypeA_child *ptrcopyCon = static_cast<TypeA_child *>(&copyCon2);
  /*
  if (!ptrcopyCon)
    printf("Test6: CopyCon test success\n");
  else
    printf("Test6: CopyCon test fail\n");
  */

  // Test7: move constructor
  TypeA moveCon(2,3);
  TypeA moveCon2 = moveConstructor();

  TypeA_child *ptrmoveCon = static_cast<TypeA_child *>(&moveCon2);
  /*
  if (!ptrmoveCon)
    printf("Test8: MoveCon test success\n");
  else
    printf("Test8: MoveCon test fail\n");
  */

  // TODO(Jeon) : need to fix
  // Test8: copy assignment
  TypeA copyAssign2(4,5);
  void *TypeATemp = (void*) malloc(sizeof(TypeA));
  TypeA *typeAPtr =  (TypeA*) TypeATemp;
  *typeAPtr = copyAssign2; // problem assignemt using heap

  TypeA_child *ptrcopyAssign = static_cast<TypeA_child *>(typeAPtr);
  /*
  if (!ptrcopyAssign)
    printf("Test7: CopyAssign test success\n");
  else
    printf("Test7: CopyAssign test fail\n");
  */

  // TODO(Jeon) : need to fix
  // Test9: move assignment
  TypeA MoveAssign(2,3), MoveAssign2(4,5);
  void *TypeAMoveTemp = (void*) malloc(sizeof(TypeA));
  TypeA *typeAMovePtr =  (TypeA*) TypeAMoveTemp;
  *typeAMovePtr = moveConstructor(); // problem assignemt using heap

  TypeA_child *ptrmoveAssign = static_cast<TypeA_child *>(typeAMovePtr);
  /*
  if (!ptrmoveAssign)
    printf("Test9: CopyAssign test success\n");
  else
    printf("Test9: CopyAssign test fail\n");
  */

  return 1; 
} 

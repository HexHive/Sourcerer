#include<stdio.h>

class parentType {
public:
  long pass_counter;            /* work units completed in this pass */         
  long pass_limit;              /* total number of work units in this pass */   
  int completed_passes;         /* passes completed so far */                   
  int total_passes;             /* total number of passes expected */          

  parentType() {}; 
};

class childType: public parentType {
public:
  long pass_counter;            /* work units completed in this pass */         
  long pass_limit;              /* total number of work units in this pass */   
  int completed_passes;         /* passes completed so far */                   
  int total_passes;             /* total number of passes expected */          
  childType() {}; 
};

union S
{
  int k;
  parentType pObj;
  childType cObj;
  S() {}
};


class A {
public:
  int a;
}; 

class B {
public:
  int b;
};

union AB {
  A a;
  B b;
  int x;
};

union C {
  A a;
  AB* b;
  int x;
};

void fooA(AB a) {
  B *ptr = reinterpret_cast<B *>(&a);
  A *ptr2 = reinterpret_cast<A *>(&a);
  //printf("fooA\n");
}

void fooB(AB b) {
  A* ptr = reinterpret_cast<A *>(&b);
  B *ptr2 = reinterpret_cast<B *>(&b);
  printf("fooB\n");
}

int main() {
//  S tt;
//
//  tt.pObj.pass_counter=1;
//  parentType *ptr = static_cast<parentType *>(&tt.cObj);
//  tt.cObj.pass_counter=1;
//  childType *ptr2 = static_cast<childType *>(&tt.pObj);

  //AB* ab = new AB();
  //A* a = new A();
  //a->a = 2;
  //C* c = new C();
  //c->b = ab;
  //c->b->a = *a;
  //ab->a = *a;
  //ab->x = 1;
  //fooA(*ab);
  //ab->b = B();
  //fooB(*ab);
  AB ab;
  ab.x = 1;
  A a = A();
  a.a = 2;
  ab.a = a;
  fooA(ab);
  ab.b = B();
  fooB(ab);

  return 0;
}

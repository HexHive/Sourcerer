#include <stdlib.h>
#include <iostream>

using namespace std;

class animal
{
   public:
   int a;
   void foo() {cout << "animal\n"; };
};

struct animal2
{
   public:
   int a;
   void foo() {cout << "animal2\n"; };
};


class cat : public animal {
  public:
  int y, b;
  void foo() {cout << "cat \n"; };
  ~cat();
};

int main()
{
  //cat c; //works

  cat *ptr = (cat*) malloc(sizeof(cat));
  cat *ptrb = new(ptr) cat;
  ptr->foo();

  cat *ptr2 = reinterpret_cast<cat*>(malloc(sizeof(cat)));
  ptr2->foo();
  cat * ptr3 = static_cast<cat*>((void*)ptr2);
  return 0;
}

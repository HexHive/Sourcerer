
#include <cstdlib>

struct Base {
  Base() {}
};

struct Derived : Base {
  Derived() : Base() {}

  const unsigned long variable = 0x12345678;
};

void *MEM_mallocN(size_t x) { return malloc(x); }

int main(int argc, const char *argv[]) {

  //Base B = Base();
  //Derived D = Derived();

  int x = 10;
  Base *B2 = (Base *)MEM_mallocN(10 * sizeof(Base));
  // this is illegal
  for (int i = 0; i < x; i++) {
    Base *B3 = &(B2[i]);
    Derived &dptr2 = static_cast<Derived &>(*B3);
  }

  return 0;
}
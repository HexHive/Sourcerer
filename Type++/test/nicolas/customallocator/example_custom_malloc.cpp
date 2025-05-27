// #include <stdio.h>
#include <stdlib.h>
#include <iostream>
using namespace std;

typedef struct {
    int payload_B;
} B;

typedef struct {
    int payload_A;
} A;

typedef struct {
    A elm_A;
    B elm_B;
} W;

void* MEM_mallocN(size_t my_size) {
    void* my_obj = malloc (my_size);

    if (my_obj == NULL)
        return NULL;
        
    return my_obj;
}

int main (int argc, char** argv)
{
  

  W* w = (W*)MEM_mallocN(sizeof(W));
  int* a = reinterpret_cast<int*>(w);
  cout << a << " <- a \n"; 
  void * w2 = w;

  w->elm_A.payload_A = 0xA;
  w->elm_B.payload_B = 0xF;

  cout << "elm_A.payload_A " << w->elm_A.payload_A  << endl;
  cout << "elm_B.payload_B " << w->elm_B.payload_B  << endl;

  return 0;
}
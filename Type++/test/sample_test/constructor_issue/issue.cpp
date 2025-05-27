#include<iostream>

using namespace std;

class S {
 int t;
};

class T : public S {
  int m;
};

template<class DATA>
class DataSet
{
public:
   struct Item
   {
      DATA data;       ///< data element
      int  info;       ///< element number. info \f$\in\f$ [0,thesize-1]
      Item() {};
                       ///< iff element is used
   }* theitem;         ///< array of elements in the #DataSet

   int themax;         ///< length of arrays #theitem and #thekey
};

template<class DATA>
class DataSet2 {
public:
  struct Item2
  {
    DATA data;       ///< data element
    int  info;       ///< element number. info \f$\in\f$ [0,thesize-1]
    Item2() {};
  } theitem2;         ///< array of elements in the #DataSet

  int k;
};

template <class T>
void foo2 (T& p, int n) {
  T* test = reinterpret_cast<T *>(malloc(sizeof(*p) * n));

  return;
}

template <class T>
void foo3 (T& p, int n) {
  T* test = reinterpret_cast<T *>(malloc(sizeof(p) * n));
  
  return;
}


int main() {
  DataSet<T> test;
  DataSet2<T> test2;

  foo2(test.theitem, 10);
  foo3(test2.theitem2, 10);

  return 1;
}

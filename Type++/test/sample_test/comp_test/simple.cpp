#include <iostream>

using namespace std;

class S {
//  int t;
 public:
  // int a;
  S() {}
  virtual void f() {printf("I am S\n");}
};

class T : public S {
  int m;
  long x;
 public:
  T() {
    printf("k\n");
  }
  virtual void f() {printf("I am T\n");}
};

// class P : public T {
//  public:
//   P() {
//     printf("k\n");
//   }
//   virtual void f() {printf("I am P\n");}
// };


// class TT : public S {
//   // int m;
//   // long x;
//  public:
//   TT() {
//     printf("k\n");
//   }
// };


// class Z {};

// class X : public Z {
// 	// other fields
// };
// struct Y {
// 	char __blob_[sizeof(X)];
// };

int main(int argc, char** argv) {

  printf("ciao!\n");

  // TT* ptt = new TT;

  // P* ppp = new P;

  // S* ps = new S;
  // const S* ps_const = new S;
  // T* pt = static_cast<T*>(ps); // bad-casting!

  // S* ptt2 =  const_cast<S*>(ps); // bad-casting!

  // T* pt2 = dynamic_cast<T*>(ps); // bad-casting!

  // TT* ptt3 = (TT*)ps;
  // T* ppt4 = (T*)ps;
  // P* ppp5 = (P*)ps;

  // T* ptt6 = dynamic_cast<T*>(ps); // bad-casting!

  // // X* xx2 = new X();
  // Z* zz = new Z();
  // X* xx = static_cast<X*>(zz);

  T t;

  printf("T: %lu\n", sizeof(T));
  printf("S: %lu\n", sizeof(S));
  // printf("int: %lu\n", sizeof(int));
  // printf("int*: %lu\n", sizeof(int*));

  // Y y;
	// X* x = reinterpret_cast<X*>(y.__blob_);

  // int* x2 = reinterpret_cast<int*>(y.__blob_);

  // // printf("offsetof*: %lu\n", offsetof(S, a));

  // int a = (int)2.4;

  // int *a2 = (int*)&t;

  // S** ps2 = (S**)pt;

  // T tt;
  // S ps3 = (S)tt;
  // // T tt2 = (T)ps3;

  return 1;
}

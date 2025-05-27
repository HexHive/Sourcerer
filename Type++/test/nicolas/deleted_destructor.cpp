#include <map>
#include <list>
using namespace std;



class Z {
public:
//	virtual ~Z();
	int a;
	bool operator< (const Z & e2) const
    {
      return false;
    }
};


class A {
	public:
	list<Z> l;
	int x;
	~A() = delete;
	A() {x = 2;};
};



/*class Z  {
	int y = 0;
	public:
	Z(){};
	bool operator< (const Z & e2) const
    {
      return false;
    }
};*/

int main (void) {
	map<Z, int> gquiz1;
 
  //insert elements in random order
	Z* zz = (Z*) malloc(sizeof(Z));
  gquiz1.insert(pair<Z, int>(*zz, 40));
	A a = A(); 	
	Z z;
	a.l.push_back(z);
	return a.x;
}
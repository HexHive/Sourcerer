#include <map>
#include <iostream>

class Z  {
	int y = 0;
	public:
	Z(){};
	bool operator< (const Z & e2) const
    {
      return false;
    }
};
class A
{
  private:
     std::map<int,Z> valueToNameMap;
		 public:
 void insert(int value, Z name);
A()
{
};

class Z {
public:
//	virtual ~Z();
	int a;
	bool operator< (const Z & e2) const
    {
      return false;
    }
};

void A::insert(int value, Z name)
{
    valueToNameMap[value] = name;
};



int main (void) {
	A a;
	Z z;
	a.insert(1, z);
	return 0;
}
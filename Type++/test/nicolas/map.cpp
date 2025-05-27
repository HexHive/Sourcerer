#include <map>
#include <iostream>

class A
{
  private:
     std::map<int,std::string> valueToNameMap;
     std::map<std::string,int> nameToValueMap;
		 public:
 void insert(int value, const char *name);
A()
{
};

};

void A::insert(int value, const char *name)
{
    valueToNameMap[value] = name;
    nameToValueMap[name] = value;
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
	A a;
	a.insert(1, "hello");
	return 0;
}
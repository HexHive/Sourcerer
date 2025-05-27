#include <map>
using namespace std;

class Z  {
	int y = 0;
	public:
	int t = 7;
	Z(int x) {y = x;};
	bool operator< (const Z & e2) const
    {
      return false;
    }
};

int main (void) {
	map<int, Z> m;
 
  //insert elements in random order
  m.insert(pair<int, int>(1, 40));
	return m.at(1).t;
}
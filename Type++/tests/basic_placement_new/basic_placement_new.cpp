// basic placement new file 

#include <iostream>
using namespace std;

int main(){

    // allocate buffer
    unsigned char buffer[10*sizeof(int)];

    cout << "buffer reference " << (void*)buffer << endl;

    // placement new
    int* p = new (buffer) int(42); 
    
    cout << "p reference " << p << endl;

    long* q = new (buffer + sizeof(int)) long(1234567890); 

    cout << "q reference " << q << endl;

}
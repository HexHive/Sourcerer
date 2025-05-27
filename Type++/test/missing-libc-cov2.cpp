class Parent{ 
};
class Child : public Parent { };


int main(void) {
       Parent* p;
       static_cast<Child*>(p);
//       Parent pp;
}



//pointer allocate(size_type count, const void* =0) { return reinterpret_cast<pointer>(fastMalloc(count * sizeof (_Tp))); }
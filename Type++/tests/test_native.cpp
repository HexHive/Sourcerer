  #include <iostream>
  
  class a {
  protected:
    int width, height;
  
  public:
    int n;
    virtual void set_values (int a, int b)
    { width=a; height=b; }
  };
  
  class b : public a {
  public:
    int area()
    { return width*height; }
  };
  
  class c : public a {
  public:
    int area()
    { return width*height; }
  };
  
  int main() {
    class a x;
    b *y = dynamic_cast<b *>(&x);

    return 1;
  }


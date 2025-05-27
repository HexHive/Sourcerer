  
  class a {
  protected:
    int width, height;
  
  public:
    int n;
//    void set_values (int a, int b)
//    { width=a; height=b; }
  };

  class alone {
  protected:
    int width, height;
  
  public:
    int n;
//    void set_values (int a, int b)
//    { width=a; height=b; }
  };

  class b : public a {
  public:
    int k;
    int area()
    { return width*height; }
  };
  
  class c : public a {
  public:
    int p;
    int area()
    { return width*height; }
  };
  
  int main() {
    class a x;
    class b y;
    class alone zz;
    b *yy = static_cast<b *>(&x);
    return 0;
  }

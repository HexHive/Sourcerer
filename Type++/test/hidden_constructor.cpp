class  A {
  private:
    A();
  public: 
    virtual ~A(){};
};
class B {
  public:
    A a;
    B() : a(){}
};
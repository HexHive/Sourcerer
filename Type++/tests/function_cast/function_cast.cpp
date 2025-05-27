int foo(int x) {
  return x*2;
}


int main() {

  int (*f)(int) = foo;
  int (*g)(int) = reinterpret_cast<int (*)(int)>(f);
  return g(2)-4;
}

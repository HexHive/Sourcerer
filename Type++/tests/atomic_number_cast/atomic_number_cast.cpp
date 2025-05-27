#include <atomic>
#include <iostream>

typedef long Atomic64;
typedef std::atomic<Atomic64> *AtomicLocation64;

inline AtomicLocation64 Acquire_Load(volatile const Atomic64 *ptr) {
  AtomicLocation64 x = ((AtomicLocation64)ptr);
  // x->load(std::memory_order_acquire);
  std::cout << "executed\n";
  return x;
}

int main() {
  AtomicLocation64 atomicLocation3 = new std::atomic<Atomic64>(0);
  Acquire_Load((Atomic64*)atomicLocation3);
  return 0;
}

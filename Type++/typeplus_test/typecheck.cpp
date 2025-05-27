#include <stdlib.h>
#include <stdio.h>

#include "types.h"

extern void allocate(int count);

__attribute__((noinline)) BaseType* getbaseptr(AllocType *allocptr) {
#if defined(BASE_BASIC) || defined(BASE_NESTED0) || defined(BASE_NESTED) || defined(BASE_NESTED_MIXED)
    return &(allocptr->baseMember);
#endif
#ifdef BASE_NESTED_ARRAY
    return &(allocptr->baseMember[2]);
#endif
#ifdef BASE_NESTED_DEEP
    return &(allocptr->intermediate.intermediate2.baseMember);
#endif
#ifdef BASE_NESTED_ARRAY_DEEP
    return &(allocptr->intermediate[2].intermediate2[2].baseMember[2]);
#endif
#if defined(BASE_INHERITANCE) || defined(BASE_VINHERITANCE) || defined(BASE_INHERITANCE_MULTI) || defined(BASE_VINHERITANCE_MULTI) || defined(BASE_INHERITANCE_MULTI_DEEP) || defined(BASE_VINHERITANCE_MULTI_DEEP)
    return static_cast<BaseType*>(allocptr);
#endif
}

#ifdef DO_PASSING
struct TestNegativeBaseType {
    unsigned long longMember;
};
struct TestNegativeDerivedType : TestNegativeBaseType {
};
struct TestNegativeType {
    TestNegativeDerivedType t1;
    TestNegativeDerivedType t2;
    TestNegativeDerivedType t3;
    TestNegativeDerivedType t4;
    BaseType base;
};

__attribute__((noinline)) void checkcast(BaseType *ptr) {
    if (dynamic_cast<CAST_TYPE*>(ptr) == NULL) {
      printf("ok\n");
      exit(-1);
    }
    // Check if any negative offsets from BaseType are affected
    TestNegativeType *testNegative = new TestNegativeType();
    TestNegativeBaseType *testPtr;
    testPtr = &(testNegative->t1);
    if (dynamic_cast<TestNegativeDerivedType*>(testPtr) == NULL) {
      printf("ok\n");
      exit(-1);
    }
    testPtr = &(testNegative->t2);
    if (dynamic_cast<TestNegativeDerivedType*>(testPtr) == NULL) {
      printf("ok\n");
      exit(-1);
    }
    testPtr = &(testNegative->t3);
    if (dynamic_cast<TestNegativeDerivedType*>(testPtr) == NULL) {
      printf("ok\n");
      exit(-1);
    }
    testPtr = &(testNegative->t4);
    if (dynamic_cast<TestNegativeDerivedType*>(testPtr) == NULL) {
      printf("ok\n");
      exit(-1);
    }
}
#else
__attribute__((noinline)) void checkcast(BaseType *ptr) {
    if (dynamic_cast<CAST_TYPE*>(ptr) == NULL) {
        printf("ok\n");
        exit(-1);
    }
}
#endif

int main(int argc, char **argv) {
    allocate(argc * 10);
    return 0;
}

/*
Command:
export TYPEPLUS_LOG_PATH=`pwd`
export TARGET_TYPE_LIST_PATH=`pwd`/merged.txt


rm warning.txt; rm type*;
./build.sh
./build/bin/clang++   -Wuninitialized warning_trigger.cpp  -fsanitize=typeplus -mllvm -create-derived-cast-type-list -mllvm -create-unrelated-cast-type-list -mllvm -cast-obj-opt -mllvm -apply-vtable-standard -fno-strict-aliasing -fno-inline-functions -fvisibility=hidden -std=c++03
./build/bin/clang++  -cc1 -load /home/nicolasbadoux/Typesafety-vtable/LLVM/build/lib/TypeXXCodeChecker.so  -plugin typexx-codecheck -fsyntax-only -Wuninitialized ../warniing_trigger.cpp  -fsanitize=typeplus -mllvm -create-derived-cast-type-list -mllvm -create-unrelated-cast-type-list -mllvm -cast-obj-opt -mllvm -apply-vtable-standard
cat warning.txt 
cat type*


merged.txt
D 
B 

works !

Not work if:  not constructor call for B or D somewhere as data is not collected 

*/
class D { 
};

class B : D{};

int main(void) {
	D* d = new D();
	B* b = reinterpret_cast<B*>(d);
	B* b2 = (B*) d;
	B bb = B();
	return sizeof(D) == 2;
}

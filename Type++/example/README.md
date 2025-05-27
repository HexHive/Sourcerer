### Example
Here is a minimal example highliting the detection of type confusion caused by
wrong derived casting.  

#### Test code (`sample.cpp`) 

```c++
#include<iostream>
  
using namespace std;

class S {
 int t;
};

class T : public S {
  int m;
};

int main() {
  S* ps = new S;
  T* pt = static_cast<T*>(ps); // bad-casting!
  return 1;
}
```

#### Set enviroment variable 

```bash
source ${HOME}/environment_patched.sh
export TYPEPLUS_LOG_PATH="/tmp/sample"
export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}"/merged.txt"
export LD_LIBRARY_PATH=${BUILD_FOLDER}/../libunwind-build/lib
mkdir -p ${TYPEPLUS_LOG_PATH}
```

#### Compile with original Clang to ensure the porgram is C++ compliant with respect to default constructors rules

```bash
${BUILD_FOLDER}/bin/clang++ sample.cpp -Wall
```


#### Create casting related object list 

```bash
${BUILD_FOLDER}/bin/clang++ sample.cpp \
    -stdlib=libc++ -nostdinc++ \
    -Wl,-rpath,${BUILD_FOLDER}/../libcxx-build/lib \
    -L${BUILD_FOLDER}/../libcxx-build/lib \
    -I${BUILD_FOLDER}/../libcxx-build/include/c++/v1 \
    -Wl,-rpath,${BUILD_FOLDER}/../libcxxabi-build/lib \
    -L${BUILD_FOLDER}/../libcxxabi-build/lib \
    -Wl,-rpath,${BUILD_FOLDER}/../libunwind-build/lib \
    -L${BUILD_FOLDER}/../libunwind-build/lib \
    -fsanitize=typeplus \
    -flto \
    -fvisibility=hidden \
    -mllvm -create-derived-cast-type-list
```

#### Merge class files 

The classes collected can be spread out to multiple files if the compiler used
multiple processes. In this case, we first need to merge all this files
together. 

```bash
${LLVM_FOLDER}/Type++/script/merge_typecasting_related_type.py ${TYPEPLUS_LOG_PATH} > ${TARGET_TYPE_LIST_PATH}
```

#### Compile

```bash
${BUILD_FOLDER}/bin/clang++ sample.cpp \
    -stdlib=libc++ -nostdinc++ \
    -Wl,-rpath,${BUILD_FOLDER}/../libcxx-build/lib \
    -L${BUILD_FOLDER}/../libcxx-build/lib \
    -I${BUILD_FOLDER}/../libcxx-build/include/c++/v1 \
    -Wl,-rpath,${BUILD_FOLDER}/../libcxxabi-build/lib \
    -L${BUILD_FOLDER}/../libcxxabi-build/lib \
    -Wl,-rpath,${BUILD_FOLDER}/../libunwind-build/lib \
    -L${BUILD_FOLDER}/../libunwind-build/lib \
    -fsanitize=typeplus \
    -flto \
    -fvisibility=hidden \
    -mllvm -apply-vtable-standard \
    -mllvm -poly-classes \
    -mllvm -cast-obj-opt \
    -mllvm -check-base-to-derived-casting \
    -mllvm -collect-profiling-data \
    -mllvm -check-unrelated-casting
```

#### Run the binary
As we enabled ` -mllvm -collect-profiling-data`, the binary will print a summary in `TYPEPLUS_LOG_PATH` folder. 
```bash
rm -drf ${TYPEPLUS_LOG_PATH}/total_result.txt
./a.out
cat ${TYPEPLUS_LOG_PATH}/total_result.txt
```
If you want more details on the type confusion (e.g., line number), you can
enable either `PRINT_BAD_CASTING_FILE` or `PRINT_BAD_CASTING_STDOUT` in the
[`typeplus.h`](LLVM/src/compiler-rt-files/typeplus.h) file before recompiling
type++ via the `build.sh ` script.

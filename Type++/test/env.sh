export BUILD_DIR=/home/vwvw/Typesafety-vtable/LLVM
export TEST_DIR=/home/vwvw/Typesafety-vtable/test

export TARGET_TYPE_LIST_PATH=${TEST_DIR}/merged.txt
export TYPEPLUS_LOG_PATH=${TEST_DIR}

export TO_REMOVE=('a.out' 'total_result.txt' 'type_confusion2.txt')
export DEFAULT_ARGS="-m64  -std=c++11 -Wno-c++11-narrowing -Wno-unused-command-line-argument -flto -fvisibility=hidden -fno-strict-aliasing -Wno-c++11-narrowing -fno-inline-functions -std=gnu++98 -Wuninitialized -Wno-string-plus-int -Wall -Werror -Wno-delete-non-abstract-non-virtual-dtor -Wno-comment -Wno-unused-variable -Wno-c++11-extensions"
export TYPEPLUS="-fsanitize=typeplus   -mllvm -create-derived-cast-type-list -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting  -mllvm -collect-profiling-data -mllvm -check-unrelated-casting -mllvm -create-unrelated-cast-type-list"
export LIBPATH="/home/vwvw/Typesafety-vtable/LLVM/libcxx-build-for-program"
export LIBPATHABI="/home/vwvw/Typesafety-vtable/LLVM/libcxxabi-build-for-program"
export LIBPATHUNWIND="/home/vwvw/Typesafety-vtable/LLVM/libunwind-build-for-program"
export LIBRARYCPP1="-stdlib=libc++ -nostdinc++ -Wl,-rpath,${LIBPATH}/lib -L${LIBPATH}/lib -I${LIBPATH}/include/c++/v1"
export LIBRARYCPP2="-stdlib=libc++ -nostdinc++ -Wl,-rpath,${LIBPATHABI}/lib -L${LIBPATHABI}/lib -I${LIBPATHABI}/include/c++/v1"
export LIBRARYCPP3="-stdlib=libc++ -nostdinc++ -Wl,-rpath,${LIBPATHUNWIND}/lib -L${LIBPATHUNWIND}/lib -I${LIBPATHUNWIND}/include/c++/v1"
export LIBRARYCPP="${LIBRARYCPP1} ${LIBRARYCPP2} ${LIBRARYCPP3}"
export CLANG=/home/vwvw/Typesafety-vtable/LLVM/build/bin/clang++
export CLANG_DEBUG=/home/vwvw/Typesafety-vtable/LLVM/build-debug/bin/clang++

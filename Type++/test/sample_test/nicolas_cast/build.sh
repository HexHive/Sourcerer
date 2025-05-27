#!/bin/bash

CLANG_PATH=../../../LLVM/build/bin/clang++ 
# CLANG_PATH=../../../LLVM/build-debug/bin/clang++ 
PROJECT_PATH=/home/nbadoux/Typesafety-vtable
MERGE_SCRIPT_PATH=../../../script/merge_typecasting_related_type.py

rm -f typehashinfo.txt typeinfo.txt type_confusion.txt
rm -f mangled_name.txt
rm -f casting_*

export TARGET_TYPE_LIST_PATH=$PWD"/casting_related_type.txt"
export TYPEPLUS_LOG_PATH=$PWD"/"
touch $TARGET_TYPE_LIST_PATH

export LD_LIBRARY_PATH=$PROJECT_PATH/LLVM/build/lib

# $CLANG_PATH -O0 simple.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib \
#     -I$PROJECT_PATH/LLVM/build/include/c++/v1 \
#     -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting \
#     -mllvm -check-code-compatibility   
# -fsanitize=typeplus
# -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting \

$CLANG_PATH simple.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list 
# -mllvm -check-code-compatibility

python $MERGE_SCRIPT_PATH $PWD &> $PWD/casting_related_type.txt

$CLANG_PATH simple.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list -fsanitize=typeplus -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting -mllvm -check-unrelated-casting -g
# -mllvm -collect-profiling-data 

# $CLANG_PATH simple.cpp -O2 -stdlib=libc++ -nostdinc++ -Wno-c++11-narrowing -Wno-unused-command-line-argument -Wno-shift-negative-value -Wno-c++11-narrowing -Wno-return-stack-address -Wno-null-dereference -Wno-dangling-else -Wno-unused-comparison -Wno-empty-body -Wno-deprecated -Wno-deprecated-register -Wno-deprecated-declarations -flto -fvisibility=hidden -fno-inline-functions -fno-strict-aliasing -std=c++03  -fsanitize=cfi-derived-cast -fsanitize=cfi-unrelated-cast  -Wl,-rpath,/workspace/typesafety-vtable/spec_cpu/../LLVM/build/lib -L/workspace/typesafety-vtable/spec_cpu/../LLVM/build/lib -I/workspace/typesafety-vtable/spec_cpu/../LLVM/build/include/c++/v1 -mllvm -collect-profiling-data -fno-sanitize-trap=cfi-derived-cast -fsanitize-recover=cfi-derived-cast

./a.out

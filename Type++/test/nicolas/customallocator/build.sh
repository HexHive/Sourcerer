#!/bin/bash


CXX=../../LLVM/build/bin/clang++ 
PROJECT_PATH=/workspace/typesafety-vtable
MERGE_SCRIPT_PATH=../../script/merge_typecasting_related_type.py

rm -f typehashinfo.txt typeinfo.txt type_confusion.txt
rm -f casting_*

export TARGET_TYPE_LIST_PATH=$PWD"/casting_related_type.txt"
export TYPEPLUS_LOG_PATH=$PWD"/"
touch $TARGET_TYPE_LIST_PATH

export LD_LIBRARY_PATH=$PROJECT_PATH/LLVM/build/lib

TARGET=example_custom_malloc

$CXX $TARGET.cpp -g -O0 -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-unrelated-cast-type-list -mllvm -create-derived-cast-type-list -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting -mllvm -check-code-compatibility -o $TARGET.out

python $MERGE_SCRIPT_PATH $PWD &> $PWD/casting_related_type.txt

$CXX $TARGET.cpp -g -O0 -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-unrelated-cast-type-list -mllvm -create-derived-cast-type-list -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting -mllvm -check-code-compatibility -o $TARGET.out

# ./$TARGET.out

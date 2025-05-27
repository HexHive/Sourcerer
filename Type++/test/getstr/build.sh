#!/bin/bash

CLANG_PATH=../../LLVM/build/bin/clang++
MERGE_SCRIPT_PATH=../../../script/merge_typecasting_related_type.py
PROJECT_PATH=/workspace/typesafety-vtable/

DIR=`pwd`
export TARGET_TYPE_LIST_PATH=$DIR"/casting_related_type.txt"
export TYPEPLUS_LOG_PATH=$DIR
touch $TARGET_TYPE_LIST_PATH

$CLANG_PATH sample.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list

python $MERGE_SCRIPT_PATH $DIR &> $DIR/casting_related_type.txt

$CLANG_PATH sample.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list -fsanitize=typeplus -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting


# ALSO THIS ONE!
export LD_LIBRARY_PATH=/workspace/typesafety-vtable/LLVM/build/lib

./a.out

# ../../LLVM/build/bin/clang++  sample.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,/workspace/typesafety-vtable/LLVM/build/lib -L/workspace/typesafety-vtableLLVM/build/lib -I/workspace/typesafety-vtable/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -apply-vtable-standard -mllvm -check-base-to-derived-casting -mllvm -check-unrelated-casting


# ../../LLVM/build/bin/clang++ -g sample.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,/workspace/typesafety-vtable/LLVM/build/lib -L/workspace/typesafety-vtableLLVM/build/lib -I/workspace/typesafety-vtable/LLVM/build/include/c++/v1 

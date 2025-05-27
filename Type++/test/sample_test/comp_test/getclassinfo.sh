#!/bin/bash 

LLVM_BUILD=../../../LLVM/build
PROJECT_PATH=/workspace/typesafety-vtable
MERGE_SCRIPT_PATH=../../../script/merge_typecasting_related_type.py

rm mangled_name.txt profiling_out.txt typehashinfo.txt typeinfo.txt casting_obj_init*

WD=`pwd`

export TARGET_TYPE_LIST_PATH=$WD"/casting_related_type.txt"
export TYPEPLUS_LOG_PATH=$WD"/"
export WARNING_LOG_PATH=$WD"/logfile.txt"

touch $TARGET_TYPE_LIST_PATH

TARGET_FILE=simple.cpp
# TARGET_FILE=phantomcast.cpp

$LLVM_BUILD/bin/clang++  $TARGET_FILE -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list

$MERGE_SCRIPT_PATH $WD > $TARGET_TYPE_LIST_PATH

rm a.out

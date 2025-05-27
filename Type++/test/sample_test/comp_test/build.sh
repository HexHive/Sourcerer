#!/bin/bash 

LLVM_BUILD=../../../LLVM/build
PROJECT_PATH=/workspace/typesafety-vtable

WD=`pwd`

export TARGET_TYPE_LIST_PATH=$WD"/casting_related_type.txt"
export TYPEPLUS_LOG_PATH=$WD"/"
export WARNING_LOG_PATH=$WD"/logfile.txt"

# no garbage on the screen if the compilation does not go smoothly
(cd $LLVM_BUILD && ninja TypeXXCodeChecker) || exit
# (cd $LLVM_BUILD && ninja PrintFunctionNames) || exit

# $LLVM_BUILD/bin/clang++ -Xclang -load -Xclang $LLVM_BUILD/lib/TypeXXCodeChecker.so -Xclang -plugin -Xclang typexx-codecheck ./simple.cpp -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1  -fsyntax-only

TARGET_FILE=simple.cpp
# TARGET_FILE=phantomcast.cpp

# ONLY ANALYSIS
# $LLVM_BUILD/bin/clang++ -fplugin=$LLVM_BUILD/lib/TypeXXCodeChecker.so $TARGET_FILE -nostdinc++ -I$PROJECT_PATH/LLVM/build/include/c++/v1 -Wuninitialized
# $LLVM_BUILD/bin/clang++ -Xclang -load -Xclang $LLVM_BUILD/lib/TypeXXCodeChecker.so -Xclang -plugin -Xclang typexx-codecheck $TARGET_FILE -nostdinc++ -I$PROJECT_PATH/LLVM/build/include/c++/v1 -Wuninitialized 
# $LLVM_BUILD/bin/clang++ -Xclang -load -Xclang $LLVM_BUILD/lib/PrintFunctionNames.so -Xclang -plugin -Xclang print-fns $TARGET_FILE -nostdinc++ -I$PROJECT_PATH/LLVM/build/include/c++/v1 -Wuninitialized

# BUILD AND RUN
$LLVM_BUILD/bin/clang++ $TARGET_FILE  -Xclang -load -Xclang $LLVM_BUILD/lib/TypeXXCodeChecker.so -Xclang -add-plugin -Xclang typexx-codecheck -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list -fsanitize=typeplus -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting -Wuninitialized

# THIS WORKS BUT NOT FIND THE MAIN..
# $LLVM_BUILD/bin/clang++ -Xclang -load -Xclang $LLVM_BUILD/lib/TypeXXCodeChecker.so  -Xclang -plugin -Xclang typexx-codecheck $TARGET_FILE -stdlib=libc++ -nostdinc++ -Wl,-rpath,$PROJECT_PATH/LLVM/build/lib -L$PROJECT_PATH/LLVM/build/lib -I$PROJECT_PATH/LLVM/build/include/c++/v1 -fsanitize=typeplus -flto -fvisibility=hidden -mllvm -create-derived-cast-type-list -fsanitize=typeplus -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting -Wuninitialized

# export LD_LIBRARY_PATH=$PROJECT_PATH/LLVM/build/lib

# ./a.out

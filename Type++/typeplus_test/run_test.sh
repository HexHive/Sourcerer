#!/bin/bash

# preliminaris: set env vars and init realtive files
export TARGET_TYPE_LIST_PATH="/tmp/casting_related_type.txt"
export TYPEPLUS_LOG_PATH="/tmp/"
touch $TARGET_TYPE_LIST_PATH

# ALSO THIS ONE!
export LD_LIBRARY_PATH=/workspace/typesafety-vtable/LLVM/build/lib

./typecheck.py ../LLVM/build/bin/clang++

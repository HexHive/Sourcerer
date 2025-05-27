#!/bin/bash

TS=/home/nicolasbadoux/Typesafety-vtable/
BUILD=${TS}LLVM/build/

export TARGET_TYPE_LIST_PATH="./merged.txt"
export TYPEPLUS_LOG_PATH="./"
printf "JMap\nmap\nParent\nChild" > $TARGET_TYPE_LIST_PATH
rm total_result.txt typehashinfo.txt;
${BUILD}bin/clang++ -m64 -stdlib=libc++ -nostdinc++ -std=c++11 -Wno-c++11-narrowing -Wno-unused-command-line-argument -flto -fvisibility=hidden -fno-strict-aliasing -Wno-c++11-narrowing -fno-inline-functions -std=gnu++98 \
		-Wl,-rpath,${BUILD}lib \
						 -L${BUILD}lib \
						 -I${BUILD}include/c++/v1 -fsanitize=typeplus -mllvm -create-derived-cast-type-list -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting   \
						 ${TS}test/missing-libc-cov.cpp -mllvm -collect-profiling-data -o missing_libc

./missing_libc
cat total_result.txt

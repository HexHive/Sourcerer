#!/usr/bin/env bash
# shellcheck  disable=SC1091
set -e
set -x

#rm -drf build_libstdcxx build

if [[ -z "${ENVIRONMENT_FOLDER}" ]]; then
  echo "ENVIRONMENT_FOLDER not set, leave"
  exit 1
fi
# set the environment properly, find better folder for the original script
if [ ! -f "${ENVIRONMENT_FOLDER}/environment_patched.sh" ]; then
    echo "environment_patched.sh doest not exist. Aborting..."
    exit 255
fi
source "${ENVIRONMENT_FOLDER}/environment_patched.sh"


export LLVM_DEBUG="Release" # RelWithDebInfo Release Debug
export LLVM_ASAN="" # use Address if you want ASAN
if [[ $# -eq 0 ]]; then
  export NORMAL_BUILD_DIR=${BUILD_FOLDER}
else
  printf "********\nDebug\n********\n";
  export LLVM_DEBUG="Debug"
  export NORMAL_BUILD_DIR=${DEBUG_BUILD_FOLDER}
  echo "$NORMAL_BUILD_DIR"
fi;


export BUILD_DIR=${NORMAL_BUILD_DIR}/../build_collect
export INSTALL_DIR=${BUILD_DIR}/collected_libs

export TYPEPLUS_LOG_PATH=/tmp/libc
export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}/merged.txt
mkdir -p ${TYPEPLUS_LOG_PATH}

export CXX_FLAGS="-O2 -Wno-unused-command-line-argument -flto -fvisibility=hidden -fuse-ld=lld "

if [ -n "$CFI" ]; then
  export CXX_FLAGS+=" -lubsan -lunwind -fsanitize=cfi-derived-cast -fsanitize=cfi-unrelated-cast -fno-sanitize-trap=all -fsanitize-recover=all"
  if [ -n "$STATS" ]; then
    export CXX_FLAGS+=" -fsanitize=typeplus -mllvm -collect-profiling-data "
    export SANITIZER="typeplus"
  fi
elif [ -n "$SOURCERER" ]; then
  export CXX_FLAGS+="-mllvm -create-derived-cast-type-list -mllvm -create-unrelated-cast-type-list -mllvm -collect-profiling-data  -mllvm -create-void-star-type-list"
  export SANITIZER="typeplus"
fi

cmake --fresh -G Ninja  \
              -DCOMPILER_RT_BUILD_SANITIZERS=ON \
              -S "${LLVM_FOLDER}"/runtimes \
              -B $BUILD_DIR \
              -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
              -DCMAKE_C_COMPILER="${NORMAL_BUILD_DIR}/bin/clang" \
              -DCMAKE_CXX_COMPILER="${NORMAL_BUILD_DIR}/bin/clang++" \
              -DCMAKE_CXX_FLAGS="$CXX_FLAGS" \
              -DLIBCXXABI_LIBCXX_PATH="${LLVM_FOLDER}/libcxx" \
              -DLIBCXXABI_LIBCXX_INCLUDES="${BUILD_DIR}/include/c++/v1" \
              -DLIBCXXABI_LIBUNWIND_PATH="${LLVM_FOLDER}/libunwind" \
              -DLIBCXXABI_LIBUNWIND_INCLUDES="${LLVM_FOLDER}/libunwind/include" \
              -DLLVM_USE_SPLIT_DWARF=ON \
              -DLLVM_TARGETS_TO_BUILD="X86" \
              -DLIBCXX_USE_COMPILER_RT=ON \
              -DBUILD_SHARED_LIBS=OFF \
              -DLIBCXXABI_USE_LLVM_UNWINDER=OFF      \
              -DLIBUNWIND_ENABLE_SHARED=OFF\
		          -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
              -DLLVM_USE_LINKER=lld \
              -DLLVM_USE_SANITIZER=${SANITIZER} 

 #             -DHAVE_RPC_XDR_H=0 \
 #             -DLLVM_ENABLE_ASSERTIONS=OFF \
 #             -DLLVM_BINUTILS_INCDIR="${LLVM_FOLDER}/binutils/include" \

ninja -C ${BUILD_DIR} cxx cxxabi 
ninja -C ${BUILD_DIR} install-cxx install-cxxabi 

python3 "${TYPESAFETY_FOLDER}/script/merge_typecasting_related_type.py" "$TYPEPLUS_LOG_PATH" > "$TARGET_TYPE_LIST_PATH"

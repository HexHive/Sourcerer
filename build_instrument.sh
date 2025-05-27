#!/usr/bin/env bash
# shellcheck  disable=SC1091
set -e
set -x
ps -o args= -p $$

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
if [[ -z "${BUILD_DIR}" ]]; then
  export BUILD_DIR=${NORMAL_BUILD_DIR}/../build_instrument
  mkdir -p ${BUILD_DIR}
fi;
echo "BUILD_DIR: $BUILD_DIR"
echo "NORMAL_BUILD_DIR: $NORMAL_BUILD_DIR"

if [[ -z "${INSTALL_DIR}" ]]; then
  export INSTALL_DIR=${BUILD_DIR}/instrument_libs
fi;

echo "INSTALL_DIR: $INSTALL_DIR"
#export NORMAL_BUILD_DIR=/usr
# build llvm with TypePlus + libstdcxx

export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}/merged.txt

cmake --fresh -G Ninja  \
              -S ${LLVM_FOLDER}/runtimes \
 	            -DCMAKE_BUILD_TYPE=${LLVM_DEBUG} \
              -B $BUILD_DIR \
              -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
              -DCMAKE_C_COMPILER="${NORMAL_BUILD_DIR}/bin/clang" \
              -DCMAKE_CXX_COMPILER="${NORMAL_BUILD_DIR}/bin/clang++" \
              -DCMAKE_CXX_FLAGS="-O2 -Wno-unused-command-line-argument -Wno-strict-prototypes -Wno-non-virtual-dtor -Wno-non-pod-varargs -flto -fvisibility=hidden -fuse-ld=lld  -mllvm -apply-vtable-standard -mllvm -poly-classes -mllvm -cast-obj-opt  " \
              -DCMAKE_C_FLAGS="-O2 -Wno-unused-command-line-argument -Wno-strict-prototypes -flto -fvisibility=hidden -fuse-ld=lld  -mllvm -apply-vtable-standard -mllvm -poly-classes -mllvm -cast-obj-opt  " \
              -DLIBCXXABI_LIBCXX_PATH="${LLVM_FOLDER}/libcxx" \
              -DLIBCXX_ENABLE_TIME_ZONE_DATABASE=OFF \
              -DLIBCXXABI_LIBCXX_INCLUDES="${BUILD_DIR}/include/c++/v1" \
              -DLIBCXXABI_LIBUNWIND_PATH="${LLVM_FOLDER}/libunwind" \
              -DLIBCXXABI_LIBUNWIND_INCLUDES="${LLVM_FOLDER}/libunwind/include" \
              -DLLVM_USE_SPLIT_DWARF=ON \
              -DLLVM_USE_LINKER=lld \
              -DLLVM_TARGETS_TO_BUILD="X86" \
              -DLIBCXX_USE_COMPILER_RT=ON \
              -DBUILD_SHARED_LIBS=OFF \
              -DLIBCXXABI_USE_LLVM_UNWINDER=OFF      \
              -DLIBUNWIND_ENABLE_SHARED=ON\
		          -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
              -DCMAKE_WARN_DEPRECATED=OFF \
              -DLLVM_USE_SANITIZER="typeplus"

 #             -DHAVE_RPC_XDR_H=0 \
 #             -DLLVM_ENABLE_ASSERTIONS=OFF \
 #             -DLLVM_BINUTILS_INCDIR="${LLVM_FOLDER}/binutils/include" \

ninja -C ${BUILD_DIR} clean 
ninja -C ${BUILD_DIR} cxx cxxabi unwind
ninja -C ${BUILD_DIR} install-cxx install-cxxabi install-unwind

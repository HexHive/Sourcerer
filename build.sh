#!/usr/bin/env bash
# shellcheck  disable=SC1091
set -e
set -x

sudo mkdir -p /dockerccache
sudo chown `whoami`:`whoami` -R /dockerccache

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
  export BUILD_DIR=${BUILD_FOLDER}
else
  printf "********\nDebug\n********\n";
  export LLVM_DEBUG="Debug" 
  export BUILD_DIR=${DEBUG_BUILD_FOLDER}
  echo "$BUILD_DIR"
fi;


export LLVM_DIR=${LLVM_FOLDER}/llvm
export INSTALL_DIR=${BUILD_DIR}/../normal_libs

mkdir -p ${BUILD_DIR}
mkdir -p ${INSTALL_DIR}

cmake -G "Ninja"\
  -S ${LLVM_DIR} \
  -B $BUILD_DIR \
  -DCMAKE_WARN_DEPRECATED=OFF \
 	-DCMAKE_BUILD_TYPE=${LLVM_DEBUG} \
	-DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi;libunwind" \
 	-DCMAKE_C_COMPILER=clang-18 \
 	-DCMAKE_CXX_COMPILER=clang++-18 \
	-DCMAKE_C_FLAGS="-Wno-switch" \
	-DCMAKE_CXX_FLAGS="-Wno-switch" \
  -DLLVM_USE_LINKER=gold \
  -DLLVM_USE_SPLIT_DWARF=ON \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_BINUTILS_INCDIR="${LLVM_FOLDER}/binutils/include" \
	-DLLVM_ENABLE_PROJECTS="clang;lld" \
	-DLLVM_BUILD_EXAMPLES=ON \
  -DLLVM_BUILD_TESTS=OFF \
	-DLLVM_INCLUDE_BENCHMARKS=OFF \
	-DLLVM_INCLUDE_EXAMPLES=ON \
  -DLLVM_INCLUDE_TESTS=OFF\
  -DLLVM_OPTIMIZED_TABLEGEN=ON \
	-DLLVM_RAM_PER_LINK_JOB=10000 \
	-DLLVM_USE_SANITIZER=${LLVM_ASAN}  \

ninja -C ${BUILD_DIR} clang
ninja -C ${BUILD_DIR} install

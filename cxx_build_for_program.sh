#!/bin/bash
# shellcheck  disable=SC1091

set -x
set -e

source "${ENVIRONMENT_FOLDER}/environment_patched.sh"
echo "$BUILD_DIR"
if [ -z "$BUILD_DIR" ]; then
  export BUILD_DIR=${BUILD_FOLDER}
fi
cd ${LLVM_FOLDER}
export VERSION=13.0.0
export LLVM_LIB_FOLDER=${LLVM_FOLDER}/llvm-project-${VERSION}
rm -drf ${LLVM_LIB_FOLDER}
mkdir -p ${LLVM_LIB_FOLDER}

for lib in libcxx libcxxabi libunwind; 
do
  wget -q "https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/${lib}-${VERSION}.src.tar.xz"
  tar -xvf "${lib}-${VERSION}.src.tar.xz" > /dev/null && rm "${lib}-${VERSION}.src.tar.xz"
  mv "${lib}-${VERSION}.src" "${LLVM_LIB_FOLDER}/${lib}"
done

patch -p1 -d "${LLVM_LIB_FOLDER}" < "libc++13.patch"


export CXX_FLAGS="-fsanitize=typeplus -flto -fvisibility=hidden -mllvm -apply-vtable-standard -mllvm -poly-classes -mllvm -cast-obj-opt -flto -fvisibility=hidden"
export C_FLAGS=" -O2 "

mkdir -p ${LLVM_LIB_FOLDER}/libunwind-build
mkdir -p ${LLVM_LIB_FOLDER}/libcxx-build
mkdir -p ${LLVM_LIB_FOLDER}/libcxxabi-build

#order matters here

export LIB_BUILD_FOLDER=${LLVM_LIB_FOLDER}/libunwind-build
echo $TYPEPLUS_LOG_PATH
echo $TARGET_TYPE_LIST_PATH

cmake -GNinja -DLLVM_PATH="${LLVM_FOLDER}/llvm" \
 -B ${LIB_BUILD_FOLDER} \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_CXX_COMPILER="${BUILD_DIR}/bin/clang++" \
 -DCMAKE_C_COMPILER="${BUILD_DIR}/bin/clang" \
 -DCMAKE_C_FLAGS="-O2" \
 -DCMAKE_CXX_FLAGS="-O2 -Wno-strict-prototypes " \
 -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
 -DLIBUNWIND_ENABLE_SHARED=ON \
 -DCMAKE_POLICY_DEFAULT_CMP0116=OLD \
 -S "${LLVM_LIB_FOLDER}/libunwind"
cmake --build ${LIB_BUILD_FOLDER}
cmake --install ${LIB_BUILD_FOLDER}


export LIB_BUILD_FOLDER="${LLVM_LIB_FOLDER}/libcxx-build"

cmake -GNinja -DLLVM_PATH="${LLVM_FOLDER}/llvm" \
 -B ${LIB_BUILD_FOLDER} \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_CXX_COMPILER="${BUILD_DIR}/bin/clang++" \
 -DCMAKE_C_COMPILER="${BUILD_DIR}/bin/clang" \
 -DCMAKE_C_FLAGS="${C_FLAGS}" \
 -DCMAKE_CXX_FLAGS="${CXX_FLAGS}" \
 -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
 -DLIBCXX_CXX_ABI_INCLUDE_PATHS="${LLVM_LIB_FOLDER}/libcxxabi/include" \
 -DLIBCXX_CXX_ABI=libcxxabi \
 -DLIBCXX_CXX_ABI_LIBRARY_PATH="${INSTALL_DIR}/lib" \
 -DLIBCXX_HAS_GCC_S_LIB=ON \
 -DLIBCXX_ENABLE_SHARED=ON \
 -DLIBCXX_ENABLE_FILESYSTEM=OFF \
 -DCMAKE_POLICY_DEFAULT_CMP0116=OLD \
 -S "${LLVM_LIB_FOLDER}/libcxx"
cmake --build ${LIB_BUILD_FOLDER}
cmake --install ${LIB_BUILD_FOLDER}


export LIB_BUILD_FOLDER="${LLVM_LIB_FOLDER}/libcxxabi-build"

cmake -GNinja -DLLVM_PATH="${LLVM_FOLDER}/llvm" \
 -B ${LIB_BUILD_FOLDER} \
 -DCMAKE_C_FLAGS="${C_FLAGS}" \
 -DCMAKE_CXX_FLAGS="${CXX_FLAGS}" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_CXX_COMPILER="${BUILD_DIR}/bin/clang++" \
 -DCMAKE_C_COMPILER="${BUILD_DIR}/bin/clang" \
 -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
 -DLIBCXXABI_LIBCXX_PATH="${LLVM_LIB_FOLDER}/libcxx" \
 -DLIBCXXABI_LIBCXX_INCLUDES="${INSTALL_DIR}/include/c++/v1" \
 -DLIBCXXABI_LIBUNWIND_PATH="${LLVM_LIB_FOLDER}/libunwind" \
 -DLIBCXXABI_LIBUNWIND_INCLUDES="${LLVM_LIB_FOLDER}/libunwind/include" \
 -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
 -DLIBCXXABI_ENABLE_SHARED=ON \
 -DCMAKE_POLICY_DEFAULT_CMP0116=OLD \
 -S "${LLVM_LIB_FOLDER}/libcxxabi"
cmake --build ${LIB_BUILD_FOLDER}
cmake --install ${LIB_BUILD_FOLDER}

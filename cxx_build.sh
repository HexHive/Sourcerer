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

LIBC_FOLDER=${TEMP_FOLDER}"/libc/"
rm -drf "$LIBC_FOLDER"
mkdir -p "$LIBC_FOLDER"

export INSTALL_DIR=${BUILD_FOLDER}/../normal_libs-${VERSION}
export CXX_FLAGS=" -O2 -flto -fvisibility=hidden -Wno-keyword-compat -Wno-unqualified-std-cast-call "
if [ -n "$SOURCERER" ]; then
  export CXX_FLAGS+=" -fsanitize=typeplus -mllvm -create-derived-cast-type-list -mllvm -create-unrelated-cast-type-list -mllvm -collect-profiling-data -mllvm -create-void-star-type-list "
elif [ -n "$CFI" ]; then
  export CXX_FLAGS+=" -fsanitize=cfi-derived-cast -fsanitize=cfi-unrelated-cast -fno-sanitize-trap=cfi-derived-cast -fno-sanitize-trap=cfi-unrelated-cast -fsanitize-recover=all "
  if [ -n "$STATS" ]; then
    export CXX_FLAGS+=" -fsanitize=typeplus -mllvm -collect-profiling-data "
  fi
fi
export C_FLAGS=" -O2 "

rm -drf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p ${LLVM_LIB_FOLDER}/libunwind-build
mkdir -p ${LLVM_LIB_FOLDER}/libcxx-build
mkdir -p ${LLVM_LIB_FOLDER}/libcxxabi-build

#order matters here

export LIB_BUILD_FOLDER=${LLVM_LIB_FOLDER}/libunwind-build
export TYPEPLUS_LOG_PATH=${LIBC_FOLDER}"libunwind/"
export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}"/merged.txt"
mkdir -p "$TYPEPLUS_LOG_PATH"
touch "$TARGET_TYPE_LIST_PATH"

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

if [ -n "$SOURCERER" ]; then
  python3 "${TYPESAFETY_FOLDER}/script/merge_typecasting_related_type.py" "$TYPEPLUS_LOG_PATH" > "$TARGET_TYPE_LIST_PATH"
  cat "$TYPEPLUS_LOG_PATH"/classes_to_instrument_derived.txt >> ${LIBC_FOLDER}/classes_to_instrument_derived.txt
  cat "$TYPEPLUS_LOG_PATH"/classes_to_instrument_unrelated.txt >> ${LIBC_FOLDER}/classes_to_instrument_unrelated.txt
  cat "$TYPEPLUS_LOG_PATH"/from_void_merged.txt >> ${LIBC_FOLDER}/from_void_merged.txt
  cat "$TYPEPLUS_LOG_PATH"/to_void_merged.txt >> ${LIBC_FOLDER}/to_void_merged.txt
  cat  "$TARGET_TYPE_LIST_PATH" >> ${LIBC_FOLDER}/merged.txt
fi


export LIB_BUILD_FOLDER="${LLVM_LIB_FOLDER}/libcxx-build"
export TYPEPLUS_LOG_PATH=${LIBC_FOLDER}"libc++/"
export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}"/merged.txt"
mkdir -p "$TYPEPLUS_LOG_PATH"
touch "$TARGET_TYPE_LIST_PATH"

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

if [ -n "$SOURCERER" ]; then
  python3 "${TYPESAFETY_FOLDER}/script/merge_typecasting_related_type.py" "$TYPEPLUS_LOG_PATH" > "$TARGET_TYPE_LIST_PATH"
  cat "$TYPEPLUS_LOG_PATH"/classes_to_instrument_derived.txt >> ${LIBC_FOLDER}/classes_to_instrument_derived.txt
  cat "$TYPEPLUS_LOG_PATH"/classes_to_instrument_unrelated.txt >> ${LIBC_FOLDER}/classes_to_instrument_unrelated.txt
  cat "$TYPEPLUS_LOG_PATH"/from_void_merged.txt >> ${LIBC_FOLDER}/from_void_merged.txt
  cat "$TYPEPLUS_LOG_PATH"/to_void_merged.txt >> ${LIBC_FOLDER}/to_void_merged.txt
  cat  "$TARGET_TYPE_LIST_PATH" >> ${LIBC_FOLDER}/merged.txt
fi


export LIB_BUILD_FOLDER="${LLVM_LIB_FOLDER}/libcxxabi-build"
export TYPEPLUS_LOG_PATH=${LIBC_FOLDER}"libc++abi/"
export TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}"/merged.txt"
mkdir -p "$TYPEPLUS_LOG_PATH"
touch "$TARGET_TYPE_LIST_PATH"

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

if [ -n "$SOURCERER" ]; then
  python3 "${TYPESAFETY_FOLDER}/script/merge_typecasting_related_type.py" "$TYPEPLUS_LOG_PATH" > "$TARGET_TYPE_LIST_PATH"
  cat "$TYPEPLUS_LOG_PATH"/classes_to_instrument_derived.txt >> ${LIBC_FOLDER}/classes_to_instrument_derived.txt
  cat "$TYPEPLUS_LOG_PATH"/classes_to_instrument_unrelated.txt >> ${LIBC_FOLDER}/classes_to_instrument_unrelated.txt
  cat "$TYPEPLUS_LOG_PATH"/from_void_merged.txt >> ${LIBC_FOLDER}/from_void_merged.txt
  cat "$TYPEPLUS_LOG_PATH"/to_void_merged.txt >> ${LIBC_FOLDER}/to_void_merged.txt
  cat  "$TARGET_TYPE_LIST_PATH" >> ${LIBC_FOLDER}/merged.txt
fi

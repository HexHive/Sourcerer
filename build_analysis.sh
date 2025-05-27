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
  export BUILD_DIR=${BUILD_FOLDER}
else
  printf "********\nDebug\n********\n";
  export LLVM_DEBUG="Debug" 
  export BUILD_DIR=${DEBUG_BUILD_FOLDER}
  echo "$BUILD_DIR"
fi;


ninja -C ${BUILD_DIR} TypeXXCodeChecker

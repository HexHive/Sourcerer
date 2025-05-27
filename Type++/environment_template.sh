#!/bin/bash
# COPY TO environment_patched.sh
export CPU2006_FOLDER=${HOME}/cpu2006
export CPU2017_FOLDER=${HOME}/cpu2017
export TEMP_FOLDER=/tmp
export RESULT_FOLDER=${HOME}/results
export CHROMIUM_FOLDER="${HOME}/chromium"

export SRC_FOLDER=${HOME}/LLVM-typepp
export TYPESAFETY_FOLDER=${SRC_FOLDER}/Type++
export LLVM_FOLDER=${SRC_FOLDER}${REFERENCE}
mkdir -p "${LLVM_FOLDER}"
export BUILD_FOLDER=${HOME}/build
export DEBUG_BUILD_FOLDER=${HOME}/build-debug
export WSS_FOLDER=${TYPESAFETY_FOLDER}/wss
export V8_FOLDER=${TYPESAFETY_FOLDER}/v8/v8

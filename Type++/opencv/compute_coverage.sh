#!/bin/bash
set -e
set -x

sudo mkdir -p ${OUT} 
sudo chown -R $(whoami):$(whoami) ${OUT}

SANCOV=1 ./build_and_run_fuzzer.sh

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

export FUZZER_DATA=${OUT}/${FUZZER}_data
export LLVM_PROFILE_FILE="${FUZZER}.profraw"

COVRAGE=${FUZZER_DATA}/output/default/coverage
rm -drf ${COVRAGE}
mkdir -p  ${COVRAGE}

# for loop over all files in the queue
for FILE in $(ls ${FUZZER_DATA}/output/default/queue); do

    ${OUT}/${FUZZER} ${FUZZER_DATA}/output/default/queue/${FILE} || true
    if [ -f ${FUZZER}.profraw ]; then
        mv ${FUZZER}.profraw ${COVRAGE}/${FILE}.profraw 
        ${BUILD_FOLDER}/bin/llvm-profdata merge  ${COVRAGE}/*.profraw -o ${OUT}/${FUZZER}.profdata
        ${BUILD_FOLDER}/bin/llvm-cov report ${OUT}/${FUZZER} -instr-profile=${OUT}/${FUZZER}.profdata  > ${OUT}/${FUZZER}.coverage

        head -1 ${OUT}/${FUZZER}.coverage > ${FUZZER_DATA}/output/default/queue/${FILE}.report
        tail -1 ${OUT}/${FUZZER}.coverage >> ${FUZZER_DATA}/output/default/queue/${FILE}.report
    fi
done

#!/bin/bash
set -x
set -e

FUZZERS="core_fuzzer filestorage_read_filename_fuzzer \
    generateusergallerycollage_fuzzer imdecode_fuzzer imencode_fuzzer \
    imread_fuzzer readnetfromtensorflow_fuzzer"
#FUZZERS="core_fuzzer generateusergallerycollage_fuzzer imdecode_fuzzer"
#FUZZERS="core_fuzzer"

if [ -n "$ASAN" ]; then
    ASAN="_asan"
fi

pushd ../../
docker build --target opencv_sancov_fuzzing -t opencv_sancov_fuzzing . 
popd

COUNTER=0   
echo "Timeout: $TIMEOUT"
for fuzzer in $FUZZERS;
do 
    for i in {1..4};
    do
        docker kill opencv_sancov_fuzzing_${fuzzer}_container_$i || true
        docker rm opencv_sancov_fuzzing_${fuzzer}_container_$i || true
        FOLDER=/media/bigDisk/sourcerer_bck/${fuzzer}${ASAN}_${i}
        docker run --rm  --detach --name opencv_sancov_fuzzing_${fuzzer}_container_$i --env FUZZER=${fuzzer} --mount type=bind,src=${FOLDER},dst=${HOME}/results  --env OUT=${HOME}/results -t opencv_sancov_fuzzing
        COUNTER=$((COUNTER+1))
    done
done

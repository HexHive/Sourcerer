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
docker build --target opencv${ASAN}_fuzzing -t opencv${ASAN}_fuzzing . 
popd

HOURS=24
TIMEOUT=$((60*60*${HOURS}))
COUNTER=0   
echo "Timeout: $TIMEOUT"
for fuzzer in $FUZZERS;
do 
    for i in {1..2};
    do
        if (( COUNTER > 0 && COUNTER % $(nproc) == 0 )); then
            sleep $TIMEOUT
            echo "Sleeping for $TIMEOUT"
        fi
        docker kill opencv${ASAN}_fuzzing_${fuzzer}_container_$i || true
        docker rm opencv${ASAN}_fuzzing_${fuzzer}_container_$i || true
        mkdir -p /media/bigDisk/sourcerer/${fuzzer}${ASAN}_${i}
        docker run --detach --name opencv${ASAN}_fuzzing_${fuzzer}_container_$i --cpuset-cpus $((COUNTER % $(nproc))) --env FUZZER=${fuzzer} --env TIMEOUT=${TIMEOUT} --mount type=bind,src=/media/bigDisk/sourcerer/${fuzzer}${ASAN}_${i},dst=${HOME}/results  --env OUT=${HOME}/results -t opencv${ASAN}_fuzzing
        COUNTER=$((COUNTER+1))
    done
done
echo "All fuzzer containers started"
echo "Sleeping for $TIMEOUT"
sleep $TIMEOUT
wait

for i in {1..4};
do
    for fuzzer in $FUZZERS;
    do 
        docker kill opencv${ASAN}_fuzzing_${fuzzer}_container_$i || true
    done
done

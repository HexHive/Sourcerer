#!/bin/bash
set -x
set -e

FUZZERS="core_fuzzer filestorage_read_file_fuzzer \
    filestorage_read_filename_fuzzer filestorage_read_string_fuzzer \
    generateusergallerycollage_fuzzer imdecode_fuzzer imencode_fuzzer \
    imread_fuzzer readnetfromtensorflow_fuzzer"
#FUZZERS="core_fuzzer generateusergallerycollage_fuzzer imdecode_fuzzer"
#FUZZERS="core_fuzzer"

mkdir -p results
for i in {1..5};
do
    for fuzzer in $FUZZERS;
    do 
        docker kill opencv_fuzzing_${fuzzer}_container_$i || true
        mkdir -p results/${fuzzer}_$i
        docker cp opencv_fuzzing_${fuzzer}_container_$i:/tmp/opencv/missed_cast.txt ./results/${fuzzer}_$i/ || true
        docker cp opencv_fuzzing_${fuzzer}_container_$i:/tmp/opencv/type_confusion.txt ./results/${fuzzer}_$i/ || true
        docker cp opencv_fuzzing_${fuzzer}_container_$i:/home/nbadoux/fuzzer-out/${fuzzer}_data ./results/${fuzzer}_$i/ || true
    done
done

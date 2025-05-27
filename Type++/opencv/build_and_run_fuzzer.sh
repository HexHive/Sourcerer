#!/bin/bash
set -e
set -x
sudo mkdir -p ${OUT} 
sudo chown -R $(whoami):$(whoami) ${OUT}

export FUZZER_DATA=${OUT}/${FUZZER}_data
export CXX_FLAGS="-fno-inline -Wl,--error-limit=0 -Wno-dynamic-class-memaccess -Wno-non-virtual-dtor \
 -nostdinc++ -stdlib=libc++ -I$LIBC_INSTALL_DIR/include/x86_64-unknown-linux-gnu/c++/v1 -I$LIBC_INSTALL_DIR/include/c++/v1"

if [ -n "$SOURCERER" ]; then
    export CXX_FLAGS+=" -fsanitize=typeplus -mllvm -collect-profiling-data -mllvm -apply-vtable-standard -mllvm -poly-classes -mllvm -check-unrelated-casting -mllvm -check-base-to-derived-casting -mllvm -cast-obj-opt"
elif [ -n "$ASAN" ]; then
    export CXX_FLAGS+=" -fsanitize=address"
elif [ -n "$SANCOV" ]; then
    export CXX_FLAGS+=" -fprofile-instr-generate -fcoverage-mapping "
fi

$CXX \
 $LIB_FUZZING_ENGINE $FUZZER.cc $CXX_FLAGS -std=c++11 \
-I$OPENCV_INSTALL_DIR/include/opencv4 -L$OPENCV_INSTALL_DIR/lib \
-L$OPENCV_INSTALL_DIR/lib/opencv4/3rdparty \
-lopencv_dnn -lopencv_objdetect -lopencv_photo -lopencv_ml -lopencv_gapi \
-lopencv_stitching -lopencv_video -lopencv_calib3d -lopencv_features2d \
-lopencv_highgui -lopencv_videoio -lopencv_imgcodecs -lopencv_imgproc \
-lopencv_flann -lopencv_core -lz -littnotify \
-lade -ldl -lm -lpthread -lrt \
-o $OUT/$FUZZER  && mkdir -p ${OUT}/${FUZZER}_data
mkdir -p ${FUZZER_DATA}/input ${FUZZER_DATA}/output && head -c 1 /dev/urandom > ${FUZZER_DATA}/input/random_20kb.bin
export  AFL_NO_AFFINITY=1
if [ ! -n "$SANCOV" ]; then
    timeout ${TIMEOUT} ${AFLPP_DIR}/afl-fuzz -i ${FUZZER_DATA}/input -o ${FUZZER_DATA}/output -- $OUT/$FUZZER
fi

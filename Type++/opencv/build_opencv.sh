#!/bin/bash
set -x
set -e
cd ${HOME}

export OPENCV_BUILD_DIR=${HOME}/build-opencv
rm -drf ${OPENCV_BUILD_DIR}
mkdir -p ${OPENCV_BUILD_DIR} && cd ${OPENCV_BUILD_DIR}

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
#fuzzing args:
#  -DOPENCV_GENERATE_PKGCONFIG=ON \
#  -DOPENCV_GENERATE_PKGCONFIG=ON \
#  -DOPENCV_FORCE_3RDPARTY_BUILD=ON \
#  -DBUILD_TESTS=OFF \
#  -DBUILD_PERF_TESTS=OFF \
#  -DBUILD_opencv_apps=OFF \
#  -DWITH_IMGCODEC_GIF=ON \

mkdir -p $TYPEPLUS_LOG_PATH
sudo mkdir -p ${TYPEPLUS_LOG_PATH} && sudo chown ${USERNAME}:${USERNAME} ${TYPEPLUS_LOG_PATH} -R
touch $TARGET_TYPE_LIST_PATH

export COLLECT_CXX_FLAGS=" -fsanitize=typeplus \
        -mllvm -create-derived-cast-type-list \
        -mllvm -create-unrelated-cast-type-list \
        -mllvm -create-void-star-type-list ${BUILD_FOLDER}/lib/clang/19/lib/x86_64-unknown-linux-gnu/libclang_rt.ubsan_standalone_cxx.a "
export INSTRUMENT_CXX_FLAGS="-fno-inline -Wl,--error-limit=0 ${BUILD_FOLDER}/lib/clang/19/lib/x86_64-unknown-linux-gnu/libclang_rt.ubsan_standalone_cxx.a -Wno-dynamic-class-memaccess -Wno-non-virtual-dtor -fsanitize=typeplus -mllvm -collect-profiling-data -mllvm -apply-vtable-standard -mllvm -poly-classes -mllvm -check-unrelated-casting -mllvm -check-base-to-derived-casting -mllvm -cast-obj-opt "

if [ -n "$COLLECT" ]; then
    CXX_FLAGS+="${COLLECT_CXX_FLAGS}"
    export LIBC_INSTALL_DIR=${BUILD_FOLDER}/../build_collect/collected_libs/
    export INSTALL_DIR=${LIBC_INSTALL_DIR}
    export LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib/x86_64-unknown-linux-gnu/
    export CCACHE_RECACHE=1
    export CC=${BUILD_FOLDER}/bin/clang
    export CXX=${BUILD_FOLDER}/bin/clang++
    ${LLVM_FOLDER}/build_collect.sh
elif [ -n "$INSTRUMENT" ]; then
    export CCACHE_RECACHE=1
    export CXX_FLAGS+="${INSTRUMENT_CXX_FLAGS}"
    export LIBC_INSTALL_DIR=${TYPEPLUS_LOG_PATH}/libc
    export LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib/ 
    export INSTALL_DIR=${LIBC_INSTALL_DIR}
    ${LLVM_FOLDER}/build_instrument.sh
    export  CC="${AFLPP_DIR}/afl-clang-lto" 
    export CXX="${AFLPP_DIR}/afl-clang-lto++" 
elif [ -n "$ASAN" ]; then
    export CCACHE_RECACHE=1
    export CXX_FLAGS+=" -fsanitize=address"
    export LIBC_INSTALL_DIR=${BUILD_FOLDER}/../normal_libs/
    export LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib/ 
    export INSTALL_DIR=${LIBC_INSTALL_DIR}
    ${LLVM_FOLDER}/build_collect.sh
    export  CC="${AFLPP_DIR}/afl-clang-lto" 
    export CXX="${AFLPP_DIR}/afl-clang-lto++" 
elif [ -n "$SANCOV" ]; then
    export CCACHE_RECACHE=1
    export CXX_FLAGS+=" -fprofile-instr-generate -fcoverage-mapping "
    export LIBC_INSTALL_DIR=${BUILD_FOLDER}/../normal_libs/
    export LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib/ 
    export INSTALL_DIR=${LIBC_INSTALL_DIR}
    export CC=${BUILD_FOLDER}/bin/clang
    export CXX=${BUILD_FOLDER}/bin/clang++
else
    LIBC_INSTALL_DIR=${BUILD_FOLDER}/../normal_libs/
    export LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib/x86_64-unknown-linux-gnu/
    echo "No sanitizer specified"
    CXX_FLAGS+="-fsanitize=address"
    #exit 1
fi

sudo mkdir -p $CCACHE_DIR
sudo chown  ${USERNAME}:${USERNAME} $CCACHE_DIR -R
#${BUILD_FOLDER}/lib/clang/19/lib/x86_64-unknown-linux-gnu/libclang_rt.ubsan_standalone.a  ${BUILD_FOLDER}/lib/clang/19/lib/x86_64-unknown-linux-gnu/libclang_rt.typeplus.a
LD_FLAGS+="-lunwind  -L${LIBC_INSTALL_DIR}/lib -Wl,-rpath,${LIBC_INSTALL_DIR}/lib -lrt -lc++abi"
CXX_FLAGS+=" -lrt -fno-omit-frame-pointer -fvisibility=hidden -fuse-ld=lld -stdlib=libc++ -flto -nostdinc++ -Wno-unused-command-line-argument -I${LIBC_INSTALL_DIR}/include/x86_64-unknown-linux-gnu/c++/v1 -lunwind -I${LIBC_INSTALL_DIR}/include/c++/v1 ${LD_FLAGS}"
cmake --fresh -G Ninja \
    -B "${OPENCV_BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=$OPENCV_INSTALL_DIR \
    -DCMAKE_C_FLAGS="-fvisibility=hidden" \
    -DCMAKE_AR=${BUILD_FOLDER}/bin/llvm-ar \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXX_FLAGS}" \
    -DCMAKE_C_FLAGS="${CXX_FLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LD_FLAGS}" \
    -DCMAKE_MODULE_LINKER_FLAGS="${LD_FLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LD_FLAGS}" \
    -DCMAKE_RANLIB=${BUILD_FOLDER}/bin/llvm-ranlib \
    -DENABLE_THIN_LTO=ON \
    -DWITH_OPENCL=OFF \
    -DWITH_PNG=OFF \
    -DWITH_JPEG=OFF \
    -DWITH_IPP=OFF \
    -DWITH_IMGCODEC_HDR=OFF \
    -DWITH_IMGCODEC_SUNRASTER=OFF \
    -DWITH_IMGCODEC_PXM=OFF \
    -DWITH_IMGCODEC_PFM=OFF \
    -DWITH_TIFF=OFF \
    -DWITH_WEBP=OFF \
    -DWITH_OPENJPEG=OFF \
    -DWITH_JASPER=OFF \
    -DWITH_OPENEXR=OFF \
    -DWITH_JPEGXL=OFF \
    -DWITH_V4L=OFF \
    -DWITH_FFMPEG=OFF \
    -DWITH_GSTREAMER=OFF \
    -DWITH_ANDROID_MEDIANDK=OFF \
    -DVIDEOIO_ENABLE_PLUGINS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DWITH_PTHREADS_PF=OFF \
    -DWITH_PARALLEL_ENABLE_PLUGINS=OFF \
    -DHIGHGUI_ENABLE_PLUGINS=OFF \
    -DWITH_PROTOBUF=OFF \
    -DBUILD_PROTOBUF=OFF \
    -DOPENCV_DNN_OPENCL=OFF \
    -DBUILD_JAVA=OFF \
    -DENABLE_FLAKE8=OFF \
    -DENABLE_PYLINT=OFF \
    \
    ${OPENCV_DIR} 

cmake --build . --clean-first -j 25
export CCACHE_RECACHE=0

if [ -n "$COLLECT" ]; then
    python3 "${TYPESAFETY_FOLDER}/script/merge_typecasting_related_type.py" "$TYPEPLUS_LOG_PATH" > "$TARGET_TYPE_LIST_PATH"
elif [ -n "$INSTRUMENT" ]; then
    ninja install
elif [ -n "$ASAN" ]; then
    ninja install
elif [ -n "$SANCOV" ]; then
    ninja install
fi

#cmake --build .  -j 25
#make test
#ninja test || true

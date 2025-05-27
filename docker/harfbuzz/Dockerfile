FROM typepp/base

ENV PATH=/LLVM-typepp/llvm/build/bin/:$PATH

ENV TYPEPLUS_LOG_PATH="/tmp/" 
ENV TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}"/merged.txt"

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/LLVM-typepp/llvm/build/lib/x86_64-unknown-linux-gnu

# ensure source command works
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# RUN rm //usr/bin/c++ /usr/bin/cc && \
#     ln -s /LLVM-typepp/llvm/build/bin/clang++ /usr/bin/c++ && \
#     ln -s /LLVM-typepp/llvm/build/bin/clang /usr/bin/cc
RUN git clone https://github.com/AFLplusplus/AFLplusplus /aflpp && \
    pushd aflpp && LLVM_CONFIG=/LLVM-typepp/llvm/build/bin/llvm-config make source-only && popd

RUN mkdir -p /src && \
    git clone https://github.com/harfbuzz/harfbuzz /src/harfbuzz/ 

RUN apt-get install -y \
    meson pkg-config ragel gtk-doc-tools \
    libfreetype6-dev libglib2.0-dev libcairo2-dev


RUN cd /src/harfbuzz && source /LLVM-typepp/Type++/environment_patched.sh && \
    export CC="/LLVM-typepp/llvm/build/bin/clang" && \
    export CXX="/LLVM-typepp/llvm/build/bin/clang++" && \
    export CXXFLAGS="-stdlib=libc++ -nostdinc++ -flto -fvisibility=hidden -Wno-unused-command-line-argument -Wl,-rpath,${LLVM_FOLDER}/build/lib -L${LLVM_FOLDER}/build/lib -I${LLVM_FOLDER}/build/include/c++/v1 -I${LLVM_FOLDER}/build/include/x86_64-unknown-linux-gnu/c++/v1/ -fsanitize=typeplus -mllvm -create-derived-cast-type-list -mllvm -create-unrelated-cast-type-list" && \
    mkdir -p /src/harfbuzz/build && \
    meson --default-library=static --wrap-mode=nodownload -Dexperimental_api=true /src/harfbuzz/build && \
    ninja -C build/ test/fuzzing/hb-shape-fuzzer && \
    rm -r /src/harfbuzz/build && mkdir -p /src/harfbuzz/build

RUN cd /src/harfbuzz && source /LLVM-typepp/Type++/environment_patched.sh && \
    python3 /LLVM-typepp/Type++/script/merge_typecasting_related_type.py ${TYPEPLUS_LOG_PATH} &> ${TARGET_TYPE_LIST_PATH} && \
    export CC="/aflpp/afl-clang-lto" && \
    export CXX="/aflpp/afl-clang-lto++" && \
    export CXXFLAGS="-stdlib=libc++ -nostdinc++ -Wno-unused-command-line-argument -Wl,-rpath,${LLVM_FOLDER}/build/lib -L${LLVM_FOLDER}/build/lib -I${LLVM_FOLDER}/build/include/c++/v1 -I${LLVM_FOLDER}/build/include/x86_64-unknown-linux-gnu/c++/v1/ -fvisibility=hidden -fsanitize=typeplus -mllvm -apply-vtable-standard -mllvm -cast-obj-opt -mllvm -check-base-to-derived-casting -mllvm -check-unrelated-casting -mllvm -poly-classes " && \
    meson --default-library=static --wrap-mode=nodownload -Dexperimental_api=true /src/harfbuzz/build && \
    ninja -C build/ test/fuzzing/hb-shape-fuzzer

RUN set -eux; \
    cd /src/harfbuzz && \
    mkdir -p all-fonts && \
    for d in \
        test/shape/data/in-house/fonts \
        test/shape/data/aots/fonts \
        test/shape/data/text-rendering-tests/fonts \
        test/api/fonts \
        test/fuzzing/fonts \
        perf/fonts \
    ; do \
        cp "$d"/* all-fonts/ || true; \
    done

RUN mkdir -p /fuzz/ && \
    cp -r /src/harfbuzz/all-fonts /fuzz/corpus && \
    cp /src/harfbuzz/build/test/fuzzing/hb-shape-fuzzer /fuzz/ && \
    echo "#!/bin/bash" > /fuzz/run.sh  && \
    echo "AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 AFL_SKIP_CPUFREQ=1 AFL_NO_AFFINITY=1 \\" >> /fuzz/run.sh  && \
    echo "  /aflpp/afl-fuzz -i /fuzz/corpus/ -o /fuzz/out/ -m none -t 1000+ \\" >> /fuzz/run.sh  && \
    echo "  -- /fuzz/hb-shape-fuzzer @@" >> /fuzz/run.sh && \
    chmod +x /fuzz/run.sh 

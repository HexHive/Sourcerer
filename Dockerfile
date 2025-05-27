# syntax = docker/dockerfile:experimental
FROM ubuntu:24.04 AS reference_user
RUN userdel -r ubuntu
ARG USERNAME=nbadoux
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG CHROMIUM=Type++/chromium/

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s/bin/zsh $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown -R $USERNAME /home/$USERNAME


USER $USERNAME
ENV HOME=/home/$USERNAME
WORKDIR ${HOME}

FROM reference_user AS spec_cpu
RUN sudo apt-get -q update && \
	DEBIAN_FRONTEND="noninteractive" sudo apt-get install -qq -y p7zip-full p7zip-rar 
COPY --chown=${USERNAME}:${USERNAME} cpu2006-1.2.iso cpu2017-1.1.8.iso /mnt/
RUN sudo 7z x -o/mnt/cpu2006 /mnt/cpu2006-1.2.iso && sudo 7z x -o/mnt/cpu2017 /mnt/cpu2017-1.1.8.iso && sudo chown -R ${USERNAME} /mnt && sudo chmod +x -R /mnt/* && cd /mnt/cpu2006 && ./install.sh -f -d ${HOME}/cpu2006 && cd /mnt/cpu2017 && ./install.sh -f -d ${HOME}/cpu2017 && sudo rm -drf /mnt

# Build LLVM
FROM reference_user AS reference

RUN --mount=type=cache,target=/var/cache/apt sudo apt-get -q update && \
	DEBIAN_FRONTEND="noninteractive" sudo -E apt-get install -qq -y git \
	clang lld wget tar build-essential make ninja-build cmake gfortran \
	vim ccache zsh zip zsh-syntax-highlighting gdb bat \
	python3-dotenv python3 make  bison texinfo \
	libxshmfence-dev devscripts tmux libmpc-dev autojump htop python3-pip  software-properties-common python3-pytest python3-pytest-xdist

# Make zsh history persitstent
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history" \
    && sudo mkdir /commandhistory \
    && sudo touch /commandhistory/.zsh_history \
    && sudo chown -R $USERNAME /commandhistory \
    && echo "$SNIPPET" >> "/home/$USERNAME/.zshrc"

# Default powerline10k theme, no plugins installed, and GDB GEF
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh)" && \
    echo "source /usr/share/autojump/autojump.sh" >> .zshrc && \
    sed -i "s/plugins=()/plugins=(git)/" .zshrc && \
    bash -c "$(curl -fsSL https://gef.blah.cat/sh)" 

ENV PATH="${PATH}:/home/${USERNAME}/.local/bin:/usr/local/bin"
ENV LLVM_FOLDER=${HOME}/LLVM-typepp
ENV TYPESAFETY_VTABLE=${LLVM_FOLDER}/Type++
ENV ENVIRONMENT_FOLDER=${HOME}

COPY --chown=${USERNAME}:${USERNAME} Type++/requirements.txt .
RUN mkdir -p ${LLVM_FOLDER} /tmp/ccache && \
    pip3 install --break-system-packages -r requirements.txt

WORKDIR ${LLVM_FOLDER}
RUN git clone -b release/19.x --single-branch --depth 1 https://github.com/llvm/llvm-project.git ${LLVM_FOLDER} && rm -drf ${LLVM_FOLDER}/.git 
COPY --chown=nbadoux:nbadoux Type++/environment_template.sh ${HOME}/environment_patched.sh
COPY --chown=${USERNAME}:${USERNAME} Type++/script/wss_install.sh ${TYPESAFETY_VTABLE}/script/wss_install.sh
RUN ${TYPESAFETY_VTABLE}/script/wss_install.sh
COPY --chown=nbadoux:nbadoux Type++/*.patch fetch_repos.sh ${LLVM_FOLDER}
RUN  ${LLVM_FOLDER}/fetch_repos.sh
ENV CCACHE_DIR=/dockerccache
RUN --mount=type=cache,target=/dockerccache  sudo chown ${USERNAME}:${USERNAME} ${CCACHE_DIR}
COPY --chown=nbadoux:nbadoux build.sh ${LLVM_FOLDER}
RUN  --mount=type=cache,target=/dockerccache ${LLVM_FOLDER}/build.sh 
COPY --chown=nbadoux:nbadoux cxx*.sh build*.sh ${LLVM_FOLDER}

CMD zsh


# SPEC CPU + REFERENCE
FROM reference AS cpu_baseline
COPY --chown=${USERNAME}:${USERNAME} --from=spec_cpu ${HOME}/cpu2006 ${HOME}/cpu2006
COPY --chown=${USERNAME}:${USERNAME} --from=spec_cpu ${HOME}/cpu2017 ${HOME}/cpu2017
COPY --chown=${USERNAME}:${USERNAME} Type++/script/*.py ${TYPESAFETY_VTABLE}/script/
COPY --chown=${USERNAME}:${USERNAME} Type++/spec_cpu ${TYPESAFETY_VTABLE}/spec_cpu
WORKDIR ${TYPESAFETY_VTABLE}/spec_cpu/patch
RUN ./official_patches.sh
WORKDIR ${TYPESAFETY_VTABLE}/spec_cpu
CMD BASELINE=1 ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC CPU + REFERENCE + MEMORY
FROM cpu_baseline AS memory_baseline
CMD BASELINE=1 MEMORY=-m ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC_CPU + CFI
FROM cpu_baseline AS cpu_cfi
CMD CFI=1 ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC CPU + CFI + MEMORY
FROM cpu_cfi AS memory_cfi
CMD CFI=1 MEMORY=-m ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh


# SOURCERER
FROM reference AS typepp
ENV SOURCERER=TRUE
COPY --chown=${USERNAME}:${USERNAME} Type++/script/*.py ${TYPESAFETY_VTABLE}/script/
COPY --chown=${USERNAME}:${USERNAME} libunwind ${LLVM_FOLDER}/libunwind
COPY --chown=${USERNAME}:${USERNAME} libcxxabi ${LLVM_FOLDER}/libcxxabi
COPY --chown=${USERNAME}:${USERNAME} compiler-rt ${LLVM_FOLDER}/compiler-rt
COPY --chown=${USERNAME}:${USERNAME} clang ${LLVM_FOLDER}/clang
COPY --chown=${USERNAME}:${USERNAME} llvm ${LLVM_FOLDER}/llvm
COPY --chown=${USERNAME}:${USERNAME} libcxx ${LLVM_FOLDER}/libcxx
COPY --chown=${USERNAME}:${USERNAME} cxx*.sh lib*.sh build.sh build_collect.sh ${LLVM_FOLDER}/
RUN --mount=type=cache,target=/dockerccache/ sudo chown ${USERNAME}:${USERNAME} /dockerccache
RUN rm -drf /home/nbadoux/build/
RUN sudo chown -R ${USERNAME} /tmp 
RUN mkdir /tmp/hello
ENV TYPEPLUS_LOG_PATH=/tmp/hello
ENV TARGET_TYPE_LIST_PATH=/tmp/hello/merged.txt
RUN --mount=type=cache,target=/dockerccache/ ./build.sh
COPY --chown=${USERNAME}:${USERNAME} build_instrument.sh ${LLVM_FOLDER}/
CMD zsh
ENV SOURCERER=

FROM typepp AS test_typepp
CMD zsh

FROM typepp AS example_typepp
COPY --chown=${USERNAME}:${USERNAME} Type++/example ${TYPESAFETY_VTABLE}/example
WORKDIR ${TYPESAFETY_VTABLE}/example
CMD zsh

FROM typepp AS microbenchmark
COPY --chown=${USERNAME}:${USERNAME} Type++/metadata-eval ${TYPESAFETY_VTABLE}/metadata-eval
WORKDIR ${TYPESAFETY_VTABLE}/metadata-eval/hextype
RUN make clean && make -j 8
CMD ./benchmark


# SPEC CPU + SOURCERER
FROM typepp AS cpu_typepp_unpatch
COPY --chown=${USERNAME}:${USERNAME} --from=spec_cpu ${HOME}/cpu2006 ${HOME}/cpu2006
COPY --chown=${USERNAME}:${USERNAME} --from=spec_cpu ${HOME}/cpu2017 ${HOME}/cpu2017
COPY --chown=${USERNAME}:${USERNAME} Type++/script/*.py ${TYPESAFETY_VTABLE}/script/
COPY --chown=${USERNAME}:${USERNAME} Type++/spec_cpu ${TYPESAFETY_VTABLE}/spec_cpu
WORKDIR ${TYPESAFETY_VTABLE}/spec_cpu/patch

# SPEC CPU + SOURCERER + PATCH
FROM cpu_typepp_unpatch AS cpu_sourcerer
RUN ./apply_patches.sh
COPY --chown=${USERNAME}:${USERNAME} libc++13.patch ${TYPESAFETY_VTABLE}/..
WORKDIR ${TYPESAFETY_VTABLE}/spec_cpu
ENV LD_LIBRARY_PATH=${LLVM_FOLDER}/libunwind-build-for-program/lib
CMD SOURCERER=1 ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC CPU + SOURCERER + MEMORY
FROM cpu_sourcerer AS memory_sourcerer
CMD SOURCERER=1 MEMORY=-m ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC CPU + SOURCERER + STATS
FROM cpu_sourcerer AS cpu_sourcerer_stats
CMD SOURCERER=1 STATS="-stats" ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC CPU + SOURCERER + NO CHECKING
FROM cpu_sourcerer AS cpu_sourcerer_no_check
CMD SOURCERER=1 CHECK="--no-check" ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC CPU + SOURCERER + NO CHECKING + NO INSERTER
FROM cpu_sourcerer AS cpu_sourcerer_abi_only
CMD SOURCERER=1 CHECK="--no-check" INSERTOR="--no-insertor" ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# SPEC CPU + SOURCERER + ANALYSIS
FROM cpu_typepp_unpatch AS cpu_typepp_analysis
RUN ./official_patches.sh
WORKDIR ${LLVM_FOLDER}/
RUN --mount=type=cache,target=/dockerccache/ ./build_analysis.sh
WORKDIR ${TYPESAFETY_VTABLE}/spec_cpu
RUN --mount=type=cache,target=/var/cache/apt sudo apt-get -q update && \
	DEBIAN_FRONTEND="noninteractive" sudo -E apt-get install -qq -y cloc
CMD ANALYSIS=1 ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh

# CFI + stats
FROM typepp AS cfi_stats
ENV CFI=TRUE
COPY --chown=${USERNAME}:${USERNAME} Type++/script/*.py ${TYPESAFETY_VTABLE}/script/
ENV CFI=
CMD zsh


# SPEC CPU + CFI + STATS
FROM cfi_stats AS cpu_cfi_stats
COPY --chown=${USERNAME}:${USERNAME} --from=spec_cpu ${HOME}/cpu2006 ${HOME}/cpu2006
COPY --chown=${USERNAME}:${USERNAME} --from=spec_cpu ${HOME}/cpu2017 ${HOME}/cpu2017
COPY --chown=${USERNAME}:${USERNAME} Type++/script/*.py ${TYPESAFETY_VTABLE}/script/
COPY --chown=${USERNAME}:${USERNAME} Type++/spec_cpu ${TYPESAFETY_VTABLE}/spec_cpu
WORKDIR ${TYPESAFETY_VTABLE}/spec_cpu/patch
RUN ./official_patches.sh
WORKDIR ${TYPESAFETY_VTABLE}/spec_cpu
ENV LD_LIBRARY_PATH=~/LLVM-typepp/libunwind-build/lib
CMD CFI=1 STATS="-stats" ${TYPESAFETY_VTABLE}/spec_cpu/run_spec_in_docker.sh


# CHROMIUM + BASELINE
FROM typepp AS chromium_normal
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && sudo ./llvm.sh 19 all
RUN sudo apt-get -q update && \
	DEBIAN_FRONTEND="noninteractive" sudo apt-get install -qq -y \
    libnss3-dev pkg-config git libcups2-dev libopenjp2-7-dev liblcms2-dev mesa-common-dev  libgl1-mesa-dev libgbm-dev build-essential \
    libgtk-3-dev librust-pangocairo-dev libdbus-glib-1-dev libgirepository1.0-dev libatk1.0-dev libpulse-dev libxkbcommon-dev libdrm-dev \
    libpci-dev gperf  libjsoncpp1 libjsoncpp-dev libasound2-dev libkrb5-dev
RUN git clone  https://github.com/jordansissel/xdotool.git && cd xdotool && git checkout edbbb7a8f664ceacbb2cffbe8ee4f5a26b5addc8 && sudo make install && cd .. && rm -drf xdotool
RUN sudo ln -s /usr/bin/lld-19 /usr/bin/lld && sudo ln -s /usr/bin/lld-19 /usr/bin/ld.lld
COPY --chown=${USERNAME}:${USERNAME} Type++/chromium/chromium-baseline /home/nbadoux/chromium/
RUN /home/${USERNAME}/chromium/build/install-build-deps.sh
COPY --chown=${USERNAME}:${USERNAME} ${CHROMIUM}/gclient_cfg ${TYPESAFETY_VTABLE}/chromium/gclient_cfg
COPY --chown=${USERNAME}:${USERNAME} ${CHROMIUM}/get_deps.sh ${TYPESAFETY_VTABLE}/chromium/get_deps.sh
WORKDIR ${TYPESAFETY_VTABLE}/chromium
RUN ./get_deps.sh
RUN sudo mkdir /dockerccache && sudo chown nbadoux:nbadoux /dockerccache 
ENV VERSION=ref

FROM chromium_normal AS chromium_baseline
CMD ./build_chromium.sh ref && ./eval/eval.sh ref

FROM chromium_normal AS chromium_cfi
CMD ./build_chromium.sh cfi && ./eval/eval.sh cfi

# CHROMIUM + SOURCERER
FROM typepp AS chromium_typepp_start
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && sudo ./llvm.sh 19 all
RUN sudo apt-get -q update && \
	DEBIAN_FRONTEND="noninteractive" sudo apt-get install -qq -y \
    libnss3-dev pkg-config git libcups2-dev libopenjp2-7-dev liblcms2-dev mesa-common-dev  libgl1-mesa-dev libgbm-dev build-essential \
    libgtk-3-dev librust-pangocairo-dev libdbus-glib-1-dev libgirepository1.0-dev libatk1.0-dev libpulse-dev libxkbcommon-dev libdrm-dev \
    libpci-dev gperf  libjsoncpp1 libjsoncpp-dev libasound2-dev libkrb5-dev
RUN git clone  https://github.com/jordansissel/xdotool.git && cd xdotool && git checkout edbbb7a8f664ceacbb2cffbe8ee4f5a26b5addc8 && sudo make install && cd .. && rm -drf xdotool
RUN sudo ln -s /usr/bin/lld-19 /usr/bin/lld && sudo ln -s /usr/bin/lld-19 /usr/bin/ld.lld

FROM chromium_typepp_start AS chromium_typepp_normal
COPY --chown=${USERNAME}:${USERNAME} Type++/chromium/chromium-typepp /home/nbadoux/chromium/
RUN sudo /home/${USERNAME}/chromium/build/install-build-deps.sh
COPY --chown=${USERNAME}:${USERNAME} ${CHROMIUM}/gclient_cfg ${TYPESAFETY_VTABLE}/chromium/gclient_cfg
COPY --chown=${USERNAME}:${USERNAME} ${CHROMIUM}/get_deps.sh ${TYPESAFETY_VTABLE}/chromium/get_deps.sh
WORKDIR ${TYPESAFETY_VTABLE}/chromium
RUN ./get_deps.sh
RUN sudo mkdir /dockerccache && sudo chown nbadoux:nbadoux /dockerccache 
ENV VERSION=typepp

FROM chromium_typepp_normal AS chromium_typepp
CMD ./build_chromium.sh typepp_checking && ./eval/eval.sh typepp_checking

FROM chromium_typepp_normal AS chromium_typepp_profiling
CMD ./build_chromium.sh typepp_checking_profiling && ./eval/eval.sh typepp_checking_profiling

# CHROMIUM + SOURCERER + CFI
FROM chromium_typepp_start AS chromium_cfi_stats
COPY --chown=${USERNAME}:${USERNAME} Type++/chromium/chromium-baseline /home/nbadoux/chromium/
RUN sudo /home/${USERNAME}/chromium/build/install-build-deps.sh
COPY --chown=${USERNAME}:${USERNAME} ${CHROMIUM}/gclient_cfg ${TYPESAFETY_VTABLE}/chromium/gclient_cfg
COPY --chown=${USERNAME}:${USERNAME} ${CHROMIUM}/get_deps.sh ${TYPESAFETY_VTABLE}/chromium/get_deps.sh
WORKDIR ${TYPESAFETY_VTABLE}/chromium
RUN ./get_deps.sh
RUN sudo mkdir /dockerccache && sudo chown nbadoux:nbadoux /dockerccache 
CMD ./build_chromium.sh cfi_stats && ./eval/eval.sh cfi_stats


# V8 + BASELINE
FROM typepp AS v8_baseline
WORKDIR ${HOME}
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH=${HOME}/depot_tools:$PATH
RUN gclient
RUN mkdir v8
WORKDIR ${HOME}/v8
RUN fetch v8 
RUN gclient sync
RUN ${HOME}/v8/v8/build/install-build-deps.sh
COPY --chown=${USERNAME}:${USERNAME} Type++/v8/ ${TYPESAFETY_VTABLE}/v8/
CMD zsh

FROM typepp AS opencv_base

RUN sudo apt-get install -y \
    cmake g++ wget unzip python3-numpy curl zsh gdb

ENV HOME=/home/${USERNAME}
ENV PATH=${HOME}/LLVM-typepp/llvm/build/bin/:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/LLVM-typepp/llvm/build/lib/x86_64-unknown-linux-gnu
ENV AFLPP_DIR=${HOME}/aflpp
ENV SOURCERER_DIR=${HOME}/LLVM-typepp
ENV LLVM_BUILD_FOLDER=${SOURCERER_DIR}/../build
ENV TYPEPLUS_LOG_PATH="/tmp/opencv"
ENV TARGET_TYPE_LIST_PATH=${TYPEPLUS_LOG_PATH}"/merged.txt"
ENV LIBC_INSTALL_DIR=${TYPEPLUS_LOG_PATH}/libc
#    SOURCERER=${HOME}LLVM-tyepp
#    LLVM_BUILD_FOLDER=${HOME}/build

RUN git clone https://github.com/AFLplusplus/AFLplusplus ${AFLPP_DIR}
RUN sudo rm /usr/bin/c++ /usr/bin/cc && \
    sudo ln -s ${LLVM_BUILD_FOLDER}/bin/clang++ /usr/bin/c++ && \
    sudo ln -s ${LLVM_BUILD_FOLDER}/bin/clang /usr/bin/cc
RUN --mount=type=cache,target=/dockerccache cd ${AFLPP_DIR} && LLVM_CONFIG=${LLVM_BUILD_FOLDER}/bin/llvm-config make source-only -j

ENV OPENCV_DIR=${HOME}/opencv 
ENV SOURCERER_OPENCV=${SOURCERER_DIR}/Type++/opencv/
ENV OPENCV_INSTALL_DIR=${HOME}/opencv-install
RUN git clone https://github.com/opencv/opencv  ${OPENCV_DIR}
COPY --chown=${USERNAME}:${USERNAME} Type++/opencv/build_opencv.sh ${SOURCERER_OPENCV}/build_opencv.sh
COPY --chown=${USERNAME}:${USERNAME} libcxx/include/__memory/shared_ptr.h ${SOURCERER_DIR}/libcxx/include/__memory/shared_ptr.h
RUN sudo mkdir -p ${TYPEPLUS_LOG_PATH} && sudo chown ${USERNAME}:${USERNAME} ${TYPEPLUS_LOG_PATH} -R


FROM opencv_base AS opencv_normal
RUN ${SOURCERER_OPENCV}/build_opencv.sh

FROM opencv_base AS opencv_asan
RUN ASAN=1 ${SOURCERER_OPENCV}/build_opencv.sh

FROM opencv_base AS opencv_collect
RUN COLLECT=1 ${SOURCERER_OPENCV}/build_opencv.sh

# Bypass class collection
FROM opencv_base AS opencv_instrument
COPY --chown=${USERNAME}:${USERNAME} Type++/opencv/merged_works.txt /tmp/opencv/merged.txt
COPY --chown=${USERNAME}:${USERNAME} Type++/opencv/opencv.patch ${OPENCV_DIR}
RUN patch -p1 -d ${OPENCV_DIR} < ${OPENCV_DIR}/opencv.patch
RUN INSTRUMENT=1 ${SOURCERER_OPENCV}/build_opencv.sh
    
FROM opencv_collect AS opencv_complete
RUN INSTRUMENT=1 ${SOURCERER_OPENCV}/build_opencv.sh


FROM opencv_instrument AS opencv_fuzzing
ENV OSS_FUZZ_DIR=${HOME}/oss-fuzz
ENV CC="${AFLPP_DIR}/afl-clang-lto"
ENV CXX="${AFLPP_DIR}/afl-clang-lto++"
ENV LIB_FUZZING_ENGINE="-fsanitize=fuzzer"
RUN git clone https://github.com/google/oss-fuzz.git  ${OSS_FUZZ_DIR}
WORKDIR ${OSS_FUZZ_DIR}/projects/opencv
ENV LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib
COPY --chown=${USERNAME}:${USERNAME} Type++/opencv/build_and_run_fuzzer.sh .
ARG FUZZER=imread_fuzzer
ARG OUT=${HOME}/fuzzer-out
CMD env SOURCERER=1 ./build_and_run_fuzzer.sh

FROM opencv_asan AS opencv_asan_fuzzing
ENV OSS_FUZZ_DIR=${HOME}/oss-fuzz
ENV CC="${AFLPP_DIR}/afl-clang-lto"
ENV CXX="${AFLPP_DIR}/afl-clang-lto++"
ENV LIB_FUZZING_ENGINE="-fsanitize=fuzzer"
RUN git clone https://github.com/google/oss-fuzz.git  ${OSS_FUZZ_DIR}
WORKDIR ${OSS_FUZZ_DIR}/projects/opencv
ENV LIBC_INSTALL_DIR=${HOME}/normal_libs/
ENV LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib:${LIBC_INSTALL_DIR}/lib/x86_64-unknown-linux-gnu
COPY --chown=${USERNAME}:${USERNAME} Type++/opencv/build_and_run_fuzzer.sh .
ARG FUZZER=imread_fuzzer
ARG OUT=${HOME}/fuzzer-out
CMD env ASAN=1 ./build_and_run_fuzzer.sh


FROM opencv_base AS opencv_sancov
RUN SANCOV=1 ${SOURCERER_OPENCV}/build_opencv.sh

FROM opencv_sancov AS opencv_sancov_fuzzing
ENV OSS_FUZZ_DIR=${HOME}/oss-fuzz
ENV CC="${AFLPP_DIR}/afl-clang-lto"
ENV CXX="${AFLPP_DIR}/afl-clang-lto++"
ENV LIB_FUZZING_ENGINE="-fsanitize=fuzzer"
RUN git clone https://github.com/google/oss-fuzz.git  ${OSS_FUZZ_DIR}
WORKDIR ${OSS_FUZZ_DIR}/projects/opencv
ENV LIBC_INSTALL_DIR=${HOME}/normal_libs/
ENV LD_LIBRARY_PATH=${LIBC_INSTALL_DIR}/lib:${LIBC_INSTALL_DIR}/lib/x86_64-unknown-linux-gnu
COPY --chown=${USERNAME}:${USERNAME} Type++/opencv/build_and_run_fuzzer.sh .
COPY --chown=${USERNAME}:${USERNAME} Type++/opencv/compute_coverage.sh .
ARG FUZZER=imread_fuzzer
ARG OUT=${HOME}/fuzzer-out
CMD env ./compute_coverage.sh

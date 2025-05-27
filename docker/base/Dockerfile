FROM ubuntu:24.04

# docker build -t typepp/base -f docker/base/Dockerfile .
COPY . /LLVM-typepp

ENV ENVIRONMENT_FOLDER=/LLVM-typepp/Type++

RUN apt update && \
    apt-get install -qq -y git clang \
    wget tar build-essential make ninja-build cmake \
    vim ccache zip python3-dotenv make  python3 \
    texinfo bison p7zip-full p7zip-rar \
    devscripts libmpc-dev python3-pip ccache sudo

RUN cd $ENVIRONMENT_FOLDER && \
    pip3 install --break-system-packages -r requirements.txt && \
    mv environment_h.sh environment_patched.sh

RUN mkdir -p /tmp/hello

ENV TYPEPLUS_LOG_PATH="/tmp/hello"
# # more cache in case some step failed
ENV CCACHE_DIR=/dockerccache2
RUN mkdir -p ${CCACHE_DIR}
RUN --mount=type=cache,target=/dockerccache2 cd /LLVM-typepp && chmod +x *.sh && \
    ./fetch_repos.sh && ./build.sh
